function out = mat2str2(x)
% An extended version of mat2str, with support for more data types
%
% str = mat2str2(x)
%
% Converts x into a string containing a Matlab M-code expression that can be
% eval()ed to reproduce the original value (or something close to it).
%
% Supports more types than Matlab's mat2str, but not all types are supported.
%
% Returns a scalar string.
%
% See also:
% MAT2STR

out = dispstrlib.internal.Dispstr.mat2str2(x);

end