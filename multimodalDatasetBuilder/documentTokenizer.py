from nltk import pos_tag
from nltk.tokenize import sent_tokenize, word_tokenize
from document import Document
from sentence import Sentence
from clip import tokenize

def tokenize_document(document: Document):
    """
    Tokenizes the content of the document by its sentences and saves them as Sentence objects.
    
    :param Document document: The document that is sentence tokenized
    """
    
    sentences = sent_tokenize(document.get_content())
    newline_removed_sentences = [sent.replace("\n", " ") for sent in sentences]
    document.set_sentences([Sentence(sent) for sent in newline_removed_sentences])
    for sent in document.get_sentences():
        sent.set_tokenized_form(word_tokenize(sent.get_raw_form()))
        sent.set_pos_tags(pos_tag(sent.get_tokenized_form()))
        try:
            tokenize(sent.get_raw_form())
            sent.set_is_clip_context_length_conform(True)
        except RuntimeError:
            pass
