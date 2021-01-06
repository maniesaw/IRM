%%
% This script proposes to align two images from different MRI modalities :
% (Diffusion MRI and FLAIR MRI)
% You will have to provide the path from this main.m file to the two images
% to align
% example with the data available :
    % path_DIFFUSION = 'data/patient1/DIFFUSION.nii'
    % path_FLAIR = 'data/patient1/FLAIR.nii'
% It is possible to use this script to align other Nifti images from
% diffusion and flair RMI

%%
clear;
clc;

% Add function folder to path
addpath('functions');

%
% Ask user to enter the paths to the images
fprintf('------------START------------\n');
disp(['Enter the paths to the images']);
prompt = 'diffusion : ';
path_DIFFUSION = input(prompt,'s');

prompt = 'flair : ';
path_FLAIR = input(prompt,'s');

% The images are imported
Im_diff = niftiread(path_DIFFUSION);
Im_flair = niftiread(path_FLAIR);

% Choice of slice to be registered
[m,n,p] = size(Im_diff);
fprintf('\nThe images you provided contain %.0f slices.\nWhich slice do you want to register ?\n', p);
prompt = 'Enter the slice number : ';
num_slice = input(prompt);

% Save figure with two slices chosen from the original images
figure('position', [100, 100, 600, 300], 'visible', 'off');
subplot(1, 2, 1);imshow(Im_diff(:,:,num_slice), []);title("Image of type Diffusion (slice " + num_slice + ")");
subplot(1, 2, 2);imshow(Im_flair(:,:,num_slice), []);title("Image of type Flair (slice " + num_slice + ")");
mkdir('output');
saveas(gcf, "output/original_images.png");
fprintf('(original images saved in output folder)\n');


% Preprocessing
% At the end of the preprocessing, only the brain is kept from the original
% images
fprintf('\n----------------------\n----Preprocessing-----\n----------------------\n\n');

[Image_diff_clean, Image_flair_clean, mask_diff, mask_flair]=preprocess(Im_diff(:,:,num_slice), Im_flair(:,:,num_slice));

figure('position', [100, 100, 600, 400], 'visible', 'off');

subplot(2, 3, 1);imshow(Im_diff(:,:,num_slice), []);title("Image of type Diffusion (slice " + num_slice + ")");
subplot(2, 3, 2);imshow(mask_diff, []);title("Mask Diffusion");
subplot(2, 3, 3);imshow(Image_diff_clean, []);title("Image Diffusion Clean");
subplot(2, 3, 4);imshow(Im_flair(:,:,num_slice), []);title("Image of type Flair (slice " + num_slice + ")");
subplot(2, 3, 5);imshow(mask_flair, []);title("Mask Flair");
subplot(2, 3, 6);imshow(Image_flair_clean, []);title("Image Flair Clean");

saveas(gcf, "output/cleaned_images.png");
fprintf('(preprocessed images saved in output folder)\n\n\n');


% Registration
fprintf('---------------------\n----Registration-----\n---------------------\n\n');

% Choise of registration type (1- Rigid | 2-Point set | 3- Non-rigid)
fprintf('Choose the type of registration you want to perform\n');
prompt = 'Enter 1 for rigid, 2 for point set or 3 for non-rigid : ';
regis_type = input(prompt);

% Rigid registration
if regis_type == 1
    
    [simcrit, tx_opt, ty_opt, r_opt, Image_diff_opt] = rigid_registration_choice_metric(Image_diff_clean,Image_flair_clean, mask_diff, mask_flair);

    disp(['The optimal x translation is : ', num2str(tx_opt)]);
    disp(['The optimal y translation is : ', num2str(ty_opt)]);
    disp(['The optimal r rotation is : ', num2str(r_opt)]);

% Point set registration
elseif regis_type == 2
    
    prompt = '\nEnter the number of points you will select : ';
    nb_points=input(prompt);
    [s, tx_opt, ty_opt, r_opt, Image_diff_opt] = point_set_registration(Image_diff_clean,Image_flair_clean,nb_points);

    disp(['The optimal x translation is : ', num2str(tx_opt)]);
    disp(['The optimal y translation is : ', num2str(ty_opt)]);
    disp(['The optimal r rotation is : ', num2str(r_opt)]);

% Non rigid registration
elseif regis_type == 3
    
    [Image_diff_opt] = non_rigid_registration(Image_diff_clean,Image_flair_clean);
    
else
    disp(['Please enter 1 or 2 for the registration type choice. Run again to process.']);
end

% Save superposed images
C = imfuse(Image_diff_opt,Image_flair_clean,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);

h1=figure();
imshow(C),title({'Superposition of images after optimal transformation'});
set(h1,'Position',[100, 100, 500, 400], 'visible', 'off')

saveas(gcf, "output/transformation_result_superposed.png");
fprintf('\n(superposed images saved in output folder)\n\n');

% Save plot with original images and superposed images
figure('position', [100, 100, 600, 200], 'visible', 'off');

subplot(1, 3, 1);imshow(Im_diff(:,:,num_slice), []);
title({
    ['Image of type Diffusion']
    ["(slice " + num_slice + ")"]
    });
subplot(1, 3, 2);imshow(Im_flair(:,:,num_slice), []);
title({
    ['Image of type Flair']
    ["(slice " + num_slice + ")"]
    });
subplot(1, 3, 3);imshow(C);
title({
    ['Superposition of images']
    ['after optimal transformation']
    });

saveas(gcf, "output/original_and_superposed.png");
fprintf('(original and superposed images saved in output folder)\n\n---------------END---------------\n\n\n');


%%




