%%
clear;
clc;

%% Import example of image and display one slice (around the middle)
Im_diff = niftiread("../project2_registration/data/patient1/DIFFUSION.nii");
Im_flair = niftiread("../project2_registration/data/patient1/FLAIR.nii");

figure('position', [100, 100, 600, 300]);

subplot(1, 2, 1);imshow(Im_diff(:,:,8), []);title("Image of type Diff");
subplot(1, 2, 2);imshow(Im_flair(:,:,8), []);title("Image of type Flair");

saveas(gcf, "../output/original_images.png");

%% 1. Preprocessing : rescale and mask
% At the end of the preprocessing, only the brain is kept from the original
% images
[Image_diff_clean, Image_flair_clean, mask_diff, mask_flair]=preprocess(Im_diff(:,:,8), Im_flair(:,:,8));

figure('position', [100, 100, 600, 400]);

subplot(2, 3, 1);imshow(Im_diff(:,:,8), []);title("Image of type Diff");
subplot(2, 3, 2);imshow(mask_diff, []);title("Mask Diff");
subplot(2, 3, 3);imshow(Image_diff_clean, []);title("Image Diff Clean");

subplot(2, 3, 4);imshow(Im_flair(:,:,8), []);title("Image of type Flair");
subplot(2, 3, 5);imshow(mask_flair, []);title("Mask Flair");
subplot(2, 3, 6);imshow(Image_flair_clean, []);title("Image Flair Clean");

saveas(gcf, "../output/cleaned_images.png");


%% 2. Rigid registration

%% 2.1 First, we grayscale the images
% The range of the cleaned images is not between 0 and 256 so we have to
% rescale them
Image_diff_clean_gray = grayscaleIm(Image_diff_clean);
Image_flair_clean_gray = grayscaleIm(Image_flair_clean);

%% 2.2 Then, we find the barycenters of both images to calculate the initial
% translations. To do this, we use the masks to give the same weight to all
% the non zeros pixels.
[x_centroid_diff, y_centroid_diff] = findCentroid(mask_diff);
[x_centroid_flair, y_centroid_flair] = findCentroid(mask_flair);

% The FLAIR image is the fixed image, and the Diffusion MRI is the moving
% image to be registered.
tx0 = x_centroid_flair - x_centroid_diff;
ty0 = y_centroid_flair - y_centroid_diff;

disp(['The initial x translation is : ', num2str(tx0)]);
disp(['The initial y translation is : ', num2str(ty0)]);


figure('position', [100, 100, 600, 300]);

subplot(1, 2, 1);
imshow(mask_diff, []);title("Mask Diff");
hold on
plot(x_centroid_diff, y_centroid_diff, 'r*')
hold off

subplot(1, 2, 2);
imshow(mask_flair, []);title("Mask Flair");
hold on
plot(x_centroid_flair, y_centroid_flair, 'r*')
hold off

saveas(gcf, "../output/centroids.png");

%% 2.3 Choice of lower/upper bounds and steps for translation and rotation
% We ask the 6 values to the user
[tmin, tmax, tstep, rmin, rmax, rstep] = askUserValue();








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

function grayIm = grayscaleIm(cleanedIm)
    grayIm = round(mat2gray(cleanedIm)*256);
end

function [tmin, tmax, tstep, rmin, rmax, rstep] = askUser()
    disp(['Enter the values of lower/upper bounds and steps for translation and rotation']);

    prompt = 'tmin :';
    tmin = input(prompt);

    prompt = 'tmax :';
    tmax = input(prompt);

    prompt = 'tstep :';
    tstep = input(prompt);

    prompt = 'rmin :';
    rmin = input(prompt);

    prompt = 'rmax :';
    rmax = input(prompt);

    prompt = 'rstep :';
    rstep = input(prompt);

end