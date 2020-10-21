%% getting input
global fissurenet input_image accuracy
[filename, pathname]=uigetfile('file selector');
a=strcat([pathname filename]);
input_image = double(imread(a))/255;
figure;imshow(input_image,[]);title('input image')

%% preprocessing
gray = (input_image);
%figure;imshow(gray,[]);title('gray image')
Filter= imgaussfilt(gray, 1);
figure;imshow(Filter,[]);title('preprocessed image')
%% edge detection
figure;
imshow(edge(input_image,'Canny'),'InitialMagnification','fit');
title('edge detection')
 %% masking

SRC=im2double(input_image);
In1=SRC(:,:,1);
IN2=SRC(:,:,1);
IN3=SRC(:,:,1);

INP_S_VL=(In1+IN2+IN3)/3;
%figure;
%imshow(INP_S_VL,[]);title('Input image')

SBL_VL = fspecial('sobel');
SBL_VL_INV = SBL_VL';
SB_FLT = imfilter(double(INP_S_VL), SBL_VL, 'replicate');
SB_RPLKT = imfilter(double(INP_S_VL), SBL_VL_INV, 'replicate');
SR_V = sqrt(SB_RPLKT.^2 + SB_FLT.^2);
figure
imshow(SR_V,[]);title('texture edge')

INP_CNV_FLT = deconvwnr(INP_S_VL,SBL_VL);% deblur the filtered image


LN_VAL = watershed(INP_CNV_FLT);% "watershed ridge lines" in an image by treating it as a surface
LBL_IMG = label2rgb(LN_VAL);%Convert the label matrix into RGB image
 %figure
% imshow(LBL_IMG,[]);title('Image Analysis3')

STRL_FUN = strel('disk',20);%morphological operation
IN_BW_OPN = imopen(INP_S_VL, STRL_FUN);% morphologically open the image
 %figure
 %imshow(IN_BW_OPN,[]);title('Image Analysis')
mask = imerode(INP_S_VL, STRL_FUN);
IR_VL = imreconstruct(mask, INP_S_VL);
% figure
 %imshow(IR_VL,[]);hold on
 %title('Image Analysis');
EN_FUN = imclose(IN_BW_OPN, STRL_FUN);

 %figure
% imshow(EN_FUN,[]);hold on;title('Image Analysis');

IMG_DLT = imdilate(IR_VL, STRL_FUN);
IMG_RCNST = imreconstruct(imcomplement(IMG_DLT), imcomplement(IR_VL));
IMG_RCNST = imcomplement(IMG_RCNST);
%figure
%imshow(IMG_RCNST,[]);title('masked 1');

IMG_RGNL_ILM = imregionalmin(IMG_RCNST);
%figure
%imshow(IMG_RGNL_ILM,[]);title('Image Analysis')

FLM_IMG = INP_S_VL;
FLM_IMG(IMG_RGNL_ILM) = 255;
%figure
%imshow(FLM_IMG,[]);title('Image Analysis')

IMG_STRL_FUN = strel(ones(7,7));
IM_FGM2 = imclose(IMG_RGNL_ILM, IMG_STRL_FUN);
IMG_FGM3 = imerode(IM_FGM2, IMG_STRL_FUN);
IMG_FGM4 = bwareaopen(IMG_FGM3, 20);
FNL = INP_S_VL;
FNL(IMG_FGM4) = 255;
%figure
%imshow(FNL,[]);title('Image Analysis')

INP_BND_W = im2bw(IMG_RCNST, graythresh(IMG_RCNST));
%figure
%imshow(INP_BND_W,[]);title('Image Analysis11')

DST_MSRT = bwdist(INP_BND_W);
D_LNGTH = watershed(DST_MSRT);
FNL_FGM_VL = D_LNGTH == 0;
 %figure
% imshow(FNL_FGM_VL,[]);title('Image Analysis12')

GRD_IMP = imimposemin(SR_V, FNL_FGM_VL | IMG_FGM4);
LN_VAL = watershed(GRD_IMP);
I4 = INP_S_VL;
I4(imdilate(LN_VAL == 0, ones(3, 3)) | FNL_FGM_VL | IMG_FGM4) = 255;
 figure
 imshow(I4,[]);title('masked image')

%LBL_IMG = label2rgb(LN_VAL, 'jet', 'w', 'shuffle');
%figure
 %imshow(LBL_IMG,[]);title('Masked image 3')
 
%figure
 %imshow(IN_BW_OPN), hold on
%H_IMG = imshow(LBL_IMG);title('Segmented Image')
%set(H_IMG, 'AlphaData', 0.3);
%IN3=3;
 
%% segmentation
%IMG_RGNL_ILM = imregionalmin(IMG_RCNST);
%IMG_RGNL_ILM=imclearborder(IMG_RGNL_ILM,[])
%figure
%imshow(IMG_RGNL_ILM,[]);title('segmented image')
IMG=double(input_image);
CLM = 2;
[ IN, CEN, NOF ] = fissure( IMG, CLM );
lb = zeros(2,1);
figure;
imshow(IN(:,:,1),[]);title('segmented image 1')
figure
imshow(IN(:,:,2),[]);title('segmented image 2')

%% Extraction
crop=gray(130:440,40:460);
figure;imshow(crop,[]);
Threshold=crop<10;
%figure;imshow(Threshold,[]);
 clearborder=imclearborder(Threshold);
figure;imshow(clearborder,[]);
big_tissue=bwareaopen(clearborder,100);
seg=imcomplement(big_tissue);
 %figure;imshow(big_tissue,[]);title('segmented lung');
 segM=imclearborder(seg);
 BW = im2bw(segM, 0.4);
% figure;imshow(BW,[]);
 big=bwareaopen(BW,70);
 %figure;imshow(big,[]);title('fina extraction')
 c=imfill(big,'holes');
 label=bwlabel(c);
 max(max(label))
 im1=(label==2);
 im2=(label==3);
 im3=(label==5);
  im4=(label==7);
 im5=(label==8);
 im6=(label==9);
 fissurenet= im1 + im2 + im3 + im4 + im5 +im6;
 figure;imshow(fissurenet,[]);title('fissure extraction'); 
depth = clearborder > 0.1 & clearborder < 0.9;
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
    sprintf('abnormal')
elseif op=='Abnormal'
    sprintf('abnormal')
else
    sprintf('normal')
end