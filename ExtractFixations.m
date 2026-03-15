%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ EYE MOVEMENTS: DISTANCES FROM THE CENTER OF THE  SCREEN    %
% For saccades (end and start positions) and fixations            %
%
% ========
% INPUTS :
% ========
% filename  -> file .mat and .asc , same directory
% 
% ========
% OUTPUT :
% ========
% FIXATIONS(x,y,TRIAL) array
% 
%
% MT 25/12/2010
 
% GET FIXATIONS 

 % get id at start, than if you get trialid -1 and "SLOW_TRIAL" skip the
 % trial
 
function FIXATIONS=ExtractFixations(filename)
fclose all;
if nargin <1;filename='101';end
fid=fopen(['./DATA/' filename '.asc']);

% SAVE starts =0
% save recording or not: if start happens - SAVE=1, if end happens, SAVE=0
% if SAVE changes the trial number changes. TN starts with zero.
% read line if saccade or fixation

SAVE=0;
oldSAVE=0;
TN= 0;
TN_check=0;
countFix=0;
countSacc=0;
FIXATIONS=[];
SACCADES=[];
while ~feof(fid)
    Line_tmp = fgetl(fid);
    % check if it includes START
    if contains(Line_tmp,'START') & contains(Line_tmp,'trialid')
        SAVE=1;
        Line_sgm=segmentline(Line_tmp);
        if strcmp(Line_sgm{3},'trialid')==0
            error('trial id not found')
        end
        TN_check=str2num(Line_sgm{4});
         % check if it's changing from no recording to recording, which means
    % next trial
    if (oldSAVE==0) & (SAVE==1)
TN=TN+1;
oldSAVE=SAVE;
    end

    if TN_check~=TN
    error('wrong trial ID')
    end
    end

    if contains(Line_tmp,'END') & contains(Line_tmp,'trialid')
       SAVE=0;
       oldSAVE=SAVE;
    end
   
%%%%% RECORD EVENTS
% FIXATIONS
if contains(Line_tmp,'EFIX') 
      Line_sgm=segmentline(Line_tmp);
      %countFix=countFix+1;
  %   FIXATIONS{countFix}=[str2num(Line_sgm{3}) str2num(Line_sgm{5}) str2num(Line_sgm{6}) str2num(Line_sgm{7})]; % time point, duration, x,y
lineF=[str2num(Line_sgm{3}) str2num(Line_sgm{5}) str2num(Line_sgm{6}) str2num(Line_sgm{7}) TN]; % time point, duration, x,y
FIXATIONS=[FIXATIONS ;lineF];
end
end
% 
% % SACCADES
% if contains(Line_tmp,'ESACC') 
%       Line_sgm=segmentline(Line_tmp);
%       %countSacc=countSacc+1;
% 
%     % SACCADES{countFix}=[str2num(Line_sgm{3}) str2num(Line_sgm{5}) str2num(Line_sgm{6}) str2num(Line_sgm{7}) str2num(Line_sgm{8}) str2num(Line_sgm{9})]; % time point, duration, x0,y0,x1,y1
% 
% lineS=[str2num(Line_sgm{3}) str2num(Line_sgm{5}) str2num(Line_sgm{6}) str2num(Line_sgm{7}) str2num(Line_sgm{8}) str2num(Line_sgm{9}) TN]; % time point, duration, x0,y0,x1,y1
% 
% try
% SACCADES=[SACCADES; lineS];
% catch
% end
% end
% 
% end


