import hashlib

class Document():
    """
    This class is used to represent a document.

    :param str path_to_document: The path to the document
    """

    def __init__(self, path_to_document: str):
        self.id, self.title, self.content =  self.get_title_and_content(path_to_document)
        self.sentences = []
    
    def get_title_and_content(self, path_to_document: str) -> (str, str):
        """
        Return the title and the content of a document assuming the title is the first line
        in the document and next lines are the content.
        
        :param str path_to_document: The path to the document
        :return: A tuple containing the title and content of the document
        :rtype: (str, str)
        """
        
        with open(path_to_document) as file:
            document = file.read()
            document_id = hashlib.sha512(document.encode("utf-8")).hexdigest()
        
        with open(path_to_document) as file:
            title = file.readline().replace("\n", " ").strip()
            content = file.read()
        return document_id, title, content
    
    def get_id(self) -> str:
        """
        Returns the id of the document.

        :return: The SHA-512 value of the document
        :rtype: str
        """

        return self.id
    
    def get_title(self) -> str:
        return self.title
    
    def get_content(self) -> str:
        return self.content
    
    def get_sentences(self) -> []:
        return self.sentences
    
    def set_sentences(self, sentences: []):
        self.sentences = sentences
