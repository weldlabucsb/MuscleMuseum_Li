classdef CenterFit < BecAnalysis
    %OD Summary of this class goes here
    %   Detailed explanation goes here

    properties
        FitMethod = "LinearFit1D"
        FitDataThermalX
        FitDataThermalY
        FitDataCondensateX
        FitDataCondensateY
    end

    properties (SetAccess = protected)
        ThermalCloudCenterMean
        ThermalCloudCenterRange
        ThermalCloudCenterSlope
        ThermalCloudCenterAcceleration
        ThermalCloudCenterSloshAmplitude
        ThermalCloudCenterSloshOffset
        ThermalCloudCenterSloshFrequency
        CondensateCenterMean
        CondensateCenterRange
        CondensateCenterSlope
        CondensateCenterAcceleration
        CondensateCenterSloshAmplitude
        CondensateCenterSloshOffset
        CondensateCenterSloshFrequency
    end

    properties (Hidden,Transient)
        ThermalXLine
        ThermalXFitLine
        ThermalYLine
        ThermalYFitLine
        ParaTable
        MinimumFitNumber
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
            %% Check if we have DensityFit
            if ~ismember("DensityFit",obj.BecExp.AnalysisMethod)
                warning("No DensityFit. Can not do CenterFit analysis")
                return
            end

            %% Initialize data
            obj.ThermalCloudCenterMean = [0;0];
            obj.ThermalCloudCenterRange = [0;0];
            obj.ThermalCloudCenterSlope = [0;0];
            obj.ThermalCloudCenterAcceleration = [0;0];
            obj.ThermalCloudCenterSloshAmplitude = [0;0];
            obj.ThermalCloudCenterSloshOffset = [0;0];
            obj.ThermalCloudCenterSloshFrequency = [0;0];
            obj.CondensateCenterMean = [0;0];
            obj.CondensateCenterRange = [0;0];
            obj.CondensateCenterSlope = [0;0];
            obj.CondensateCenterAcceleration = [0;0];
            obj.CondensateCenterSloshAmplitude = [0;0];
            obj.CondensateCenterSloshOffset = [0;0];
            obj.CondensateCenterSloshFrequency = [0;0];
            obj.FitDataThermalX = [];
            obj.FitDataThermalY = [];
            obj.FitDataCondensateX = [];
            obj.FitDataCondensateY = [];

            %% Initialize plots
            fig = obj.Chart(1).initialize;
            if ishandle(fig)
                %% Initialize plots, general

                % Plot curves into panel1
                p1 = uipanel(fig,"Position",[0,0.3,1,0.7]);
                t = tiledlayout(p1,2,1);
                t.TileSpacing = 'compact';
                t.Padding = 'compact';

                % X axes
                ax1 = nexttile(t);
                ax1.XLabel.Interpreter = "latex";
                ax1.YLabel.String = "$x_0$ [Pixels]";
                ax1.YLabel.Interpreter = "latex";
                ax1.FontSize = 12;
                ax1.Box = "on";
                ax1.XGrid = "on";
                ax1.YGrid = "on";
                ax1.XTickLabel = [];

                % Y Axes
                ax2 = nexttile(t);
                ax2.XLabel.String = becExp.XLabel;
                ax2.XLabel.Interpreter = "latex";
                ax2.YLabel.String = "$y_0$ [Pixels]";
                ax2.YLabel.Interpreter = "latex";
                ax2.FontSize = 12;
                ax2.Box = "on";
                ax2.XGrid = "on";
                ax2.YGrid = "on";

                %% Initialize plots, based on DensityFit method
                switch becExp.DensityFit.FitMethod
                    case {"GaussianFit1D","BosonicGaussianFit1D"}
                        % X data lines
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

                        % Y data lines
                        co = ax2.ColorOrder;
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
            end
            
            %% Initialize table
            if ishandle(fig)
                %% Initialize table data
                switch becExp.DensityFit.FitMethod
                    case {"GaussianFit1D","BosonicGaussianFit1D"}
                        %% Thermal fit only
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
                        switch obj.FitMethod
                            case "LinearFit1D"
                                obj.MinimumFitNumber = 2;
                                data{5,1} = 'Thermal Cloud Center Slope in x';
                                data{5,2} = '';
                                data{5,3} = 'Pixels/VarUnit';
                                data{6,1} = 'Thermal Cloud Center Slope in y';
                                data{6,2} = '';
                                data{6,3} = 'Pixels/VarUnit';
                            case "ParabolicFit1D"
                                obj.MinimumFitNumber = 3;
                                data{5,1} = 'Thermal Cloud Center Acceleration in x';
                                data{5,2} = '';
                                data{5,3} = 'Pixels/VarUnit^2';
                                data{6,1} = 'Thermal Cloud Center Acceleration in y';
                                data{6,2} = '';
                                data{6,3} = 'Pixels/VarUnit^2';
                            case "SineFit1D"
                                obj.MinimumFitNumber = 4;
                                data{5,1} = 'Thermal Cloud Center Slosh Amplitude in x';
                                data{5,2} = '';
                                data{5,3} = 'Pixels';
                                data{6,1} = 'Thermal Cloud Center Slosh Amplitude in y';
                                data{6,2} = '';
                                data{6,3} = 'Pixels';
                                data{7,1} = 'Thermal Cloud Center Slosh Offset in x';
                                data{7,2} = '';
                                data{7,3} = 'Pixels';
                                data{8,1} = 'Thermal Cloud Center Slosh Offset in y';
                                data{8,2} = '';
                                data{8,3} = 'Pixels';
                                data{9,1} = 'Thermal Cloud Center Slosh Frequency in x';
                                data{9,2} = '';
                                data{9,3} = '1/VarUnit';
                                data{10,1} = 'Thermal Cloud Center Slosh Frequency in y';
                                data{10,2} = '';
                                data{10,3} = '1/VarUnit';
                        end
                    
                    case "BimodalFit1D"
                        %% Thermal and condensate fit
                end

                %% Initialize table plot
                p2 = uipanel(fig,"Position",[0,0,1,0.3]);
                obj.ParaTable = uitable(p2,'Data', [1 2 3],Unit='normalized',Position=[0,0,1,1]);
                obj.ParaTable.ColumnName = {'Parameter','Value','Unit'};
                obj.ParaTable.Data = data;
                obj.ParaTable.FontSize = 12;
                obj.ParaTable.Units = 'pixel';
                tWidth = obj.ParaTable.Position(3);
                obj.ParaTable.ColumnWidth={tWidth*0.6 tWidth*0.2 tWidth*0.2};
                obj.ParaTable.ColumnEditable=[false false];
                obj.ParaTable.RowName=[];
                obj.ParaTable.Units = 'normalized';

            end
        end

        function updateData(obj,~)
            becExp = obj.BecExp;
            if ~ismember("DensityFit",obj.BecExp.AnalysisMethod)
                return
            end
            paraList = becExp.ScannedParameterList.';

            %% Update data
            switch becExp.DensityFit.FitMethod
                case {"GaussianFit1D","BosonicGaussianFit1D"}
                    %% Thermal fit only
                    obj.ThermalCloudCenterMean = mean(becExp.DensityFit.ThermalCloudCenter,2);
                    obj.ThermalCloudCenterRange = max(becExp.DensityFit.ThermalCloudCenter,[],2) - ...
                        min(becExp.DensityFit.ThermalCloudCenter,[],2);
                    if becExp.NCompletedRun >= obj.MinimumFitNumber
                        switch obj.FitMethod
                            case "LinearFit1D"
                                %% Linear Fit
                                    obj.FitDataThermalX = ...
                                        LinearFit1D([paraList,becExp.DensityFit.ThermalCloudCenter(1,:).']);
                                    obj.FitDataThermalY = ...
                                        LinearFit1D([paraList,becExp.DensityFit.ThermalCloudCenter(2,:).']);
                                    obj.FitDataThermalX.do;
                                    obj.FitDataThermalY.do;
                                    obj.ThermalCloudCenterSlope = ...
                                        [obj.FitDataThermalX.Coefficient(1);obj.FitDataThermalY.Coefficient(1)];
                            case "ParabolicFit1D"
                                %% Parabolic Fit
                                    obj.FitDataThermalX = ...
                                        ParabolicFit1D([paraList,becExp.DensityFit.ThermalCloudCenter(1,:).']);
                                    obj.FitDataThermalY = ...
                                        ParabolicFit1D([paraList,becExp.DensityFit.ThermalCloudCenter(2,:).']);
                                    obj.FitDataThermalX.do;
                                    obj.FitDataThermalY.do;
                                    obj.ThermalCloudCenterAcceleration = ...
                                        2 * [obj.FitDataThermalX.Coefficient(1);obj.FitDataThermalY.Coefficient(1)];
                            case "SineFit1D"
                                %% Sine Fit
                                    obj.FitDataThermalX = ...
                                        SineFit1D([paraList,becExp.DensityFit.ThermalCloudCenter(1,:).']);
                                    obj.FitDataThermalY = ...
                                        SineFit1D([paraList,becExp.DensityFit.ThermalCloudCenter(2,:).']);
                                    obj.FitDataThermalX.do;
                                    obj.FitDataThermalY.do;
                                    obj.ThermalCloudCenterSloshAmplitude = ...
                                        [obj.FitDataThermalX.Coefficient(1);obj.FitDataThermalY.Coefficient(1)];
                                    obj.ThermalCloudCenterSloshOffset = ...
                                        [obj.FitDataThermalX.Coefficient(4);obj.FitDataThermalY.Coefficient(4)];
                                    obj.ThermalCloudCenterSloshFrequency = ...
                                        [obj.FitDataThermalX.Coefficient(2);obj.FitDataThermalY.Coefficient(2)];
                        end
                    end
                case "BimodalFit1D"
                    %% Thermal and condensate fit

            end
        end

        function updateFigure(obj,~)
            fig = obj.Chart(1).Figure;
            becExp = obj.BecExp;
            if ~ismember("DensityFit",obj.BecExp.AnalysisMethod) || ~ishandle(fig)
                return
            end
            px = becExp.Acquisition.PixelSizeReal;

            switch becExp.DensityFit.FitMethod
                case {"GaussianFit1D","BosonicGaussianFit1D"}
                    %% Thermal fit only
                    obj.ParaTable.Data{1,2} = num2str(obj.ThermalCloudCenterMean(1)/px,'%.2f');
                    obj.ParaTable.Data{2,2} = num2str(obj.ThermalCloudCenterMean(2)/px,'%.2f');
                    obj.ParaTable.Data{3,2} = num2str(obj.ThermalCloudCenterRange(1)/px,'%.2f');
                    obj.ParaTable.Data{4,2} = num2str(obj.ThermalCloudCenterRange(2)/px,'%.2f');
                    if becExp.NCompletedRun >= 1 && becExp.NCompletedRun < obj.MinimumFitNumber 
                        obj.ThermalXLine.XData = obj.BecExp.ScannedParameterList;
                        obj.ThermalXLine.YData = obj.BecExp.DensityFit.ThermalCloudCenter(1,:) / px;
                        obj.ThermalYLine.XData = obj.BecExp.ScannedParameterList;
                        obj.ThermalYLine.YData = obj.BecExp.DensityFit.ThermalCloudCenter(2,:) / px;
                    elseif becExp.NCompletedRun >= obj.MinimumFitNumber 
                        rawXT = obj.FitDataThermalX.RawData;
                        rawYT = obj.FitDataThermalY.RawData;
                        obj.ThermalXLine.XData = rawXT(:,1);
                        obj.ThermalXLine.YData = rawXT(:,2) / px;
                        obj.ThermalYLine.XData = rawYT(:,1);
                        obj.ThermalYLine.YData = rawYT(:,2) / px;

                        fitXT = obj.FitDataThermalX.FitPlotData;
                        fitYT = obj.FitDataThermalY.FitPlotData;
                        obj.ThermalXFitLine.XData = fitXT(:,1);
                        obj.ThermalXFitLine.YData = fitXT(:,2) / px;
                        obj.ThermalYFitLine.XData = fitYT(:,1);
                        obj.ThermalYFitLine.YData = fitYT(:,2) / px;

                        switch obj.FitMethod
                            case "LinearFit1D"
                                    obj.ParaTable.Data{5,2} = num2str(obj.ThermalCloudCenterSlope(1)/px);
                                    obj.ParaTable.Data{6,2} = num2str(obj.ThermalCloudCenterSlope(2)/px);
                            case "ParabolicFit1D"
                                    obj.ParaTable.Data{5,2} = num2str(obj.ThermalCloudCenterAcceleration(1)/px);
                                    obj.ParaTable.Data{6,2} = num2str(obj.ThermalCloudCenterAcceleration(2)/px);
                            case "SineFit1D"
                                    obj.ParaTable.Data{5,2} = num2str(obj.ThermalCloudCenterSloshAmplitude(1)/px);
                                    obj.ParaTable.Data{6,2} = num2str(obj.ThermalCloudCenterSloshAmplitude(2)/px);
                                    obj.ParaTable.Data{7,2} = num2str(obj.ThermalCloudCenterSloshOffset(1)/px);
                                    obj.ParaTable.Data{8,2} = num2str(obj.ThermalCloudCenterSloshOffset(2)/px);
                                    obj.ParaTable.Data{9,2} = num2str(obj.ThermalCloudCenterSloshFrequency(1)/px);
                                    obj.ParaTable.Data{10,2} = num2str(obj.ThermalCloudCenterSloshFrequency(2)/px);
                        end
                    end
                case "BimodalFit1D"
                    %% Thermal and condensate fit
            end

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

