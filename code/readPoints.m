function [pts_diff, pts_flair] = readPoints(image_Diff, image_Flair, n)
%readPoints   Read manually-defined points from image
%   POINTS = READPOINTS(IMAGE_DIFF,IMAGE_FLAIR) displays the two images in the current figure,
%   then records the position of each click of button 1 of the mouse in the
%   figure, and stops when another button is clicked. The track of points
%   is drawn as it goes along. The result are a 2 x NPOINTS matrixes; each
%   column is [X; Y] for one point.
%   
%   POINTS = READPOINTS(IMAGE_DIFF,IMAGE_FLAIR, N) reads up to N points only.
%   Adapted from https://github.com/leonpalafox/planet_utils/blob/master/Matlab/readPoints.m

if nargin < 2
    n = Inf;
    pts_diff = zeros(2, 0);
    pts_flair = zeros(2, 0);
else
    pts_diff = zeros(2, n);
    pts_flair = zeros(2, n);
end

for i=1:2
    if i==1
        subplot(1,2,1); 
        imshow(image_Diff,[]);     % display image
    else
        subplot(1,2,2); 
        imshow(image_Flair,[]);
    end
    xold = 0;
    yold = 0;
    k = 0;
    hold on;           % and keep it there while we plot
    
    if nargin < 2
        n = Inf;
        pts = zeros(2, 0);
    else
        pts = zeros(2, n);
    end
    
    while 1
        [xi, yi, but] = ginput(1);      % get a point
        if ~isequal(but, 1)             % stop if not button 1
            break
        end
        k = k + 1;
        pts(1,k) = xi;
        pts(2,k) = yi;
    
          if xold
              plot([xold xi], [yold yi], 'ro');  % draw as we go
          else
              plot(xi, yi, 'ro');         % first point on its own
          end
    
          if isequal(k, n)
              break
          end
          xold = xi;
          yold = yi;
    end
    
    hold off;
    if k < size(pts,2)
        pts = pts(:, 1:k);
    end
    
    if i==1
        pts_diff=pts;
    else
        pts_flair=pts;
    end
end

end

