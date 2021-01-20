classdef DispstrHelper
  
  methods (Static)
    
    function txt = disparray(x)
      strs = dispstrs(x);
      txt = dispstrlib.internal.DispstrImpl.prettyprintArray(strs);
      if nargout == 0
        disp(txt)
        clear txt
      end
    end
    
  end
  
end