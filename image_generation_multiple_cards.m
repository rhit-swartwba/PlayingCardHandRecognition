% Parameters
cardFolder = '../Dom Cards/';
backgroundFolder = '../BackgroundsResized/';
outputFolder = '../Results/';

scalingMin = 1/4;
scalingMax = 1/3;
fanAngleMin = 12;
fanAngleMax = 20; 
minRandomCards = 1;
maxRandomCards = 5;

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
cardMap = containers.Map({ ...
    '2C', '3C', '4C', '5C', '6C', '7C', '8C', '9C', '10C', 'JC', 'QC', 'KC', 'AC', ... % Clubs
    '2D', '3D', '4D', '5D', '6D', '7D', '8D', '9D', '10D', 'JD', 'QD', 'KD', 'AD', ... % Diamonds
    '2H', '3H', '4H', '5H', '6H', '7H', '8H', '9H', '10H', 'JH', 'QH', 'KH', 'AH', ... % Hearts
    '2S', '3S', '4S', '5S', '6S', '7S', '8S', '9S', '10S', 'JS', 'QS', 'KS', 'AS'  ... % Spades
}, 0:51);

for bgIdx = 1:1 % Process each background image
    bgImagePath = fullfile(backgroundFolder, backgroundImages(bgIdx).name);
    bgImage = imread(bgImagePath);
    [bgHeight, bgWidth, ~] = size(bgImage);
    disp(['Processing background image: ', bgImagePath]);

    for cardIdx1 = 1:length(cardImages) % Loop through the primary cards
        % Load the primary card image
        cardImagePath1 = fullfile(cardFolder, cardImages(cardIdx1).name);
        [img1, ~, alpha1] = imread(cardImagePath1);

        % Making png background white instead of black
        alphaMask1 = double(alpha1) / 255;
        bgColor = [255, 255, 255];
        background1 = uint8(ones(size(img1)) .* reshape(bgColor, [1 1 3]));
        cardImage1 = uint8(double(img1) .* alphaMask1 + double(background1) .* (1 - alphaMask1));

        % Random scaling for the primary card
        scaleFactor = scalingMin + (scalingMax - scalingMin) * rand;
        newCardHeight = round(bgHeight * scaleFactor);
        aspectRatio1 = size(cardImage1, 2) / size(cardImage1, 1);
        cardImage1 = imresize(cardImage1, [newCardHeight, round(newCardHeight * aspectRatio1)]);
        alpha1 = imresize(alpha1, [newCardHeight, round(newCardHeight * aspectRatio1)]);

        % Random rotation and placement for the primary card
        angle = randi([-180, 180]);
        cardImage1Rotated = imrotate(cardImage1, angle, 'bilinear', 'loose');
        alpha1Rotated = imrotate(alpha1, angle, 'bilinear', 'loose');
        [cardHeight1, cardWidth1, ~] = size(cardImage1Rotated);
        xPos = randi([1, bgWidth - cardWidth1 + 1]);
        yPos = randi([1, bgHeight - cardHeight1 + 1]);

        % Initialize combined image and bounding box data
        combinedImage = bgImage;

        % Place the primary card
        alphaMask1Rotated = double(alpha1Rotated) / 255;
        bgRegion1 = combinedImage(yPos:yPos+cardHeight1-1, xPos:xPos+cardWidth1-1, :);
        blendedRegion1 = uint8(double(cardImage1Rotated) .* alphaMask1Rotated + double(bgRegion1) .* (1 - alphaMask1Rotated));
        combinedImage(yPos:yPos+cardHeight1-1, xPos:xPos+cardWidth1-1, :) = blendedRegion1;

        % Calculate bounding box for the primary card
        [rows1, cols1] = find(alpha1Rotated > 0);
        x_min1 = min(cols1);
        x_max1 = max(cols1);
        y_min1 = min(rows1);
        y_max1 = max(rows1);
        x_center1 = (xPos + (x_min1 + x_max1)/2) / bgWidth;
        y_center1 = (yPos + (y_min1 + y_max1)/2) / bgHeight;
        width1 = (x_max1 - x_min1) / bgWidth;
        height1 = (y_max1 - y_min1) / bgHeight;

        % Get class ID for the primary card
        [~, imageName1, ~] = fileparts(cardImagePath1);
        label1 = split(imageName1, '_');
        classID1 = cardMap(label1{1});

        % Write the primary card bounding box
        bboxData = sprintf('%d %f %f %f %f\n', classID1, x_center1, y_center1, width1, height1);

        % Generate between 1 and 5 additional random cards
        numAdditionalCards = randi([minRandomCards, maxRandomCards]);
        randomCardIndices = randperm(length(cardImages), numAdditionalCards);
        randomCardIndices(randomCardIndices == cardIdx1) = []; % Avoid duplicating the primary card

        for i = 1:length(randomCardIndices)
            cardIdx2 = randomCardIndices(i);

            % Load additional card image
            cardImagePath2 = fullfile(cardFolder, cardImages(cardIdx2).name);
            [img2, ~, alpha2] = imread(cardImagePath2);

            % Making png background white instead of black
            alphaMask2 = double(alpha2) / 255;
            background2 = uint8(ones(size(img2)) .* reshape(bgColor, [1 1 3]));
            cardImage2 = uint8(double(img2) .* alphaMask2 + double(background2) .* (1 - alphaMask2));

            % Random scaling and placement
            newCardHeight = round(bgHeight * scaleFactor);
            aspectRatio2 = size(cardImage2, 2) / size(cardImage2, 1);
            cardImage2 = imresize(cardImage2, [newCardHeight, round(newCardHeight * aspectRatio2)]);
            alpha2 = imresize(alpha2, [newCardHeight, round(newCardHeight * aspectRatio2)]);

            angle = angle - randi([fanAngleMin, fanAngleMax]);
            cardImage2Rotated = imrotate(cardImage2, angle, 'bilinear', 'loose');
            alpha2Rotated = imrotate(alpha2, angle, 'bilinear', 'loose');
            [cardHeight2, cardWidth2, ~] = size(cardImage2Rotated);

            % xPos2 = randi([1, bgWidth - cardWidth2 + 1]);
            % yPos2 = randi([1, bgHeight - cardHeight2 + 1]);

            xPos2 = min(max(1, xPos), bgWidth - cardWidth2);
            yPos2 = min(max(1, yPos), bgHeight - cardHeight2);

            % Blend additional card onto the background
            alphaMask2Rotated = double(alpha2Rotated) / 255;
            bgRegion2 = combinedImage(yPos2:yPos2+cardHeight2-1, xPos2:xPos2+cardWidth2-1, :);
            blendedRegion2 = uint8(double(cardImage2Rotated) .* alphaMask2Rotated + double(bgRegion2) .* (1 - alphaMask2Rotated));
            combinedImage(yPos2:yPos2+cardHeight2-1, xPos2:xPos2+cardWidth2-1, :) = blendedRegion2;

            % Calculate bounding box for the additional card
            [rows2, cols2] = find(alpha2Rotated > 0);
            x_min2 = min(cols2);
            x_max2 = max(cols2);
            y_min2 = min(rows2);
            y_max2 = max(rows2);
            x_center2 = (xPos2 + (x_min2 + x_max2)/2) / bgWidth;
            y_center2 = (yPos2 + (y_min2 + y_max2)/2) / bgHeight;
            width2 = (x_max2 - x_min2) / bgWidth;
            height2 = (y_max2 - y_min2) / bgHeight;

            % Get class ID for the additional card
            [~, imageName2, ~] = fileparts(cardImagePath2);
            label2 = split(imageName2, '_');
            classID2 = cardMap(label2{1});

            % Append bounding box data
            bboxData = sprintf('%s%d %f %f %f %f\n', bboxData, classID2, x_center2, y_center2, width2, height2);
        end

        % Save the output image
        outputImageName = fullfile(outputFolder, sprintf('%s_%d.png', imageName1, bgIdx));
        imwrite(combinedImage, outputImageName);

        % Save bounding boxes
        bboxFileName = fullfile(outputFolder, sprintf('%s_%d.txt', imageName1, bgIdx));
        fid = fopen(bboxFileName, 'w');
        if fid == -1
            error('Could not open file for writing: %s', bboxFileName);
        end
        fprintf(fid, '%s', bboxData);
        fclose(fid);
    end
end

disp('Image generation and bounding box calculation complete.');
