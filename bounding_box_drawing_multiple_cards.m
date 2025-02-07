imagePath = '../Results/KD_1.png';
bboxFile = '../Results/KD_1.txt';

% Read the image
img = imread(imagePath);

% Open and read the bounding box file
fileID = fopen(bboxFile, 'r');
bboxData = fscanf(fileID, '%d %f %f %f %f', [5, Inf]); % Read data in columns
fclose(fileID);

% Transpose bboxData for easier indexing
bboxData = bboxData';

% Get the dimensions of the image
[imgHeight, imgWidth, ~] = size(img);

% Display the image
figure;
imshow(img);
hold on;

% Loop through all bounding boxes and draw them
for i = 1:size(bboxData, 1)
    x_center = bboxData(i, 2);
    y_center = bboxData(i, 3);
    width = bboxData(i, 4);
    height = bboxData(i, 5);

    % Convert normalized bounding box to pixel coordinates
    bboxWidth = round(width * imgWidth);
    bboxHeight = round(height * imgHeight);
    xMin = round((x_center * imgWidth) - (bboxWidth / 2));
    yMin = round((y_center * imgHeight) - (bboxHeight / 2));

    % Draw the bounding box
    rectangle('Position', [xMin, yMin, bboxWidth, bboxHeight], 'EdgeColor', 'r', 'LineWidth', 2);
end

hold off;
