function [s, tx_opt, ty_opt, r_opt, Image_diff_opt] = rigid_registration_choice_metric(Image_diff_clean,Image_flair_clean, mask_diff, mask_flair)
%2.1 First, we grayscale the images
% The range of the cleaned images is not between 0 and 256 so we have to
% rescale them
Image_diff_clean_gray = grayscaleIm(Image_diff_clean);
Image_flair_clean_gray = grayscaleIm(Image_flair_clean);

% 2.2 Then, we find the barycenters of both images to calculate the initial
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

% 2.3 Choice of lower/upper bounds and steps for translation and rotation
% Choice of metric (1-Squared difference | 2-Mutual information)
[tmin, tmax, tstep, rmin, rmax, rstep, metric] = askUserValue_choice_metric();


% 2.4 & 2.5 Implement the different transformations to apply to the moving image and store
% the pi value that give the best translation parameters
if metric == 1
    
    p_opt=[0 0 0];
    s = simcrit(Image_diff_clean_gray, Image_flair_clean_gray );
    tx_opt = 0;
    ty_opt = 0;
    r_opt = 0;

    for tx=tmin:tstep:tmax
        for ty=tmin:tstep:tmax
            for r=rmin:rstep:rmax
                ID_temp=imtranslate(Image_diff_clean_gray,[tx,ty]);
                ID_temp=imrotate(ID_temp,r,'crop');
                ssimval=simcrit(ID_temp,Image_flair_clean_gray);
                if ssimval<s
                    s=ssimval;
                    tx_opt = tx;
                    ty_opt = ty;
                    r_opt = r;
                    p_opt=[tx ty r];
                end
            end
        end
    end
    
elseif metric == 2
    
    p_opt=[0 0 0];
    s = cal_mi(Image_diff_clean_gray, Image_flair_clean_gray );
    tx_opt = 0;
    ty_opt = 0;
    r_opt = 0;

    for tx=tmin:tstep:tmax
        for ty=tmin:tstep:tmax
            for r=rmin:rstep:rmax
                ID_temp=imtranslate(Image_diff_clean_gray,[tx,ty]);
                ID_temp=imrotate(ID_temp,r,'crop');
                mival=cal_mi(ID_temp,Image_flair_clean_gray);
                if mival>s
                    s=mival;
                    tx_opt = tx;
                    ty_opt = ty;
                    r_opt = r;
                    p_opt=[tx ty r];
                end
            end
        end
    end

else
    disp(['Please enter 1 or 2 for the metric choice. Run again to process.']);
end

Image_diff_opt = imtranslate(Image_diff_clean_gray,[tx_opt,ty_opt]);
Image_diff_opt = imrotate(Image_diff_opt,r_opt,'crop');

end

