function [img, data, numReturnedCards] = GenerateImage(bgImage, imgList, alphaList, idList, style, scalingMin, scalingMax)

    numCards = length(imgList);
    [bgHeight, bgWidth, ~] = size(bgImage);
    data = cell(1, numCards); % Preallocate cell array

    % Random scaling
    [cardHeight, cardWidth, ~] = size(imgList{1});
    scaleFactor = scalingMin + (scalingMax - scalingMin) * rand;
    newCardHeight = round(bgHeight * scaleFactor);
    aspectRatio = cardWidth / cardHeight;
    newCardWidth = round(newCardHeight * aspectRatio);
    maxDist = floor(sqrt(newCardHeight^2 + newCardWidth^2));

    counter = 0;

    while 1
        % Random initial rotation
        angle = randi([-180, 180]); 
        angleInc = randi([15, 40]);

        %initial position
        coverPercent = randi([50, 110]);
        cover = coverPercent / 100;
        xInc = floor(cos(deg2rad(angle)) * newCardWidth * cover);
        yInc = floor(-sin(deg2rad(angle)) * newCardHeight * cover);
        xRand = randi([0, maxDist]);
        yRand = randi([0, maxDist]);
    
        if style == 1 || style == 2
            xmin = max(-xRand*numCards, 1);
            xmax = bgWidth - maxDist - max(xRand*numCards, 1);
            ymin = max(-yRand*numCards, 1);
            ymax = bgHeight - maxDist - max(yRand*numCards, 1);
            if xmin <= xmax && ymin <= ymax
                xPos = randi([xmin, xmax]);
                yPos = randi([ymin, ymax]);
                break;
            end
        elseif style == 3
            xmin = max(-numCards*xInc, 1);
            xmax = bgWidth - maxDist - max(numCards*xInc, 1);
            ymin = max(-numCards*yInc, 1);
            ymax = bgHeight - maxDist - max(numCards*yInc, 1);
            if xmin <= xmax && ymin <= ymax
                xPos = randi([xmin, xmax]);
                yPos = randi([ymin, ymax]);
                break;
            end
        end
        counter = counter + 1;
        if counter == 50
            if numCards == 1
                error("Cards Too Big");
            else
                numCards = 1;
                counter = 0;
            end
        end
    end
    

    for imgIDX = 1:numCards

        img = imgList{imgIDX};
        alpha = alphaList{imgIDX};
        classID = idList{imgIDX};

        % Making png background white instead of black
        alphaMask = double(alpha) / 255; 
        bgColor = [255, 255, 255]; 
        background = uint8(ones(size(img)) .* reshape(bgColor, [1 1 3]));
        cardImage = uint8(double(img) .* alphaMask + double(background) .* (1 - alphaMask));
       
        % Resizing
        cardImage = imresize(cardImage, [newCardHeight, newCardWidth]);
        alpha = imresize(alpha, [newCardHeight, newCardWidth]);

        % rotate image
        cardImageRotated = imrotate(cardImage, angle, 'bilinear', 'loose');
        alphaRotated = imrotate(alpha, angle, 'bilinear', 'loose');
        [cardHeightRotated, cardWidthRotated, ~] = size(cardImageRotated);
        
        if style == 1
            angle = angle - angleInc;

        elseif style == 2
            angle = angle + angleInc;
              
        end

        
        if cardWidthRotated > bgWidth || cardHeightRotated > bgHeight
            warning('Rotated card image is larger than the background image. Skipping this card.');
            continue;
        end
        
        % Mask
        alphaMaskRotated = double(alphaRotated) / 255;
        bgRegion = bgImage(yPos:yPos+cardHeightRotated-1, xPos:xPos+cardWidthRotated-1, :);
        blendedRegion = uint8(double(cardImageRotated) .* alphaMaskRotated + double(bgRegion) .* (1 - alphaMaskRotated));
        
        % Place the blended region back
        bgImage(yPos:yPos+cardHeightRotated-1, xPos:xPos+cardWidthRotated-1, :) = blendedRegion;
        
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

        data{imgIDX} = [classID, x_center, y_center, width, height];

        % set up next image
        if style == 1 || style == 2
            xPos = xPos + xRand;
            yPos = yPos + yRand;
        elseif style == 3
            xPos = xPos + xInc;
            yPos = yPos + yInc;
        end

    end

    bgImage = im2double(bgImage);

    % Generate random coloration offsets
    colorShift = rand(1, 3) * 0.2 - 0.1;  % Random values between [-0.1, 0.1]
    
    for i = 1:3  % Iterate over R, G, B channels
        bgImage(:,:,i) = bgImage(:,:,i) + colorShift(i);
    end
    bgImage = min(max(bgImage, 0), 1);  % Clip values to [0,1]


    % Generate random shadow polygon
    numPoints = randi([3, 8]);  % Random number of vertices (3-8 for variety)
    x = randi([1, bgWidth], 1, numPoints);  % Random x-coordinates
    y = randi([1, bgHeight], 1, numPoints);  % Random y-coordinates
    
    % Create a shadow mask
    shadowMask = poly2mask(x, y, bgHeight, bgWidth);
    shadowMask = imgaussfilt(double(shadowMask), 15);  % Adjust sigma for softness
    
    % Shadow intensity (0 = completely black, 1 = no change)
    shadowStrength = 0.5 * rand;  % Adjust for darker or lighter shadow
    
    for i = 1:3  % Apply to all color channels
        bgImage(:,:,i) = bgImage(:,:,i) .* (1 - shadowStrength * shadowMask);
    end

    numReturnedCards = numCards;
    img = uint8(bgImage * 255);
end

% bgImage = imread('BackgroundsResized/OIP.jpg');
% 
% cardImages = ["CardsAlpha/Bicycle-Standard/AH.png", "CardsAlpha/Bicycle-Standard/3D.png", "CardsAlpha/Bicycle-Standard/9S.png"];
% images = cell(1, length(cardImages)); % Preallocate cell array
% alphas = cell(1, length(cardImages)); % Preallocate cell array
% 
% for cardIdx = 1:length(cardImages)
%     cardImages(cardIdx)
%     [img, ~, alpha] = imread(cardImages(cardIdx));
%     images{cardIdx} = img;
%     alphas{cardIdx} = alpha;
% end
% 
% [imgOut, data] = GenerateImageT(bgImage, images, alphas, [44, 43, 42], 2, 1/8, 1/3);
% imshow(imgOut)