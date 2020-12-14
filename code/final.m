%%
clear;
clc;

%%

Im_diff = niftiread("../project2_registration/data/patient1/DIFFUSION.nii");
Im_flair = niftiread("../project2_registration/data/patient1/FLAIR.nii");
subplot(1, 2, 1);imshow(Im_diff(:,:,8), []);title("Image of type Diff");
subplot(1, 2, 2);imshow(Im_flair(:,:,8), []);title("Image of type Flair");

[Im1,Im2]=rescaleIm(Im_diff(:,:,8), Im_flair(:,:,8));

[Image_diff_Clean, Image_Flair_Clean, mask_diff, mask_flair]=preprocess(Im_diff(:,:,8), Im_flair(:,:,8));

subplot(2, 3, 1); imshow(Im_diff(:,:,8), []);title("Image of type Diff");
subplot(2, 3, 2);imshow(mask_diff, []);title("Mask Diff");
subplot(2, 3, 3);imshow(Image_diff_Clean, []);title("Image Diff Clean");

subplot(2, 3, 4);imshow(Im_flair(:,:,8), []);title("Image of type Flair");
subplot(2, 3, 5);imshow(mask_flair, []);title("Mask Flair");
subplot(2, 3, 6);imshow(Image_Flair_Clean, []);title("Image Flair Clean");

%%
function [Image_diff_Clean,Image_Flair_Clean, mask_diff, mask_flair]=preprocess(Image_diff, Image_flair)
    [I_diff_r, I_flair_r] = rescaleIm(Image_diff, Image_flair);
    [Image_diff_Clean, mask_diff] = filter_IRM(I_diff_r, "diff");
    [Image_Flair_Clean, mask_flair] = filter_IRM(I_flair_r, "flair");
end

function [image_masked, maskImageClean] = filter_IRM(image, nature)
    grayImage = double(image);
    if nature=="diff"
        numberOfClasses = 3;
    elseif nature=="flair"
        numberOfClasses = 2;
    end
    
    % Création du masque (filtre)   
    clusters = kmeans(grayImage(:), numberOfClasses);
    
    [nb_pixels,index] = groupcounts(clusters);
    [min_nb_pixels,index_min] = min(nb_pixels);
    [max_nb_pixels,index_max] = max(nb_pixels);

    if nature=="diff"
        clusters(clusters == index_min) = 0;
    end
    
    clusters(clusters == index_max) = 0;
    clusters(clusters ~= 0) = 1;
    
    maskImage = reshape(clusters, size(grayImage));
    
    %Nettoyage du masque
    CC = bwlabel(maskImage);
    [nb_pix_CC, index_CC] = groupcounts(reshape(CC, [224*224 1]));
    [nb_pix_max, index_max] = max(nb_pix_CC(nb_pix_CC ~= max(nb_pix_CC)));
    
    maskImageClean = zeros(size(maskImage));
    maskImageClean(CC == index_max) = 1;

    %Filtrage de l image
    image_masked = grayImage;
    image_masked(maskImageClean==0) = 0;
end

function [Im1r, Im2r] = rescaleIm(Im1, Im2)
    Im1r = Im1;
    Im2r = Im2;
    % on rescale limage la plus grande de la taille de la plus petite
    if size(Im1r) > size(Im2r)
        Im1r = imresize(Im1r, size(Im2r));
    elseif size(Im2r) > size(Im1r)
        Im2r = imresize(Im2r, size(Im1r));
    end
    
end