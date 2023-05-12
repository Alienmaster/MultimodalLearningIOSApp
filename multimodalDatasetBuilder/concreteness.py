import json
from nltk.stem import WordNetLemmatizer
from sentence import Sentence
from duplicateWordsRemover import remove_duplicate_words

class Concreteness():
    """
    This class is responsible for finding concrete/depictable words. For that, a file containing the concreteness values of words is used.

    :param str path_to_concreteness_values_file: path to the json file containing the concreteness values
    :param float concreteness_threshold: a value to filter out the words from the concreteness file which have a value below the specified threshold
    """

    def __init__(self, path_to_concreteness_values_file: str, concreteness_threshold: float):
        self.concreteness_set = self.build_concreteness_set(path_to_concreteness_values_file,
                concreteness_threshold)
    
    def get_word_forms(self, word: str) -> []:
        """
        Build different forms a word can have and is related to.
        
        :param str word: The word of which the forms are built
        :return: A list containing the different forms the word can have
        :rtype: []
        """
        
        wnl = WordNetLemmatizer()
        word_lower = word.lower()
        word_lower_lemmatized = wnl.lemmatize(word_lower)
        return [word_lower, word_lower_lemmatized]
    
    def build_concreteness_set(self, path_to_concreteness_values_file: str, threshold_concreteness: float) -> set:
        """
        Build the set of concrete/depictable words from the file containing
        the concreteness values.
        
        :param str path_to_concreteness_values_file: path to the json file containing
                the concreteness values
        :param float threshold_concreteness: The minimum score a word from the file
                has to have to be considered in the concreteness set
        :return: Set containing depictable words
        :rtype: set
        """
        
        concreteness_dict = []
        with open(path_to_concreteness_values_file) as file:
            concreteness_dict = json.loads(file.read())
        
        filtered_concreteness = [word_concr_tuple[0] for word_concr_tuple
                in concreteness_dict if word_concr_tuple[1] >= threshold_concreteness]
        
        extended_concreteness = [word_form for word in filtered_concreteness
                for word_form in self.get_word_forms(word)]
        
        return set(extended_concreteness)
    
    def is_word_concrete(self, word: str) -> bool:
        """
        Return if a word is concrete/depictable
        
        :param str word: The word that is checked if it is concrete or not
        :return: Boolean representing if the word is concrete
        :rtype: bool
        """
        
        word_forms = self.get_word_forms(word)
        is_word_concrete = False
        for w in word_forms:
            is_word_concrete = is_word_concrete or w in self.concreteness_set
        return is_word_concrete
    
    def find_concrete_words_in_sentence(self, sentence: Sentence):
        """
        Saves the concrete words in the sentence object.
        
        :param [] sentence: A sentence object
        """
       
        nouns = set(word_posTag_tuple[0] for word_posTag_tuple in sentence.get_pos_tags()
                if word_posTag_tuple[1] == "NN" or word_posTag_tuple[1] == "NNS")
        complex_nouns = [word for word in sentence.get_complex_words() if word in nouns]
        complex_nouns_without_duplicates = remove_duplicate_words(complex_nouns)
        sentence.set_concrete_words([word for word in complex_nouns_without_duplicates
            if self.is_word_concrete(word)])
    
    def find_concrete_words_in_sentences(self, sentences: []):
        """
        Saves the concrete words in the sentence objects.
        
        :param [] sentences: An array containing sentence objects
        """
        
        for sent in sentences:
            self.find_concrete_words_in_sentence(sent)
