classdef Birthday1
    
    properties
        Month double
        Day double
    end
    
    methods
        function this = Birthday1(month, day)
            this.Month = month;
            this.Day = day;
        end

        function disp(this)
          fprintf('%s\n', datestr(datenum(1, this.Month, this.Day), 'mmm dd'));
        end
    end
    
end