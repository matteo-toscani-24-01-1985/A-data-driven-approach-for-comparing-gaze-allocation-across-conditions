function ALL_FIX=ANALYZE(filename)

load(['./DATA/' filename '.mat'],'RESPONSES')

Fixations=ExtractFixations(filename);


imagesList=dir('./images/*.png');
%imagesList=imagesList(10:end);
   for im=1:length(imagesList)
        I=imread(['./images/' imagesList(im).name]);
     
        sizes(:,im)=size(I);
    end

r=[0 0 1920 1080];
titles={'consistent', 'random', 'scrambled', 'pink', 'no sound'};
for sce=1:10
I=imread(['./images/' imagesList(sce).name]);
 staX= round((r(3)-sizes(2,sce))/2);
    enX=staX+sizes(2,sce)-1;

    staY= round((r(4)-sizes(1,sce))/2);
    enY=staY+sizes(1,sce)-1;


    I=imresize(I,[enY-staY enX-staX]);

    figure
    for co=1:5 % consistent, random, scrambed, pink, no sound
 
subplot(2,3,co)

    pos=find( (RESPONSES.TABLE(:,1)==sce) & (RESPONSES.TABLE(:,2)==co));
% collect all trial
allfix=[];
for t=1:length(pos)
    postmp = find(Fixations(:,end)==pos(t));
ftmp=Fixations(postmp,:);
allfix=[allfix;[ftmp (1:size(ftmp,1))']];
end


imshow(I)
hold on
plot(allfix(:,3),allfix(:,4),'ro','markersize',15,'markerfacecolor','r')
title(titles{co})

ALL_FIX{sce,co}=allfix;
    end
end

   
