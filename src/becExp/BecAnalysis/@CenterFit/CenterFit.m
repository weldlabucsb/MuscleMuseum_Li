classdef CenterFit < BecAnalysis
    %OD Summary of this class goes here
    %   Detailed explanation goes here

    properties
        FitMethod = "LinearFit1D"
        FitDataX
        FitDataY
    end

    properties (SetAccess = protected)
        ThermalCloudCenterMean
        ThermalCloudCenterRange
        ThermalCloudCenterSlope
    end

    properties (Hidden,Transient)
        ThermalXLine
        ThermalXFitLine
        ThermalYLine
        ThermalYFitLine
        ParaTable
    end

    methods
        function obj = CenterFit(becExp)
            %OD Construct an instance of this class
            %   Detailed explanation goes here
            obj@BecAnalysis(becExp)
            obj.Chart(1) = Chart(...
                name = "Center fit",...
                num = 30, ...
                fpath = fullfile(becExp.DataAnalysisPath,"CenterFit"),...
                loc = [0.3919,0.032],...
                size = [0.3069,0.57]...
                );
        end

        function initialize(obj)
            becExp = obj.BecExp;
            if ~isprop(obj.BecExp,"DensityFit")
                warning("No DensityFit. Can not do CenterFit analysis")
                return
            end
            fig = obj.Chart(1).initialize;

            if ishandle(fig)
                p1 = uipanel(fig,"Position",[0,0.3,1,0.7]);
                % ax = axes(p1);

                t = tiledlayout(p1,2,1);
                t.TileSpacing = 'compact';
                t.Padding = 'compact';
                ax1 = nexttile(t);
                % ax1.XLabel.String = becExp.XLabel;
                ax1.XLabel.Interpreter = "latex";
                ax1.YLabel.String = "$x_0$ [Pixels]";
                ax1.YLabel.Interpreter = "latex";
                ax1.FontSize = 12;
                ax1.Box = "on";
                ax1.XGrid = "on";
                ax1.YGrid = "on";
                ax1.XTickLabel = [];

                co = ax1.ColorOrder;
                obj.ThermalXLine = line(ax1,1,1);
                obj.ThermalXLine.Marker = "o";
                obj.ThermalXLine.MarkerFaceColor = co(1,:);
                obj.ThermalXLine.MarkerEdgeColor = co(1,:)*.5;
                obj.ThermalXLine.MarkerSize = 8;
                obj.ThermalXLine.LineWidth = 2;
                obj.ThermalXLine.LineStyle = "none";

                obj.ThermalXFitLine = line(ax1,1,1);
                obj.ThermalXFitLine.LineWidth = 2;
                obj.ThermalXFitLine.Color = co(1,:);

                legend(ax1,"Thermal Data","Thermal Fit");

                ax2 = nexttile(t);
                ax2.XLabel.String = becExp.XLabel;
                ax2.XLabel.Interpreter = "latex";
                ax2.YLabel.String = "$y_0$ [Pixels]";
                ax2.YLabel.Interpreter = "latex";
                ax2.FontSize = 12;
                ax2.Box = "on";
                ax2.XGrid = "on";
                ax2.YGrid = "on";

                obj.ThermalYLine = line(ax2,1,1);
                obj.ThermalYLine.Marker = "o";
                obj.ThermalYLine.MarkerFaceColor = co(1,:);
                obj.ThermalYLine.MarkerEdgeColor = co(1,:)*.5;
                obj.ThermalYLine.MarkerSize = 8;
                obj.ThermalYLine.LineWidth = 2;
                obj.ThermalYLine.LineStyle = "none";

                obj.ThermalYFitLine = line(ax2,1,1);
                obj.ThermalYFitLine.LineWidth = 2;
                obj.ThermalYFitLine.Color = co(1,:);

                legend(ax2,"Thermal Data","Thermal Fit");

            end

            switch obj.FitMethod
                case "LinearFit1D"
                    obj.ThermalCloudCenterMean = [0;0];
                    obj.ThermalCloudCenterRange = [0;0];
                    obj.ThermalCloudCenterSlope = [0;0];
                    obj.FitDataX = LinearFit1D([1,1]);
                    obj.FitDataY = LinearFit1D([1,1]);
                    if ishandle(fig)
                        p2 = uipanel(fig,"Position",[0,0,1,0.3]);
                        obj.ParaTable = uitable(p2,'Data', [1 2 3],Unit='normalized',Position=[0,0,1,1]);
                        obj.ParaTable.ColumnName = {'Parameter','Value','Unit'};
                        data{1,1} = 'Thermal Cloud Center Mean in x';
                        data{1,2} = '';
                        data{1,3} = 'Pixels';
                        data{2,1} = 'Thermal Cloud Center Mean in y';
                        data{2,2} = '';
                        data{2,3} = 'Pixels';
                        data{3,1} = 'Thermal Cloud Center Range in x';
                        data{3,2} = '';
                        data{3,3} = 'Pixels';
                        data{4,1} = 'Thermal Cloud Center Range in y';
                        data{4,2} = '';
                        data{4,3} = 'Pixels';
                        data{5,1} = 'Thermal Cloud Center Slope in x';
                        data{5,2} = '';
                        data{5,3} = 'Pixels/VarUnit';
                        data{6,1} = 'Thermal Cloud Center Slope in y';
                        data{6,2} = '';
                        data{6,3} = 'Pixels/VarUnit';

                        obj.ParaTable.Data = data;
                        obj.ParaTable.FontSize = 12;
                        obj.ParaTable.Units = 'pixel';
                        tWidth = obj.ParaTable.Position(3);
                        obj.ParaTable.ColumnWidth={tWidth/2.01 tWidth/4.01 tWidth/4.01};
                        obj.ParaTable.ColumnEditable=[false false];
                        obj.ParaTable.RowName=[];
                        obj.ParaTable.Units = 'normalized';
                    end
            end
        end

        function updateData(obj,~)
            becExp = obj.BecExp;
            if ~isprop(becExp,"DensityFit")
                return
            end
 
            obj.ThermalCloudCenterMean = mean(becExp.DensityFit.ThermalCloudCenter,2);
            obj.ThermalCloudCenterRange = max(becExp.DensityFit.ThermalCloudCenter,[],2) - ...
                min(becExp.DensityFit.ThermalCloudCenter,[],2);

            paraList = becExp.ScannedParameterList;
            paraList = paraList.';
            if class(paraList) == "datetime"
                paraList = paraList - paraList(1);
                paraList = seconds(paraList);
            end

            switch obj.FitMethod
                case "LinearFit1D"
                    obj.FitDataX = LinearFit1D([paraList,becExp.DensityFit.ThermalCloudCenter(1,:).']);
                    obj.FitDataX.do;
                    obj.FitDataY = LinearFit1D([paraList,becExp.DensityFit.ThermalCloudCenter(2,:).']);
                    obj.FitDataY.do;
                    obj.ThermalCloudCenterSlope = [obj.FitDataX.Coefficient(1);obj.FitDataY.Coefficient(1)];
            end

        end

        function updateFigure(obj,~)
            fig = obj.Chart(1).Figure;

            if ~isprop(obj.BecExp,"DensityFit") || ~ishandle(fig)
                return
            end

            px = obj.BecExp.Acquisition.PixelSizeReal;

            rawXT = obj.FitDataX.RawData;
            fitXT = obj.FitDataX.FitPlotData;
            rawYT = obj.FitDataY.RawData;
            fitYT = obj.FitDataY.FitPlotData;
            obj.ThermalXLine.XData = rawXT(:,1);
            obj.ThermalXLine.YData = rawXT(:,2) / px;
            obj.ThermalXFitLine.XData = fitXT(:,1);
            obj.ThermalXFitLine.YData = fitXT(:,2) / px;
            obj.ThermalYLine.XData = rawYT(:,1);
            obj.ThermalYLine.YData = rawYT(:,2) / px;
            obj.ThermalYFitLine.XData = fitYT(:,1);
            obj.ThermalYFitLine.YData = fitYT(:,2) / px;

            
            obj.ParaTable.Data{1,2} = num2str(obj.ThermalCloudCenterMean(1)/px,'%.2f');
            obj.ParaTable.Data{2,2} = num2str(obj.ThermalCloudCenterMean(2)/px,'%.2f');
            obj.ParaTable.Data{3,2} = num2str(obj.ThermalCloudCenterRange(1)/px,'%.2f');
            obj.ParaTable.Data{4,2} = num2str(obj.ThermalCloudCenterRange(2)/px,'%.2f');
            obj.ParaTable.Data{5,2} = num2str(obj.ThermalCloudCenterSlope(1)/px);
            obj.ParaTable.Data{6,2} = num2str(obj.ThermalCloudCenterSlope(2)/px);

            lg = findobj(fig,'Type','Legend');
            lg(1).Location = 'best';
            lg(2).Location = 'best';
        end

        function refresh(obj)
            obj.initialize;
            obj.updateData(obj.BecExp.NCompletedRun)
            obj.updateFigure(obj.BecExp.NCompletedRun)
        end


    end
end

