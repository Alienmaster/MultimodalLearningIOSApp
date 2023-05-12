import hashlib

class Sentence():
    """
    The class that represents a sentence and saves a lot of informations which are related to the sentence.

    :param str sentence: sentence as a string
    """

    def __init__(self, sentence: str):
        self.raw_form = sentence
        self.tokenized_form = []
        self.pos_tags = []
        
        self.id = hashlib.sha512(sentence.encode('utf-8')).hexdigest()
        
        self.complex_words = []
        self.concrete_words = []
        self.focus_words = []
        self.is_clip_context_length_conform = False
        
        self.is_multimodal = False
        self.path_to_main_img = ""
        self.multimodal_focus_word_to_highlighted_img = {}
    
    def get_raw_form(self) -> str:
        return self.raw_form
    
    def get_tokenized_form(self) -> []:
        return self.tokenized_form
    
    def get_pos_tags(self) -> []:
        return self.pos_tags

    def get_id(self) -> str:
        return self.id
    
    def get_complex_words(self) -> []:
        return self.complex_words
    
    def get_concrete_words(self) -> []:
        return self.concrete_words
    
    def get_focus_words(self) -> []:
        return self.focus_words
    
    def get_is_clip_context_length_conform(self) -> bool:
        return self.is_clip_context_length_conform
    
    def get_is_multimodal(self) -> bool:
        return self.is_multimodal
    
    def get_path_to_main_img(self) -> str:
        return self.path_to_main_img
    
    def get_multimodal_focus_word_to_highlighted_img(self) -> {}:
        return self.multimodal_focus_word_to_highlighted_img
    
    def set_tokenized_form(self, tokenized_sentence: []):
        self.tokenized_form = tokenized_sentence
    
    def set_pos_tags(self, pos_tags: []):
        self.pos_tags = pos_tags
    
    def set_complex_words(self, complex_words: []):
        self.complex_words = complex_words
    
    def set_concrete_words(self, concrete_words: []):
        self.concrete_words = concrete_words
    
    def set_focus_words(self, focus_words: []):
        self.focus_words = focus_words
    
    def set_is_clip_context_length_conform(self, is_clip_context_length_conform: bool):
        self.is_clip_context_length_conform = is_clip_context_length_conform
    
    def set_is_multimodal(self, is_multimodal: bool):
        self.is_multimodal = is_multimodal
    
    def set_path_to_main_img(self, path_to_main_img: str):
        self.path_to_main_img = path_to_main_img
    
    def set_multimodal_focus_word_to_highlighted_img(self, multimodal_focus_word_to_highlighted_img: {}):
        self.multimodal_focus_word_to_highlighted_img = multimodal_focus_word_to_highlighted_img
