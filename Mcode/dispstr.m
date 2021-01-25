function out = dispstr(x, varargin)
%DISPSTR Display string for array
%
% out = dispstr(x)
% out = dispstr(x, options)
%
% Creates a string describing the contents of x, considered as a whole array.
% This is a human-readable string representing the meaning or value of x,
% suitable for presentation for users or in UIs.
%
% This returns a one-line string representing the input value, in a format
% suitable for inclusion into multi-element output. The output describes the
% entire input array in a single string (as opposed to dumping all its
% elements).
%
% The intention is for user-defined classes to override this method, providing
% customized display of their values.
%
% The input x may be a value of any type. The main DISPSTR implementation has
% support for Matlab built-ins and common types. Other user-defined objects are
% displayed in a generic "m-by-n <class> array" format.
%
% Returns a scalar string.
%
% Options:
%   QuoteStrings - DEPRECATED - Put scalar strings in quotes. Deprecation: if
%     you're using this option, you probably want reprstr() instead.
%
% Examples:
%   dispstr(magic(3))
%
% See also:
% DISPSTRS, REPRSTR, SPRINTFD

out = dispstrlib.internal.Dispstr.dispstr(x, varargin{:});

end

