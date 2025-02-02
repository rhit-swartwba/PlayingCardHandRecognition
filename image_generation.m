% Randomly place cards from one folder onto backgrounds
% Using convention card naming of 2C_1.png to save labels 2C

% Parameters
cardFolder = '../BlaiseCards/';
backgroundFolder = '../BackgroundsResized/';
outputFolder = '../Results/';

scalingMin = 1/4;
scalingMax = 1/3;

% Image preparation
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

cardImages = dir(fullfile(cardFolder, '*.png')); 
backgroundImages = dir(fullfile(backgroundFolder, '*.jpg')); 

if isempty(cardImages)
    error('No card images found in the specified folder.');
end
if isempty(backgroundImages)
    error('No background images found in the specified folder.');
end

% Hashtable
labels = cell(1, length(cardImages)*length(backgroundImages));
labelIdx = 1;

cardMap = containers.Map({ ...
    '2C', '3C', '4C', '5C', '6C', '7C', '8C', '9C', '10C', 'JC', 'QC', 'KC', 'AC', ... % Clubs
    '2D', '3D', '4D', '5D', '6D', '7D', '8D', '9D', '10D', 'JD', 'QD', 'KD', 'AD', ... % Diamonds
    '2H', '3H', '4H', '5H', '6H', '7H', '8H', '9H', '10H', 'JH', 'QH', 'KH', 'AH', ... % Hearts
    '2S', '3S', '4S', '5S', '6S', '7S', '8S', '9S', '10S', 'JS', 'QS', 'KS', 'AS'  ... % Spades
}, 0:51);

% Loop
for bgIdx = 1:length(backgroundImages)
    bgImagePath = fullfile(backgroundFolder, backgroundImages(bgIdx).name);
    bgImage = imread(bgImagePath);
    [bgHeight, bgWidth, ~] = size(bgImage);
    disp(['Processing background image: ', bgImagePath]);
    
    for cardIdx = 1:length(cardImages)
        cardImagePath = fullfile(cardFolder, cardImages(cardIdx).name);
        [img, ~, alpha] = imread(cardImagePath);

        % Making png background white instead of black
        alphaMask = double(alpha) / 255; 
        bgColor = [255, 255, 255]; 
        background = uint8(ones(size(img)) .* reshape(bgColor, [1 1 3]));
        cardImage = uint8(double(img) .* alphaMask + double(background) .* (1 - alphaMask));

        [cardHeight, cardWidth, ~] = size(cardImage);
        disp(['Processing card image: ', cardImagePath]);
        
        % Random scaling
        scaleFactor = scalingMin + (scalingMax - scalingMin) * rand;
        newCardHeight = round(bgHeight * scaleFactor);
        aspectRatio = cardWidth / cardHeight;
        newCardWidth = round(newCardHeight * aspectRatio);

        % Resizing
        cardImage = imresize(cardImage, [newCardHeight, newCardWidth]);
        alpha = imresize(alpha, [newCardHeight, newCardWidth]);

        [cardHeight, cardWidth, ~] = size(cardImage);
        
        % Random rotation
        angle = randi([-180, 180]);   
        cardImageRotated = imrotate(cardImage, angle, 'bilinear', 'loose');
        alphaRotated = imrotate(alpha, angle, 'bilinear', 'loose');
        [cardHeightRotated, cardWidthRotated, ~] = size(cardImageRotated);
        
        if cardWidthRotated > bgWidth || cardHeightRotated > bgHeight
            warning('Rotated card image is larger than the background image. Skipping this card.');
            continue;
        end
        
        % Random Placement
        xPos = randi([1, bgWidth - cardWidthRotated + 1]);
        yPos = randi([1, bgHeight - cardHeightRotated + 1]);
        
        % Mask
        alphaMaskRotated = double(alphaRotated) / 255;
        bgRegion = bgImage(yPos:yPos+cardHeightRotated-1, xPos:xPos+cardWidthRotated-1, :);
        blendedRegion = uint8(double(cardImageRotated) .* alphaMaskRotated + double(bgRegion) .* (1 - alphaMaskRotated));
        
        % Place the blended region back
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

        if isKey(cardMap, label)
            classID = cardMap(label);
        else
            error('Unknown card label: %s', label);
        end

        % Store class ID in labels array
        labels{labelIdx} = classID;
        
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
        fprintf(fid, '%d %f %f %f %f\n', classID, x_center, y_center, width, height); 
        fclose(fid);
        disp(['Saved bounding box file: ', bboxFileName]);
    end
end

disp('Image generation and bounding box calculation complete.');
