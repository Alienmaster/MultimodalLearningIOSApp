import clip
import glob
import logging
import numpy as np
import pickle
import time
import torch
from os import path
from PIL import Image
from heapq import nlargest
from tqdm import tqdm

class ImageRetrieval():
    """
    This class is responsible for retreiving appropriate images for sentences and their focus words.

    :param str path_to_images: path to the directory where the images are
    :param str path_to_cached_image_features: file that is saved after the first run and contains the image features which are used by CLIP to calculate the similarity between images and texts
    :param int num_of_best_candidate_imgs: integer value which represents how many 'good' images must be found for a sentence to further process it.
    :param float candidate_imgs_threshold: threshold for the similarity value calculated by CLIP that defines if an image is 'good' enough for 'representing' a sentence
    :param float focus_word_representation_threshold: threshold for the similarity value calculated by CLIP that defines if an image is 'good' enough for 'representing' a focus word
    """

    def __init__(self, path_to_images: str, path_to_cached_image_features: str,
            num_of_best_candidate_imgs: int, candidate_imgs_threshold: float,
            focus_word_representation_threshold: float):
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.model, self.preprocess = clip.load("ViT-B/32", device=self.device)
        
        self.batch_size = 1000
        self.path_to_images = path_to_images
        self.path_to_cached_image_features = path_to_cached_image_features
        self.image_names = [path.basename(image_path) for image_path in
                sorted(glob.glob(self.path_to_images + "*.jpg"))]
        self.image_features = self.initImageFeatures()
        
        self.num_of_best_candidate_imgs = num_of_best_candidate_imgs
        self.candidate_imgs_threshold = candidate_imgs_threshold
        self.focus_word_representation_threshold = focus_word_representation_threshold
    
    def initImageFeatures(self):
        """
        Loads and returns the cached image features if a file was specified containing them, otherwise calculates and saves them first.

        :return: The image features which are created by CLIP in the preprocessing and encoding step
        """
        
        with torch.no_grad():
            try:
                # Load image features
                with open(self.path_to_cached_image_features, "rb") as f:
                    image_features = pickle.load(f)
            except FileNotFoundError:
                # Save image features
                image_features_batches = []
                logging.basicConfig(format="%(levelname)s:%(message)s", level=logging.INFO)
                logging.info(f"Caching image features to {self.path_to_cached_image_features} (might take a while)")
                time.sleep(3)
                for i in tqdm(range(0, len(self.image_names), self.batch_size)):
                    preprocessed_images = [self.preprocess(Image.open(self.path_to_images + image_name)) for image_name in self.image_names[i:i+self.batch_size]]
                    image_input = torch.tensor(np.stack(preprocessed_images))
                    image_features_batches.append(self.model.encode_image(image_input))
                image_features = torch.vstack(image_features_batches)
                with open(self.path_to_cached_image_features, "wb") as f:
                    pickle.dump(image_features, f)
            return image_features
    
    def get_similarity_for_sentences_and_img_features(self, sentences_raw_form, image_features):
        """
        Calculates the similarity between sentences and image features.
        
        :param sentences_raw_form: List of sentences which are represented as strings
        :param image_features: The image features as Torch Tensor
        :return: 2d list containing the similarity values between sentences and images
        """
        
        text_tokens = clip.tokenize(sentences_raw_form).to(self.device)
        with torch.no_grad():
            text_features = self.model.encode_text(text_tokens)

            image_features /= image_features.norm(dim=-1, keepdim=True)
            text_features /= text_features.norm(dim=-1, keepdim=True)
            similarity = text_features.cpu().numpy() @ image_features.cpu().numpy().T
        return similarity
    
    def is_focus_word_in_image(self, img: str, focus_word: str) -> bool:
        """
        Estimates if a focus word is represented in the image.
        
        :param str img: The file name of the image
        :param str focus_word: The focus word that is checked if it is represented in the image
        :return: Boolean representing if the focus word is represented in the image
        :rtype: bool
        """
        
        is_focus_word_in_image = False
        img_index = self.image_names.index(img)
        image_features = torch.tensor([self.image_features[img_index][:].tolist()])
        similarity = self.get_similarity_for_sentences_and_img_features([focus_word], image_features)
        if similarity[0][0] >= self.focus_word_representation_threshold:
            is_focus_word_in_image = True
        return is_focus_word_in_image
    
    def get_image_with_most_focus_words(self, imgs: [], focus_words: []) -> str:
        """
        If possible the 'best' image and the focus words it represents are returned. Otherwise an empty string and list are returned.
        
        :param imgs: List with image file names
        :param focus_words: List with focus words
        :return: Name of the 'best' image and the focus words it represents
        :rtype: (str, [])
        """
        
        max_focus_words_found = 0
        focus_words_in_image = []
        image_with_most_focus_words = ""
        for img in imgs:
            focus_word_counter = 0
            focus_words_found = []
            for focus_word in focus_words:
                if self.is_focus_word_in_image(img, focus_word):
                    focus_word_counter += 1
                    focus_words_found.append(focus_word)
            if focus_word_counter > max_focus_words_found:
                max_focus_words_found = focus_word_counter
                focus_words_in_image = focus_words_found
                image_with_most_focus_words = img

        return image_with_most_focus_words, focus_words_in_image
    
    def get_similarity_for_sentences_and_images(self, focus_sentences: []):
        """
        Calculates the similarity between focus sentences and images.
        
        :param focus_sentences: List of sentence objects which have at least one focus word
        :return: 2d similaritiy between focus sentences and images
        """
        
        focus_sentences_raw_form = [sent.get_raw_form() for sent in focus_sentences]
        similarity = self.get_similarity_for_sentences_and_img_features(focus_sentences_raw_form,
                self.image_features)
        return similarity
    
    def find_best_matching_image(self, sentences: []) -> bool:
        """
        For each sentence, tries to find the best image that represents the sentence and most
        of the focus words. Returns if an image was found for at least one of the sentences.
        
        :param [] sentences: List of sentence objects
        :return: boolean that specifies if there is at least one sentence with an image
        :rtype: bool
        """
        
        focus_sentences = [sent for sent in sentences
                if len(sent.get_focus_words()) > 0 and sent.get_is_clip_context_length_conform()]
        
        if len(focus_sentences) == 0:
            return False
        
        similarity = self.get_similarity_for_sentences_and_images(focus_sentences)
        
        document_is_multimodal = False

        for i in range(len(focus_sentences)):
            focus_sent = focus_sentences[i]
            similarity_of_focus_sent_and_imgs = similarity[i]
            
            # Saves the best candidate images depending on the similarity value between
            # focus sentence and images
            candidate_img_score_tuples = nlargest(self.num_of_best_candidate_imgs, zip(self.image_names, similarity_of_focus_sent_and_imgs), key=lambda e:e[1])
            
            # Leaves the focus sentence out if not all candidate images have a certain
            # similarity value
            if not all(img_score_tuple[1] >= self.candidate_imgs_threshold for img_score_tuple in candidate_img_score_tuples):
                continue

            candidate_imgs = [img_score_tuple[0] for img_score_tuple
                    in candidate_img_score_tuples]
            best_img, focus_words_in_best_img = self.get_image_with_most_focus_words(candidate_imgs, focus_sent.get_focus_words())

            if best_img == "":
                # Leaves the focus sentence out if there is no candidate image that represents
                # at least one focus word
                continue
            
            document_is_multimodal = True
            
            focus_sent.set_is_multimodal(True)
            focus_sent.set_path_to_main_img(self.path_to_images + best_img)
            focus_sent.set_multimodal_focus_word_to_highlighted_img({word:None
                for word in focus_words_in_best_img})
        
        return document_is_multimodal
