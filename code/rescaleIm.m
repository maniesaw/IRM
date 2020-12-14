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