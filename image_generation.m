% Randomly place cards from one folder onto backgrounds
% Using convention card naming of 2C_1.png to save labels 2C

%img = imread('../BlaiseCards/2C.png'); 

%cardFolder = '../BlaiseCards/';
cardFolder = '../DigitalCards/';
backgroundFolder = '../Backgrounds/';
outputFolder = '../Results/';

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

cardImages = dir(fullfile(cardFolder, '*.png')); 
backgroundImages = dir(fullfile(backgroundFolder, '*.png')); 

if isempty(cardImages)
    error('No card images found in the specified folder.');
end
if isempty(backgroundImages)
    error('No background images found in the specified folder.');
end

labels = cell(1, length(cardImages));

for bgIdx = 1:1

    bgImagePath = fullfile(backgroundFolder, backgroundImages(bgIdx).name);
    bgImage = imread(bgImagePath);
    [bgHeight, bgWidth, ~] = size(bgImage);
    disp(['Processing background image: ', bgImagePath]);
    
    for cardIdx = 1:4
        
        cardImagePath = fullfile(cardFolder, cardImages(cardIdx).name);
        [img, ~, alpha] = imread(cardImagePath);

        % Making png background white instead of black
        alphaMask = double(alpha) / 255; 
        bgColor = [255, 255, 255]; 
        background = uint8(ones(size(img)) .* reshape(bgColor, [1 1 3]));
        cardImage = uint8(double(img) .* alphaMask + double(background) .* (1 - alphaMask));

        [cardHeight, cardWidth, ~] = size(cardImage);
        disp(['Processing card image: ', cardImagePath]);
        
        % Rotation
        angle = randi([-45, 45]);
        
        cardImageRotated = imrotate(cardImage, angle, 'bilinear', 'loose');
        alphaRotated = imrotate(alpha, angle, 'bilinear', 'loose');
        [cardHeightRotated, cardWidthRotated, ~] = size(cardImageRotated);
        
        % Ensure the rotated card fits within the background
        if cardWidthRotated > bgWidth || cardHeightRotated > bgHeight
            warning('Rotated card image is larger than the background image. Skipping this card.');
            continue;
        end
        
        % Random position for the rotated card
        xPos = randi([1, bgWidth - cardWidthRotated + 1]);
        yPos = randi([1, bgHeight - cardHeightRotated + 1]);
        
        % Mask
        alphaMaskRotated = double(alphaRotated) / 255;
        
        % Extract region from the background
        bgRegion = bgImage(yPos:yPos+cardHeightRotated-1, xPos:xPos+cardWidthRotated-1, :);
        
        % Blend the rotated card 
        blendedRegion = uint8(double(cardImageRotated) .* alphaMaskRotated + double(bgRegion) .* (1 - alphaMaskRotated));
        
        % Place the blended region back into the background
        combinedImage = bgImage;
        combinedImage(yPos:yPos+cardHeightRotated-1, xPos:xPos+cardWidthRotated-1, :) = blendedRegion;
        
        % Bounding box
        [rows, cols] = find(alphaRotated > 0);
        x_min = min(cols);
        x_max = max(cols);
        y_min = min(rows);
        y_max = max(rows);
        
        % Normalize and convert
        x_center = (xPos + (x_min + x_max)/2) / bgWidth;
        y_center = (yPos + (y_min + y_max)/2) / bgHeight;
        width = (x_max - x_min) / bgWidth;
        height = (y_max - y_min) / bgHeight;

        % Array of labels
        [~, imageName, ~] = fileparts(cardImagePath);
        imageNameParts = split(imageName, '_'); 
        label = imageNameParts{1};
        labels{cardIdx} = label;
        
        % Save image
        outputImageName = fullfile(outputFolder, sprintf('%s_%d.png', imageName, bgIdx));
        imwrite(combinedImage, outputImageName);
        disp(['Saved combined image: ', outputImageName]);
        
        % Save bounding box
        bboxFileName = fullfile(outputFolder, sprintf('%s_%d.txt', imageName, bgIdx));
        fid = fopen(bboxFileName, 'w');
        if fid == -1
            error('Could not open file for writing: %s', bboxFileName);
        end
        fprintf(fid, '%d %f %f %f %f\n', cardIdx, x_center, y_center, width, height); 
        fclose(fid);
        disp(['Saved bounding box file: ', bboxFileName]);
    end
end

disp('Image generation and bounding box calculation complete.');