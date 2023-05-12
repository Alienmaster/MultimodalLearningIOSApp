import numpy as np
from PIL import Image
import torch
import clip
from torchray.attribution.grad_cam import grad_cam
from miniclip.imageWrangle import heatmap, min_max_norm, torch_to_rgba
import argparse

device = "cuda" if torch.cuda.is_available() else "cpu"

def get_model():
    return clip.load("RN50", device=device, jit=False)


# OPTIONS:

# st.sidebar.header('Options')
# alpha = st.sidebar.radio("select alpha", [0.5, 0.7, 0.8], index=1)
# layer = st.sidebar.selectbox("select saliency layer", ['layer4.2.relu'], index=0)

# st.header("Saliency Map demo for CLIP")
# st.write(
#     "a quick experiment by [Hendrik Strobelt](http://hendrik.strobelt.com) ([MIT-IBM Watson AI Lab](https://mitibmwatsonailab.mit.edu/)) ")
# with st.beta_expander('1. Upload Image', expanded=True):
#     imageFile = st.file_uploader("Select a file:", type=[".jpg", ".png", ".jpeg"])

# # st.write("### (2) Enter some desriptive texts.")
# with st.beta_expander('2. Write Descriptions', expanded=True):
#     textarea = st.text_area("Descriptions seperated by semicolon", "a car; a dog; a cat")
#     prefix = st.text_input("(optional) Prefix all descriptions with: ", "an image of")



def doThings(image_raw, words, alpha=.5):
    textarea = ''
    for word in words:
        textarea += f'{word}; '
    layer = 'layer4.2.relu3'
    prefix = 'an image of'
    # textarea = 'a dog; a face; a selfie; a wooden floor; a wood; palms; beach; horizon'
    # image_raw = Image.open(imageFile)
    model, preprocess = get_model()

    # preprocess image:
    image = preprocess(image_raw).unsqueeze(0).to(device)

    # preprocess text
    prefix = prefix.strip()
    if len(prefix) > 0:
        categories = [f"{prefix} {x.strip()}" for x in textarea.split(';')]
    else:
        categories = [x.strip() for x in textarea.split(';')]
    text = clip.tokenize(categories).to(device)

    with torch.no_grad():
        image_features = model.encode_image(image)
        text_features = model.encode_text(text)
        image_features_norm = image_features.norm(dim=-1, keepdim=True)
        image_features_new = image_features / image_features_norm
        text_features_norm = text_features.norm(dim=-1, keepdim=True)
        text_features_new = text_features / text_features_norm
        logit_scale = model.logit_scale.exp()
        logits_per_image = logit_scale * image_features_new @ text_features_new.t()
        probs = logits_per_image.softmax(dim=-1).cpu().numpy().tolist()

    saliency = grad_cam(model.visual, image.type(model.dtype), image_features, saliency_layer=layer)
    hm = heatmap(image[0], saliency[0][0,].detach().type(torch.float32).cpu(), alpha=alpha)

    collect_images = []
    for i in range(len(categories)):
        # mutliply the normalized text embedding with image norm to get approx image embedding
        text_prediction = (text_features_new[[i]] * image_features_norm)
        saliency = grad_cam(model.visual, image.type(model.dtype), text_prediction, saliency_layer=layer)
        hm = heatmap(image[0], saliency[0][0,].detach().type(torch.float32).cpu(), alpha=alpha)
        collect_images.append(hm)
    logits = logits_per_image.cpu().numpy().tolist()[0]
    results = []
    for a, b in zip(collect_images, categories):
        # a.save(f'{b}.png')
        results.append([a, b])
    return results
    # st.write("### Grad Cam for text embeddings")
    # st.image(collect_images,
    #          width=256,
    #          caption=[f"{x} - {str(round(y, 3))}/{str(round(l, 2))}" for (x, y, l) in
    #                   zip(categories, probs[0], logits)])

    # st.write("### Original Image and Grad Cam for image embedding")
    # st.image([Image.fromarray((torch_to_rgba(image[0]).numpy() * 255.).astype(np.uint8)), hm],
    #          caption=["original", "image gradcam"])  # , caption="Grad Cam for original embedding")

    # st.image(imageFile)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('filename', help='Input filename')
    parser.add_argument('-a', '--alpha', help='sets the alpha value', required=False, default=.5)
    args = parser.parse_args()
    filename = args.filename
    alpha = args.alpha
    model = get_model()
    doThings(filename, alpha)