%% Classify all test images with each trained network (I1–I10)

clear; clc;
pattern='I(\d+)C(\d+)S(\d+)P(\d+)';

numNetworks = 10;
inputSize   = [227 227 3];

netDir  = './trained_networks_scratch_participant_subtract_mean1';
testDir = './deep_learning_data_one_out_subtract_mean/train';

% Load all test images once

% Store results: rows = images, cols = networks
classification_matrix = zeros(18000, 10);



%% Loop over networks
for i = 1:numNetworks
testFiles = dir(fullfile(testDir, ['I' num2str(i) 'C*']));
numTest   = numel(testFiles);

% 
% Create datastore
testImds = imageDatastore(fullfile(testDir, {testFiles.name}));

% Resize + grayscale → RGB (same preprocessing as training)
augTest = augmentedImageDatastore(inputSize, testImds, ...
    'ColorPreprocessing', 'gray2rgb');

     
    fprintf('Classifying with network I%d...\n', i);

    % Load network
    netFile = fullfile(netDir, sprintf('alexnet_scratch_I%d.mat', i));
    S = load(netFile);       % loads netScratch
    net = S.netScratch;

    % Classify
    predictedLabels = classify(net, augTest, ...
        'MiniBatchSize', 256, ...
        'ExecutionEnvironment', 'gpu');

    % Convert categorical → binary (0/1)
    % assuming classes are {1,2}
    classification_matrix(:, i) = double(predictedLabels == categorical(2));
end
save classification_matrix_realfix classification_matrix
%% Result
% classification_matrix(img, network) ∈ {0,1}
disp('Done.');


%% USE CLSSIFICSTION MATRIX TO PUT GENERATE IMAGES
%testFiles is in  the corret order
r=[0 0 1920 1080];
imagesList=dir('./images/*.png');
%imagesList=imagesList(10:end);
% THIS RECOVERS HOW IMAGES WERE PRESENTED ON SCREEN
for im=1:length(imagesList)
    I=imread(['./images/' imagesList(im).name]);
    sizes(:,im)=size(I);
end


for sce=1:10
    I=imread(['./images/' imagesList(sce).name]);
    staX= round((r(3)-sizes(2,sce))/2);
    enX=staX+sizes(2,sce)-1;
    staY= round((r(4)-sizes(1,sce))/2);
    enY=staY+sizes(1,sce)-1;
    STARTS(sce,:)=[staX staY];
    I=imresize(I,[enY-staY enX-staX]);
    IMAGES{sce}=I;
end
for im=1:10
    testFiles = dir(fullfile(testDir, ['I' num2str(im) 'C*']));
    pos1= find(classification_matrix(:,im)==0);
    pos2= find(classification_matrix(:,im)==1);
    % sum all imgs 1
    IMG1=zeros(size(IMAGES{im},1),size(IMAGES{im},2));
    for i=1:length(pos1)
        iname=testFiles(pos1(i)).name;
        I=imread([testDir '/' iname]);
        IMG1=IMG1+double(I)/255;
    end
IMAGES_SUM{im,1}=IMG1;


IMG2=zeros(size(IMAGES{im},1),size(IMAGES{im},2));
    for i=1:length(pos2)
        iname=testFiles(pos2(i)).name;
        I=imread([testDir '/' iname]);
        IMG2=IMG2+double(I)/255;
    end
IMAGES_SUM{im,2}=IMG2;
disp(im)
end
save REVERSE_CORRELATION_REAL_FIX


%% plot heatmaps
figure
for im=1:10
    I=IMAGES{im};
    h1=IMAGES_SUM{im,1};
    h2=IMAGES_SUM{im,2};
    %hd= (h1-h2)./(h1+h2);
    hd=zscore(h1)-zscore(h2);
   % Iov=heatmap_overlay(I,Scale(hd),'jet',2);
    Iov=heatmap_overlay(I,Scale(hd));
subplot(2,5,im)
imshow(Scale(Iov))
end


figure
for im=1:10
    I=IMAGES{im};
    h1=IMAGES_SUM{im,1};
    h2=IMAGES_SUM{im,2};
    % hd= (h1-h2)./(abs(h1)+abs(h2));
    % hd=hd-nanmin(hd(:));
    % hd=hd/nanmax(hd(:));
    % hd(isnan(hd))=0;
    h1=h1/sum(h1(:));
    h2=h2/sum(h2(:));
    zeropos= h2==0 & h1==0;
    hd=   h1-h2;
    hd(zeropos)=0;
    
   %hd=h1-h2;
    %hd=Scale(h2);
   % Iov=heatmap_overlay(I,Scale(hd),'jet',2);
    %Iov=heatmap_overlay(I,Scale(hd));
    hd=hd/max(abs(hd(:)));
    hd=tanh(5*hd);
    Iov=overlaySignedHeatmap(I,hd,.5);

subplot(2,5,im)
imshow(Scale(Iov))
end