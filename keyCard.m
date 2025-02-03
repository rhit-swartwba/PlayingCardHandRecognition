function [output, alpha] = keyCard(img)
    hsv = rgb2hsv(img);
    % Convert image to double for processing
    img = im2double(img);

    % Extract RGB channels
    H = hsv(:,:,1);
    S = hsv(:,:,2);
    V = hsv(:,:,3);
    
    % Create a mask where green dominates
    mask = (H > 0.2 & H < 0.5) & (S > 0.2) & (V > 0.1 & V < 0.8);
    mask = medfilt2(mask, [15 15]);
    mask = imclose(mask, strel('disk', 5));
    
    % Create an output image with an alpha channel
    output = img;
    
    % Convert the mask to an alpha channel
    alphaChannel = ~mask;
    alphaChannel(1:10,:) = 0;
    alphaChannel(end-10:end,:) = 0;

    alpha = double(alphaChannel);
    
    % Apply the mask by setting green pixels to transparent (optional black background)
    output(:,:,1) = img(:,:,1) .* alphaChannel;
    output(:,:,2) = img(:,:,2) .* alphaChannel;
    output(:,:,3) = img(:,:,3) .* alphaChannel;
end