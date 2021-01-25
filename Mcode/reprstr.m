function out = reprstr(x)
% Debugging-oriented display string for array
%
% out = reprstr(x)
%
% Creates a string describing the contents of x, considered as a whole array.
% This is a human-readable, developer-oriented representation, suitable for
% presentation to developers, in debugging contexts, and in log files.
%
% Returns a scalar string.

out = dispstrlib.internal.Dispstr.reprstr(x);

end