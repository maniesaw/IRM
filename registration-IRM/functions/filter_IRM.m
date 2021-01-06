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