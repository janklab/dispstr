function out = reprstrs(x)
% Debugging-oriented display strings for array elements
%
% out = reprstrs(x)
%
% Creates strings describing the contents of x, considered as individual elements.
% This is a human-readable, developer-oriented representation, suitable for
% presentation to developers, in debugging contexts, and in log files.
%
% Returns a string array the same size as x (or as string(x), if x is a char array).

out = dispstrlib.internal.Dispstr.reprstrs(x);

end