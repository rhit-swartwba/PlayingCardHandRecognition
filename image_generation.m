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
    
    for cardIdx = 1:2
        
        cardImagePath = fullfile(cardFolder, cardImages(cardIdx).name);
        [img, ~, alpha] = imread(cardImagePath);

        % Making png background white instead of black
        alphaMask = double(alpha) / 255; 
        bgColor = [255, 255, 255]; 
        background = uint8(ones(size(img)) .* reshape(bgColor, [1 1 3]));
        cardImage = uint8(double(img) .* alphaMask + double(background) .* (1 - alphaMask));

        [cardHeight, cardWidth, ~] = size(cardImage);
        disp(['Processing card image: ', cardImagePath]);
        
        if cardWidth > bgWidth || cardHeight > bgHeight
            warning('Card image is larger than the background image. Skipping this card.');
            continue;
        end
        
        % Random position
        xPos = randi([1, bgWidth - cardWidth + 1]);
        yPos = randi([1, bgHeight - cardHeight + 1]);
        
        % Placing card
        combinedImage = bgImage;
        combinedImage(yPos:yPos+cardHeight-1, xPos:xPos+cardWidth-1, :) = cardImage;
        
        % Calculate the relative bounding box [x_center, y_center, width, height]
        x_center = (xPos + cardWidth/2) / bgWidth;
        y_center = (yPos + cardHeight/2) / bgHeight;
        width = cardWidth / bgWidth;
        height = cardHeight / bgHeight;

        % Rotation

        % Array of labels
        [~, imageName, ~] = fileparts(cardImagePath);
        labels{cardIdx} = imageName;
        
        % Save image
        outputImageName = fullfile(outputFolder, sprintf('combined_%d_%d.png', bgIdx, cardIdx));
        imwrite(combinedImage, outputImageName);
        disp(['Saved combined image: ', outputImageName]);
        
        % Save bounding box
        bboxFileName = fullfile(outputFolder, sprintf('combined_%d_%d.txt', bgIdx, cardIdx));
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