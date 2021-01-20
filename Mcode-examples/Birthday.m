classdef Birthday < dispstrlib.Displayable
    
    properties
        Month double
        Day double
    end
    
    methods
        function this = Birthday(month, day)
            this.Month = month;
            this.Day = day;
        end
    end
    
    methods (Access = protected)
        function out = dispstr_scalar(this)
            out = datestr(datenum(1, this.Month, this.Day), 'mmm dd');
        end
    end
    
end