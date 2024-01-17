classdef (Abstract) FitData < handle
    %FIT Summary of this class goes here
    %   Detailed explanation goes here

    properties
        StartPoint
        Lower
        Upper
        TolFun = 1E-16
        MaxFunEvals = 2000
        MaxIter = 2000
    end

    properties (Dependent,Hidden,Transient)
        Option
    end

    properties (SetAccess = protected)
        Func
        Result
        Gof
        Coefficient
    end

    methods
        function obj = FitData()
        end

        function option = get.Option(obj)
            if ~isempty(obj.Func)
                option = fitoptions(obj.Func);
                if ~isempty(obj.StartPoint)
                    option.StartPoint = obj.StartPoint;
                end
                if ~isempty(obj.Lower)
                    option.Lower = obj.Lower;
                end
                if ~isempty(obj.Upper)
                    option.Upper = obj.Upper;
                end
                if option.Method ~= "LinearLeastSquares"
                    option.TolFun = obj.TolFun;
                    option.MaxFunEvals = obj.MaxFunEvals;
                    option.MaxIter = obj.MaxIter;
                end     
                
            end
        end

    end

    methods (Abstract)
        do(obj)
        plot(obj)
    end
end

