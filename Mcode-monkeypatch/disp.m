function disp(x)
% Monkey-patched disp to add dispstr support
if isnumeric(x)
  builtin('disp', x);
else
  dispstrlib.internal.Dispstr.disp(x);
end