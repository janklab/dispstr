classdef DispstrHelper
    
    methods (Static)
        function disparray(x)
        if ~ismatrix(x)
            fprintf('%s %s\n', size2str(size(x)), class(x));
            return
        end
        strs = dispstrs(x);
        lens = strlen(strs);
        widths = max(lens);
        formats = sprintfv('%%%ds', widths);
        format = strjoin(formats, '   ');
        for i = 1:size(x, 1)
            fprintf([format '\n'], strs{i,:});
        end
        end
    end
end