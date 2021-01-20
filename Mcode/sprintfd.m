function out = sprintfd(fmt, varargin)
% A sprintf that respects dispstr
%
% out = sprintfd(fmt, varargin)
%
% This is a variant of sprintf that respects the dispstr functions. For
% inputs that are objects, dispstr() is implicitly called on them, so you
% can pass them directly to '%s' conversion specifiers in your format
% string. ('%s' already works with datetime and related types, so those do
% not need to be converted.)
%
% Examples:
%
% bday = Birthday(3, 14);
% str = sprintfd('The value is: %s', bday)
%
% See also:
% FPRINTFDS

args = dispstrlib.internal.Dispstr.convertArgsForPrintf(varargin);

out = sprintf(fmt, args{:});

end