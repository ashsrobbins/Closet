%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IntoTheCloset
%
% bSub(imagePath, croppedPic)
% 
% Input- imagePath: string of image (.jpg/.jpeg)
%        croppedPic: string of (.png)
% Output - 
%
% Description- Input an image of a piece of clothing and a .png copy of the
%              image will be returned with the background subtracted
%
% 
% Written by: Maryam Tebyani
% Requires: OpenCV Matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function  out = bSub(imagePath, outputFile)

I = imread(imagePath);
sz = size(I);
%scale down image
if sz(2) > 1000
    image = imresize(I,.2);
else 
    image = I;
end

cform = makecform('srgb2lab');
lab_im = applycform(image, cform);

%cluster colors saved in space
ab = double(lab_im(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);

nColors = 3;
% repeat the clustering 3 times to avoid local minima
[cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);

%label pixel location
pixel_labels = reshape(cluster_idx,nrows,ncols);

%create image
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);

for k = 1:nColors
    color = image;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end

for k = 1:2
    temp = segmented_images{k}; 
    if all(temp(1,:, :))
        break;
    end
end

picture = segmented_images{k};

[m, n, b] = size(picture);
alp = ones(m, n);

for x = 1:m
    for y = 1:n
        if ((picture(x, y, :) ~= 0))
           alp(x, y) =  0; 
        end
    end
end

croppedPic = strcat(outputFile, '.png');

imwrite(image, croppedPic, 'Alpha', alp);
imshow(image);
out = image;

if(exist(outputFile, 'file') ~= 7)
    mkdir(outputFile);
end
movefile('cloth_info.txt', strcat(outputFile, '.txt'));

copyfile(strcat(outputFile, '.txt'), outputFile);
copyfile(croppedPic, outputFile);

end
