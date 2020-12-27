function simval = simcrit(Im_diff_clean, Im_flair_clean)
if size(Im_diff_clean) == size(Im_flair_clean)
    [w,h] = size(Im_flair_clean);
    simval = 0;
    for i = 1:h
        for j = 1:w
            simval = simval + (Im_flair_clean(i,j) - Im_diff_clean(i,j))^2;
        end
    end
elseif size(Im_diff_clean) ~= size(Im_flair_clean)
    disp('Size of input image are incorrects');
end

end


