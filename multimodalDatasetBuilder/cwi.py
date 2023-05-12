from complexWordIdentifier.complex_labeller import Complexity_labeller
from sentence import Sentence

class CWI():
    """
    This class uses the complex word identifier to find complex words.
    """

    def __init__(self):
        self.model_path = './complexWordIdentifier/ankit.model'
        self.temp_path = './complexWordIdentifier/temp_file.txt'

        self.model = Complexity_labeller(self.model_path, self.temp_path)

    def find_complex_words_in_sentence(self, sentence: Sentence):
        """
        Saves the complex words in the sentence object.
        
        :param Sentence sentence: A sentence object
        """
        
        Complexity_labeller.convert_format_token(self.model, sentence.get_tokenized_form())
        dataframe = Complexity_labeller.get_dataframe(self.model)
        word_tag_tuples = list(zip(dataframe['sentences'].values[0],dataframe['labels'].values[0]))
        complex_words = [word_tag_tuple[0] for word_tag_tuple in word_tag_tuples if word_tag_tuple[1] == 1]
        sentence.set_complex_words(complex_words)
    
    def find_complex_words_in_sentences(self, sentences: []):
        """
        Saves the complex words in the sentence objects.
        
        :param [] sentences: A list containing sentence objects
        """
        
        for sent in sentences:
            self.find_complex_words_in_sentence(sent)
