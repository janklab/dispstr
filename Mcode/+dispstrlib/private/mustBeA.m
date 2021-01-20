function mustBeA(value, type)
% Validate that an input is of a particular data type
%
% mustBeA(value, type)
%
% Validates that the input Value is of the specified Type or a
% subtype. If Value is not of Type (according to Matlab's isa() function), an
% error is raised. If Value is of Type, does nothing and returns.
%
% Value is the value to validates the type of. It may be anything. If
% you call it using a variable (as opposed to a longer expression),
% the variable name is included in any error messages.
%
% Type (char) is the name of the type that Value must be. It may be:
%   - the name of a Matlab type
%   - 'cellstr', 'numeric', or 'object' (Janklab pseudotypes)
%   - 'any', which allows anything and always passes

% Avoid infinite recursion
assert(ischar(type), 'jl:InvalidInput',...
    'type must be a char, but got a %s', class(type));

% Special pseudotype cases
switch type
    case 'cellstr'
        if iscellstr(value) %#ok<ISCLSTR>
            return
        else
            if iscell(value)
                elementTypes = unique(cellfun(@class, value, 'UniformOutput',false));
                typeDescription = sprintf('cell containing %s', strjoin(elementTypes, ' and '));
            else
                typeDescription = class(value);
            end
            reportBadValue(inputname(1), type, typeDescription);
        end
    case 'numeric'
        if isnumeric(value)
            return
        else
            reportBadValue(inputname(1), 'numeric', class(value));
        end
    case 'object'
        % 'object' means user-defined Matlab objects
        if isobject(value)
            return
        else
            reportBadValue(inputname(1), 'object', class(value));
        end
    case 'nil'
        % nil uses a special test
        if isnil(value)
            return
        else
            reportBadValue(inputname(1), 'nil', class(value));
        end
    case 'any'
        % Always passes: any type is an 'any'
        return
end

% General case
if ~isa(value, type)
    reportBadValue(inputname(1), type, class(value));
end

end

function reportBadValue(label, want, got)
error('jl:InvalidInput', 'Input %s must be a %s, but got a %s', label, want, got);
end

