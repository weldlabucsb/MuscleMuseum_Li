classdef DensityFit < BecAnalysis
    %OD Summary of this class goes here
    %   Detailed explanation goes here

    properties
        FitMethod string = "BosonicGaussianFit1D"
        FitData
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
            becExp = obj.BecExp;
            nSub = becExp.Roi.NSub;
            nSub(nSub == 0) = 1;

            %% Initialize plots
            obj.Gui(1).initialize(becExp)

            %% Initialize data
            obj.ThermalCloudCenter = zeros(2,1,nSub);
            obj.ThermalCloudSize = zeros(2,1,nSub);
            obj.ThermalCloudCentralDensity = zeros(1,1,nSub);
            obj.CondensateCenter = zeros(2,1,nSub);
            obj.CondensateSize = zeros(2,1,nSub);
            obj.CondensateCentralDensity = zeros(1,1,nSub);
            obj.BackGroundDensity = zeros(1,1,nSub);

            %% Initialize fit objects
            switch obj.FitMethod
                case "GaussianFit1D"
                    obj.FitData = GaussianFit1D([1,1]);
                case "BosonicGaussianFit1D"
                    obj.FitData = BosonicGaussianFit1D([1,1]);
            end
            obj.FitData = repmat(obj.FitData,2,1,nSub);
        end

        function updateData(obj,runIdx)
            becExp = obj.BecExp;
            px = becExp.Acquisition.PixelSizeReal;
            nRun = numel(runIdx);
            nSub = obj.BecExp.Roi.NSub;
            nSub(nSub == 0) = 1;

            %% Initialize fit objects
            switch obj.FitMethod
                case "GaussianFit1D"
                    fitData = GaussianFit1D([1,1]);
                case "BosonicGaussianFit1D"
                    fitData = BosonicGaussianFit1D([1,1]);
            end
            fitData = repmat(fitData,2,nRun,nSub);

            %% Assign data to the fit objects
            for ii = 1:nRun
                if isempty(becExp.Roi.SubRoi)
                    adData = becExp.Ad.AdData(:,:,runIdx(ii));
                else
                    adData = becExp.Roi.selectSub(becExp.Ad.AdData(:,:,runIdx(ii)));
                end
                for jj = 1:nSub
                    if isempty(becExp.Roi.SubRoi)
                        xList = obj.BecExp.Roi.XList;
                        yList = obj.BecExp.Roi.YList;
                        xRaw = sum(adData,1).'*px;
                        yRaw = sum(adData,2)*px;
                    else
                        xList = obj.BecExp.Roi.SubRoi(jj).XList;
                        yList = obj.BecExp.Roi.SubRoi(jj).YList;
                        xRaw = sum(adData{jj},1).'*px;
                        yRaw = sum(adData{jj},2)*px;
                    end
                    switch obj.FitMethod
                        case "GaussianFit1D"
                            fitData(1,ii,jj) = GaussianFit1D([xList,xRaw]);
                            fitData(2,ii,jj) = GaussianFit1D([yList,yRaw]);
                        case "BosonicGaussianFit1D"
                            fitData(1,ii,jj) = BosonicGaussianFit1D([xList,xRaw]);
                            fitData(2,ii,jj) = BosonicGaussianFit1D([yList,yRaw]);
                    end
                end
            end

            %% Do fit
            % if numel(fitData) > 2
                p = gcp('nocreate');
                if ~isempty(p)
                    parfor ii = 1:numel(fitData)
                        fitData(ii) = fitData(ii).do;
                    end
                else
                    for ii = 1:numel(fitData)
                        fitData(ii) = fitData(ii).do;
                    end
                end
                obj.FitData(:,runIdx,1:nSub) = fitData;
            % else
            %     fitData(1).do;
            %     fitData(2).do;
            %     obj.FitData(1,runIdx,1) = fitData(1);
            %     obj.FitData(2,runIdx,1) = fitData(2);
            % end

            %% Assign values to properties
            for ii = runIdx
                for jj = 1:nSub
                    switch obj.FitMethod
                        case "GaussianFit1D"
                            amp = [obj.FitData(1,ii,jj).Coefficient(1);...
                                obj.FitData(2,ii,jj).Coefficient(1)];
                            obj.ThermalCloudCenter(:,ii,jj) = px * [obj.FitData(1,ii,jj).Coefficient(2);...
                                obj.FitData(2,ii,jj).Coefficient(2)];
                            obj.ThermalCloudSize(:,ii,jj) = sqrt(2) * px * ...
                                [obj.FitData(1,ii,jj).Coefficient(3);obj.FitData(2,ii,jj).Coefficient(3)];
                            obj.ThermalCloudCentralDensity(1,ii,jj) = ...
                                mean(amp/sqrt(2*pi)./flip(obj.ThermalCloudSize(:,ii,jj)));
                        case "BosonicGaussianFit1D"
                            amp = [obj.FitData(1,ii,jj).Coefficient(1);...
                                obj.FitData(2,ii,jj).Coefficient(1)];
                            obj.ThermalCloudCenter(:,ii,jj) = px * [obj.FitData(1,ii,jj).Coefficient(2);...
                                obj.FitData(2,ii,jj).Coefficient(2)];
                            obj.ThermalCloudSize(:,ii,jj) = sqrt(2) * px * ...
                                [obj.FitData(1,ii,jj).Coefficient(3);obj.FitData(2,ii,jj).Coefficient(3)];
                            obj.ThermalCloudCentralDensity(1,ii,jj) = ...
                                mean(amp*boseFunction(1,2)/sqrt(pi)./flip(obj.ThermalCloudSize(:,ii,jj)));
                    end
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

