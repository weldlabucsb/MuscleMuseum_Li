classdef (Abstract) Tof < ParameterScan
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        InitialGuess
        FitRepetition = 2
        IsDisplay = 1
        CAxis = [0,1.5]
        OscillationFrequency
        PlotRange % In microns.
    end
    
    properties (Dependent)
        NewCenters
        TfRadius
        YListPlot
        PlotBoundary
    end
    
    properties (SetAccess = protected)
        Shape
        Centers
        Radii     
        Shape2
    end
    
    methods
        function obj = Tof(expName,start,stop,step,nRepetition,isNormalize)
            obj@ParameterScan(expName,start,stop,step,nRepetition,isNormalize)
        end
        
        function set.PlotRange(obj,value)
            obj.PlotRange = value;
            obj.IsChanged = 1;
        end
        
        function FitShape(obj)
            iG = obj.InitialGuess;
            tList = obj.FitList;
            nRep = obj.NRepetition;
            fitRep = obj.FitRepetition;
            startRun = obj.FitStartRun;
            stopRun = obj.FitStopRun;
            isDisp = obj.IsDisplay;
            cAxis = obj.CAxis;
            isNor = obj.IsNormalize;
            if isNor
                tList = reshape(repmat(tList,nRep*2,1),[],1);
            else
                tList = reshape(repmat(tList,nRep,1),[],1);
            end
            roiSize = obj.RoiSize;
            roiPos = obj.RoiPosition;
            nRoi = obj.NRoi;
            
            if nRoi == 3
                return
            end

            shape = zeros(8,numel(startRun:stopRun));
            for iRun = 1:numel(startRun:stopRun)
                time = tList(iRun);         
                roiData = obj.ShowRoi(iRun+startRun-1);
                
                for kk = 1:fitRep
                    fitresult = fitBimodal2D(roiData,1,iG,cAxis,time,isDisp);
                    shape(:,iRun) = coeffvalues(fitresult);
                    
                    iG.od_c = shape(1,iRun); %OD of condensate
                    iG.x0_c = shape(2,iRun); %condensate radial position
                    iG.wx_c = shape(3,iRun); %condensate radial width
                    iG.y0_c = shape(4,iRun); %condensate axial position
                    iG.wy_c = shape(5,iRun); %condensate axial width
                    iG.wx_t = shape(6,iRun); %thermal cloud radial width
                    iG.wy_t = shape(7,iRun); %thermal cloud axial width
                    iG.od_t = shape(8,iRun); %OD of thermal cloud
                end
                if ~isDisp
                    disp(['t = ',num2str(time),'ms, fitted.'])
                end
            end
            obj.Shape = shape;
            obj.Centers = shape(4,:);
            obj.Radii = shape(5,:);
            
            obj.RoiPosition = roiPos;
            obj.RoiSize = roiSize;
            obj.Update
        end
        
        function FitShape2(obj)            
            %% Read parameters from properties.
            iG0 = obj.InitialGuess;
            tList = obj.FitList;
            nRep = obj.NRepetition;
            fitRep = obj.FitRepetition;
            startRun = obj.FitStartRun;
            stopRun = obj.FitStopRun;
            isDisp = obj.IsDisplay;
            cAxis = obj.CAxis;
            isNor = obj.IsNormalize;
            nRuns = numel(startRun:stopRun);
            roiLim = obj.RoiLim;
            xMin = roiLim(:,1);
            yMin = roiLim(1,3);
            
            if isNor
                tList = reshape(repmat(tList,nRep*2,1),[],1);
            else
                tList = reshape(repmat(tList,nRep,1),[],1);
            end
            roiPos = obj.RoiPosition;
            
            %% Initialization.
            shape = zeros(8,nRuns,2);
            
            %% Fit m = +1 component.
            obj.TempRoiPosition = [roiPos(1),roiPos(4)];     
            iG = iG0;
            for iRun = 1:nRuns
                time = tList(iRun);         
                roiData = obj.ShowRoi(iRun+startRun-1);
                for kk = 1:fitRep
                    fitresult = fitBimodal2D(roiData,1,iG,cAxis,time,isDisp);
                    shape(:,iRun,1) = coeffvalues(fitresult);
                    
                    iG.od_c = shape(1,iRun,1); %OD of condensate
                    iG.x0_c = shape(2,iRun,1); %condensate radial position
                    iG.wx_c = shape(3,iRun,1); %condensate radial width
                    iG.y0_c = shape(4,iRun,1); %condensate axial position
                    iG.wy_c = shape(5,iRun,1); %condensate axial width
                    iG.wx_t = shape(6,iRun,1); %thermal cloud radial width
                    iG.wy_t = shape(7,iRun,1); %thermal cloud axial width
                    iG.od_t = shape(8,iRun,1); %OD of thermal cloud
                end
                if ~isDisp && mod(iRun,nRep) == 0
                    if ~isNor
                        disp(['t = ',num2str(time),' ms, m = +1, fitted.'])
                    elseif mod(iRun,nRep*2) == 0
                        disp(['t = ',num2str(time),' ms, m = +1, fitted.'])
                    end
                end
            end
            
            %% Fit m = -1 component
            obj.TempRoiPosition = [roiPos(3),roiPos(4)];
            iG = iG0;
            for iRun = 1:nRuns
                time = tList(iRun);         
                roiData = obj.ShowRoi(iRun+startRun-1);
                for kk = 1:fitRep
                    fitresult = fitBimodal2D(roiData,1,iG,cAxis,time,isDisp);
                    shape(:,iRun,2) = coeffvalues(fitresult);
                    
                    iG.od_c = shape(1,iRun,2); %OD of condensate
                    iG.x0_c = shape(2,iRun,2); %condensate radial position
                    iG.wx_c = shape(3,iRun,2); %condensate radial width
                    iG.y0_c = shape(4,iRun,2); %condensate axial position
                    iG.wy_c = shape(5,iRun,2); %condensate axial width
                    iG.wx_t = shape(6,iRun,2); %thermal cloud radial width
                    iG.wy_t = shape(7,iRun,2); %thermal cloud axial width
                    iG.od_t = shape(8,iRun,2); %OD of thermal cloud
                end
                if ~isDisp && mod(iRun,nRep) == 0
                    if ~isNor
                        disp(['t = ',num2str(time),' ms, m = -1, fitted.'])
                    elseif mod(iRun,nRep*2) == 0
                        disp(['t = ',num2str(time),' ms, m = -1, fitted.'])
                    end
                end
            end
            
            %% Update
            obj.Shape2 = shape;
            obj.TempRoiPosition = [];
            roiPos2 = repmat(roiPos,nRuns,1);
            xMin = repmat(xMin',nRuns,1);
            xCenterP1 = shape(2,:,1)';
            xCenterM1 = shape(2,:,2)';
            roiPos2(:,1) = round(xMin(:,1)+xCenterP1-1);
            roiPos2(:,3) = round(xMin(:,3)+xCenterM1-1);
            
            obj.Centers = shape(4,:,1)+yMin-1;
            obj.Radii = (shape(5,:,1)+shape(5,:,2))/2;
            
            obj.RoiPosition = roiPos;
            obj.RoiPosition2 = roiPos2;
            obj.Update
            
        end
          
        function FitCenterOscillation(obj)
            centers = obj.Centers;
            nRep = obj.NRepetition;
            dataAnaPath = obj.DataAnalysisPath;
            isNor = obj.IsNormalize;
            oscFreq = obj.OscillationFrequency;
            start2 = obj.FitStart2;
            
            t = obj.FitList;
            [~,startIdx] = min(abs(t-start2));
            t = t(startIdx:end);
            figPath = fullfile(dataAnaPath,'centerFit.fig');
            pngPath = fullfile(dataAnaPath,'centerFit.png');
            
%             if isempty(centers)
%                 obj.FitCenter
%                 centers = obj.Centers;
%             end
            
            if isNor
                centers = mean(reshape(centers(2:2:end),nRep,[]),1);
            else
                centers = mean(reshape(centers,nRep,[]),1);
            end
            
            centers = centers(startIdx:end);
            
            if isempty(oscFreq)
                fitResult = fitSine(t,centers);
            else
                fitResult = fitSine(t,centers,oscFreq);
            end
            obj.FitResult = fitResult;
            obj.Update
            
            omega = num2str(fitResult.omega/2/pi);
            a = num2str(fitResult.a);
            phi = num2str(fitResult.phi);
            c = num2str(fitResult.c);
            titleText = {'Center-of-mass Oscillation',...
                ['$y=',a,'\times\sin{(2\pi\times',omega,'t+',phi,')}+',c,'$']};
            
            figure(2)
            plot(fitResult,t,centers)
            title(titleText,'interpreter','latex')
            xlabel(obj.ParameterLabel,'interpreter','latex')
            ylabel('Center-of-mass $y$ position (pixel)','interpreter','latex')
            saveas(gcf,figPath)
            saveas(gcf,pngPath)
            
            roiPos2 = obj.RoiPosition2;
            newCenters = obj.NewCenters;
            if isNor
                newCenters = repmat(newCenters',nRep*2,1);
            else
                newCenters = repmat(newCenters',nRep,1);
            end
            newCenters = newCenters(:);
            roiPos2(:,4) = newCenters;
            obj.RoiPosition2 = roiPos2;
            obj.Update
        end
        
        function FitCenter(obj)
            %% Read parameters from properties.
            roiSize = obj.RoiSize;
            roiPos = obj.RoiPosition;      
            startRun = obj.FitStartRun;
            stopRun = obj.FitStopRun;
            nRuns = obj.NRuns;
            
            %% Change Roi to inclde more data points.
            obj.RoiSize = [roiSize(1),1022];
            obj.RoiPosition = [roiPos(1:end-1),512];
            roiData = arrayfun(@(x) obj.ShowRoi(x),1:nRuns,'UniformOutput',false);
            roiData = cat(4,roiData{:});
            roiData = squeeze(roiData(:,:,1,:));
            
            %% Fit centers of each image.
            [centers, radii] = arrayfun(@(x) fitCenter(roiData(:,:,x)),startRun:stopRun);
            obj.Centers = centers;
            obj.Radii = radii;
            
            %% Roll back Roi
            obj.RoiSize = roiSize;
            obj.RoiPosition = roiPos;
            obj.Update
            
        end
        
        function newCenters = get.NewCenters(obj)
            fitResult = obj.FitResult;
            if isempty(fitResult)
                newCenters = [];
            else
                t = obj.ParameterList;
                newCenters = round(fitResult(t));
            end
        end
        
        function tfRadius = get.TfRadius(obj)
            isNor = obj.IsNormalize;
            nRep = obj.NRepetition;
            radii = obj.Radii;
            if isempty(radii)
                tfRadius = [];
            else
                if isNor
                    tfRadius = mean(radii(2:2:nRep*2));
                else
                    tfRadius = mean(radii(1:nRep));
                end
                tfRadius = round(tfRadius);
            end
        end
        
        function pBound = get.PlotBoundary(obj)
            tfRadius = obj.TfRadius;
            pix = obj.PixelSize;
            pRange = obj.PlotRange; 
            b = obj.RoiSize(2);
            
            if isempty(tfRadius)
                pBound = [1,b];
            elseif isempty(pRange)
                pBound = round([b/2-tfRadius,b/2+tfRadius]);
            else
                pBound = round(b/2 + pRange./pix);
            end
        end
        
        function yPlot = get.YListPlot(obj)
            pBound = obj.PlotBoundary;
            tfRadius = obj.TfRadius;
            y = obj.YList;
            
            if isempty(tfRadius)
                yPlot = y;
            else
                y = y - y(round(1/2*numel(y)));
                yPlot = y(pBound(1):pBound(2));
            end
        end
        
    end
end

