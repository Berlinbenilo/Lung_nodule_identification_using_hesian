%% read image
global proj big_tissue accuracy
[filename, pathname]=uigetfile('file selector');
a=strcat([pathname filename]);
proj = double(imread(a));
save proj.mat
proj=imresize(proj,[512,512]);
%% apply hesian masking and segmentation
Ivessel=FrangiFilter2D(proj);
figure;imshow(proj,[]);title('input image');
figure;
imshow(Ivessel,[]);title('hessian filter');
crop=Ivessel(130:440,40:460);
figure;imshow(crop,[]);title('cropped image');
Threshold=crop<0.1;
%figure;imshow(Threshold,[]);
clearborder=imclearborder(Threshold);
figure;imshow(clearborder,[]);title('segmented 1')
image=imsubtract(Threshold,clearborder);
figure;imshow(image,[]);title('segmented 2 ')
%% extraction
big_tissue=bwareaopen(clearborder,100);
seg=imcomplement(big_tissue);
c=imfill(big_tissue,'holes');
 BW = im2bw(clearborder, 0.4);
 label=bwlabel(c);
 max(max(label))% length
 im1=(label==2);
 im2=(label==3);
 im3=(label==5);
  im4=(label==7);
 im5=(label==8);
 im6=(label==9);
 extract= im1 + im3 + im4 ;
%figure;imshow(big_tissue,[]);title('hessian extraction ')
figure;imshow(extract,[]);title('extraction ')
depth = clearborder > 0.4 & clearborder < 0.9;
depth = bwareafilt(depth, 1); % Extract largest blob only.
props = regionprops(depth, 'BoundingBox');

%% clasification
imageFolder = fullfile('prediction');
catageries={'normal','Abnormal'}
imds = imageDatastore(fullfile(imageFolder,catageries),'LabelSource', 'foldernames', 'IncludeSubfolders',true);

tbl = countEachLabel(imds);

minSetCount = min(tbl{:,2}); 
%maxNumImages = 5;
%minSetCount = min(maxNumImages,minSetCount);
% Use splitEachLabel method to trim the set.
imds = splitEachLabel(imds, minSetCount, 'randomize');
%countEachLabels(imds)

% Notice that each set now has exactly the same number of images.
countEachLabel(imds)
normal = find(imds.Labels == 'normal', 1);
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
% Display a montage of network weights. There are 96 individual sets of
% weights in the first layer.
%figure
%montage(w1)
%title('First convolutional layer weights')
featureLayer = 'fc1000';
trainingFeatures = activations(net, augmentedTrainingSet, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');
trainingLabels = trainingSet.Labels;

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
confMat = bsxfun(@rdivide,confMat,sum(confMat,2));
accuracy=mean(diag(confMat));

newimage=imread(a);
%process the  image
ds= augmentedImageDatastore(imageSize, newimage, 'ColorPreprocessing', 'gray2rgb');
imagefeature = activations(net, ds, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');

op = predict(classifier,imagefeature, 'ObservationsIn', 'columns');
%sprintf('segment is %s',op)
if accuracy<0.75 && op=='normal'
    sprintf('normal')
elseif op=='Abnormal'
    sprintf('abnormal')
else
    sprintf('normal')
end
    