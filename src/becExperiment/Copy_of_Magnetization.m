classdef Magnetization < Tof
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MagnetizationAxis = [-0.15,0.15]
        DensityAxis = [0.7,1.3]
        NormalizationMethod = 1
        WaterfallStep = 5
        MagWaterfallTickStep = 0.25
        DensWaterfallTickStep = 0.6
        IsShift = 0
        IsShift2Each = 0
        SizeGuess = 30
        ManakovInitialGuess
        ManakovSizeGuess = 20
        ManakovFitRoi
        PulseDuration = 50
        Threshhold1 = 25;
        Threshhold2 = 30;
    end
    
    properties (SetAccess = private)
        SolitonPosition
        SolitonVelocity
        SpinHealingLength
        ManakovPosition
        SolitonFitResult
        SolitonFittedVelocity % [data,error]
        SolitonFittedAmplitude % [Positive amplitude,error; Negative amplitude,error]
    end
    
    methods
        function obj = Magnetization(start,stop,step,nRepetition,isNormalize,pulseDuration)
            obj@Tof('magnetization',start,stop,step,nRepetition,isNormalize)
            obj.ParameterName = 'Hold time';
            obj.ParameterUnit = '$\mathrm{ms}$';
            obj.PulseDuration = pulseDuration;
            
            iG.od_c = 0.7421; %OD of condensate
            iG.x0_c = 99.29; %condensate radial position
            iG.wx_c = 113.9; %condensate radial width
            iG.y0_c = 546; %condensate axial position
            iG.wy_c = 319.4; %condensate axial width
            iG.wx_t = 227.7; %thermal cloud radial width
            iG.wy_t = 620.9; %thermal cloud axial width
            iG.od_t = 0.3; %OD of thermal cloud
            
            obj.InitialGuess = iG;
            obj.Update
        end
        
        function varargout = ShowMag(obj,setNumber)
            %% Read parameters from properties.
            nSets = obj.NDataSets;
            y = obj.YList;
            magAxis = obj.MagnetizationAxis;
            densAxis = obj.DensityAxis;
            normMethod = obj.NormalizationMethod;
            nRep = obj.NRepetition;
            isShift = obj.IsShift;
            is2Each = obj.IsShift2Each;
            centers = obj.Centers;     
            startIdx = obj.FitStartIndex;
            isNor = obj.IsNormalize;
            if isNor
                centers = mean(reshape(centers(2:2:end),nRep,[]),1);
            else
                centers = mean(reshape(centers,nRep,[]),1);
            end
            
            %% Return data
            if nargin == 2
                if isShift
                    newCenters = obj.NewCenters;
                    roiPos = obj.RoiPosition;
                    if is2Each
                        if setNumber<startIdx
                            obj.RoiPosition(4) = newCenters(setNumber);
                        else
                            obj.RoiPosition(4) = round(centers(setNumber-startIdx+1));
                        end
                    else
                        obj.RoiPosition(4) = newCenters(setNumber);
                    end
                end
                if normMethod == 1 % Method 1.
                    aveData = obj.ShowAve(setNumber);
                    magData = (aveData(:,1) - aveData(:,3))/2;
                    densData = (aveData(:,1) + aveData(:,3))/2;
                    varargout{1} = magData;
                    varargout{2} = densData;
                elseif normMethod == 2 % Method 2.
                    axialData = arrayfun(@(x) obj.ShowAD(x),(setNumber-1)*nRep*2+1:2:(setNumber)*nRep*2,...
                        'UniformOutput',false);
                    axialData = cat(3,axialData{:});
                    axialData_bg = arrayfun(@(x) obj.ShowAD(x),(setNumber-1)*nRep*2+2:2:(setNumber)*nRep*2,...
                        'UniformOutput',false);
                    axialData_bg = cat(3,axialData_bg{:});
                    magData = (axialData(:,1,:)-axialData(:,3,:))./(axialData(:,1,:)+axialData(:,3,:));
                    magData_bg = (axialData_bg(:,1,:)-axialData_bg(:,3,:))./(axialData_bg(:,1,:)+axialData_bg(:,3,:));
                    magData = squeeze(mean(magData-magData_bg,3));
                    varargout{1} = magData;
                end
                if isShift
                    obj.RoiPosition = roiPos;
                end
                return
            end
            
            %% Initialize the figure.
            fig = renderFigure(1,[1024,1024],'center');
            tit = sgtitle('Magnetization and Density Axial Distribution, Set 1');
            aveData0 = obj.ShowAve(1);
            magData0 = (aveData0(:,1) - aveData0(:,3))/2;
            densData0 = (aveData0(:,1) + aveData0(:,3))/2;
            
            ax = renderSubplot(2,0);
            cl(1) = plot(ax(1),y,magData0);
            renderPlot(cl,'$y$ position ($\mu\mathrm{m}$)','Normalized magnetization')
            ax(1).YLim = magAxis;
            
            cl(2) = plot(ax(2),y,densData0);
            renderPlot(cl(2),'$y$ position ($\mu\mathrm{m}$)','Normalized Density')
            ax(2).YLim = densAxis;
            
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
                aveData = obj.ShowAve(n);
                magData = (aveData(:,1) - aveData(:,3))/2;
                densData = (aveData(:,1) + aveData(:,3))/2;
                
                h(1).YData = magData;
                h(2).YData = densData;
                t.String = ['Magnetization and Density Axial Distribution, Set ',num2str(n)];
            end
            
        end
        
        function varargout = ShowMagMat(obj)
            %% Read parameters from properties.
            nSets = obj.NDataSets;
            pBound = obj.PlotBoundary;
            magAxis = obj.MagnetizationAxis;
            densAxis = obj.DensityAxis;
            dataAnaPath = obj.DataAnalysisPath;
            expName = obj.ExperimentName;
            wStep = obj.WaterfallStep;
            mwtStep = obj.MagWaterfallTickStep;
            dwtStep = obj.DensWaterfallTickStep;
            isChanged = obj.IsChanged;
            xLabel = '$y$ position [$\mu\mathrm{m}$]';
            yLabel = obj.ParameterLabel;
            t = obj.ParameterList;
            yPlot = obj.YListPlot;
            
            %% Calculate magnetization and density matrix.
            matName = fullfile(dataAnaPath,[expName,'.mat']);
            densName = fullfile(dataAnaPath,'density.mat');
            if isChanged
                [magMat,densMat] = arrayfun(@(x) obj.ShowMag(x),(1:nSets),'UniformOutput',false);
                magMat = cell2mat(magMat);
                densMat = cell2mat(densMat);
                save(matName,'magMat')
                save(densName,'densMat')
                obj.IsChanged = 0;
            else
                load(matName,'magMat')
                load(densName,'densMat')
            end
            magMat = magMat(pBound(1):pBound(2),:);
            densMat = densMat(pBound(1):pBound(2),:);
            if nargout >= 1
                varargout{1} = magMat;
                varargout{2} = densMat;
                return
            end
            
            %% 2D plot of magnetization.
            figure(2)
            img = imagesc(magMat);
            renderImage(img,magAxis,parula,1)
            renderTicks(img,t,yPlot)
            xlabel(yLabel,'interpreter','latex')
            ylabel(xLabel,'interpreter','latex')
            title('Normalized Magnetization')
            axis normal
            ax = gca;
            ax.YDir = 'normal';
            movegui('northwest')
            
            figName = fullfile(dataAnaPath,[expName,'.fig']);
            pngName = fullfile(dataAnaPath,[expName,'.png']);
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Waterfall plot of magnetization.
            figure(3)
            clf
            hold on
            jj = 0;
            for ii = 1:wStep:nSets
                jj = jj+1;
                plot(-magMat(:,ii)+mwtStep*jj,yPlot);
            end
            axis([-inf,inf,yPlot(1),yPlot(end)])
            hold off
            xlabel(yLabel,'interpreter','latex')
            ylabel(xLabel,'interpreter','latex')
            title('Normalized Magnetization')
            ax = gca;
            ax.XTickMode = 'manual';
            ax.XTick = (1:jj)*mwtStep;
            ax.XTickLabel = t(1:wStep:nSets);
            ax.XLim = [0,(jj+1)*mwtStep];
%             ax.XDir = 'reverse';
            ax.Box = 'on';
            movegui('north')
            figName = fullfile(dataAnaPath,[expName,'_waterfall.fig']);
            pngName = fullfile(dataAnaPath,[expName,'_waterfall.png']);
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% 2D plot of density.
            figure(4)
            img = imagesc(densMat');
            renderImage(img,densAxis,parula,1)
            renderTicks(img,yPlot,t)
            xlabel(xLabel,'interpreter','latex')
            ylabel(yLabel,'interpreter','latex')
            title('Normalized Density')
            axis normal
            ax = gca;
            ax.YDir = 'reverse';
            movegui('southwest')
            
            figName = fullfile(dataAnaPath,'density.fig');
            pngName = fullfile(dataAnaPath,'density.png');
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Waterfall plot of density.
            figure(5)
            clf
            hold on
            jj = 0;
            for ii = 1:wStep:nSets
                jj = jj+1;
                plot(yPlot,densMat(:,ii)-1+dwtStep*jj);
            end
            
            hold off
            xlabel(xLabel,'interpreter','latex')
            ylabel(yLabel,'interpreter','latex')
            title('Normalized Density')
            ax = gca;
            ax.YTickMode = 'manual';
            ax.YTick = (1:jj)*dwtStep;
            ax.YTickLabel = t(1:wStep:nSets);
            ax.YLim = [0,(jj+1)*dwtStep];
            ax.YDir = 'reverse';
            movegui('south')
            
            figName = fullfile(dataAnaPath,'density_waterfall.fig');
            pngName = fullfile(dataAnaPath,'density_waterfall.png');
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
        end
        
        function FitSoliton(obj)
            %% Read parameters from properties.
            fitRoi = obj.FitRoi;
            isDisp = obj.IsDisplay;
            solSize = obj.SizeGuess;
            y = obj.YList;
            t = obj.FitList;
            nFit = obj.NFit;
            startIdx = obj.FitStartIndex;
            th1 = obj.Threshhold1;
            th2 = obj.Threshhold2;
%             stopIdx = obj.FitStopIndex;
            
            %% Plot preparation.
            xLabel = '$y$ position [$\mu\mathrm{m}$]';
            yLabel = 'Normalized magnetiztion';
            if isDisp
                figure(3)
            end
            
            %% Initialization.
            y = y(fitRoi(1):fitRoi(2));
            solPosList = zeros(2,nFit);
            solVelList = zeros(2,nFit);
            xi_s = zeros(2,nFit);
            fitRoiSize = numel(y);
            
            %% Fit
            for iSet = 1:nFit
                %% Load data.
                magData = obj.ShowMag(iSet+startIdx-1);
                solData = magData(fitRoi(1):fitRoi(2));
                [~,idx] = sort(solData);
                
                %% Fit positive solitons.
                [~,solPos] = max(solData);
                
                if iSet > 1
                    for ii = 1:fitRoiSize-1
                        if abs(y(solPos)-solPosList(1,(iSet-1)))>th1
                            solPos = idx(end-ii);
                        else
                            break
                        end
                    end
                end
                
                solDataFit = solData(round(solPos-solSize/2):round(solPos+solSize/2));
                yFit = y(round(solPos-solSize/2):round(solPos+solSize/2));
                fitResult = fitMagSoliton(yFit,solDataFit,1);
                solPosList(1,iSet) = fitResult.x_c;
                solVelList(1,iSet) = fitResult.U;
                xi_s(1,iSet) = fitResult.xi_s;
                
                if isDisp
                    plot(fitResult,y,solData)
                    xlabel(xLabel,'Interpreter','latex')
                    ylabel(yLabel,'Interpreter','latex')
                    title(['Positive Magnetic Soliton, $t=',num2str(t(iSet)),'~\mathrm{ms}$'],...
                        'interpreter','latex')
                    pause(1.5)
                end
                
                %% Fit negative solitons
                [~,solPos] = min(solData);
                
                if iSet > 1
                    for ii = 1:fitRoiSize-1
                        if abs(y(solPos)-solPosList(2,(iSet-1)))>th2
                            solPos = idx(1+ii);
                        else
                            break
                        end
                    end
                end
                
                solDataFit = solData(round(solPos-solSize/2):round(solPos+solSize/2));
                yFit = y(round(solPos-solSize/2):round(solPos+solSize/2));
                fitResult = fitMagSoliton(yFit,solDataFit,0);
                solPosList(2,iSet) = fitResult.x_c;
                solVelList(2,iSet) = fitResult.U;
                xi_s(2,iSet) = fitResult.xi_s;
                
                if isDisp
                    plot(fitResult,y,solData)
                    xlabel(xLabel,'Interpreter','latex')
                    ylabel(yLabel,'Interpreter','latex')
                    title(['Negative Magnetic Soliton, $t=',num2str(t(iSet)),'~\mathrm{ms}$'],...
                        'interpreter','latex')
                    pause(1.5)
                end
                
            end
            
            %% Update
            obj.SolitonPosition = solPosList;
            obj.SolitonVelocity = solVelList;
            obj.SpinHealingLength = xi_s;
            
        end
        
        function FitSoliton2(obj)
            %% Read parameters from properties.
            fitRoi = obj.FitRoi;
            isDisp = obj.IsDisplay;
            solSize = obj.SizeGuess;
            y = obj.YList;
            t = obj.FitList;
            nFit = obj.NFit;
            startIdx = obj.FitStartIndex;
            nRep = obj.NRepetition;
            th1 = obj.Threshhold1;
            th2 = obj.Threshhold2;
            
%             stopIdx = obj.FitStopIndex;
            
            %% Plot preparation.
            xLabel = '$y$ position [$\mu\mathrm{m}$]';
            yLabel = 'Normalized magnetiztion';
            if isDisp
                figure(3)
            end
            
            %% Initialization.
            y = y(fitRoi(1):fitRoi(2));
            solPosList = zeros(2,nFit,nRep);
            solVelList = zeros(2,nFit,nRep);
            xi_s = zeros(2,nFit,nRep);
            fitRoiSize = numel(y);
            
            %% Fit
            for iSet = 1:nFit
                for iNor = 1:nRep
                    %% Load data.
                    norData = obj.ShowNor((iSet+startIdx-2)*nRep+iNor);
                    magData = (norData(:,1)-norData(:,3))/2;
                    solData = magData(fitRoi(1):fitRoi(2));
                    [~,idx] = sort(solData);
                    
                    %% Fit positive solitons.
                    [~,solPos] = max(solData);
                    
                    if ~(iSet == 1 && iNor==1)
                        for ii = 1:fitRoiSize-1
                            if abs(y(solPos)-pPosTemp)>th1
                                solPos = idx(end-ii);
                            else
                                break
                            end
                        end
                    end
                    
                    solDataFit = solData(round(solPos-solSize/2):round(solPos+solSize/2));
                    yFit = y(round(solPos-solSize/2):round(solPos+solSize/2));
                    fitResult = fitMagSoliton(yFit,solDataFit,1);
                    solPosList(1,iSet,iNor) = fitResult.x_c;
                    solVelList(1,iSet,iNor) = fitResult.U;
                    xi_s(1,iSet,iNor) = fitResult.xi_s;
                    pPosTemp = fitResult.x_c;
%                     disp(fitError(fitResult))
                    
                    if isDisp
                        plot(fitResult,y,solData)
                        xlabel(xLabel,'Interpreter','latex')
                        ylabel(yLabel,'Interpreter','latex')
                        title(['Positive Magnetic Soliton, $t=',num2str(t(iSet)),'~\mathrm{ms}$'],...
                            'interpreter','latex')
%                         pause(1.5)
                    end
                    
                    %% Fit negative solitons
                    [~,solPos] = min(solData);
                    
                    if ~(iSet == 1 && iNor==1)
                        for ii = 1:fitRoiSize-1
                            if abs(y(solPos)-nPosTemp)>th2
                                solPos = idx(1+ii);
                            else
                                break
                            end
                        end
                    end
                    
                    solDataFit = solData(round(solPos-solSize/2):round(solPos+solSize/2));
                    yFit = y(round(solPos-solSize/2):round(solPos+solSize/2));
                    fitResult = fitMagSoliton(yFit,solDataFit,0);
                    solPosList(2,iSet,iNor) = fitResult.x_c;
                    solVelList(2,iSet,iNor) = fitResult.U;
                    xi_s(2,iSet,iNor) = fitResult.xi_s;
                    nPosTemp = fitResult.x_c;
                    
                    if isDisp
                        plot(fitResult,y,solData)
                        xlabel(xLabel,'Interpreter','latex')
                        ylabel(yLabel,'Interpreter','latex')
                        title(['Negative Magnetic Soliton, $t=',num2str(t(iSet)),'~\mathrm{ms}$'],...
                            'interpreter','latex')
%                         pause(1.5)
                    end
                    
                end
            end
            
            %% Update
            obj.SolitonPosition = solPosList;
            obj.SolitonVelocity = solVelList;
            obj.SpinHealingLength = xi_s;
            
        end
        
        function FitManakov(obj)
            %% Read parameters from properties.
            fitRoi = obj.ManakovFitRoi;
            isDisp = obj.IsDisplay;
            solSize = obj.ManakovSizeGuess;
            y = obj.YList;
            t = obj.FitList;
            nFit = obj.NFit;
            startIdx = obj.FitStartIndex;
            mIG = obj.ManakovInitialGuess;
%             stopIdx = obj.FitStopIndex;
            
            %% Plot preparation.
            xLabel = '$y$ position [$\mu\mathrm{m}$]';
            yLabel = 'Normalized magnetiztion';
            if isDisp
                figure(3)
            end
            
            %% Initialization.
            y = y(fitRoi(1):fitRoi(2));
%             solPosList = zeros(2,nFit);
%             solVelList = zeros(2,nFit);
%             xi_s = zeros(2,nFit);
            mPos = zeros(1,nFit);
            th = 12;
            fitRoiSize = numel(y);
            
            %% Fit
            for iSet = 1:nFit
                %% Load data.
                magData = obj.ShowMag(iSet+startIdx-1);
                solData = magData(fitRoi(1):fitRoi(2));
                [~,idx] = sort(solData);
                
                %% Fit positive solitons.
                [~,solPos] = max(solData);
                
                if iSet > 1
                    for ii = 1:fitRoiSize-1
                        if abs(y(solPos)-mPos(1,(iSet-1)))>th
                            solPos = idx(end-ii);
                        else
                            break
                        end
                    end
                else   
                    [~,solPos] = min(abs(mIG-y));
                end
                
                solDataFit = solData(round(solPos-solSize/2):round(solPos+solSize/2));
                yFit = y(round(solPos-solSize/2):round(solPos+solSize/2));
                fitResult = fitMagSoliton(yFit,solDataFit,1);
                mPos(iSet) = fitResult.x_c;
%                 solPosList(1,iSet) = fitResult.x_c;
%                 solVelList(1,iSet) = fitResult.U;
%                 xi_s(1,iSet) = fitResult.xi_s;
                
                if isDisp
                    plot(fitResult,y,solData)
                    xlabel(xLabel,'Interpreter','latex')
                    ylabel(yLabel,'Interpreter','latex')
                    title(['Positive Magnetic Soliton, $t=',num2str(t(iSet)),'~\mathrm{ms}$'],...
                        'interpreter','latex')
                    pause(1.5)
                end
                
                %% Fit negative solitons
%                 [~,solPos] = min(solData);
%                 
%                 if iSet > 1
%                     for ii = 1:fitRoiSize-1
%                         if abs(y(solPos)-solPosList(2,(iSet-1)))>th
%                             solPos = idx(1+ii);
%                         else
%                             break
%                         end
%                     end
%                 end
%                 
%                 solDataFit = solData(round(solPos-solSize/2):round(solPos+solSize/2));
%                 yFit = y(round(solPos-solSize/2):round(solPos+solSize/2));
%                 fitResult = fitMagSoliton(yFit,solDataFit,0);
%                 solPosList(2,iSet) = fitResult.x_c;
%                 solVelList(2,iSet) = fitResult.U;
%                 xi_s(2,iSet) = fitResult.xi_s;
%                 
%                 if isDisp
%                     plot(fitResult,y,solData)
%                     xlabel(xLabel,'Interpreter','latex')
%                     ylabel(yLabel,'Interpreter','latex')
%                     title(['Negative Magnetic Soliton, $t=',num2str(t(iSet)),'~\mathrm{ms}$'],...
%                         'interpreter','latex')
%                     pause(1.5)
%                 end
                
            end
            
            %% Update
            obj.ManakovPosition = mPos;
%             obj.SolitonVelocity = solVelList;
%             obj.SpinHealingLength = xi_s;
            
        end
        
        function PlotSoliton(obj)
            %% Read parameters from properties.
            t = obj.FitList;
            nSets = obj.NDataSets;
            xLabel = obj.ParameterLabel;
            daPath = obj.DataAnalysisPath;
            lg = {'Positive soliton','Negative soliton'};
            
            %% Read soliton data.
            solPos = obj.SolitonPosition;
            solVel = obj.SolitonVelocity;
            xi_s = obj.SpinHealingLength;
            if isempty(solPos)
                obj.FitSoliton
                solPos = obj.SolitonPosition;
                solVel = obj.SolitonVelocity;
                xi_s = obj.SpinHealingLength;
            end
            
            %% Plot soliton positions.
            yLabel = 'Soliton position [$\mu\mathrm{m}$]';
            figName = fullfile(daPath,'solitonPosition.fig');
            pngName = fullfile(daPath,'solitonPosition.png');
            
            figure(2)
            plot(t,solPos,'.')
            xlabel(xLabel,'Interpreter','latex')
            ylabel(yLabel,'Interpreter','latex')
            title('Soliton Positions')
            legend(lg{:})
            movegui('northwest')
            
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Fit and plot relative soliton position.
            relPos = (solPos(1,:)-solPos(2,:))/2;
            fitFun = fittype('poly1');
            fitResult = fit(t',relPos',fitFun);
            fitData = fitResult(t);
            errors = confint(fitResult);
            error1 = fitResult.p1-errors(1,1);
            error2 = fitResult.p2-errors(1,2);
            
            yLabel = 'Soliton position [$\mu\mathrm{m}$]';
            figName = fullfile(daPath,'relativePosition.fig');
            pngName = fullfile(daPath,'relativePosition.png');
            
            figure(3)
            plot(t,relPos,'.',t,fitData)
            xlabel(xLabel,'Interpreter','latex')
            ylabel(yLabel,'Interpreter','latex')
            title({'Soliton Position',['$y=(',num2str(fitResult.p1),'\pm',num2str(error1),')t+(',...
                num2str(fitResult.p2),'\pm',num2str(error2),')$']},'interpreter','latex')
            movegui('north')
            
            obj.SolitonFitResult = fitResult;
            
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Plot U
            xiAve = mean(solVel,2);
            
            yLabel = '$U$';
            figName = fullfile(daPath,'U.fig');
            pngName = fullfile(daPath,'U.png');
            
            figure(4)
            plot(t,solVel,'.')
            xlabel(xLabel,'Interpreter','latex')
            ylabel(yLabel,'Interpreter','latex')
            title({'Soliton Parameter $U=V/c_s$',['Average Values: ',num2str(xiAve(1)),...
                '(positive), ',num2str(xiAve(2)),'(negative)']},'interpreter','latex')
            legend(lg{:})
            movegui('southwest')
            
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Plot amplitude
            ampAve = mean(sqrt(1-solVel.^2),2);
            
            yLabel = 'Soliton amplitude';
            figName = fullfile(daPath,'amplitude.fig');
            pngName = fullfile(daPath,'amplitude.png');
            
            figure(5)
            plot(t,sqrt(1-solVel.^2),'-+')
            xlabel(xLabel,'Interpreter','latex')
            ylabel(yLabel,'Interpreter','latex')
            title({'Soliton amplitude $\sqrt{1-U^2}$',['Average Values: ',num2str(ampAve(1)),...
                '(positive), ',num2str(ampAve(2)),'(negative)']},'interpreter','latex')
            legend(lg{:})
            movegui('south')
            
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Plot xi_s
            xiAve = mean(xi_s,2);
            
            yLabel = '$\xi_s$ $[\mu\mathrm{m}]$';
            figName = fullfile(daPath,'xi_s.fig');
            pngName = fullfile(daPath,'xi_s.png');
            
            figure(6)
            plot(t,xi_s,'.')
            xlabel(xLabel,'Interpreter','latex')
            ylabel(yLabel,'Interpreter','latex')
            title({'Spin Healing Length $\xi_s$',['Average Values: ',num2str(xiAve(1)),...
                '~$\mu\mathrm{m}$ (positive), ',num2str(xiAve(2)),'~$\mu\mathrm{m}$ (negative)']},'interpreter','latex')
            legend(lg{:})
            movegui('southeast')
            
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            obj.Update
            
        end
        
        function PlotSoliton2(obj)
            %% Read parameters from properties.
            t = obj.FitList;
            xLabel = obj.ParameterLabel;
            daPath = obj.DataAnalysisPath;
            start2 = obj.FitStart2;
            lg = {'Positive soliton','Negative soliton'};
            
            if ~isempty(start2)
                [~,idx] = min(abs(t - start2));
                t = t(idx:end);
            end
            
            %% Read soliton data.
            solPos = obj.SolitonPosition;
            solVel = obj.SolitonVelocity;
            xi_s = obj.SpinHealingLength;
            if isempty(solPos)
                obj.FitSoliton
                solPos = obj.SolitonPosition;
                solVel = obj.SolitonVelocity;
                xi_s = obj.SpinHealingLength;
            end
            
            if ~isempty(start2)
                solPos = solPos(:,idx:end,:);
                solVel = solVel(:,idx:end,:);
                xi_s = xi_s(:,idx:end,:);
            end
            
            %% Calculation
            solVel1 = solVel(1,:,:);
            solVel2 = solVel(2,:,:);
            solVel1 = solVel1(:);
            solVel2 = solVel2(:);
            UAve = [mean(solVel1),mean(solVel2)];
            U_s = [std(solVel1),std(solVel2)];
            ampAve = sqrt(1-UAve.^2);
            ampAve_s = (UAve./sqrt(1-UAve.^2)).*U_s;
            
            solPos_s = std(solPos,0,3);
            solVel_s = std(solVel,0,3);
            xi_s_s = std(xi_s,0,3);
            
            solPos = mean(solPos,3);
            solVel = mean(solVel,3);
            xi_s = mean(xi_s,3);
            
            amp = sqrt(1-solVel.^2);
            amp_s = (solVel./sqrt(1-solVel.^2)).*solVel_s;
            
            %% Plot soliton positions.
            yLabel = 'Soliton position [$\mu\mathrm{m}$]';
            figName = fullfile(daPath,'solitonPosition.fig');
            pngName = fullfile(daPath,'solitonPosition.png');
            
            figure(2)
            clf
            hold on
            errorbar(t,solPos(1,:),solPos_s(1,:),'o')
            errorbar(t,solPos(2,:),solPos_s(2,:),'o')
            hold off
            xlabel(xLabel,'Interpreter','latex')
            ylabel(yLabel,'Interpreter','latex')
            title('Soliton Positions')
            legend(lg{:})
            movegui('northwest')
            
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Fit and plot relative soliton position.
            relPos = (solPos(1,:)-solPos(2,:))/2;
            relPos_s = sqrt(solPos_s(1,:).^2+solPos_s(2,:).^2);
            
            fitFun = fittype('poly1');
            fitResult = fit(t',relPos',fitFun);
            tPlot = obj.ParameterList;
            fitData = fitResult(tPlot);
            errors = fitError(fitResult);
            error1 = errors(1);
            error2 = errors(2);
            
            yLabel = 'Soliton position [$\mu\mathrm{m}$]';
            figName = fullfile(daPath,'relativePosition.fig');
            pngName = fullfile(daPath,'relativePosition.png');
            
            figure(3)
            clf
            hold on
            errorbar(t,relPos,relPos_s,'o')
            plot(tPlot,fitData)
            hold off
            xlabel(xLabel,'Interpreter','latex')
            ylabel(yLabel,'Interpreter','latex')
            title({'Soliton Position',['$y=(',num2str(fitResult.p1),'\pm',num2str(error1),')t+(',...
                num2str(fitResult.p2),'\pm',num2str(error2),')$']},'interpreter','latex')
            legend('Data','Fit result')
            movegui('north')
            
            obj.SolitonFitResult = fitResult;
            obj.SolitonFittedVelocity = [fitResult.p1,error1];
            
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Plot U
            xiAve = mean(solVel,2);
            
            yLabel = '$U$';
            figName = fullfile(daPath,'U.fig');
            pngName = fullfile(daPath,'U.png');
            
            figure(4)
            plot(t,solVel,'.')
            xlabel(xLabel,'Interpreter','latex')
            ylabel(yLabel,'Interpreter','latex')
            title({'Soliton Parameter $U=V/c_s$',['Average Values: ',num2str(xiAve(1)),...
                '(positive), ',num2str(xiAve(2)),'(negative)']},'interpreter','latex')
            legend(lg{:})
            movegui('southwest')
            
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Plot amplitude         
            yLabel = 'Soliton amplitude';
            figName = fullfile(daPath,'amplitude_positive.fig');
            pngName = fullfile(daPath,'amplitude_positive.png');
            
            figure(5)
            errorbar(t,amp(1,:),amp_s(1,:),'o-')

            xlabel(xLabel,'Interpreter','latex')
            ylabel(yLabel,'Interpreter','latex')
            title({'Positive soliton amplitude $\sqrt{1-U^2}$',['Average Values: $',num2str(ampAve(1)),'\pm',...
                num2str(ampAve_s(1)),'$']},'interpreter','latex')
            movegui('south')
            
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            
            figName = fullfile(daPath,'amplitude_negative.fig');
            pngName = fullfile(daPath,'amplitude_negative.png');
            figure(6)
            errorbar(t,amp(2,:),amp_s(2,:),'o-')

            xlabel(xLabel,'Interpreter','latex')
            ylabel(yLabel,'Interpreter','latex')
            title({'Negative soliton amplitude $\sqrt{1-U^2}$',['Average Values: $',num2str(ampAve(2)),'\pm',...
                num2str(ampAve_s(2)),'$']},'interpreter','latex')
            movegui('southeast')
            
            obj.SolitonFittedAmplitude = [ampAve',ampAve_s'];
            
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Plot xi_s
            xiAve = mean(xi_s,2);
            
            yLabel = '$\xi_s$ $[\mu\mathrm{m}]$';
            figName = fullfile(daPath,'xi_s.fig');
            pngName = fullfile(daPath,'xi_s.png');
            
            figure(7)
            plot(t,xi_s,'.')
            xlabel(xLabel,'Interpreter','latex')
            ylabel(yLabel,'Interpreter','latex')
            title({'Spin Healing Length $\xi_s$',['Average Values: ',num2str(xiAve(1)),...
                '~$\mu\mathrm{m}$ (positive), ',num2str(xiAve(2)),'~$\mu\mathrm{m}$ (negative)']},'interpreter','latex')
            legend(lg{:})
            movegui('northeast')
            
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            obj.Update
            
        end
        
        function PlotManakov(obj)
            %% Read parameters from properties.
            t = obj.FitList;
            nSets = obj.NDataSets;
            xLabel = obj.ParameterLabel;
            daPath = obj.DataAnalysisPath;
            lg = {'Positive magnetic soliton','Manakov soliton'};
            
            %% Read soliton data.
            solPos = obj.SolitonPosition;
            mPos = obj.ManakovPosition;
            if isempty(solPos)
                obj.FitSoliton
                obj.FitManakov
                solPos = obj.SolitonPosition;
                mPos = obj.ManakovPosition;
            end
            
            %% Fit and plot relative soliton position.
            centerPos = (solPos(1,:)+solPos(2,:))/2;
            pPos = solPos(1,:) - centerPos;
            mPos = mPos - centerPos;
            p1 = polyfit(t,pPos,1);
            fitData1 = polyval(p1,t);
            p2 = polyfit(t,mPos,1);
            fitData2 = polyval(p2,t);
            
            yLabel = 'Soliton position [$\mu\mathrm{m}$]';
            figName = fullfile(daPath,'ManakovPosition.fig');
            pngName = fullfile(daPath,'ManakovPosition.png');
            
            figure(3)
            plot(t,pPos,'.',t,fitData1,t,mPos,'.',t,fitData2)
            xlabel(xLabel,'Interpreter','latex')
            ylabel(yLabel,'Interpreter','latex')
            title({'Magnetic Soliton Position',['$y=',num2str(p1(1)),'t+',num2str(p1(2)),'$'],...
                'Manakov Soliton Position',['$y=',num2str(p2(1)),'t+',num2str(p2(2)),'$']},'interpreter','latex')
            movegui('north')
            
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
        end
        
    end
end

