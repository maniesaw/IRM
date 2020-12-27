Project 2: Registration of different MRI modalities
=========================

Introduction
------------
Image registration consists in aligning two images that are initially shifted. It is one of the two
major issues in the field of image processing, with segmentation.
The mapping is done by searching for geometric transformations (translations, rotation, etc)
to move from one image to another. One of the images is considered as reference, it is the fixed
image. We apply to the other, the movinf image, a succession of geometric transformations. At
each transformation, the alignment between the fixed and mobile images is calculated according
to a pixel-to-pixel comparison criterion previously defined. We then preserve the  transformation
which allowed the best alignment: the moving image, once transformed, is called the registrated
image.

Pre-processing
--------------
1) Sometimes, the two images do not have the same **size** -> Reducing the size of the largest image to the size of the smallest. (`rescaleIm.m`)

2) We want to keep only the **brain** on the image. We start by tresholding the image and fetch the biggest blob that is supposed to be the brain. Then we create a **"mask"** and apply this mask in the original image to keep only pixels of the brain. (`filter_IRM.m`)

All pre-processing objectives are carried out thanks to the file `preprocessing.m` which call `rescaleIm.m` and `filter_IRM.m` files.

Rigid registration
------------------

1) First, we grayscale the images: The range of the cleaned images is **not between 0 and 256** so we have to **rescale** them
2) Then, we find the barycenters of the two image to calculate the initial **translations** (a **tx** translation on the x axis and a **ty** translation on the y axis)
3) Then, we propose to the user to choose the lower/upper bounds and steps for the applied transformations. 