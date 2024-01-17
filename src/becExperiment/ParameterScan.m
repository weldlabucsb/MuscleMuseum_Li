classdef (Abstract) ParameterScan < BecExperiment
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Start
        Stop
        Step = 1
        NRepetition
        IsNormalize
        ParameterPlotTitle
        FitStart
        FitStart2
        FitStop
        FitStop2
        FitResult
        FitRoi
    end
    
    properties (SetAccess = protected)
        ParameterName
        ParameterUnit
    end
    
    properties (Dependent, Hidden)
        ParameterLabel
        FitStartIndex
        FitStartIndex2
        FitStartRun
        FitStopIndex
        FitStopIndex2
        FitStopRun
        FitList
        NFit
    end
    
    properties (Dependent)
        ParameterList
        NDataSets
        NNormalizedSets
        NRuns
    end
    
    methods
        function obj = ParameterScan(expName,start,stop,step,nRepetition,isNormalize)
            obj@BecExperiment(expName)
            obj.Start = start;
            obj.Stop = stop;
            obj.Step = step;
            obj.FitStart = start;
            obj.FitStop = stop;
            obj.NRepetition = nRepetition;
            obj.IsNormalize = isNormalize;
        end
        
        function set.Stop(obj,value)
            obj.Stop = value;
            obj.IsChanged = 1;
        end
        
        function set.Start(obj,value)
            obj.Start = value;
            obj.IsChanged = 1;
        end
        
        function set.Step(obj,value)
            obj.Step = value;
            obj.IsChanged = 1;
        end
        
        function paraList = get.ParameterList(obj)
            paraList = obj.Start:obj.Step:obj.Stop;
        end
        
        function startIdx = get.FitStartIndex(obj)
            paraList = obj.ParameterList;
            fitStart = obj.FitStart;
            [~,startIdx] = min(abs(paraList-fitStart));
        end
        
        function startIdx = get.FitStartIndex2(obj)
            paraList = obj.ParameterList;
            fitStart2 = obj.FitStart2;
            [~,startIdx] = min(abs(paraList-fitStart2));
        end
        
        function startRun = get.FitStartRun(obj)
            nRep = obj.NRepetition;
            isNor = obj.IsNormalize;
            startIdx = obj.FitStartIndex;
            if isNor
                startRun = (startIdx-1)*nRep*2+1;
            else
                startRun = (startIdx-1)*nRep+1;
            end
        end
        
        function stopRun = get.FitStopRun(obj)
            nRep = obj.NRepetition;
            isNor = obj.IsNormalize;
            stopIdx = obj.FitStopIndex;
            if isNor
                stopRun = stopIdx*nRep*2;
            else
                stopRun = stopIdx*nRep;
            end
        end
        
        function stopIdx = get.FitStopIndex(obj)
            paraList = obj.ParameterList;
            fitStop = obj.FitStop;
            [~,stopIdx] = min(abs(paraList-fitStop));
        end
        
        function stopIdx = get.FitStopIndex2(obj)
            paraList = obj.ParameterList;
            fitStop2 = obj.FitStop2;
            [~,stopIdx] = min(abs(paraList-fitStop2));
        end
        
        function fitList = get.FitList(obj)
            paraList = obj.ParameterList;
            startIdx = obj.FitStartIndex;
            stopIdx = obj.FitStopIndex;
            fitList = paraList(startIdx:stopIdx);
        end
        
        function nFit = get.NFit(obj)
           fitList = obj.FitList;
           nFit = numel(fitList);
        end
        
        function paraLabel = get.ParameterLabel(obj)
            paraLabel = [obj.ParameterName,' [',obj.ParameterUnit,']'];
        end
        
        function nDataSets = get.NDataSets(obj)
            nDataSets = numel(obj.ParameterList);
        end
        
        function nNor = get.NNormalizedSets(obj)
            nNor = obj.NDataSets*obj.NRepetition;
        end
        
        function nRuns = get.NRuns(obj)
            nNor = obj.NNormalizedSets;
            if obj.IsNormalize
                nRuns = 2*nNor;
            else
                nRuns = nNor;
            end
        end
        
        function ParameterPlot(obj)
            aD = obj.axialDistribution;
            aDs = reshape(sum(aD,2),3,obj.nData);
            aDsn = aDs./repmat(sum(aDs,1),3,1);
            figure(1)
            plot(obj.parameterList,aDsn(1,:),obj.parameterList,aDsn(2,:),obj.parameterList,aDsn(3,:))
        end
        
        function varargout = ShowNor(obj,norNumber)
            %% Read parameters from properties.
            nNor = obj.NNormalizedSets;
            isNor = obj.IsNormalize;
            y = obj.YList;
            
            %% Return data
            if isNor
                if nargin == 2
                    axialData = obj.ShowAD((norNumber-1)*2+1);
                    axialData_bg = obj.ShowAD(norNumber*2);
                    norData = axialData./axialData_bg;
                    varargout{1} = norData;
                    return
                end
            else
                if nargin == 2
                    varargout{1} = obj.ShowAD(norNumber);
                    return
                else
                    disp('No normalization in this data set')
                end         
                return
            end
            
            %% Initialize the figure.
            fig = renderFigure(1,[1024,1024],'center');
            tit = sgtitle('Normalized Axial Distribution, Set 1');
            axialData0 = obj.ShowAD(1);
            axialData_bg0 = obj.ShowAD(2);
            norData0 = axialData0./axialData_bg0;
            
            ax = renderSubplot(3,1);
            cl = gobjects(1,3);
            for iSpin = 1:3
                cl(iSpin) = plot(ax(iSpin),y,norData0(:,iSpin));
                renderPlot(cl(iSpin),'$y$ position ($\mu\mathrm{m}$)','Normalized population')
            end
            setYLimit(ax,1.5,0);
            
            [slider,editbox] = createUis(fig,nNor,'set');
            
            %% Define the callback function.
            slider.Callback = @(es,ed) setHandles(cl,tit,es.Value);
            editbox.Callback = @(es,ed) setHandles(cl,tit,es.String);
            function setHandles(h,t,n)
                if class(n) == "char"
                    n = str2double(n);
                    if n>nNor || n<1 || isnan(n)
                        return
                    end
                end
                n = round(n);
                axialData = obj.ShowAD((n-1)*2+1);
                axialData_bg = obj.ShowAD(n*2);
                norData = axialData./axialData_bg;
                for ii = 1:3
                    h(ii).YData = norData(:,ii);
                end
                t.String = ['Normalized Axial Distribution, Set ',num2str(n)];
            end
                        
        end
        
        function norMat = ShowNorMat(obj)
            nSets = obj.NNormalizedSets;
            %             dataAnaPath = obj.DataAnalysisPath;
            %             expName = obj.ExperimentName;
            temp = arrayfun(@(x) obj.ShowNor(x),(1:nSets),'UniformOutput',false);
            norMat = cat(3,temp{:});
            %             save(fullfile(dataAnaPath,[expName,'.mat']),'aveMat')
        end
        
        function varargout = ShowAve(obj,setNumber)
            %% Read parameters from properties.
            nSets = obj.NDataSets;
            nRep = obj.NRepetition;
            y = obj.YList;
            
            %% Return data
            if nargin == 2
                temp = arrayfun(@(x) obj.ShowNor(x),(setNumber-1)*nRep+(1:nRep),'UniformOutput',false);
                aveData = mean(cat(3,temp{:}),3);
                varargout{1} = aveData;
                return
            end
            
            %% Initialize the figure.
            fig = renderFigure(1,[1024,1024],'center');
            tit = sgtitle('Normalized and Averaged Axial Distribution, Set 1');
            temp0 = arrayfun(@(x) obj.ShowNor(x),1:nRep,'UniformOutput',false);
            aveData0 = mean(cat(3,temp0{:}),3);
            
            ax = renderSubplot(3,1);
            cl = gobjects(1,3);
            for iSpin = 1:3
                cl(iSpin) = plot(ax(iSpin),y,aveData0(:,iSpin));
                renderPlot(cl(iSpin),'$y$ position ($\mu\mathrm{m}$)','Normalized population')
            end
            setYLimit(ax,1.5,0);
            
            [slider,editbox] = createUis(fig,nSets,'set');
            
            %% Define the callback function.
            slider.Callback = @(es,ed) setHandles(cl,tit,es.Value);
            editbox.Callback = @(es,ed) setHandles(cl,tit,es.String);
            function setHandles(h,t,n)
                if class(n) == "char"
                    n = str2double(n);
                    if n>nSets || n<1 || isnan(n)
                        return
                    end
                end
                n = round(n);
                temp = arrayfun(@(x) obj.ShowNor(x),(n-1)*nRep+(1:nRep),'UniformOutput',false);
                aveData = mean(cat(3,temp{:}),3);
                for ii = 1:3
                    h(ii).YData = aveData(:,ii);
                end
                t.String = ['Normalized and Averaged Axial Distribution, Set ',num2str(n)];
            end
        end
        
        function varargout = ShowAveOD(obj,setNumber)
            %% Read parameters from properties.
            nSets = obj.NDataSets;
            nRep = obj.NRepetition;
            
            %% Return data
            if obj.IsNormalize == 1
                return
            elseif nargin == 2
                temp = arrayfun(@(x) obj.ShowOD(x),(setNumber-1)*nRep+(1:nRep),'UniformOutput',false);
                aveOD = mean(cat(3,temp{:}),3);
                varargout{1} = aveOD;
                return
            end
            
            %% Initialize the figure.
            fig = renderFigure(1,[1024,1024],'center');
            
            temp0 = arrayfun(@(x) obj.ShowOD(x),(1-1)*nRep+(1:nRep),'UniformOutput',false);
            aveImage0 = mean(cat(3,temp0{:}),3);
            img = imagesc(aveImage0);
            tit = title('Averaged Optical Depth, Set 1');
            renderImage(img,[0,2.5],parula,0)
            
            [slider,editbox] = createUis(fig,nSets,'set');
            
            %% Define the callback function.
            slider.Callback = @(es,ed) setHandles(img,tit,es.Value);
            editbox.Callback = @(es,ed) setHandles(img,tit,es.String);
            function setHandles(h,t,n)
                if class(n) == "char"
                    n = str2double(n);
                    if n>nSets || n<1 || isnan(n)
                        return
                    end
                end
                n = round(n);
                temp = arrayfun(@(x) obj.ShowOD(x),(n-1)*nRep+(1:nRep),'UniformOutput',false);
                aveOD = mean(cat(3,temp{:}),3);
                h.CData = aveOD;
                t.String = ['Averaged Optical Depth, Set ',num2str(n)];
            end
            
        end
        
        function aveMat = ShowAveMat(obj)
            nSets = obj.NDataSets;
%             dataAnaPath = obj.DataAnalysisPath;
%             expName = obj.ExperimentName;
            temp = arrayfun(@(x) obj.ShowAve(x),(1:nSets),'UniformOutput',false);
            aveMat = cat(3,temp{:});
%             save(fullfile(dataAnaPath,[expName,'.mat']),'aveMat')
        end
        
        function popu = ShowPopu(obj,setNumber)
            nRoi = obj.NRoi;
            if nRoi == 3
                aveData = obj.ShowAve(setNumber);
                popu = sum(aveData,1);
                popu = popu/sum(popu);
            elseif nRoi == 1
                roiData = obj.ShowRoi(setNumber);
                popu = sum(roiData,'all');
            end
        end
        
        function popuMat = ShowPopuMat(obj)
            nSets = obj.NDataSets;
            dataAnaPath = obj.DataAnalysisPath;
            expName = obj.ExperimentName;
            popuMat = cell2mat(arrayfun(@(x) obj.ShowPopu(x),(1:nSets)','UniformOutput',false));
            save(fullfile(dataAnaPath,[expName,'.mat']),'popuMat')
        end
        
        function PlotPopu(obj)
            %% Read parameters from properties.
            dataAnaPath = obj.DataAnalysisPath;
            expName = obj.ExperimentName;
            nSets = obj.NDataSets;
            plotTitle = obj.ParameterPlotTitle;
            nRoi = obj.NRoi;
            
            %% Calculate population
            popuMatPath = fullfile(dataAnaPath,[expName,'.mat']);
            if exist(popuMatPath,'file')
                load(popuMatPath,'popuMat')
            else
                popuMat = cell2mat(arrayfun(@(x) obj.ShowPopu(x),(1:nSets)','UniformOutput',false));
            end
            
            %% Plot
            figPath = fullfile(dataAnaPath,[expName,'.fig']);
            pngPath = fullfile(dataAnaPath,[expName,'.png']);
            figure(2)
            plot(obj.ParameterList,popuMat)
            if nRoi == 3        
                legend('m = +1','m = 0','m = -1')
                ylabel('Normalized population','interpreter','latex')
            elseif nRoi == 1
                ylabel('Optical depth','interpreter','latex')
            end
            xlabel(obj.ParameterLabel,'interpreter','latex')
            
            title(plotTitle,'interpreter','latex')
            saveas(gcf,figPath)
            saveas(gcf,pngPath)
            
        end
    end
    
end