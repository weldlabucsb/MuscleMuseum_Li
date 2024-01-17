classdef DensityFit < BecAnalysis
    %OD Summary of this class goes here
    %   Detailed explanation goes here

    properties
        FitMethod string = "BosonicGaussianFit1D"
        FitDataX
        FitDataY
    end

    properties (SetAccess = protected)
        ThermalCloudCenter %[x0t;y0t] in pixel
        ThermalCloudSize % [wt_x;wt_y] in m
        ThermalCloudCentralDensity % m^-2
        CondensateCenter %[x0c;y0c] in pixel
        CondensateSize % [wc_x;wc_y] in m
        CondensateCentralDensity % m^-2
        BackGroundDensity % m^-2
    end

    methods
        function obj = DensityFit(becExp)
            %OD Construct an instance of this class
            %   Detailed explanation goes here
            obj@BecAnalysis(becExp)
            obj.Gui(1) = Gui(...
                name = "DensityFitDisplay",...
                fpath = fullfile(becExp.DataAnalysisPath,"DensityFit"),...
                loc = [0.003125,0.032],...
                size = [0.38984375,0.330]...
                );
        end

        function initialize(obj)
            obj.Gui(1).initialize(obj.BecExp)
            obj.ThermalCloudCenter = [0;0];
            obj.ThermalCloudSize = [0;0];
            obj.ThermalCloudCentralDensity = 0;
            obj.CondensateCenter = [0;0];
            obj.CondensateSize = [0;0];
            obj.CondensateCentralDensity = 0;
            obj.BackGroundDensity = 0;

            xList = obj.BecExp.Roi.XList;
            yList = obj.BecExp.Roi.YList;

            switch obj.FitMethod
                case "GaussianFit1D"
                    obj.FitDataX = GaussianFit1D([xList,xList]);
                    obj.FitDataY = GaussianFit1D([yList,yList]);
                case "BosonicGaussianFit1D"
                    obj.FitDataX = BosonicGaussianFit1D([xList,xList]);
                    obj.FitDataY = BosonicGaussianFit1D([yList,yList]);
            end
        end

        function updateData(obj,runIdx)
            becExp = obj.BecExp;
            px = becExp.Acquisition.PixelSizeReal;

            xList = obj.BecExp.Roi.XList;
            xRaw = sum(obj.BecExp.Ad.AdData(:,:,runIdx),1).'*becExp.Acquisition.PixelSizeReal;
            yList = obj.BecExp.Roi.YList;
            yRaw = sum(obj.BecExp.Ad.AdData(:,:,runIdx),2)*becExp.Acquisition.PixelSizeReal;
            switch obj.FitMethod
                case "GaussianFit1D"
                    obj.FitDataX(runIdx) = GaussianFit1D([xList,xRaw]);
                    obj.FitDataY(runIdx) = GaussianFit1D([yList,yRaw]);
                case "BosonicGaussianFit1D"
                    obj.FitDataX(runIdx) = BosonicGaussianFit1D([xList,xRaw]);
                    obj.FitDataY(runIdx) = BosonicGaussianFit1D([yList,yRaw]);
            end

            obj.FitDataX(runIdx).do;
            obj.FitDataY(runIdx).do; 

            switch obj.FitMethod
                case "GaussianFit1D"
                    amp = [obj.FitDataX(runIdx).Coefficient(1);...
                        obj.FitDataY(runIdx).Coefficient(1)];
                    obj.ThermalCloudCenter(:,runIdx) = px * [obj.FitDataX(runIdx).Coefficient(2);...
                        obj.FitDataY(runIdx).Coefficient(2)];
                    obj.ThermalCloudSize(:,runIdx) = sqrt(2) * px * ...
                        [obj.FitDataX(runIdx).Coefficient(3);obj.FitDataY(runIdx).Coefficient(3)];
                    obj.ThermalCloudCentralDensity(runIdx) = ...
                        mean(amp/sqrt(2*pi)./flip(obj.ThermalCloudSize(:,runIdx)));
                case "BosonicGaussianFit1D"
                    amp = [obj.FitDataX(runIdx).Coefficient(1);...
                        obj.FitDataY(runIdx).Coefficient(1)];
                    obj.ThermalCloudCenter(:,runIdx) = px * [obj.FitDataX(runIdx).Coefficient(2);...
                        obj.FitDataY(runIdx).Coefficient(2)];
                    obj.ThermalCloudSize(:,runIdx) = sqrt(2) * px * ...
                        [obj.FitDataX(runIdx).Coefficient(3);obj.FitDataY(runIdx).Coefficient(3)];
                    obj.ThermalCloudCentralDensity(runIdx) = ...
                        mean(amp*boseFunction(1,2)/sqrt(pi)./flip(obj.ThermalCloudSize(:,runIdx)));
            end
        end

        function updateFigure(obj,~)
            obj.Gui(1).update
        end

    end
end

