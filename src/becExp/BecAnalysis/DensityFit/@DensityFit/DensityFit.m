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
            nRun = numel(runIdx);

            %% Initialize the fit objects
            switch obj.FitMethod
                case "GaussianFit1D"
                    fitDataX = GaussianFit1D.empty(0,nRun);
                    fitDataY = GaussianFit1D.empty(0,nRun);
                case "BosonicGaussianFit1D"
                    fitDataX = BosonicGaussianFit1D.empty(0,nRun);
                    fitDataY = BosonicGaussianFit1D.empty(0,nRun);
            end

            %% Assign data to the fit objects
            xList = obj.BecExp.Roi.XList;
            yList = obj.BecExp.Roi.YList;
            for ii = 1:nRun     
                xRaw = sum(obj.BecExp.Ad.AdData(:,:,runIdx(ii)),1).'*px;
                yRaw = sum(obj.BecExp.Ad.AdData(:,:,runIdx(ii)),2)*px;
                switch obj.FitMethod
                    case "GaussianFit1D"
                        fitDataX(ii) = GaussianFit1D([xList,xRaw]);
                        fitDataY(ii) = GaussianFit1D([yList,yRaw]);
                    case "BosonicGaussianFit1D"
                        fitDataX(ii) = BosonicGaussianFit1D([xList,xRaw]);
                        fitDataY(ii) = BosonicGaussianFit1D([yList,yRaw]);
                end
            end

            %% Do fit
            if nRun > 1
                p = gcp('nocreate');
                if ~isempty(p)
                    parfor ii = 1:nRun
                        fitDataX(ii) = fitDataX(ii).do;
                        fitDataY(ii) = fitDataY(ii).do;
                    end
                else
                    for ii = 1:nRun
                        fitDataX(ii) = fitDataX(ii).do;
                        fitDataY(ii) = fitDataY(ii).do;
                    end
                end
                obj.FitDataX(runIdx) = fitDataX;
                obj.FitDataY(runIdx) = fitDataY;
            else
                fitDataX.do;
                fitDataY.do;
                obj.FitDataX(runIdx) = fitDataX;
                obj.FitDataY(runIdx) = fitDataY;
            end

            %% Assign values to properties
            for ii = runIdx
                switch obj.FitMethod
                    case "GaussianFit1D"
                        amp = [obj.FitDataX(ii).Coefficient(1);...
                            obj.FitDataY(ii).Coefficient(1)];
                        obj.ThermalCloudCenter(:,ii) = px * [obj.FitDataX(ii).Coefficient(2);...
                            obj.FitDataY(ii).Coefficient(2)];
                        obj.ThermalCloudSize(:,ii) = sqrt(2) * px * ...
                            [obj.FitDataX(ii).Coefficient(3);obj.FitDataY(ii).Coefficient(3)];
                        obj.ThermalCloudCentralDensity(ii) = ...
                            mean(amp/sqrt(2*pi)./flip(obj.ThermalCloudSize(:,ii)));
                    case "BosonicGaussianFit1D"
                        amp = [obj.FitDataX(ii).Coefficient(1);...
                            obj.FitDataY(ii).Coefficient(1)];
                        obj.ThermalCloudCenter(:,ii) = px * [obj.FitDataX(ii).Coefficient(2);...
                            obj.FitDataY(ii).Coefficient(2)];
                        obj.ThermalCloudSize(:,ii) = sqrt(2) * px * ...
                            [obj.FitDataX(ii).Coefficient(3);obj.FitDataY(ii).Coefficient(3)];
                        obj.ThermalCloudCentralDensity(ii) = ...
                            mean(amp*boseFunction(1,2)/sqrt(pi)./flip(obj.ThermalCloudSize(:,ii)));
                end
            end
        end

        function updateFigure(obj,~)
            obj.Gui(1).update
        end

        function refresh(obj)
            obj.initialize;
            nRun = obj.BecExp.NCompletedRun;
            obj.updateData(1:nRun);
            obj.updateFigure(1);
        end

    end
end

