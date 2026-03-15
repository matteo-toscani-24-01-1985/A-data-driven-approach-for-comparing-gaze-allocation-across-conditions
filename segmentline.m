function mycell=segmentline(myline)

% mycell=segmentline(myline);
%
% segment a string in space delimited segments and put chunks in
% progressive cells of a cell array

fieldn=0;
if ~isempty(myline)
    while ~isempty(myline)
        [T,myline] = strtok(myline);
        fieldn=fieldn+1;
        mycell{fieldn}=T;
    end
else
    mycell{1}=[];
end