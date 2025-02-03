Set1path='Cards/Bicycle-Jumbo';
Set2path='Cards/Bicycle-RiderBack';
Set3path='Cards/Regal-MonacoCasino';

Save1path='CardsAlpha/Bicycle-Jumbo';
Save2path='CardsAlpha/Bicycle-RiderBack';
Save3path='CardsAlpha/Regal-MonacoCasino';

% Load datasets
Set1 = imageDatastore(Set1path, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

Set2 = imageDatastore(Set2path, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

Set3 = imageDatastore(Set3path, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

% Display dataset information
disp('Set 1 Data:');
disp(Set1);
disp('Set 2 Data:');
disp(Set2);
disp('Set 3 Data:');
disp(Set3);

%Set 1
nImages = numel(Set1.Files);

for i = 1:nImages
    [img, fileinfo] = readimage(Set1, i);
    % fileinfo struct with filename and another field.
    fprintf('Processing %s\n', fileinfo.Filename);
    % extract features
    [imgAlpha, alphaChannel] = keyCard(img);
    [folder, baseFileName, ext] = fileparts(fileinfo.Filename);
    imwrite(imgAlpha, strcat(Save1path, '/', baseFileName, '.png'), 'Alpha', alphaChannel);
end

%Set 2
nImages = numel(Set2.Files);

for i = 1:nImages
    [img, fileinfo] = readimage(Set2, i);
    % fileinfo struct with filename and another field.
    fprintf('Processing %s\n', fileinfo.Filename);
    % extract features
    [imgAlpha, alphaChannel] = keyCard(img);
    [folder, baseFileName, ext] = fileparts(fileinfo.Filename);
    imwrite(imgAlpha, strcat(Save2path, '/', baseFileName, '.png'), 'Alpha', alphaChannel);
end

%Set 3
nImages = numel(Set3.Files);

for i = 1:nImages
    [img, fileinfo] = readimage(Set3, i);
    % fileinfo struct with filename and another field.
    fprintf('Processing %s\n', fileinfo.Filename);
    % extract features
    [imgAlpha, alphaChannel] = keyCard(img);
    [folder, baseFileName, ext] = fileparts(fileinfo.Filename);
    imwrite(imgAlpha, strcat(Save3path, '/', baseFileName, '.png'), 'Alpha', alphaChannel);
end