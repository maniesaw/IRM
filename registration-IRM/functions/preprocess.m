function [Image_diff_Clean,Image_flair_Clean, mask_diff, mask_flair]=preprocess(Image_diff, Image_flair)
    [I_diff_r, I_flair_r] = rescaleIm(Image_diff, Image_flair);
    [Image_diff_Clean, mask_diff] = filter_IRM(I_diff_r, "diff");
    [Image_flair_Clean,mask_flair] = filter_IRM(I_flair_r, "flair");
end