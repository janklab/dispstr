function errord(varargin)
% A variant of error() that supports dispstr functionality
%
% errord(fmt, varargin)
% errord(errorId, fmt, varargin)
%
% This is just like Matlab's error(), except you can pass objects
% directly to '%s' conversion specifiers, and they will be automatically
% converted using dispstr.

args = dispstrlib.internal.Dispstr.convertArgsForPrintf(varargin);

if dispstrlib.internal.Dispstr.isErrorIdentifier(args{1})
  id = args{1};
  args = args(2:end);
else
  id = '';
end

err = MException(id, args{:});
throwAsCaller(err);

end