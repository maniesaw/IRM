function [s, tx_opt, ty_opt, r_opt, Image_diff_opt] = point_set_registration(Image_diff_clean,Image_flair_clean, Nb_points)    
    % The user select the points that will be align. He must chose
    % Nb_points in each image and they have to be chose in the right order.
    [pts_diff, pts_flair]=readPoints(Image_diff_clean,Image_flair_clean, Nb_points);
    
    % Choice of lower/upper bounds and steps for translation and rotation
    [tmin, tmax, tstep, rmin, rmax, rstep] = askUserValue();
    
    s=simcrit_set_points_registration(Image_diff_clean,Image_flair_clean, pts_diff, pts_flair);
    p_opt=[0 0 0];
    
    % The FLAIR image is the fixed image, and the Diffusion MRI is the moving
    % image to be registered.
    
    for tx=tmin:tstep:tmax
        for ty=tmin:tstep:tmax
            for r=rmin:rstep:rmax
                ID_temp=imtranslate(Image_diff_clean,[tx,ty]);
                ID_temp=imrotate(ID_temp,r,'crop');
                stemp=simcrit_set_points_registration(ID_temp,Image_flair_clean, pts_diff, pts_flair);
                if stemp<s
                    s=stemp;
                    p_opt=[tx ty r];
                end
            end
        end
    end
    
    tx_opt=p_opt(1);
    ty_opt=p_opt(2);
    r_opt=p_opt(3);
    
    Image_diff_opt=imtranslate(Image_diff_clean,[tx_opt,ty_opt]);
    Image_diff_opt=imrotate(Image_diff_opt,r_opt,'crop');
end