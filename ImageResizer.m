% Script resizes all background images to 640,640 for Yolo
inputFolder = 'Backgrounds/'; 
outputFolder = 'BackgroundsResized/'; 

letterBoxing = false;

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

imageExtensions = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tiff', '*.gif'};
imageFiles = [];
for i = 1:length(imageExtensions)
    imageFiles = [imageFiles; dir(fullfile(inputFolder, imageExtensions{i}))];
end

targetSize = [640, 640];

for i = 1:length(imageFiles)
    imagePath = fullfile(inputFolder, imageFiles(i).name);
    img = imread(imagePath);
    
    finalImg = imresize(img, targetSize);
    
    % Letterboxing
    if letterBoxing == true
        [originalHeight, originalWidth, ~] = size(img);
    
        scale = min(targetSize(1) / originalHeight, targetSize(2) / originalWidth);
        newHeight = round(originalHeight * scale);
        newWidth = round(originalWidth * scale);
    
        resizedImg = imresize(img, [newHeight, newWidth]);
        finalImg = uint8(255*ones(targetSize(1), targetSize(2), size(img, 3)));
    
        padTop = floor((targetSize(1) - newHeight) / 2);
        padLeft = floor((targetSize(2) - newWidth) / 2);
    
        finalImg(padTop+1:padTop+newHeight, padLeft+1:padLeft+newWidth, :) = resizedImg;
    end

    % Saving image
    [~, name, ext] = fileparts(imageFiles(i).name);
    outputPath = fullfile(outputFolder, [name, ext]);
    imwrite(finalImg, outputPath);
    
    fprintf('Resized and saved: %s\n', imageFiles(i).name);
end

fprintf('All images have been resized and saved to %s\n', outputFolder);