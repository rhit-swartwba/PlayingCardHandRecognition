imagePath = 'Results/1_1_9.png';
bboxFile = 'Results/1_1_9.txt';

img = imread(imagePath);

fileID = fopen(bboxFile, 'r');
bboxData = fscanf(fileID, '%d %f %f %f %f');
fclose(fileID);

x_center = bboxData(2);
y_center = bboxData(3);
width = bboxData(4);
height = bboxData(5);

[imgHeight, imgWidth, ~] = size(img);

bboxWidth = round(width * imgWidth);
bboxHeight = round(height * imgHeight);
xMin = round((x_center * imgWidth) - (bboxWidth / 2));
yMin = round((y_center * imgHeight) - (bboxHeight / 2));

figure;
imshow(img);
hold on;
rectangle('Position', [xMin, yMin, bboxWidth, bboxHeight], 'EdgeColor', 'r', 'LineWidth', 2);
hold off;