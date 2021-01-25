function out = dispstrs(x)
%DISPSTRS Display strings for array elements
%
% out = dispstrs(x)
%
% Creates strings describing the contents of x, considered as individual elements.
% This are human-readable strings representing the meaning or value of x,
% suitable for presentation for users or in UIs.
%
% DISPSTRS returns a cellstr array containing display strings that represent the
% values in the elements of x. These strings are concise, single-line strings
% suitable for incorporation into multi-element output. If x is a cell, each
% element cell's contents are displayed, instead of each cell.
%
% Unlike DISPSTR, DISPSTRS returns output describing each element of the input
% array individually.
%
% This is used for constructing display output for functions like DISP.
% User-defined objects are expected to override DISPSTRS to produce suitable,
% readable output.
%
% The output is human-consumable text. It does not have to be fully precise, and
% does not have to be parseable back to the original input. Full type
% information will not be inferrable from DISPSTRS output. The primary audience
% for DISPSTRS output is Matlab programmers and advanced users.
%
% The intention is for user-defined classes to override this method, providing
% customized display of their values.
%
% The input x may be a value of any type. The main DISPSTRS implementation has
% support for Matlab built-ins and common types. Other user-defined objects are
% displayed in a generic "m-by-n <class> array" format.
%
% Returns a string array the same size as x. Unless x is a char, in which
% case it returns a string array the same size as string(x).
%
% Examples:
%   dispstrs(magic(3))
%
% See also: DISPSTR, REPRSTRS

out = dispstrlib.internal.Dispstr.dispstrs(x);

end

