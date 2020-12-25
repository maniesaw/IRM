%%
clear;
clc;

%% Chargement des images
I_p1_diff = niftiread("../project2_registration/data/patient1/DIFFUSION.nii");
I_p1_flair = niftiread("../project2_registration/data/patient1/FLAIR.nii");

I_p6_diff = niftiread("../project2_registration/data/patient6/DIFFUSION.nii");
I_p6_flair = niftiread("../project2_registration/data/patient6/FLAIR.nii");

I_p27_diff = niftiread("../project2_registration/data/patient27/DIFFUSION.nii");
I_p27_flair = niftiread("../project2_registration/data/patient27/FLAIR.nii");


%% Test : Affichage des images (slices 1 et 8) du patient 1
c1_diff = I_p1_diff(:,:,1);
c8_diff = I_p1_diff(:,:,8);
c15_diff = I_p1_diff(:,:,15);

c1_flair = I_p1_flair(:,:,1);
c8_flair = I_p1_flair(:,:,8);
c15_flair = I_p1_flair(:,:,15);

subplot(2,3,1); imshow(c1_diff,[]);
subplot(2,3,2); imshow(c8_diff,[]);
subplot(2,3,3); imshow(c15_diff,[]);
subplot(2,3,4); imshow(c1_flair,[]);
subplot(2,3,5); imshow(c8_flair,[]);
subplot(2,3,6); imshow(c15_flair,[]);
% on voit que la slice du milieu est la plus informative


%% 1 - Preprocessing

%% 1.1 Resize images

%% Appel de la fonction rescaleIm qui permet de rescale l'image la plus grande de la taille de la plus petite
% on ne va rescale que la slice du milieu

[I_p1_diff_r, I_p1_flair_r] = rescaleIm(I_p1_diff, I_p1_flair);
[I_p6_diff_r, I_p6_flair_r] = rescaleIm(I_p6_diff, I_p6_flair);
[I_p27_diff_r, I_p27_flair_r] = rescaleIm(I_p27_diff, I_p27_flair);



%% Affichage résultats de la fonction rescaleIm pour le patient 1
subplot(2,2,1); imshow(I_p1_diff(:,:,7),[]);
subplot(2,2,2); imshow(I_p1_diff_r,[]);
subplot(2,2,3); imshow(I_p1_flair(:,:,7),[]);
subplot(2,2,4); imshow(I_p1_flair_r,[]);




%% 1.2 Création des masques pour ne garder que le cortex cérébral

%% 1.2.1 Pour une imagerie de diffusion

%% Segmentation

% On réalise la segmentation de notre image
% On décide d'avoir 3 clusters de segmentation : le fond, le cortex
% cérébral et les cavités (en blanc sur l'imagerie de diffusion)
grayImage = double(I_p1_diff_r);
subplot(1, 2, 1);imshow(grayImage, []);
numberOfClasses = 3;
indexes = kmeans(grayImage(:), numberOfClasses);
classImage = reshape(indexes, size(grayImage));
h2 = subplot(1, 2, 2);imshow(classImage, []);
colormap(h2, lines(numberOfClasses));
colorbar;

%% Création du masque (filtre)
% La zone d'intérêt est le cortex cérébral
% Le cluster du fond représente la plus grande partie de l'image
% Le cluster des cavités représente la plus petite
% Pour constituer notre masque, on fixe à 0 les pixels venant des clusters
% le plus grand (fond) et le plus petit (cavités)
[GC,GR] = groupcounts(indexes);
[min_GC,index_min_GC] = min(GC);
[max_GC,index_max_GC] = max(GC);

indexes(indexes == index_min_GC) = 0;
indexes(indexes == index_max_GC) = 0;
indexes(indexes ~= 0) = 1;

maskImage = reshape(indexes, size(grayImage));
imshow(maskImage, []);
% Le masque obtenu contient donc des 0 et des 1
% Les pixels à 1 correspondent au cortex cérébral


%%
CC = bwlabel(maskImage);
[nb_pix_CC, index_CC] = groupcounts(reshape(CC, [224*224 1]));
[nb_pix_max, index_max] = max(nb_pix_CC(nb_pix_CC ~= max(nb_pix_CC)))

maskImageClean = zeros(size(maskImage));
maskImageClean(CC == index_max) = 1;

%%
subplot(1,2,1);imshow(maskImage);
subplot(1,2,2);imshow(maskImageClean);


%% Passage de notre image originale dans le filtre
% Cette étape permet de ne garder que la région d'intérêt
I_p1_diff_r_masked = I_p1_diff_r
I_p1_diff_r_masked(maskImageClean == 0) = 0;

subplot(1,3,1);imshow(I_p1_diff_r);
subplot(1,3,2);imshow(maskImageClean, []);
subplot(1,3,3);imshow(I_p1_diff_r_masked);




%% 1.2.2 Pour une imagerie de flair

%% Segmentation

% On réalise la segmentation de notre image
% On décide d'avoir 2 clusters de segmentation : le fond et le cortex cérébral
grayImage = double(I_p1_flair_r);
subplot(1, 2, 1);imshow(grayImage, []);
numberOfClasses = 2;
indexes = kmeans(grayImage(:), numberOfClasses);
classImage = reshape(indexes, size(grayImage));
h2 = subplot(1, 2, 2);imshow(classImage, []);
colormap(h2, lines(numberOfClasses));
colorbar;

%% Création du masque (filtre)
% La zone d'intérêt est le cortex cérébral
% Le cluster du fond représente la plus grande partie de l'image
% Pour constituer notre masque, on fixe à 0 les pixels venant du cluster le
% plus grand (fond)
[GC,GR] = groupcounts(indexes);
[max_GC,index_max_GC] = max(GC);

indexes(indexes == index_max_GC) = 0;
indexes(indexes ~= 0) = 1;

maskImage = reshape(indexes, size(grayImage));
imshow(maskImage, []);
% Le masque obtenu contient donc des 0 et des 1
% Les pixels à 1 correspondent au cortex cérébral

%% Passage de notre image originale dans le filtre
% Cette étape permet de ne garder que la région d'intérêt
I_p1_flair_r_masked = I_p1_flair_r
I_p1_flair_r_masked(maskImage == 0) = 0;

subplot(1,3,1);imshow(I_p1_flair_r);
subplot(1,3,2);imshow(maskImage, []);
subplot(1,3,3);imshow(I_p1_flair_r_masked);






%% 2. Rigid registration

% Image Flair correspond à l'image fixe, on va faire bouger l'image de diffusion

%% 2.1 Convertir images en niveau de gris

I_p1_diff_gray = niftiread("../project2_registration/data/patient1/DIFFUSION_greyscale.nii");
I_p1_flair_gray = niftiread("../project2_registration/data/patient1/FLAIR_greyscale.nii");

subplot(2,2,1);imshow(I_p1_diff(:,:,8), []);
subplot(2,2,2);imshow(I_p1_flair(:,:,8), []);
subplot(2,2,3);imshow(I_p1_diff_gray(:,:,8), []);
subplot(2,2,4);imshow(I_p1_flair_gray(:,:,8), []);

%%
%imshow(I_p1_diff(:,:,8), []);
%imshow(mat2gray(I_p1_diff(:,:,8)));

subplot(1,3,1);imshow(I_p1_diff(:,:,8), []);
subplot(1,3,2);imshow(I_p1_diff_gray(:,:,8), []);
subplot(1,3,3);imshow(round(mat2gray(I_p1_diff(:,:,8))*256), []);

%%
I_p1_diff_gray = round(mat2gray(I_p1_diff(:,:,8))*256);
I_p1_flair_gray = round(mat2gray(I_p1_flair(:,:,8))*256);


%% 2.2.1 Trouver le barycentre des images
% On va en fait chercher le barycentre du masque pour ne pas donner plus de
% poids à des pixels de fortes intensités

%% 
s_diff = regionprops(maskImageClean, 'centroid');
centroids_diff = cat(1, s_diff.Centroid);
imshow(maskImageClean, [])
hold on
plot(centroids_diff(:,1), centroids_diff(:,2), 'b*')
hold off

%%

diff_clean = imread("../project2_registration/data/cleaned_images/DIFFUSION_p1_s8.png");
imshow(diff_clean);













%% functions

% rescaleIm
function [Im1r, Im2r] = rescaleIm(Im1, Im2)
    
    % on récupère pour les deux images 3D seulement la slice du milieu
    [m1,n1,p1] = size(Im1);
    slice1 = floor(p1/2);
    Im1r = uint8(255 * mat2gray(Im1(:,:,slice1)));
    
    
    [m2,n2,p2] = size(Im2);
    slice2 = floor(p2/2);
    Im2r = uint8(255 * mat2gray(Im2(:,:,slice2)));
    
    % on rescale l'image la plus grande de la taille de la plus petite
    if size(Im1r) > size(Im2r)
        Im1r = imresize(Im1r, size(Im2r));
    elseif size(Im2r) > size(Im1r)
        Im2r = imresize(Im2r, size(Im1r));
    end
    
end

%%





