clear all
close all

numNetworks = 10;   % I = 1..10
numClasses  =4;   

folder='trained_networks_scratch_participant_subtract_mean1';
folderRandom='trained_networks_scratch_participant_subtract_mean_random1';

trainDir = ['./deep_learning_data_one_out_subtract_mean/train'];
testDir  = ['./deep_learning_data_one_out_subtract_mean/test'];

trainFiles = dir(fullfile(trainDir, '*.png'));
testFiles  = dir(fullfile(testDir, '*.png'));

pattern='I(\d+)C(\d+)S(\d+)P(\d+)';

inputSize = [227 227 3];


disp('DONE WITH BOOTSTRAP - start with means')

for i=1:10 % LOOP OVER IMAGE
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

load(fullfile(folder, sprintf('alexnet_scratch_I%d.mat', i)), 'netScratch');

 
 

    valImds = imageDatastore(filesTestI);
    valImds.Labels = categorical(labelsTest(:));
%% Resize + Convert grayscale→RGB
    % augTrain = augmentedImageDatastore(inputSize, trainImds, ...
    %     'ColorPreprocessing', 'gray2rgb');
    augVal = augmentedImageDatastore(inputSize, valImds, ...
        'ColorPreprocessing', 'gray2rgb');
YPred = classify(netScratch, augVal);
YTest = valImds.Labels;
confusion=zeros(4,4);
for con=1:4
    posreal=find(double(YTest)==con);
    for j=1:length(posreal)
       confusion(con,YPred(posreal(j))) =       confusion(con,YPred(posreal(j))) +1;
    end
   
end

    % do one vs others
    clear accuracy
    for co=1:3
submatrix=confusion([1 (co+1)],[1 (co+1)]);
correct=sum(submatrix(eye(2)==1));
accuracy(co)=correct/sum(submatrix(:));
    end
 
ACCURACIES(i,:)=accuracy;
end
titles={'consistent', 'random', 'scrambled', 'pink', 'no sound'};

error pd
disp('DONE WITH FULL VALIDATIONS - start with random trained')

for i=1:10 % LOOP OVER IMAGE
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

load(fullfile(folderRandom, sprintf('alexnet_scratch_random_I%d.mat', i)), 'netScratch');

 
 

    valImds = imageDatastore(filesTestI);
    valImds.Labels = categorical(labelsTest(:));
%% Resize + Convert grayscale→RGB
    % augTrain = augmentedImageDatastore(inputSize, trainImds, ...
    %     'ColorPreprocessing', 'gray2rgb');
    augVal = augmentedImageDatastore(inputSize, valImds, ...
        'ColorPreprocessing', 'gray2rgb');

     
YPred = classify(netScratch, augVal);
YTest = valImds.Labels;
accuracy = mean(YPred == YTest);
fprintf('Test accuracy: %.2f%%\n', accuracy * 100);
ACTUALACCURACIES_RANDOM(i)=accuracy;


end

%% 
display('BOOTSTRAP RANDOM')
for i=1:10 % LOOP OVER IMAGE
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

load(fullfile(folderRandom, sprintf('alexnet_scratch_random_I%d.mat', i)), 'netScratch');
nrandsam=1000;
nboot=100;
ACCURACIES=nan(nboot,1);
 
for boot=1:nboot
indrand=randsample(1:length(labelsTest),nrandsam);

    valImds = imageDatastore(filesTestI(indrand));
    valImds.Labels = categorical(labelsTest(indrand)');
%% Resize + Convert grayscale→RGB
    % augTrain = augmentedImageDatastore(inputSize, trainImds, ...
    %     'ColorPreprocessing', 'gray2rgb');
    augVal = augmentedImageDatastore(inputSize, valImds, ...
        'ColorPreprocessing', 'gray2rgb');

     
YPred = classify(netScratch, augVal);
YTest = valImds.Labels;
accuracy = mean(YPred == YTest);
fprintf('Test accuracy: %.2f%%\n', accuracy * 100);
ACCURACIES(boot)=accuracy;
end
DISTROS_RAND(i,:)=ACCURACIES;
end

%%

save BOOTSTRAP_RESULTS ACTUALACCURACIES ACTUALACCURACIES_RANDOM DISTROS DISTROS_RAND


lowrand=quantile(DISTROS_RAND(:),.025);
highrand=quantile(DISTROS_RAND(:),1 - (.025));

figure
 violinplot(100*DISTROS',[],'MedianMarkerSize',NaN,'ShowData',false,'ShowWhiskers',false,'ShowBox' ,false,'ViolinColor' ,[0 1 0],'EdgeColor' ,[1 1 1],'ViolinAlpha' ,.25)
hold on
plot([0 11],mean(100*ACTUALACCURACIES_RANDOM)*ones(1,2),'k-','LineWidth',2)
hf=fill([ 0 11 11 0],100*[lowrand lowrand highrand highrand],'r');

hf.FaceAlpha=.2;
hf.EdgeColor="none";
%lowrand=quantile(DISTROS_RAND',.025/10);
%highrand=quantile(DISTROS_RAND',1 - (.025/10));

%plot(1:10,ACTUALACCURACIES_RANDOM,'k-','LineWidth',2)
%hf=fill([1:10 fliplr(1:10)],[lowrand fliplr(highrand)],'r');


for i=1:10
    data=100*DISTROS(i,:);
    meanVal=100*ACTUALACCURACIES(i);
    %errLow=meanVal-quantile(data,.025/10);
     %errHigh=quantile(data,1-(.05/20))-meanVal;
plot(i,meanVal,'ko','MarkerSize',15,'MarkerFaceColor','k')
plot([i i],[quantile(data,.025) quantile(data,1-(.025))],'k-','LineWidth',3)
 %bar(1:10,ACTUALACCURACIES)
hold on
end
box off
set(gca,'LineWidth',3,'XTick',1:10,'XTickLabel',[],'FontSize',20)
ylabel('Accuracy (%)','FontSize',20)