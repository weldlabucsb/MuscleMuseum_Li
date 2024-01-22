classdef AtomNumber < BecAnalysis
    %OD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
       Raw
       Thermal
       Condensate
       Total
    end

    properties (Constant)
        Unit = 10^6;
    end

    properties (SetObservable)
        YLim = [0,30];
    end

    properties (Hidden,Transient)
        RawLine 
        ThermalLine 
        CondensateLine
        TotalLine
    end
    
    methods
        function obj = AtomNumber(becExp)
            %OD Construct an instance of this class
            %   Detailed explanation goes here
            obj@BecAnalysis(becExp)
            obj.Chart(1) = Chart(...
                name = "Atom number",...
                num = 29, ...
                fpath = fullfile(becExp.DataAnalysisPath,"AtomNumber"),...
                loc = "northeast",...
                size = [0.3069,0.3995]...
                );
        end
        
        function initialize(obj)
            fig = obj.Chart(1).initialize;
            obj.Raw = 0;
            obj.Thermal = 0;
            obj.Condensate = 0;
            obj.Total = 0;

            if ~ishandle(fig)
                return
            end

            addlistener(obj,'YLim','PostSet',@obj.handlePropEvents);

            ax = gca;
            ax.Box = "on";
            ax.XGrid = "on";
            ax.YGrid = "on";
            ax.XLabel.String = obj.BecExp.XLabel;
            ax.XLabel.Interpreter = "latex";
            ax.YLabel.String = "${N}_{\mathrm{atom}}~[\times 10^{" + string(log(obj.Unit)/log(10)) + "}]$";
            ax.YLabel.Interpreter = "latex";
            ax.FontSize = 12;
            ax.YLim = obj.YLim;
            co = ax.ColorOrder;

            obj.RawLine = line(ax,1,1);
            obj.RawLine.Marker = "o";
            obj.RawLine.MarkerFaceColor = co(1,:);
            obj.RawLine.MarkerEdgeColor = co(1,:)*.5;
            obj.RawLine.MarkerSize = 8;
            obj.RawLine.LineWidth = 2;
            obj.RawLine.Color = co(1,:);
            
            if ismember("DensityFit",obj.BecExp.AnalysisMethod)
                hold(ax,'on')
                switch obj.BecExp.DensityFit.FitMethod
                    case {"GaussianFit1D","BosonicGaussianFit1D"}
                        obj.ThermalLine = line(ax,1,1);
                        obj.ThermalLine.Marker = "o";
                        obj.ThermalLine.MarkerFaceColor = co(2,:);
                        obj.ThermalLine.MarkerEdgeColor = co(2,:)*.5;
                        obj.ThermalLine.MarkerSize = 8;
                        obj.ThermalLine.LineWidth = 2;
                        obj.ThermalLine.Color = co(2,:);
                        legend(ax,"Raw","Thermal")
                end
                hold(ax,'off')
            end           

        end

        function updateData(obj,runIdx)
            becExp = obj.BecExp;
            obj.Raw(runIdx) = sum(becExp.Ad.AdData(:,:,runIdx),"all") * (becExp.Acquisition.PixelSizeReal)^2;
            if ismember("DensityFit",obj.BecExp.AnalysisMethod)
                switch obj.BecExp.DensityFit.FitMethod
                    case "GaussianFit1D"
                        obj.Thermal(runIdx) = 2 * pi * prod(becExp.DensityFit.ThermalCloudSize(:,runIdx)) * ...
                            becExp.DensityFit.ThermalCloudCentralDensity(runIdx);
                    case "BosonicGaussianFit1D"
                        obj.Thermal(runIdx) = pi * prod(becExp.DensityFit.ThermalCloudSize(:,runIdx)) * ...
                            becExp.DensityFit.ThermalCloudCentralDensity(runIdx) * ...
                            boseFunction(1,3) / boseFunction(1,2);
                end
            end
        end

        function updateFigure(obj,~)
            if ishandle(obj.Chart(1).Figure)
                fig = figure(obj.Chart(1).Figure);
            else
                return
            end

            paraList = obj.BecExp.ScannedParameterList;
            obj.RawLine.XData = paraList;
            obj.RawLine.YData = obj.Raw / obj.Unit;

            if ismember("DensityFit",obj.BecExp.AnalysisMethod)
                switch obj.BecExp.DensityFit.FitMethod
                    case {"GaussianFit1D","BosonicGaussianFit1D"}
                        obj.ThermalLine.XData = paraList;
                        obj.ThermalLine.YData = obj.Thermal / obj.Unit;
                end
            end
            
            lg = findobj(fig,"Type","Legend");
            lg.Location = "best";
        end

    end

    methods (Static)
        function handlePropEvents(src,evnt)
            switch src.Name
                case 'YLim'
                    obj = evnt.AffectedObject;
                    for ii = 1:numel(obj.Chart)
                        if ishandle(obj.Chart(ii).Figure)
                            fig = obj.Chart(ii).Figure;
                            ax = fig.CurrentAxes;
                            ax.YLim = obj.YLim;
                        end
                    end
            end
        end
    end
end

