function s=simcrit_set_points_registration(Im_diff_clean,Im_flair_clean, pts_diff, pts_flair)
    s=0;
    L=length(pts_diff);
    for i=1:L
       s=s+(Im_diff_clean(round(pts_diff(1,i)),round(pts_diff(2,i)))-Im_flair_clean(round(pts_flair(1,i)),round(pts_flair(2,i))))^2; 
    end
end
