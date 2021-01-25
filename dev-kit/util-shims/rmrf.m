function rmrf(files)
% Recursively delete files and directories
%
% rmrf(files)
arguments
  files string
end
dispstrlib.internal.util.rmrf(files);
end