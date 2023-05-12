import pymongo
from document import Document
from sentence import Sentence

class MDB():
    """
    The class that is used to add the multimodal documents to a MongoDB database.

    :param str db_name: Name of the database

    """
    def __init__(self, db_name: str):
        self.client = pymongo.MongoClient('mongodb://localhost:27017/')
        self.db = self.client[db_name]
        self.books_col = self.db['books']
        self.focusSents_col = self.db['focusSents']

    def add_document(self, document: Document):
        """
        Adds a document to a database.

        :param Document document: A document that is added to a database
        """
        book = {'id' : '', 'title' : '', 'data' : []}
        book['id'] = document.get_id()
        book['title'] = document.get_title()
        sentences = document.get_sentences()
        for sent in sentences:
            sent_id = sent.get_id()
            sentenceDict = {}
            sentenceDict['id'] = sent_id
            sentenceDict['sentence'] = sent.get_raw_form()
            sent_is_multimodal = sent.get_is_multimodal()
            sentenceDict['isMultiModal'] = sent_is_multimodal
            if sent_is_multimodal:
                multimodal_focus_word_dict = sent.get_multimodal_focus_word_to_highlighted_img()
                sentenceDict['focusWords'] = list(multimodal_focus_word_dict.keys())
                if not self.is_multimodal_sentence_duplicate(sent):
                    focusSent = {'id' : '', 'mainImg' : '', 'focusImgs' : []}
                    focusSent['id'] = sent_id
                    focusSent['mainImg'] = sent.get_path_to_main_img()
                    focusSent['focusImgs'] = multimodal_focus_word_dict
                    self.focusSents_col.insert_one(focusSent)
            book['data'].append(sentenceDict)
        self.books_col.insert_one(book)

    def is_document_duplicate(self, document: Document) -> bool:
        """
        Returns if the database (the books collection) already contains a row with the same id (SHA-512 value) as the input document.

        :param Document document: A document that is checked if it is a duplicate
        :return: Boolean that represents if the document is a duplicate
        :rtype: bool
        """

        return len(list(self.books_col.find({"id" : document.get_id()}, {"id" : 1}))) > 0

    def is_multimodal_sentence_duplicate(self, sentence: Sentence) -> bool:
        """
        Returns if the database (the focusSents collection) already contains a row with the same id (SHA-512 value) as the multimodal input sentence.

        :param Sentence sentence: A multimodal sentence that is checked if it is a duplicate
        :return: Boolean that represents if the multimodal sentence is a duplicate
        :rtype: bool
        """

        return len(list(self.focusSents_col.find({"id" : sentence.get_id()}, {"id" : 1}))) > 0
