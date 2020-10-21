function varargout = anusha(varargin)
% ANUSHA MATLAB code for anusha.fig
%      ANUSHA, by itself, creates a new ANUSHA or raises the existing
%      singleton*.
%
%      H = ANUSHA returns the handle to a new ANUSHA or the handle to
%      the existing singleton*.
%
%      ANUSHA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANUSHA.M with the given input arguments.
%
%      ANUSHA('Property','Value',...) creates a new ANUSHA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before anusha_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to anusha_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help anusha

% Last Modified by GUIDE v2.5 03-Sep-2019 04:58:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @anusha_OpeningFcn, ...
                   'gui_OutputFcn',  @anusha_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before anusha is made visible.
function anusha_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to anusha (see VARARGIN)

% Choose default command line output for anusha
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes anusha wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = anusha_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global input_image
global gray
gray=rgb2gray(input_image);
axes(handles.axes2);
imshow(gray,[]);title('Gray Image');
figure;imshow(gray)

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gray
Filter= imgaussfilt(gray, 1);
%Filter = imsmooth(gray, 'Gaussian', 1.00);
axes(handles.axes2);
imshow(Filter,[]);title('Filtered Image');
figure;imshow(Filter)

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global input_image a
[filename, pathname]=uigetfile('file selector');
a=strcat([pathname filename]);
input_image = double(imread(a))/255;
axes(handles.axes1);
imshow(input_image);title('Input Image');
figure;imshow(input_image)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global input_image
n1 = input_image(:, 1 : end/2);
n2 = input_image(:, end/2+1 : end );

SRC=im2double(input_image);
In1=SRC(:,:,1);
IN2=SRC(:,:,1);
IN3=SRC(:,:,1);


INP_S_VL=(In1+IN2+IN3)/3;
% axes(handles.axes2);
imshow(INP_S_VL);title('Image Analysis')

SBL_VL = fspecial('sobel');
SBL_VL_INV = SBL_VL';
SB_FLT = imfilter(double(INP_S_VL), SBL_VL, 'replicate');
SB_RPLKT = imfilter(double(INP_S_VL), SBL_VL_INV, 'replicate');
SR_V = sqrt(SB_RPLKT.^2 + SB_FLT.^2);
% axes(handles.axes2);
imshow(SR_V,[]);title('Image Analysis')

INP_CNV_FLT = deconvwnr(INP_S_VL,SBL_VL);

LN_VAL = watershed(INP_CNV_FLT);
LBL_IMG = label2rgb(LN_VAL);
% axes(handles.axes2);
imshow(LBL_IMG);title('Image Analysis')

STRL_FUN = strel('disk',20);
IN_BW_OPN = imopen(INP_S_VL, STRL_FUN);
%  axes(handles.axes2);
 imshow(IN_BW_OPN);title('Image Analysis')
IS_VL = imerode(INP_S_VL, STRL_FUN);
IR_VL = imreconstruct(IS_VL, INP_S_VL)
%  axes(handles.axes2);
 imshow(IR_VL);title('Image Analysis')
EN_FUN = imclose(IN_BW_OPN, STRL_FUN);

%  axes(handles.axes2);
 imshow(EN_FUN);title('Image Analysis')

IMG_DLT = imdilate(IR_VL, STRL_FUN);
IMG_RCNST = imreconstruct(imcomplement(IMG_DLT), imcomplement(IR_VL));
IMG_RCNST = imcomplement(IMG_RCNST);
%  axes(handles.axes2);
 imshow(IMG_RCNST);title('Image Analysis')

IMG_RGNL_ILM = imregionalmin(IMG_RCNST);
% axes(handles.axes2);
imshow(IMG_RGNL_ILM);title('Image Analysis')

FLM_IMG = INP_S_VL;
FLM_IMG(IMG_RGNL_ILM) = 255;
% axes(handles.axes2);
imshow(FLM_IMG);title('Image Analysis')

IMG_STRL_FUN = strel(ones(7,7));
IM_FGM2 = imclose(IMG_RGNL_ILM, IMG_STRL_FUN);
IMG_FGM3 = imerode(IM_FGM2, IMG_STRL_FUN);
IMG_FGM4 = bwareaopen(IMG_FGM3, 20);
FNL = INP_S_VL;
FNL(IMG_FGM4) = 255;
% axes(handles.axes2);
imshow(FNL);title('Image Analysis')

INP_BND_W = im2bw(IMG_RCNST, graythresh(IMG_RCNST));
% axes(handles.axes2);
imshow(INP_BND_W);title('Image Analysis')

DST_MSRT = bwdist(INP_BND_W);
D_LNGTH = watershed(DST_MSRT);
FNL_FGM_VL = D_LNGTH == 0;
%  axes(handles.axes2);
 imshow(FNL_FGM_VL);title('Image Analysis')

GRD_IMP = imimposemin(SR_V, FNL_FGM_VL | IMG_FGM4);
LN_VAL = watershed(GRD_IMP);
I4 = INP_S_VL;
I4(imdilate(LN_VAL == 0, ones(3, 3)) | FNL_FGM_VL | IMG_FGM4) = 255;
%  axes(handles.axes2);
 imshow(I4);title('Imege Analysis')

LBL_IMG = label2rgb(LN_VAL, 'jet', 'w', 'shuffle');
%  axes(handles.axes2);
 imshow(LBL_IMG);title('Image Analysis')
 
% axes(handles.axes2)
 imshow(IN_BW_OPN), hold on
H_IMG = imshow(LBL_IMG);title('Segmented Image')
set(H_IMG, 'AlphaData', 0.3);
IN3=3;

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global IMG
global input_image;
IMG=double(rgb2gray(input_image));
CLM = 2;
[ IN, CEN, NOF ] = SUB_FUN8( IMG, CLM );
lb = zeros(2,1);
figure;
imshow(IN(:,:,1),[]);title('segmented image 1')
figure
imshow(IN(:,:,2),[]);title('segmented image 2')


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gray
global V2
Ip = single(gray);
thr = prctile(Ip(Ip(:)>0),1) * 0.9;
Ip(Ip<=thr) = thr;
Ip = Ip - min(Ip(:));
Ip = Ip ./ max(Ip(:));    

% compute enhancement for two different tau values
V1 = vesselness2D(Ip, 0.5:0.5:2.5, [1;1], 1, false);
V2 = vesselness2D(Ip, 0.5:0.5:2.5, [1;1], 0.5, false);
figure; 
imshow(V1,[])
title('Enhanced Image for tau=1')

figure; 
imshow(V2,[])
axes(handles.axes2);
imshow(V2,[])
title('Enhanced Image for tau=0.5')


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global input_image a
run masking.m
