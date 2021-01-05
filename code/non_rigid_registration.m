function [Image_diff_opt] = non_rigid_registration(Image_diff_clean,Image_flair_clean)

Image_diff_clean_gray = grayscaleIm(Image_diff_clean);
Image_flair_clean_gray = grayscaleIm(Image_flair_clean);

[optimizer,metric] = imregconfig('multimodal');

moving = Image_diff_clean_gray;
fixed = Image_flair_clean_gray;

% Changing the number of iterations
optimizer.MaximumIterations = 1000;

% Affine transformation consisting of translation, rotation, scale, and shear.
Image_diff_opt = imregister(moving,fixed,'affine',optimizer,metric);

end
