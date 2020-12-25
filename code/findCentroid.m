function [x_centroid, y_centroid] = findCentroid(maskImageClean)
    s_diff = regionprops(maskImageClean, 'centroid');
    centroids_diff = cat(1, s_diff.Centroid);
    x_centroid = centroids_diff(:,1);
    y_centroid = centroids_diff(:,2);
end