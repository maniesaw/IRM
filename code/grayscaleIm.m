function grayIm = grayscaleIm(cleanedIm)
    grayIm = round(mat2gray(cleanedIm)*256);
end