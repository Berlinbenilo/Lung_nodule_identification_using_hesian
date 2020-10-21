global a input_image% Erase all existing variables. Or clearvars if you want.
% Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 18;
% Read in a standard MATLAB gray scale demo image.
% folder = 'C:\Users\MATLAB\Desktop\anusha-lung';
% baseFileName = 'image.png';
% Get the full filename, with path prepended.
fullFileName = fullfile(a);
% Check if file exists.
if ~exist(fullFileName, 'file')
  % File doesn't exist -- didn't find it there.  Check the search path for it.
  fullFileNameOnSearchPath = input_image; % No path this time.
  if ~exist(fullFileNameOnSearchPath, 'file')
    % Still didn't find it.  Alert user.
    errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
    uiwait(warndlg(errorMessage));
    return;
  end
end
grayImage = imread(fullFileName);
% Get the dimensions of the image.  
% numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(grayImage);
if numberOfColorBands > 1
  % It's not really gray scale like we expected - it's color.
  % Convert it to gray scale by taking only the green channel.
  grayImage = grayImage(:, :, 2); % Take green channel.
end
% Display the original gray scale image.
subplot(2, 2, 1);
imshow(grayImage, []);
% axis on;
title('Original Grayscale Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 
% Binarize, invert, and clear border.
binaryImage = (grayImage < 128);
binaryImage = imclearborder(binaryImage);
subplot(2, 2, 2);
imshow(binaryImage, []);
title('Initial Binary Image', 'FontSize', fontSize);
% axis on;
% Measure sizes
labeledImage = bwlabel(binaryImage);
measurements = regionprops(labeledImage, 'Area');
allAreas = [measurements.Area];
[biggestArea, indexOfBiggest] = sort(allAreas, 'descend');
% Extract largest
biggestBlob = ismember(labeledImage, indexOfBiggest(1));
% Convert to binary
biggestBlob = biggestBlob > 0;
subplot(2, 2, 3);
imshow(biggestBlob, []);
title('Final Binary Image', 'FontSize', fontSize);
% axis on;