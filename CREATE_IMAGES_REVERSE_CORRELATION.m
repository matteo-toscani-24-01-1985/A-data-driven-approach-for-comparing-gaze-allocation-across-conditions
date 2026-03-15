close all
clear all
rng(1701)
r=[0 0 1920 1080];
Screen_Height = 30;
ViewingDistance = 74;
PixelsPerCent = r(4)/Screen_Height;
PixPerDeg = round(Deg2Cm(1,ViewingDistance)*PixelsPerCent);
fix2sample=1;

images_per_scene=10000;

 folder=['./reverse_correlation_data/test/'];

mkdir(folder)
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



% THIS COMPUTES HEATH MAPS


  parfor sce=1:10
   % for sce=1:10
        I=IMAGES{sce};
        vline=[];
      
            tmp_train=[];

            %subsin=1:length(F);
            %subsin(pp)=[]; % remove participant out from index in
            %for sub=subsin
              %  tmp_train=[tmp_train;F{sub}{sce,co}(:,3:4)];

            %end

            % TRAIN GETS  1 2, test gets 3
          %  trainInd= find(mod(1:size(F{pp}{sce,co}(:,3:4),1),3)>0);
% testInd= find(mod(1:size(F{pp}{sce,co}(:,3:4),1),3)==0);



          
            make_reverse_corr_images(sce,I,fix2sample,PixPerDeg,images_per_scene,folder)
            

                   end



