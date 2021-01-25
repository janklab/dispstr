function out = reporoot
% The root dir of the dispstr repo
out = string(fileparts(fileparts(fileparts(mfilename('fullpath')))));
end