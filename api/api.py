import os
from cgitb import reset
from urllib import response
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from typing import Optional, Dict
from pydantic import BaseModel
import pymongo
from pprint import pprint


'''
Wiki at https://git.informatik.uni-hamburg.de/6ebrahimi/nlp-project-2022/-/wikis/content/API
'''

#Connect to the local Database
myclient = pymongo.MongoClient('mongodb://localhost:27017/')
mydb = myclient['multimodalDB']
mybooks = mydb['books']
myfocus = mydb['focusSents']
app = FastAPI()


#Basemodels describing the datastructures of Focuswords and Sentences
class FocusWord(BaseModel):
    definition: Optional[str] = None
    image: Optional[str] = None


class Sentence(BaseModel):
    sentence : str
    base: Optional[str] = None
    focuswords: Optional[Dict[str, FocusWord]] = None





@app.get("/images/")
async def getImage(img_name: str):
    """
    description: returns the image given the imagepath as parameter
    return: filetype
    """
    if os.path.exists(img_name):
        return FileResponse(img_name)
    raise HTTPException(status_code=404, detail="image not found")
        


@app.get("/books")
async def getBooks():  
    """
    description: returns all the books in the database
    return: dictionary
    """
    books = {}
    cursor = mybooks.find({})
    for document in cursor: 
        books[document['id']] =  {'wordcount': len(document['data']), 'title' : document['title']} 
    return books 




@app.get("/getSentence/", response_model=Sentence)
async def process(bookID: str = "", senNr: int = 0):
    """
    description: returns the sentence specified by the ID of the book
                and the sentence number 
    parameters:
                bookID - hashed string of the book
                senNr - number of the sentence of the book
    return: dictionary
    """
    data = None
    if mybooks.count_documents({'id': bookID}) == 0:
        raise HTTPException(status_code=404, detail="couldn't find book by ID")

    mcursor = mybooks.find({'id': bookID})
    document = mcursor[0]

    if senNr < 0 or senNr >= len(document['data']):     
        raise HTTPException(status_code=404, detail="senNr is invalid")
    data = document['data'][senNr]


    sentence = data['sentence']
    isMultiModal = data['isMultiModal']
    senID = data['id']

    mainImage = None
    flist = []

    if isMultiModal:
        focusWords = data['focusWords']
        fcursor = myfocus.find({'id': senID})[0]
        mainImage = fcursor['mainImg']
        focusDict = fcursor['focusImgs']

        for word in focusWords:
            flist.append([word, None, focusDict[word]])


    res = createData(sentence, mainImage, flist)
    return res



def createData(sentence, base, list):
    """
    description: creates dictionary with all the data needed for one sentence
    parameters:
    sentence - String (Sentence to read)
    base - String (Filepath of the image without any heatmaps)
    list - 2DArray (Array containing all the focuswords, their definitions and their path to the heatmap-image)
    return: Dictionary
    """
    data =  {}
    data["sentence"] = sentence
    data["base"] = base
    data["focuswords"] = {}
    for e in list:
        subdata =  {}
        subdata["definition"] = e[1]
        subdata["image"] = e[2]
        data["focuswords"][e[0]] = subdata
    return data
