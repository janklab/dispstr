function dispd(x)
% A disp that respects dispstr
%
% dispd(x)
%
% This is a variant of disp that respects the dispstr functions.
%
% Examples:
%
% bday = Birthday(3, 14);
% c = repmat({bday bday [bday bday bday]});
% dispd(c);
%
% See also:
% SPRINTFDS

dispstrlib.internal.Dispstr.disp(x);

end