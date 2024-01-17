classdef (Abstract) FitData1D < FitData
    %FIT1D Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RawData % n * 2 array
    end

    properties (Dependent)
        FitPlotData % n * 2 array
    end
    
    methods
        function obj = FitData1D(rawData)
            %FIT1D Construct an instance of this class
            %   Detailed explanation goes here
            obj.RawData = rawData;
        end

        function fpData = get.FitPlotData(obj)
            if isempty(obj.Result)
                fpData = [];
                return
            end
            xFit = linspace(min(obj.RawData(:,1)),max(obj.RawData(:,1)),1000).';
            yFit = feval(obj.Result,xFit);
            fpData = [xFit,yFit];
        end

        function fitResult = do(obj)
            [fitResult,gof] = fit(obj.RawData(:,1),obj.RawData(:,2),obj.Func,obj.Option);
            obj.Result = fitResult;
            obj.Gof = gof;
            obj.Coefficient = coeffvalues(fitResult);
        end

        function plot(obj,targetAxes,isRender)
            arguments
                obj FitData1D
                targetAxes = []
                isRender logical = true
            end

            if isempty(targetAxes)
                figure
                ax = gca;
                
            else
                ax = targetAxes;
            end
            l = plot(ax,obj.RawData(:,1),obj.RawData(:,2),obj.FitPlotData(:,1),obj.FitPlotData(:,2));
            l(1).LineWidth = 1.5;
            l(2).LineWidth = 1.5;
            legend(ax,"Raw Data","Fit Data")

            if isRender
                box on
                xlabel("$x$",'Interpreter','latex')
                ylabel("$y$",'Interpreter','latex')
            end
        end
        
    end
end

