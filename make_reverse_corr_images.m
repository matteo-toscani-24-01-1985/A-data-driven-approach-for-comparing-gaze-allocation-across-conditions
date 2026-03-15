function make_reverse_corr_images(sce,I,fix2sample,PixPerDeg,ImagesPerCondition,folder)

for i=1:ImagesPerCondition
    done =0;
    while done==0
    try
%for i=1:ImagesPerCondition
  %  try
   %pc=round(100*i/ImagesPerCondition);
   %if exist(['./deep_learning_data/I' num2str(sce) 'C' num2str(co) 'S' num2str(i) '.png'])==0
  % if mod(pc,1)==0
    %   disp(pc)
   %end
%    try
% randfixs=tmp(randsample(1:size(tmp,1),fix2sample),:);
%    catch
randfixs=ceil([ rand(fix2sample)*size(I,2) rand(fix2sample)*size(I,1)]);

      
   % 
   %      warning('replacement')
   % end
 heat=zeros(size(I,1),size(I,2));
        for fi=1:size(randfixs,1)
                heat(ceil(randfixs(fi,2)),ceil(randfixs(fi, 1)))=  heat(ceil(randfixs(fi,2)),ceil(randfixs(fi, 1)))+1 ;    
        end

        heat=imgaussfilt(heat,PixPerDeg/2);
        heat = Scale(heat);
        if exist(folder)==0
            mkdir(folder)
        end
      
 imwrite(heat,[folder 'I' num2str(sce) 'C0S' num2str(i) 'P0.png'])
 %  else
   %    warning('already done')
 %  end  
 done=1;
    catch
        done=0;
       % save WS 
   % error porcodio
   warning('not proceeding')
    end
    end
end