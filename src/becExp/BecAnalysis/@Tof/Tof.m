classdef Tof < BecAnalysis
    %OD Summary of this class goes here
    %   Detailed explanation goes here

    properties
        FitDataX
        FitDataY
    end

    properties (SetAccess = protected)
        TofTime double
        Temperature double
        TrappingFrequency double %[omega_x;omega_y]
        ThermalCloudSizeInSitu double
        ThermalCloudCentralDensityInSitu double
    end

    properties (Hidden,Transient)
        ThermalXLine
        ThermalXFitLine
        ThermalYLine
        ThermalYFitLine
        CondensateXLine
        CondensateXFitLine
        CondensateYLine
        CondensateYFitLine
        ParaTable
        kBoverM
    end

    methods
        function obj = Tof(becExp)
            %OD Construct an instance of this class
            %   Detailed explanation goes here
            obj@BecAnalysis(becExp)
            obj.Chart(1) = Chart(...
                name = "Time of flight",...
                num = 31, ...
                fpath = fullfile(becExp.DataAnalysisPath,"Tof"),...
                loc = [-0.00001,0.032],...
                size = [0.3069,0.57]...
                );
        end

        function initialize(obj)
            if obj.BecExp.ScannedParameter ~= "TOF"
                warning("Scanned Parameter is not TOF. Can not do TOF analysis")
                return
            elseif ~isprop(obj.BecExp,"DensityFit")
                warning("No DensityFit. Can not do TOF analysis")
                return
            end
            fig = obj.Chart(1).initialize;
            obj.FitDataX = SqrtParabolicFit1D([1,1]);
            obj.FitDataY = SqrtParabolicFit1D([1,1]);
            obj.TofTime = 0;
            obj.kBoverM = Constants.SI("kB") / obj.BecExp.Atom.mass;

            if ~ishandle(fig)
                return
            end

            p1 = uipanel(fig,"Position",[0,0.3,1,0.7]);
            ax = axes(p1);
            ax.XLabel.String = "$t^{2}_{\mathrm{TOF}}$ [$\mu\mathrm{s}^2$]";
            ax.XLabel.Interpreter = "latex";
            ax.YLabel.String = "$R^{2}$ [$\mu\mathrm{m}^2$]";
            ax.YLabel.Interpreter = "latex";
            ax.FontSize = 12;
            ax.Box = "on";
            ax.XGrid = "on";
            ax.YGrid = "on";
            co = ax.ColorOrder;
            
            p2 = uipanel(fig,"Position",[0,0,1,0.3]);
            obj.ParaTable = uitable(p2,'Data', [1 2 3],Unit='normalized',Position=[0,0,1,1]);
            obj.ParaTable.ColumnName = {'Parameter','Value','Unit'};
            data{1,1} = 'Temperature';
            data{1,2} = '';
            data{1,3} = 'μK';
            data{2,1} = 'Thermal Cloud Radius in x';
            data{2,2} = '';
            data{2,3} = 'μm';
            data{3,1} = 'Thermal Cloud Radius in y';
            data{3,2} = '';
            data{3,3} = 'μm';
            data{4,1} = 'Thermal Cloud Central Column Density';
            data{4,2} = '';
            data{4,3} = 'm^-2';
            data{5,1} = 'Trapping frequency in x';
            data{5,2} = '';
            data{5,3} = 'Hz';
            data{6,1} = 'Trapping frequency in y';
            data{6,2} = '';
            data{6,3} = 'Hz';


            obj.ParaTable.Data = data;
            obj.ParaTable.FontSize = 12;
            obj.ParaTable.Units = 'pixel';
            tWidth = obj.ParaTable.Position(3);
            obj.ParaTable.ColumnWidth={tWidth/2.01 tWidth/4.01 tWidth/4.01};
            obj.ParaTable.ColumnEditable=[false false];
            obj.ParaTable.RowName=[];
            obj.ParaTable.Units = 'normalized';

            switch obj.BecExp.DensityFit.FitMethod
                case {"GaussianFit1D","BosonicGaussianFit1D"}
                    obj.ThermalXLine = line(ax,1,1);
                    obj.ThermalXLine.Marker = "o";
                    obj.ThermalXLine.MarkerFaceColor = co(1,:);
                    obj.ThermalXLine.MarkerEdgeColor = co(1,:)*.5;
                    obj.ThermalXLine.MarkerSize = 8;
                    obj.ThermalXLine.LineWidth = 2;
                    obj.ThermalXLine.LineStyle = "none";

                    obj.ThermalXFitLine = line(ax,1,1);
                    obj.ThermalXFitLine.LineWidth = 2;
                    obj.ThermalXFitLine.Color = co(1,:);

                    obj.ThermalYLine = line(ax,1,1);
                    obj.ThermalYLine.Marker = "o";
                    obj.ThermalYLine.MarkerFaceColor = co(2,:);
                    obj.ThermalYLine.MarkerEdgeColor = co(2,:)*.5;
                    obj.ThermalYLine.MarkerSize = 8;
                    obj.ThermalYLine.LineWidth = 2;
                    obj.ThermalYLine.LineStyle = "none";

                    obj.ThermalYFitLine = line(ax,1,1);
                    obj.ThermalYFitLine.LineWidth = 2;
                    obj.ThermalYFitLine.Color = co(2,:);

                    lg = legend(ax,"$R^{2}_{\mathrm{thermal},x}$ Data","$R^{2}_{\mathrm{thermal},x}$ Fit", ...
                        "$R^{2}_{\mathrm{thermal},y}$ Data","$R^{2}_{\mathrm{thermal},y}$ Fit");
                    lg.Interpreter = "latex";
                    lg.Location = "best";
            end

        end

        function updateData(obj,~)
            becExp = obj.BecExp;
            if becExp.ScannedParameter ~= "TOF" || becExp.NCompletedRun < 3 ||...
                    ~isprop(obj.BecExp,"DensityFit")
                return
            end
            obj.TofTime = becExp.ScannedParameterList * unit2SI(becExp.ScannedParameterUnit);
            wt = obj.BecExp.DensityFit.ThermalCloudSize;
            obj.FitDataX = LinearFit1D([(obj.TofTime.^2).',(wt(1,:).^2).']);
            obj.FitDataX.do;

            obj.FitDataY = LinearFit1D([(obj.TofTime.^2).',(wt(2,:).^2).']);
            obj.FitDataY.do;

            obj.Temperature = mean([obj.FitDataX.Coefficient(1),obj.FitDataY.Coefficient(1)]) / ...
                2 / obj.kBoverM;
            obj.TrappingFrequency = sqrt(1 ./ ([obj.FitDataX.Coefficient(2);obj.FitDataY.Coefficient(2)] / ...
                2 / obj.kBoverM / obj.Temperature));
            obj.ThermalCloudSizeInSitu = sqrt([obj.FitDataX.Coefficient(2);obj.FitDataY.Coefficient(2)]);
            obj.ThermalCloudCentralDensityInSitu = max(becExp.AtomNumber.Thermal) / ...
                pi / prod(obj.ThermalCloudSizeInSitu) / boseFunction(1,3) * boseFunction(1,2);
        end

        function updateFigure(obj,~)
            becExp = obj.BecExp;
            fig = obj.Chart(1).Figure;
            if becExp.ScannedParameter ~= "TOF" || becExp.NCompletedRun < 3 ...
                    || ~ishandle(fig) || ~isprop(obj.BecExp,"DensityFit")
                return
            end
            
            switch obj.BecExp.DensityFit.FitMethod
                case {"GaussianFit1D","BosonicGaussianFit1D"}
                    rawXT = obj.FitDataX.RawData;
                    fitXT = obj.FitDataX.FitPlotData;
                    rawYT = obj.FitDataY.RawData;
                    fitYT = obj.FitDataY.FitPlotData;
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
                    % ax.Title.String = string(obj.Temperature);
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

