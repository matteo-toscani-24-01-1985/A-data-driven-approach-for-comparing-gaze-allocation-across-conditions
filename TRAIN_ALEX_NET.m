%% Train AlexNet-like architecture from scratch for 5-class classification
% Each network corresponds to a specific I value (I1–I10)
% Labels are extracted from filenames like "I2C3S123.png" (network 2, class 3)

clear; clc;

% Parameters
numNetworks = 10;   % I = 1..10
numClasses  = 2;    % C = 1..5

for pp = 1

trainDir = ['./deep_learning_data_one_out_subtract_mean/train'];
testDir  = ['./deep_learning_data_one_out_subtract_mean/test'];

outputDir = ['trained_networks_scratch_participant_subtract_mean' num2str(pp)];
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%pattern = 'I(\d+)C(\d+)S\d+'; % extract I and C from filename
pattern='I(\d+)C(\d+)S(\d+)P(\d+)';
%error('look at the format now that the last is the participant')
%% Define AlexNet-like architecture
inputSize = [227 227 3];
layers = [
    imageInputLayer(inputSize, 'Normalization', 'zerocenter', 'Name', 'input')
    convolution2dLayer(11, 96, 'Stride', 4, 'Padding', 0, 'Name', 'conv1')
    reluLayer('Name', 'relu1')
    crossChannelNormalizationLayer(5, 'Name', 'norm1')
    maxPooling2dLayer(3, 'Stride', 2, 'Name', 'pool1')
    convolution2dLayer(5, 256, 'Padding', 2, 'Name', 'conv2')
    reluLayer('Name', 'relu2')
    crossChannelNormalizationLayer(5, 'Name', 'norm2')
    maxPooling2dLayer(3, 'Stride', 2, 'Name', 'pool2')
    convolution2dLayer(3, 384, 'Padding', 1, 'Name', 'conv3')
    reluLayer('Name', 'relu3')
    convolution2dLayer(3, 384, 'Padding', 1, 'Name', 'conv4')
    reluLayer('Name', 'relu4')
    convolution2dLayer(3, 256, 'Padding', 1, 'Name', 'conv5')
    reluLayer('Name', 'relu5')
    maxPooling2dLayer(3, 'Stride', 2, 'Name', 'pool5')
    fullyConnectedLayer(4096, 'Name', 'fc6')
    reluLayer('Name', 'relu6')
    dropoutLayer(0.5, 'Name', 'drop6')
    fullyConnectedLayer(4096, 'Name', 'fc7')
    reluLayer('Name', 'relu7')
    dropoutLayer(0.5, 'Name', 'drop7')
    fullyConnectedLayer(numClasses, 'Name', 'fc8')
    softmaxLayer('Name', 'softmax')
    classificationLayer('Name', 'output')
];

% Load train and test file lists once
trainFiles = dir(fullfile(trainDir, '*.png'));
testFiles  = dir(fullfile(testDir, '*.png'));

%% Loop over I values
for i = 1:numNetworks
    fprintf('\n=== Training network for I%d ===\n', i);

    %% Select TRAIN files for this I
    filesTrainI = {};
    labelsTrain = [];

    for f = 1:numel(trainFiles)
        fileName = trainFiles(f).name;
        tokens = regexp(fileName, pattern, 'tokens');
        if isempty(tokens), continue; end
        Ival = str2double(tokens{1}{1});
        Cval = str2double(tokens{1}{2});
        if Ival == i
            filesTrainI{end+1} = fullfile(trainDir, fileName);
            labelsTrain(end+1) = Cval;
        end
    end

    %% Select TEST files for this I
    filesTestI = {};
    labelsTest = [];

    for f = 1:numel(testFiles)
        fileName = testFiles(f).name;
        tokens = regexp(fileName, pattern, 'tokens');
        if isempty(tokens), continue; end
        Ival = str2double(tokens{1}{1});
        Cval = str2double(tokens{1}{2});
        if Ival == i
            filesTestI{end+1} = fullfile(testDir, fileName);
            labelsTest(end+1) = Cval;
        end
    end

    if isempty(filesTrainI)
        warning('No training images for I%d — skipping.', i);
        continue;
    end

    % Create datastores
    trainImds = imageDatastore(filesTrainI);
    trainImds.Labels = categorical(labelsTrain(:));

    valImds = imageDatastore(filesTestI);
    valImds.Labels = categorical(labelsTest(:));

    fprintf('Training samples: %d | Validation samples: %d\n', ...
        numel(trainImds.Files), numel(valImds.Files));

    %% Resize + Convert grayscale→RGB
imageAug = imageDataAugmenter( ...
    'RandRotation', [-20 20], ...
    'RandXTranslation', [-10 10], ...
    'RandYTranslation', [-10 10], ...
    'RandXScale', [0.8 1.2], ...
    'RandYScale', [0.8 1.2], ...
    'RandXReflection', true);

 augTrain = augmentedImageDatastore( ...
    inputSize, ...
    trainImds, ...
    'DataAugmentation', imageAug, ...
    'ColorPreprocessing', 'gray2rgb');

augVal = augmentedImageDatastore( ...
    inputSize, ...
    valImds, ...
    'ColorPreprocessing', 'gray2rgb');

    %% Training options
    options = trainingOptions('sgdm', ...
    'MiniBatchSize', 32, ...
    'MaxEpochs', 8, ...
    'InitialLearnRate', 6e-4, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 4, ...
    'Momentum', 0.9, ...
    'L2Regularization', 1e-4, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', augVal, ...
    'ValidationFrequency', 50, ...
    'Verbose', false, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'gpu');



    %% Train Network
    fprintf('Training AlexNet for I%d...\n', i);
    netScratch = trainNetwork(augTrain, layers, options);

    save(fullfile(outputDir, sprintf('alexnet_scratch_I%d.mat', i)), 'netScratch');
end
end
