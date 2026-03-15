close all
clear all
rng(1701)
r=[0 0 1920 1080];
Screen_Height = 30;
ViewingDistance = 74;
PixelsPerCent = r(4)/Screen_Height;
PixPerDeg = round(Deg2Cm(1,ViewingDistance)*PixelsPerCent);
fix2sample=1;

Subjects={'BBd','IIs','JJc','JJS','MLS','NM1'};
% consistent, random, scrambed, pink, no sound
for s=1:length(Subjects)
    F{s}=ANALYZE(Subjects{s}); % THIS IS EXTRACTING FIXATIONS
end
close all

warning('hard coded - condition consistent vs no sound')
%ImagesPerConditionTest=25000/(length(Subjects)-1);
%ImagesPerConditionTrain=75000/(length(Subjects)-1);


ImagesPerConditionTest=2500/(length(Subjects)-1);
ImagesPerConditionTrain=7500/(length(Subjects)-1);
% compute heat maps
% load images
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
titles={'consistent', 'random', 'scrambled', 'pink', 'no sound'}; % random is same as consistent

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute average heat maps across condition, leave one pp out
% figure('Name','averages - train')
% figure('Name','averages - test')
% for pp=1:length(Subjects)
%     for sce=1:10
%         I=IMAGES{sce};
%         tmp_train=[];
%         tmp_test=[];
%         for co=1:5
%             tmp_train_co=[];
%             tmp_test_co=[];
% 
% 
% allFixationsThisScenePPandCOND=F{pp}{sce,co};
% unitrials=unique(allFixationsThisScenePPandCOND(:,5));
% testrial=unitrials(find(mod(1:length(unitrials),3)==1));
% 
% testInd = find(ismember(allFixationsThisScenePPandCOND(:,5), testrial));
% trainInd = find(~ismember(allFixationsThisScenePPandCOND(:,5), testrial));
% 
% 
%  %              trainInd= find(mod(1:size(F{pp}{sce,co}(:,3:4),1),3)>0);
%  % testInd= find(mod(1:size(F{pp}{sce,co}(:,3:4),1),3)==0); % every 3
% 
%  % TRIAL IS THE SECOND LAST COLUMN
%  %error pd
% tmp_train_co=F{pp}{sce,co}(:,3:4);
% tmp_train_co=tmp_train_co(trainInd,:);
% 
%     tmp_test_co=F{pp}{sce,co}(:,3:4);
%     tmp_test_co=tmp_test_co(testInd,:);
% 
% 
%             tmp_train_co(:,1)=tmp_train_co(:,1)-STARTS(sce,1);
%             tmp_train_co(:,2)=tmp_train_co(:,2)-STARTS(sce,2);
%             heat=zeros(size(I,1),size(I,2));
%             posout = (tmp_train_co(:,2)<=0) | (tmp_train_co(:,1)<=0) | (tmp_train_co(:,2) >size(I,1))| (tmp_train_co(:,1) >size(I,2));
%             tmp_train_co(posout,:)=[];
% 
%             % make tmp test
%             %tmp_test_co=F{pp}{sce,co}(:,3:4);
%             tmp_test_co(:,1)=tmp_test_co(:,1)-STARTS(sce,1);
%             tmp_test_co(:,2)=tmp_test_co(:,2)-STARTS(sce,2);
%             heat=zeros(size(I,1),size(I,2));
%             posout = (tmp_test_co(:,2)<=0) | (tmp_test_co(:,1)<=0) | (tmp_test_co(:,2) >size(I,1))| (tmp_test_co(:,1) >size(I,2));
%             tmp_test_co(posout,:)=[];
% 
%              tmp_train=[tmp_train;tmp_train_co];
%         tmp_test=[tmp_test;tmp_test_co];
%         end
% 
%         heat_train=zeros(size(I,1),size(I,2));
%         for fi=1:size(tmp_train,1)
%                 heat_train(ceil(tmp_train(fi,2)),ceil(tmp_train(fi, 1)))=  heat_train(ceil(tmp_train(fi,2)),ceil(tmp_train(fi, 1)))+1 ;    
%         end
%         heat_train=imgaussfilt(heat_train,PixPerDeg/2);
%         %heat_train = Scale(heat_train);
% 
% % heat test
% heat_test=zeros(size(I,1),size(I,2));
%         for fi=1:size(tmp_test,1)
%                 heat_test(ceil(tmp_test(fi,2)),ceil(tmp_test(fi, 1)))=  heat_test(ceil(tmp_test(fi,2)),ceil(tmp_test(fi, 1)))+1 ;    
%         end
%         heat_test=imgaussfilt(heat_test,PixPerDeg/2);
%         error pd
%         %heat_test = Scale(heat_test);
% AVERAGES{sce,pp,1}=heat_train;
% AVERAGES{sce,pp,2}=heat_test;
% figure(1)
%  subplot(6,10,sce+10*(pp-1))   
%  imshow(Scale(heat_train))
%  figure(2)
%  subplot(6,10,sce+10*(pp-1))   
%  imshow(Scale(heat_test))
%     end
% end


% THIS COMPUTES HEATH MAPS
for pp=1:length(Subjects) % leave one out

  parfor sce=1:10
    %for sce=1:10
        I=IMAGES{sce};
        vline=[];
        for co=[1  5]
            tmp_train=[];

            %subsin=1:length(F);
            %subsin(pp)=[]; % remove participant out from index in
            %for sub=subsin
              %  tmp_train=[tmp_train;F{sub}{sce,co}(:,3:4)];

            %end

            % TRAIN GETS  1 2, test gets 3
          %  trainInd= find(mod(1:size(F{pp}{sce,co}(:,3:4),1),3)>0);
% testInd= find(mod(1:size(F{pp}{sce,co}(:,3:4),1),3)==0);

allFixationsThisScenePPandCOND=F{pp}{sce,co};
unitrials=unique(allFixationsThisScenePPandCOND(:,5));
testrial=unitrials(find(mod(1:length(unitrials),5)==1));

testInd = find(ismember(allFixationsThisScenePPandCOND(:,5), testrial));
trainInd = find(~ismember(allFixationsThisScenePPandCOND(:,5), testrial));

tmp_train=F{pp}{sce,co}(:,3:4);
tmp_train=tmp_train(trainInd,:);

tmp_test=F{pp}{sce,co}(:,3:4);
tmp_test=tmp_test(testInd,:);

            tmp_train(:,1)=tmp_train(:,1)-STARTS(sce,1);
            tmp_train(:,2)=tmp_train(:,2)-STARTS(sce,2);
            heat=zeros(size(I,1),size(I,2));

            posout = (tmp_train(:,2)<=0) | (tmp_train(:,1)<=0) | (tmp_train(:,2) >size(I,1))| (tmp_train(:,1) >size(I,2));
            tmp_train(posout,:)=[];

            % make tmp test




           % tmp_test=F{pp}{sce,co}(:,3:4);


            tmp_test(:,1)=tmp_test(:,1)-STARTS(sce,1);
            tmp_test(:,2)=tmp_test(:,2)-STARTS(sce,2);
            heat=zeros(size(I,1),size(I,2));

            posout = (tmp_test(:,2)<=0) | (tmp_test(:,1)<=0) | (tmp_test(:,2) >size(I,1))| (tmp_test(:,1) >size(I,2));
            tmp_test(posout,:)=[];

            % create train data
            % if exist(['./deep_learning_data_one_out/participant' num2str(pp) '/train/'])==0
            %     mkdir(['./deep_learning_data_one_out/participant' num2str(pp) '/train/'])
            %
            %
            % end
            folder=['./deep_learning_data_one_out_subtract_mean/train/'];

            % conditions 1 and 2 are the same, so if condition is ==1 or 2,
            % samples are half
            if co==1 
            make_random_images(tmp_train,1,sce,I,fix2sample,PixPerDeg,ImagesPerConditionTrain,folder,pp)
            else
                 make_random_images(tmp_train,2,sce,I,fix2sample,PixPerDeg,ImagesPerConditionTrain,folder,pp)
           
            end
            % if exist(['./deep_learning_data_one_out/participant' num2str(pp) '/test/'])==0
            %     mkdir(['./deep_learning_data_one_out/participant' num2str(pp) '/test/'])
            %
            %
            % end
            folder=['./deep_learning_data_one_out_subtract_mean/test/'];
            if co==1 
               make_random_images(tmp_test,1,sce,I,fix2sample,PixPerDeg,ImagesPerConditionTest,folder,pp)

            else
                 make_random_images(tmp_test,2,sce,I,fix2sample,PixPerDeg,ImagesPerConditionTest,folder,pp)


            end
            
           

            disp(['P' num2str(pp) 'I' num2str(sce) 'C' num2str(co)])
        end

    end
end
