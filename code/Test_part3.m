%%
clear;
clc;
%%

Im_diff = niftiread("DIFFUSION.nii");
Im_flair = niftiread("FLAIR.nii");

%% 
[ID, IF, mask_diff, mask_flair]=preprocess(Im_diff(:,:,8), Im_flair(:,:,8));
[s, tx_opt, ty_opt, r_opt, Image_diff_opt] = point_set_registration(ID,IF,3);    

h1=figure();
C = imfuse(Image_diff_opt,IF,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
imshow(C),title({'Superposition of images after', 'optimal transformation', '(-10,10,1,-2,2,0.1)'});
set(h1,'Position',[100, 100, 500, 400])
h2=figure();
C2=imfuse(ID,IF,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
imshow(C2),title({'Superposition of images before', 'optimal transformation'});
set(h2,'Position',[100, 100, 500, 400])

%%
%{

[pts_diff, pts_flair]=readPoints(ID,IF, 2);

tmin=-10;
tmax=10;
tstep=2;
rmin=-1;
rmax=1;
rstep=0.2;
s=0;
L=length(pts_diff);
for i=1:L
   s=s+(ID(round(pts_diff(1,i)),round(pts_diff(2,i)))-IF(round(pts_flair(1,i)),round(pts_flair(2,i))))^2; 
end
p_opt=[0 0 0];
for tx=tmin:tstep:tmax
    for ty=tmin:tstep:tmax
        for r=rmin:rstep:rmax
            ID_temp=imtranslate(ID,[tx,ty]);
            ID_temp=imrotate(ID_temp,r,'crop');
            stemp=0;
            for i=1:L
               stemp=stemp+(ID_temp(round(pts_diff(1,i)),round(pts_diff(2,i)))-IF(round(pts_flair(1,i)),round(pts_flair(2,i))))^2; 
            end
            if stemp<s
                s=stemp;
                p_opt=[tx ty r];
            end
        end
    end
end
%}
