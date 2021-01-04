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
%{
%% 2.1 First, we grayscale the images
% The range of the cleaned images is not between 0 and 256 so we have to
% rescale them
Image_diff_clean_gray = grayscaleIm(Image_diff_clean);
Image_flair_clean_gray = grayscaleIm(Image_flair_clean);

%% 2.2 Then, we find the barycenters of both images to calculate the initial
%translations. To do this, we use the masks to give the same weight to all
%the non zeros pixels.
[x_centroid_diff, y_centroid_diff] = findCentroid(mask_diff);
[x_centroid_flair, y_centroid_flair] = findCentroid(mask_flair);

%The FLAIR image is the fixed image, and the Diffusion MRI is the moving
%image to be registered.
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

%% 2.4 & 2.5 Implement the different transformations to apply to the moving image and store
% the pi value that give the best translation parameters

%pi_opt=[0 0 0];
s = simcrit(Image_diff_clean_gray, Image_flair_clean_gray);
Image_diff_clean_gray_0=imtranslate(Image_diff_clean_gray,[tx0,ty0]);

for tx=tmin:tstep:tmax
    for ty=tmin:tstep:tmax
        for r=rmin:rstep:rmax
            ID_temp=imtranslate(Image_diff_clean_gray_0,[tx,ty]);
            ID_temp=imrotate(ID_temp,r,'crop');
            ssimval=simcrit(ID_temp,Image_flair_clean_gray);
            if ssimval<s
                s=ssimval;
                p_opt=[tx ty r];
            end
        end
    end
end

%% 2.6 Comments of  results
%}
%% Test rigid_registration function
[simcrit, tx_opt, ty_opt, r_opt, Image_diff_opt] = rigid_registration(Image_diff_clean,Image_flair_clean, mask_diff, mask_flair);

disp(['The optimal x translation is : ', num2str(tx_opt)]);
disp(['The optimal y translation is : ', num2str(ty_opt)]);
disp(['The optimal r rotation is : ', num2str(r_opt)]);

figure('position', [100, 100, 600, 300]);

subplot(1,2,1);imshow(Image_flair_clean),title('Original flair image (fixed)')
subplot(1,2,2);imshow(Image_diff_opt),title('Diffusion image with optimal transformation')

saveas(gcf, "../output/rigid_transformation_result.png");

%% Display results
C = imfuse(Image_diff_opt,Image_flair_clean,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);

h1=figure();
imshow(C),title({'Superposition of images after optimal transformation', '(-10,10,1,-2,2,0.1,SE)'});
set(h1,'Position',[100, 100, 500, 400])

saveas(gcf, "../output/rigid_transformation_result_superposed.png");



%% 3 - Point set registration

nb_points=5;
[s, tx_opt, ty_opt, r_opt, Image_diff_opt_PS] = point_set_registration(Image_diff_clean,Image_flair_clean,nb_points);

disp(['The optimal x translation is : ', num2str(tx_opt)]);
disp(['The optimal y translation is : ', num2str(ty_opt)]);
disp(['The optimal r rotation is : ', num2str(r_opt)]);

h1=figure();
C = imfuse(Image_diff_opt_PS,IF,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
imshow(C),title({'Superposition of images after', 'optimal transformation', '(-10,10,1,-2,2,0.1)'});
set(h1,'Position',[100, 100, 500, 400])
h2=figure();
C2=imfuse(ID,IF,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
imshow(C2),title({'Superposition of images before', 'optimal transformation'});
set(h2,'Position',[100, 100, 500, 400])



%% 5. Additional similarity metric - mutual information

%% Test rigid_registration_choice_metric
[simcrit, tx_opt, ty_opt, r_opt, Image_diff_opt] = rigid_registration_choice_metric(Image_diff_clean,Image_flair_clean, mask_diff, mask_flair);

disp(['The optimal x translation is : ', num2str(tx_opt)]);
disp(['The optimal y translation is : ', num2str(ty_opt)]);
disp(['The optimal r rotation is : ', num2str(r_opt)]);

figure('position', [100, 100, 600, 300]);

subplot(1,2,1);imshow(Image_flair_clean),title('Original flair image (fixed)')
subplot(1,2,2);imshow(Image_diff_opt),title('Diffusion image with optimal transformation')

saveas(gcf, "../output/rigid_transformation_choice_metric_result.png");

%% Display results
C = imfuse(Image_diff_opt,Image_flair_clean,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);

h1=figure(1);
imshow(C),title({'Superposition of images after optimal transformation', '(-10,10,1,-2,2,0.1,MI)'});
set(h1,'Position',[100, 100, 500, 400])

saveas(gcf, "../output/rigid_transformation_choice_metric_result_superposed.png");


