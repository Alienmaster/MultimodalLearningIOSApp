# Multimodal Learning

The goal of this topic is to create a multimodal dataset which will be saved in a database and is accessible through a REST-API. An iOS-App is made which uses the API to display the multimodal documents. The App can be used via eyetracking.

Documents (e.g. books, wikipedia articles ...) can be processed to create a multimodal dataset. For this, the focus words of the sentences are found. A focus word is a word that is complex and depictable at the same time. Then, for the sentences with at least one focus word an image is retrieved from the image dataset. In best case, the image represents the focus word/s and the context of the sentence. The next step is to save different versions of that image in which the focus word/s is/are highlighted. A document with at least one sentence that has at least one focus word and an image will be saved in a database.

## Demovideo
A video of the app can be found in this repository

## Installation and Usage
Please have a look at the wiki for a detailed description in how to install and use the multimodal dataset builder, the api and the frontend.

## Documentation 
To learn about the basic mechanims and techniques please look into our wiki. 
The documentation for the backend and the NLP pipeline can be found in the respective folders.

The iOS app is build using apple's basic UI Framework called UIKit. Therefore we did not documentate the default mechanisms and functions, like generating basic UI elements. More over it is common in iOS development to rather use long signitures and varibale names, which describe the functions good enaugh, so less documentation is needed.
However, the interesting part of the application is how the eye tracking works, which is done using multiple service classes. We documented them since they are not trivial. They can be found in the files laying in the *Multimodal Learning App/Multimodal Learning/Tools* folder. 

## Acknowledgment
Especially the multimodal dataset builder uses the work of others. These are referenced here:

* [Idea, Pipeline and Parameters](https://www.inf.uni-hamburg.de/en/inst/ab/lt/publications/2022-wangetal-lrec.pdf)
* [Simple Wikipedia Articles](https://github.com/LGDoor/Dump-of-Simple-English-Wiki)
* [Images](http://images.cocodataset.org/zips/train2014.zip)/[Paper](http://arxiv.org/abs/1405.0312)
* [Complex Word Identifier](https://github.com/in2dblue/mastersThesis)
* [Visual Concreteness](https://arxiv.org/abs/1804.06786) and [Implementation](https://github.com/victorssilva/concreteness)
* [Image Retrieval](https://github.com/openai/CLIP)/[Paper](https://arxiv.org/abs/2103.00020)
* [Image Highlighting](https://github.com/HendrikStrobelt/miniClip)

## License

For the multimodal dataset creation, we included the [complex word identifier](https://github.com/in2dblue/mastersThesis) and [miniCLIP](https://github.com/HendrikStrobelt/miniClip) to our code. That's why we want to explicitly point out how they are licensed.

| Name                      | License       | URL                                           |
|---------------------------|---------------|-----------------------------------------------|
| Complex Word Identifier   | Unkown        | https://github.com/in2dblue/mastersThesis     |
| miniCLIP                  | Apache 2.0    | https://github.com/HendrikStrobelt/miniClip   |

The file "DEP_LICENSES.md" shows how the dependencies of the multimodal dataset builder are licensed.
