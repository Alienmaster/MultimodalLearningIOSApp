import argparse
import glob
import random
from os import path
from document import Document
from documentTokenizer import tokenize_document
from concreteness import Concreteness
from imageRetrieval import ImageRetrieval
from sentence import Sentence
from runminiclip import Runminiclip
from mdb import MDB


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--documents",
            default="../data/documents/",
            help="Path to the directory of the documents which are processed for the multimodal dataset creation.")
    parser.add_argument("-i", "--images",
            default="../data/train2014/",
            help="Path to the directory of the main images which are used for the multimodal dataset creation.")
    parser.add_argument("-m", "--mcimages",
            default="../data/miniclip/",
            help="Path to the directory where the highlighted images from miniclip will be saved.")
    parser.add_argument("--resized_main_images",
            default=None,
            help="Path to the directory where the resized main images will be saved. If not specified the main images for the multimodal sentences will keep their original size.")
    parser.add_argument("-c", "--concreteness",
            default="../data/concreteness/concretenessValuesMscoco.json",
            help="Path to the file with concreteness values which define the depictability of words.")
    parser.add_argument("-t", "--concreteness_threshold",
            type=float,
            default=20,
            help="Threshold that defines the minimum required concreteness value. Words in the concreteness values file with a value that is lower than this threshold will be discarded.")
    parser.add_argument("-f", "--cached_image_features",
            default="../data/cache/mscoco_features.pkl",
            help="Path to cached image features file. If it doesn't exist it will be created.")
    parser.add_argument("--cwi",
            type=str,
            default="on",
            help="The status of the complex word identifier: on | off.")
    parser.add_argument("--multimodal_sents_only",
            type=str,
            default="off",
            help="Filters out sentences from the document that are not multimodal: on | off.")
    parser.add_argument("--max_docs",
            type=int,
            default=None,
            help="The maximum number of documents to save in the database. If not specified all documents will be processed.")
    parser.add_argument("--max_sents",
            type=int,
            default=None,
            help="The maximum number of sentences a document may have to be processed. If not specified all documents will be processed.")
    parser.add_argument("--rnd_seed",
            type=int,
            default=None,
            help="If specified the order of the documents to be processed will be shuffled depending on the seed")
    parser.add_argument("--candidate_imgs",
            type=int,
            default=5,
            help="The number of best candidate images which have to have the minimum required similarity value to a sentence defined by the parameter 'sent_img_similarity'.")
    parser.add_argument("--sent_img_similarity",
            type=float,
            default=0.225,
            help="The threshold that defines the minimum required similarity value between a sentence and an image.")
    parser.add_argument("--focus_word_img_similarity",
            type=float,
            default=0.25,
            help="The threshold that defines the minimum required similarity value between a focus word and a candidate image")
    parser.add_argument("--db_name",
            type=str,
            default="multimodalDB",
            help="The name of the database.")
    args = parser.parse_args()

    directory_attributes = ["documents", "images", "mcimages", "resized_main_images"]
    for a in directory_attributes:
        old_attr_value = getattr(args, a)
        if not (old_attr_value == None):
            new_attr_value = path.join(path.normpath(old_attr_value), "")
            setattr(args, a, new_attr_value)
            if not path.isdir(new_attr_value):
                raise NotADirectoryError("The parameter {0:s} was set to '{1:s}' but it is not a directory.".format(a, old_attr_value))

    if args.cwi == "on":
        from cwi import CWI
        # init cwi
        cwi = CWI()
    elif not args.cwi == "off":
        raise Exception("The status of the cwi was set to '{:s}' but only 'on' or 'off' is allowed.".format(args.cwi))

    if not (args.multimodal_sents_only == "on" or args.multimodal_sents_only == "off"):
        raise Exception("The parameter multimodal_sents_only was set to '{:s}' but only 'on' or 'off' is allowed.".format(args.multimodal_sents_only))
    
    if not (args.max_docs == None or args.max_docs > 0):
        raise Exception("The maximum number of documents was set to '{}' but only a value greater than '0' is allowed if specified.".format(args.max_docs))
    
    if not (args.max_sents == None or args.max_sents > 0):
        raise Exception("The maximum number of sentences was set to '{}' but only a value greater than '0' is allowed if specified.".format(args.max_sents))

    if not (args.candidate_imgs > 0):
        raise Exception("The number of candidate images was set to '{}' but the value has to be greater than '0'.".format(args.candidate_imgs))

    num_of_imgs = len(glob.glob(args.images + "*.jpg"))
    if not (args.candidate_imgs <= num_of_imgs):
        raise Exception("The number of candidate images was set to '{0}' but the value has to be equals or less than the total number of images '{1}'.".format(args.candidate_imgs, num_of_imgs))

    # init concreteness
    concreteness = Concreteness(args.concreteness, args.concreteness_threshold)
    
    # init image retrieval
    imageRetrieval = ImageRetrieval(args.images, args.cached_image_features,
        args.candidate_imgs, args.sent_img_similarity, args.focus_word_img_similarity)

    # init runminiclip
    runminiclip = Runminiclip(args.mcimages, path_to_resized_main_imgs = args.resized_main_images)

    # init mdb
    db = MDB(args.db_name)
    
    # load documents
    document_paths = sorted(glob.glob(args.documents + "*.txt"))
    
    if not (args.rnd_seed == None):
        random.Random(args.rnd_seed).shuffle(document_paths)
    
    documents = [Document(document_path) for document_path in document_paths]
    
    doc_counter = 0
    max_sents_on = not (args.max_sents == None)

    # building the multimodal dataset
    for document in documents:

        # tokenize document
        tokenize_document(document)

        if db.is_document_duplicate(document):
            continue
        
        document_sentences = document.get_sentences()
        
        sents_num = len(document_sentences)
        
        if ((sents_num == 0) or (max_sents_on and (sents_num > args.max_sents))):
            continue
        
        # find complex words
        if args.cwi == "on":
            cwi.find_complex_words_in_sentences(document_sentences)
        else:
            for sent in document_sentences:
                sent.set_complex_words(sent.get_tokenized_form())
        
        # find depictable words
        concreteness.find_concrete_words_in_sentences(document_sentences)
        
        # find focus words
        for sent in document_sentences:
            sent.set_focus_words(sent.get_concrete_words())
        
        # find best image for each sentence (if possible)
        document_is_multimodal = imageRetrieval.find_best_matching_image(document_sentences)
        
        if not document_is_multimodal:
            continue

        # filter out non multimodal sentences if specified
        if args.multimodal_sents_only == "on":
            multimodal_sentences = []
            for sent in document_sentences:
                if sent.get_is_multimodal():
                    multimodal_sentences.append(sent)
            document.set_sentences(multimodal_sentences)
            document_sentences = document.get_sentences()
        
        # highlight multimodal focus word in main image
        runminiclip.highlight_word_in_images(document_sentences)
        
        # add document to database
        db.add_document(document)
        
        doc_counter += 1
        if doc_counter == args.max_docs:
            break

if __name__ == "__main__":
    main()
