%--------------------------------------------------------------------------
function S = Deg2Cm(ang,D, rad)
%--------------------------------------------------------------------------
%Converts degree of visual angle into cm given the observer's distance
%from the screen

%"ang" is the angle in degree, "D" the distance and "rad" is a string that
%could be 'F' or 'T', by default is 'F', if true ('T') the function takes radiants instead of degree

% MT, 2/04/2010
if nargin < 3
    rad = 'F';
end


if ~((rad =='F')|(rad =='T'))
    fprintf('ERROR: the third argument should be F or T - The result is in radiants')
end

if rad=='F'
    ang=(ang*2*pi)/360 ;
end

S=tan(ang/2)*(2*D);