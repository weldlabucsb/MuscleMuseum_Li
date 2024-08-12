classdef ScopeValue < BecAnalysis
    %OD Summary of this class goes here
    %   Detailed explanation goes here

    properties
        FullValueName
    end

    properties (SetAccess = protected)

    end

    properties (Hidden,Transient)
 
    end

    methods
        function obj = ScopeValue(becExp)
            %OD Construct an instance of this class
            %   Detailed explanation goes here
            obj@BecAnalysis(becExp)
            obj.Chart(1) = Chart(...
                name = "Scope Value",...
                num = 34, ...
                fpath = fullfile(becExp.DataAnalysisPath,"ScopeValue"),...
                loc = [-0.00001,0.032],...
                size = [0.3069,0.57]...
                );
        end

        function initialize(obj)
            %% Check if we can plot scope values
            if isempty(obj.FullValueName)
                warning("No FullValueName given. Can not plot scope values.")
                return
            end

            %% Initialize plots
            fig = obj.Chart(1).initialize;
            if ~ishandle(fig)
                return
            end

            % Initialize axis
            ax = gca;
            co = ax.ColorOrder;
            conum=size(co, 1);
            mOrder = markerOrder();

            obj.RawLine = matlab.graphics.chart.primitive.ErrorBar.empty;
            obj.ThermalLine = matlab.graphics.chart.primitive.ErrorBar.empty;
            obj.CondensateLine = matlab.graphics.chart.primitive.ErrorBar.empty;
            obj.TotalLine = matlab.graphics.chart.primitive.ErrorBar.empty;

            hold(ax,'on')

            % Initialize raw plots
            for ii = 1:nSub
                obj.RawLine(ii) = errorbar(ax,1,1,[]);
                obj.RawLine(ii).Marker = mOrder(ii);
                obj.RawLine(ii).MarkerFaceColor = co(ii,:);
                obj.RawLine(ii).MarkerEdgeColor = co(ii,:)*.5;
                obj.RawLine(ii).MarkerSize = 8;
                obj.RawLine(ii).LineWidth = 2;
                obj.RawLine(ii).Color = co(ii,:);
                obj.RawLine(ii).CapSize = 0;
            end
            legendStrRaw = arrayfun(@(x) "Raw " + x,1:nSub);

        end

        function updateData(obj,~)
            becExp = obj.BecExp;
            if becExp.ScannedParameter ~= "TOF" || becExp.NCompletedRun < 2 ||...
                    ~ismember("DensityFit",obj.BecExp.AnalysisMethod) ||...
                    ~isempty(obj.BecExp.Roi.SubRoi)
                return
            end
            obj.TofTime = becExp.ScannedParameterList * unit2SI(becExp.ScannedParameterUnit);
            wt = obj.BecExp.DensityFit.ThermalCloudSize;
            obj.FitDataThermal = [LinearFit1D([(obj.TofTime.^2).',(wt(1,:).^2).']);...
                LinearFit1D([(obj.TofTime.^2).',(wt(2,:).^2).'])];
            obj.FitDataThermal(1).do;
            obj.FitDataThermal(2).do;

            obj.Temperature = mean([obj.FitDataThermal(1).Coefficient(1),obj.FitDataThermal(2).Coefficient(1)]) / ...
                2 / obj.kBoverM;
            obj.TrappingFrequency = sqrt(1 ./ ([obj.FitDataThermal(1).Coefficient(2);obj.FitDataThermal(2).Coefficient(2)] / ...
                2 / obj.kBoverM / obj.Temperature));
            obj.ThermalCloudSizeInSitu = sqrt([obj.FitDataThermal(1).Coefficient(2);obj.FitDataThermal(2).Coefficient(2)]);
            obj.ThermalCloudCentralDensityInSitu = max(becExp.AtomNumber.Thermal) / ...
                pi / prod(obj.ThermalCloudSizeInSitu) / boseFunction(1,3) * boseFunction(1,2);
        end

        function updateFigure(obj,~)
            becExp = obj.BecExp;
            fig = obj.Chart(1).Figure;
            if becExp.ScannedParameter ~= "TOF" || becExp.NCompletedRun < 2 ...
                    || (isempty(fig) || ~ishandle(fig)) || ~ismember("DensityFit",obj.BecExp.AnalysisMethod) ||...
                    ~isempty(obj.BecExp.Roi.SubRoi)
                return
            end
            
            switch obj.BecExp.DensityFit.FitMethod
                case {"GaussianFit1D","BosonicGaussianFit1D"}
                    rawXT = obj.FitDataThermal(1).RawData;
                    fitXT = obj.FitDataThermal(1).FitPlotData;
                    rawYT = obj.FitDataThermal(2).RawData;
                    fitYT = obj.FitDataThermal(2).FitPlotData;
                    obj.ThermalXLine.XData = rawXT(:,1) * 1e12;
                    obj.ThermalXLine.YData = rawXT(:,2) * 1e12;
                    obj.ThermalXFitLine.XData = fitXT(:,1) * 1e12;
                    obj.ThermalXFitLine.YData = fitXT(:,2) * 1e12;
                    obj.ThermalYLine.XData = rawYT(:,1) * 1e12;
                    obj.ThermalYLine.YData = rawYT(:,2) * 1e12;
                    obj.ThermalYFitLine.XData = fitYT(:,1) * 1e12;
                    obj.ThermalYFitLine.YData = fitYT(:,2) * 1e12;

                    obj.ParaTable.Data{1,2} = obj.Temperature * 1e6;
                    obj.ParaTable.Data{2,2} = obj.ThermalCloudSizeInSitu(1) * 1e6;
                    obj.ParaTable.Data{3,2} = obj.ThermalCloudSizeInSitu(2) * 1e6;
                    obj.ParaTable.Data{4,2} = obj.ThermalCloudCentralDensityInSitu;
                    obj.ParaTable.Data{5,2} = obj.TrappingFrequency(1);
                    obj.ParaTable.Data{6,2} = obj.TrappingFrequency(2);
            end
            lg = findobj(fig,"Type","Legend");
            lg.Location = "best";
        end

        function refresh(obj)
            obj.initialize;
            obj.updateData(obj.BecExp.NCompletedRun)
            obj.updateFigure(obj.BecExp.NCompletedRun)
        end

    end
end

