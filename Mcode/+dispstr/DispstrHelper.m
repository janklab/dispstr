classdef DispstrHelper
    
    methods (Static)
        function disparray(x)
        strs = dispstrs(x);
        out = dispstr.internal.prettyprint_array(strs);
        disp(out);
        end
    end
end