from sentence import Sentence
from os import path

# miniclip
import miniclip.miniClip as miniClip
from PIL import Image
from torchvision.transforms import Resize, CenterCrop, InterpolationMode

class Runminiclip:
    """
    The class that uses miniCLIP to highlight images. If specified the main images of the sentences can be resized to match the size of the highlighted images from miniCLIP.

    :param str path_to_highlighted_imgs: path where the highlighted images will be saved
    :param str path_to_resized_main_imgs: path where the resized version of the main images will be saved. If not specified the main images for the multimodal sentences will keep their original size.
    """
    def __init__(self, path_to_highlighted_imgs: str, path_to_resized_main_imgs: str = None):
        self.path_to_highlighted_imgs = path_to_highlighted_imgs
        self.path_to_resized_main_imgs = path_to_resized_main_imgs
        self.resize = not (path_to_resized_main_imgs == None)
        self.size = 224

    def resize_image(self, image: Image) -> Image:
        """
        Resizes and crops the center of an image.

        :param Image image: image that is resized and cropped
        :return: resized and cropped image
        :rtype: Image
        """
        resized_image = Resize(self.size, interpolation = InterpolationMode.BICUBIC).forward(image)
        return CenterCrop(self.size).forward(resized_image)

    def highlight_word_in_image(self, sentence: Sentence):
        """
        For every multimodal focus word in a sentence, the main image of the sentence will be highlighted according to the focus word and saved seperately. If specified on class instantiation the main image of the sentence will be resized to match the size of the highlighted image(s).
        
        :param Sentence sentence: A sentence object
        """
        
        path_to_main_img = sentence.get_path_to_main_img()
        main_img_name = path.basename(path_to_main_img)
        main_image = Image.open(path_to_main_img)

        multimodal_focus_word_dict = sentence.get_multimodal_focus_word_to_highlighted_img()
        
        for focus_word in multimodal_focus_word_dict.keys():
            path_to_highlighted_img = f'{self.path_to_highlighted_imgs}{path.splitext(main_img_name)[0]}_{focus_word}.png'
            multimodal_focus_word_dict[focus_word] = path_to_highlighted_img
            if not path.isfile(path_to_highlighted_img):
                highlighted_img = miniClip.doThings(main_image, [focus_word])[0][0]
                highlighted_img.save(path_to_highlighted_img)
        
        if self.resize:
            path_to_resized_main_img = f'{self.path_to_resized_main_imgs}{main_img_name}'
            sentence.set_path_to_main_img(path_to_resized_main_img)
            if not path.isfile(path_to_resized_main_img):
                resized_main_image = self.resize_image(main_image)
                resized_main_image.save(path_to_resized_main_img)

    def highlight_word_in_images(self, sentences: []):
        """
        For every multimodal focus word in a sentence, the main image of the sentence will be highlighted according to the focus word and saved seperately. If specified on class instantiation the main image of the sentence will be resized to match the size of the highlighted image(s).
        
        :param [] sentences: A list of sentences
        """
        
        for sent in sentences:
            if sent.get_is_multimodal():
                self.highlight_word_in_image(sent)
