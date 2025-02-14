% Randomly place cards from one folder onto backgrounds
% Using convention card naming of 2C_1.png to save labels 2C

% Parameters
cardFolders = ["CardsAlpha/Bicycle-Jumbo", "CardsAlpha/Bicycle-RiderBack", ...
    "CardsAlpha/Bicycle-Standard", "CardsAlpha/Regal-MonacoCasino", "CardsAlpha/SEP"];
backgroundFolder = 'BackgroundsResized/';
outputFolder = 'Results/';

scalingMin = 1/10;
scalingMax = 1/4;

maxCards = 4;

numLoops = 10;

% Image preparation
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

backgroundImages = dir(fullfile(backgroundFolder, '*.jpg')); 
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

% how many generations desired?
for generation = 1:numLoops
    %loop over card sets
    for typeIdx = 1:length(cardFolders)
        cardImages = dir(fullfile(cardFolders(typeIdx), '*.png'));
        if isempty(cardImages)
            error(['No card images found in the folder: ', cardImages]);
        end
    
        %loop over background images
        for bgIdx = 1:length(backgroundImages)
            bgImagePath = fullfile(backgroundFolder, backgroundImages(bgIdx).name);
            bgImage = imread(bgImagePath);
            disp(['Processing background image: ', bgImagePath]);
    
            %generate list of random cards or random length
            numCards = randi([1,maxCards]);
            images = cell(1, length(numCards)); % Preallocate cell array
            alphas = cell(1, length(numCards)); % Preallocate cell array
            idList = cell(1, length(numCards));
            counter = 0;
    
            for i = 1:numCards
                while 1
                    index = randi([1,length(cardImages)]);
                    cardImagePath = fullfile(cardImages(index).folder, cardImages(index).name);
                    [~, imageName, ~] = fileparts(cardImagePath);
                    imageNameParts = split(imageName, '_'); 
                    label = upper(imageNameParts{1});
                    if isKey(cardMap, label)
                        idList{i} = cardMap(label);
                        [img, ~, alpha] = imread(cardImagePath);
                        images{i} = img;
                        alphas{i} = alpha;
                        break;
                    elseif counter == 50
                        error('Loop iterations exceeded expectations');
                    else
                        disp(['Unknown card label: ', label]);
                        counter = counter + 1;
                    end
                end
            end
    
            %random placement style (style 2 tends to cover so not used)
            styles = [1, 3];
            style = styles(randi([1,2]));
    
            %generate image
            [imgOut, data, numReturnedCards] = GenerateImage(bgImage, images, alphas, idList, style, scalingMin, scalingMax);
            
            % Save image
            outputImageName = fullfile(outputFolder, sprintf('%d_%d_%d.png', generation, typeIdx, bgIdx));
            imwrite(imgOut, outputImageName);
            disp(['Saved combined image: ', outputImageName]);
            
            % Save bounding box
            bboxFileName = fullfile(outputFolder, sprintf('%d_%d_%d.txt', generation, typeIdx, bgIdx));
            fid = fopen(bboxFileName, 'w');
            if fid == -1
                error('Could not open file for writing: %s', bboxFileName);
            end
            for line = 1:numReturnedCards
                classID = data{line}(1);
                x_center = data{line}(2);
                y_center = data{line}(3);
                width = data{line}(4);
                height = data{line}(5);
                fprintf(fid, '%d %f %f %f %f\n', classID, x_center, y_center, width, height); 
            end
            fclose(fid);

            if numReturnedCards ~= numCards
                disp(['Check %d_%d_%d', generation, typeIdx, bgIdx])
            end
            disp(['Saved bounding box file: ', bboxFileName]);
        end
    end
end

disp('Image generation and bounding box calculation complete.');