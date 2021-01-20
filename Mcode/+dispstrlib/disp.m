function disp(x)
% disp Display, with support for dispstr
%
% This is just like Matlab's disp() function, except it respects dispstr()
% overrides on objects inside composite data types like cells and structs.

if isstruct(x)
  dispstrlib.internal.DispstrImpl.disp_struct(x);
elseif iscell(x)
  dispstrlib.internal.DispstrImpl.disp_cell(x);
elseif istable(x)
  % Not implemented yet
  disp(x);
else
  % Everything else just gets normal disp, because there are either no
  % composite members to transform, or it's an object that will have its
  % own disp() override.
  disp(x);
end
