
imageFolder = fullfile('prediction');
imds = imageDatastore(imageFolder, 'LabelSource', 'foldernames', 'IncludeSubfolders',true);

%imshow(readimage(imds,daisy))
tbl = countEachLabel(imds)

minSetCount = min(tbl{:,2}); 
%maxNumImages = 5;
%minSetCount = min(maxNumImages,minSetCount);
% Use splitEachLabel method to trim the set.
imds = splitEachLabel(imds, minSetCount, 'randomize');
%countEachLabels(imds)

% Notice that each set now has exactly the same number of images.
countEachLabel(imds)
Normal = find(imds.Labels == 'Normal', 1);
Abnormal = find(imds.Labels == 'Abnormal', 1);




net = resnet50();
net.Layers(1)
% plot(net)
% set(gca,'YLim',[150,170]);
net.Layers(end)
% Number of class names for ImageNet classification task
numel(net.Layers(end).ClassNames)
%to tarin and test
[trainingSet, testSet] = splitEachLabel(imds, 0.3, 'randomize');
imageSize = net.Layers(1).InputSize;
augmentedTrainingSet = augmentedImageDatastore(imageSize, trainingSet, 'ColorPreprocessing', 'gray2rgb');
augmentedTestSet = augmentedImageDatastore(imageSize, testSet, 'ColorPreprocessing', 'gray2rgb');
w1 = net.Layers(2).Weights;

% Scale and resize the weights for visualization
w1 = mat2gray(w1);
w1 = imresize(w1,5); 




% Display a montage of network weights. There are 96 individual sets of
% weights in the first layer.
%figure
%montage(w1)
%title('First convolutional layer weights')
featureLayer = 'fc1000';
trainingFeatures = activations(net, augmentedTrainingSet, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');
trainingLabels = trainingSet.Labels;

% Train multiclass SVM classifier using a fast linear solver, and set
% 'ObservationsIn' to 'columns' to match the arrangement used for training
% features.
classifier = fitcecoc(trainingFeatures, trainingLabels, ...
    'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');
testFeatures = activations(net, augmentedTestSet, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');

% Pass CNN image features to trained classifier
predictedLabels = predict(classifier, testFeatures, 'ObservationsIn', 'columns');

% Get the known labels
testLabels = testSet.Labels;

% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);

% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))
mean(diag(confMat))
%newimage=imread(x);
%process the  image
ds= augmentedImageDatastore(imageSize, x, 'ColorPreprocessing', 'gray2rgb');
imagefeature = activations(net, ds, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');

op = predict(classifier,imagefeature, 'ObservationsIn', 'columns');
sprintf('segment is:%s',op)

% testImage = readimage(testSet,1);
% testLabel = testSet.Labels(1)
% 
% ds = augmentedImageDatastore(imageSize, testImage, 'ColorPreprocessing', 'gray2rgb');
% 
% % Extract image features using the CNN
% imageFeatures = activations(net, ds, featureLayer, 'OutputAs', 'columns');
% 
% predictedLabel = predict(classifier, imageFeatures, 'ObservationsIn', 'columns')
