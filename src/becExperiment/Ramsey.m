classdef Ramsey < Tof
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MagnetizationName
        ColarAxis = [-1,1]
        ReferencePoint
    end
    
    properties(Dependent)
        Magnetization
    end
    
    methods
        function obj = Ramsey(start,stop,step,nRepetition,isNormalize)
            obj@Tof('ramsey',start,stop,step,nRepetition,isNormalize)
            obj.ParameterName = 'Hold time';
            obj.ParameterUnit = '$\mathrm{ms}$';
            obj.Update
        end
        
        function mag = get.Magnetization(obj)
            mag = loadVar(obj.MagnetizationName);
        end
        
        function UpdateTf(obj)
           mag = obj.Magnetization;
           obj.RoiSize = mag.RoiSize;
           obj.RoiPosition = mag.RoiPosition;
           mag.PlotRange = obj.PlotRange;
           mag.Update
           obj.Update
        end
        
        function varargout = ShowCos(obj,runNumber)
            %% Read parameters from properties.
            nRuns = obj.NRuns;
            mag = obj.Magnetization;
            tList = obj.ParameterList;
            nRep = obj.NRepetition;
            tMag = mag.ParameterList;
            obj.RoiSize = mag.RoiSize;
            obj.RoiPosition = mag.RoiPosition;
            centers = mag.Centers;
            newCenters = mag.NewCenters;
            isNor = mag.IsNormalize;
            nRepMag = mag.NRepetition;
            mag.IsShift = 0;
            y = obj.YList;
            roiPos = obj.RoiPosition;
            startIdx = mag.FitStartIndex;
            
            if isNor
                centers = mean(reshape(centers(2:2:end),nRepMag,[]),1);
            else
                centers = mean(reshape(centers,nRepMag,[]),1);
            end
            
            %% Return data.
            if nargin == 2
                setNumber = ceil(runNumber/nRep);             
                tSet = tList(setNumber);
                magIdx = find(tMag == tSet);
                if ~isempty(newCenters)
                    obj.RoiPosition(4) = newCenters(magIdx);
                    mag.RoiPosition(4) = newCenters(magIdx);
                else
                    obj.RoiPosition(4) = round(centers(magIdx-startIdx+1)); %should be fixed later
                    mag.RoiPosition(4) = round(centers(magIdx-startIdx+1)); %should be fixed later
                end
                [magData,~] = mag.ShowMag(magIdx);
                adData = obj.ShowAD(runNumber);
                cosData = (adData(:,1) + adData(:,3) - adData(:,2))./(adData(:,1) + adData(:,3) + adData(:,2))./...
                    (sqrt(abs(1-magData.^2)).*((1-magData.^2)>0)+((1-magData.^2)<=0));
                varargout{1} = cosData;
                obj.RoiPosition = roiPos;
                mag.RoiPosition = roiPos;
                return
            end
            
            %% Initialize the figure.
            fig = renderFigure(1,[1024,1024],'center');
            tit = sgtitle('$\cos(\alpha)$ Axial Distribution, Run 1','interpreter','latex');
            setNumber = ceil(1/nRep);
            tSet = tList(setNumber);
            magIdx = find(tMag == tSet);
            [magData0,~] = mag.ShowMag(magIdx);
            adData0 = obj.ShowAD(1);
            cosData0 = (adData0(:,1) + adData0(:,3) - adData0(:,2))./(adData0(:,1) + adData0(:,3) + adData0(:,2))./...
                (sqrt(abs(1-magData0.^2)).*((1-magData0.^2)>0)+((1-magData0.^2)<=0));
            cl = plot(y,cosData0);
            renderPlot(cl,'$y$ position ($\mu\mathrm{m}$)','$\cos(\alpha)$')
            ax = cl.Parent;
            pos = ax.Position;
            pos(2) = pos(2)+0.05;
            pos(4) = pos(4)-0.05;
            ax.Position = pos;
            
            [slider,editbox] = createUis(fig,nRuns,'set');
            
            %% Define the callback function.
            slider.Callback = @(es,ed) setHandles(cl,tit,es.Value);
            editbox.Callback = @(es,ed) setHandles(cl,tit,es.String);
            function setHandles(h,t,n)
                if class(n) == "char"
                    n = str2double(n);
                    if n>nRuns || n<1 || isnan(n)
                        return
                    end
                end
                n = round(n);
                setNumber = ceil(n/nRep);
                tSet = tList(setNumber);
                magIdx = find(tMag == tSet);
                [magData,~] = mag.ShowMag(magIdx);
                adData = obj.ShowAD(n);
                cosData = (adData(:,1) + adData(:,3) - adData(:,2))./(adData(:,1) + adData(:,3) + adData(:,2))./...
                    (sqrt(abs(1-magData.^2)).*((1-magData.^2)>0)+((1-magData.^2)<=0));
                h.YData = cosData;
                t.String = ['$\cos(\alpha)$ Axial Distribution, Run, Set ',num2str(n)];
            end
            
        end
        
        function varargout = ShowCosMat(obj)
            %% Read parameters from properties.
            obj.UpdateTf
            nRuns = obj.NRuns;
            mag = obj.Magnetization;
            yPlot = mag.YListPlot;
            pRange = obj.PlotRange;
            cAxis = obj.ColarAxis;
            dataAnaPath = obj.DataAnalysisPath;
            xLabel = '$y$ position [$\mu$m]';
            yLabel = 'Run number';
            pBound = mag.PlotBoundary;
            isChanged = obj.IsChanged;
                       
            %% Calculate Cos(alpha)
            cosName = fullfile(dataAnaPath,'cos.mat');
            if isChanged
                cosData = arrayfun(@(x) obj.ShowCos(x),(1:nRuns),'UniformOutput',false);
                cosData = cell2mat(cosData);
                cosData = cosData(pBound(1):pBound(2),:);
                save(cosName,'cosData')
                obj.IsChanged = 0;
            else
                load(cosName,'cosData')
            end
            
            if nargout == 1
                varargout{1} = cosData;
                return
            end
            
            %% Plot
            figure(2)
            img = imagesc(cosData');
%             renderImage(img,cAxis,parula,1)a
            ax = gca;
            caxis(ax,cAxis)
            ax.YDir = 'normal';
            colorbar(ax)
            renderTicks(img,yPlot,1:nRuns)
            xlabel(xLabel,'interpreter','latex')
            ylabel(yLabel,'interpreter','latex')
            title('$\cos(\alpha)$, Raw','Interpreter',"latex")
            axis normal
            ax = gca;
            ax.YDir = 'reverse';
            movegui('northwest')
            
            figName = fullfile(dataAnaPath,'cos.fig');
            pngName = fullfile(dataAnaPath,'cos.png');
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Plot Magnetization
               if obj.NDataSets == 1
                   magPos = mag.RoiPosition;
                   nRepMag = mag.NRepetition;
                   centers = mag.Centers;
                   centers = mean(reshape(centers(2:2:end),nRepMag,[]),1);
                   mag.RoiPosition(4) = round(centers(1));
                   magData = mag.ShowMag(1);
                   magData = magData(pBound(1):pBound(2));
                   figure(3)
                   plot(yPlot,magData)
                   xlabel(xLabel,'Interpreter','latex')
                   ylabel('$\langle F_z \rangle$','Interpreter','latex')
                   title(['Magnetization at $t=',num2str(mag.ParameterList),'~\mathrm{ms}$'],'Interpreter','latex')
                   axis([yPlot(1),yPlot(end),-inf,inf])
                   movegui('southwest')
                   
                   figName = fullfile(dataAnaPath,'magRamsey.fig');
                   pngName = fullfile(dataAnaPath,'magRamsey.png');
                   saveas(gcf,figName)
                   saveas(gcf,pngName)
                   obj.Magnetization.RoiPosition = magPos;
               end
                      
            %% Plot Correlation
            [~,idx1] = max(magData);
            [~,idx2] = min(magData);
            pos = round((idx1+idx2)/2);
            point1 = cosData(obj.ReferencePoint,:);
            point2 = cosData(pos,:);
            fitResult = fit(point1',point2','poly1');
            p1 = fitResult.p1;
            p2 = fitResult.p2;
            error = fitError(fitResult);
            figure(4)
            plot(fitResult,point1,point2)
            xlabel('$\cos(\alpha_0)$','Interpreter','latex')
            ylabel('$\cos(\alpha_0+\alpha_1)$','Interpreter','latex')
            title(['$y=(',num2str(p1),'\pm',num2str(error(1)),')x+(',num2str(p2),'\pm',num2str(error(2)),')$'],'Interpreter','latex')
            axis([-1,1,-1,1])
            movegui('south')
            
            figName = fullfile(dataAnaPath,'correlation.fig');
            pngName = fullfile(dataAnaPath,'correlation.png');
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
        end
        
        function ShowCosMat2(obj)
            %% Read parameters from properties.
            obj.UpdateTf
            refPoint = obj.ReferencePoint;
            dataAnaPath = obj.DataAnalysisPath;
            cosName = fullfile(dataAnaPath,'cos.mat');
            nRuns = obj.NRuns;
            mag = obj.Magnetization;
            yPlot = mag.YListPlot;
            pBound = mag.PlotBoundary;
%             yPlot = yPlot(pBound(1):pBound(2));
            cAxis = obj.ColarAxis;
            xLabel = '$y$ position [$\mu$m]';
            yLabel = 'Run number';
            
            %% Read Cos data
            if ~exist(cosName,'file') || obj.IsChanged
                obj.ShowCosMat
                close('all')
            end
            load(cosName,'cosData')
            
            %% Subtract background phase
            cosAlpha0 = cosData(refPoint,:);
            b = size(cosData,1);
            cosAlpha = zeros(b,nRuns);
            cosAlpha(refPoint,:) = 1;
            th = 0.1;
            for ii = 1:nRuns
                for jj = refPoint-1:-1:1
                    cosProd = cosData(jj,ii)*cosAlpha0(ii);
                    sinProd = sqrt(1-cosData(jj,ii).^2)*sqrt(1-cosAlpha0(ii)^2);
                    temp = [cosProd+sinProd,cosProd-sinProd];
%                     if abs(jj-refPoint)>30
%                         cosTemp1 = cosAlpha(:,ii);
%                         cosTemp1(jj) = temp(1);
%                         gd1 = gradient(cosTemp1);
%                         cosTemp2 = cosAlpha(:,ii);
%                         cosTemp2(jj) = temp(2);
%                         gd2 = gradient(cosTemp2);
%                         geTemp = [abs(gd1(jj)-gd1(jj+1)),abs(gd2(jj)-gd2(jj+1))];
%                         [~,idx] = min(geTemp);
%                     else
                        [~,idx] = min(abs(temp-cosAlpha(jj+1,ii)));
%                     end
                    cosAlpha(jj,ii) = temp(idx);
                end
                for jj = refPoint+1:1:b
                    cosProd = cosData(jj,ii)*cosAlpha0(ii);
                    sinProd = sqrt(1-cosData(jj,ii).^2)*sqrt(1-cosAlpha0(ii)^2);
                    temp = [cosProd+sinProd,cosProd-sinProd];
%                     if abs(jj-refPoint)>10
%                         cosTemp1 = cosAlpha(:,ii);
%                         cosTemp1(jj) = temp(1);
%                         gd1 = gradient(cosTemp1);
%                         cosTemp2 = cosAlpha(:,ii);
%                         cosTemp2(jj) = temp(2);
%                         gd2 = gradient(cosTemp2);
%                         geTemp = [abs(gd1(jj)-gd1(jj-1)),abs(gd2(jj)-gd2(jj-1))];
%                         [~,idx] = min(geTemp);
%                     else
                        [~,idx] = min(abs(temp-cosAlpha(jj-1,ii)));
%                     end
                    cosAlpha(jj,ii) = temp(idx);
                end
            end
            
            %% Plot
            figure(2)
            img = imagesc(cosAlpha');
%             renderImage(img,cAxis,parula,1)
            ax = gca;
            caxis(ax,cAxis)
            ax.YDir = 'normal';
            colorbar(ax)
            renderTicks(img,yPlot,1:nRuns)
            xlabel(xLabel,'interpreter','latex')
            ylabel(yLabel,'interpreter','latex')
            title('$\cos(\alpha)$, Processed','Interpreter',"latex")
            axis normal
            ax = gca;
            ax.YDir = 'reverse';
            movegui('northwest')
            
            figName = fullfile(dataAnaPath,'cos2.fig');
            pngName = fullfile(dataAnaPath,'cos2.png');
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Plot Average
            figure(3)
            cosAve = mean(cosAlpha,2);
            plot(yPlot,cosAve)
            xlabel(xLabel,'interpreter','latex')
            ylabel('$\langle\cos(\alpha)\rangle$','interpreter','latex')
            title('Average of $\cos(\alpha)$','Interpreter',"latex")
            axis([yPlot(1),yPlot(end),-inf,inf])
            movegui('north')
            
            figName = fullfile(dataAnaPath,'cos2_ave.fig');
            pngName = fullfile(dataAnaPath,'cos2_ave.png');
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
            %% Plot Magnetization
            if obj.NDataSets == 1
                magPos = mag.RoiPosition;
                nRepMag = mag.NRepetition;
                centers = mag.Centers;
                centers = mean(reshape(centers(2:2:end),nRepMag,[]),1);
                mag.RoiPosition(4) = round(centers(1));
                magData = mag.ShowMag(1);
                magData = magData(pBound(1):pBound(2));
                figure(4)
                plot(yPlot,magData)
                xlabel(xLabel,'Interpreter','latex')
                ylabel('$\langle F_z \rangle$','Interpreter','latex')
                title(['Magnetization at $t=',num2str(mag.ParameterList),'~\mathrm{ms}$'],'Interpreter','latex')
                axis([yPlot(1),yPlot(end),-inf,inf])
                movegui('southwest')
                
                figName = fullfile(dataAnaPath,'magRamsey.fig');
                pngName = fullfile(dataAnaPath,'magRamsey.png');
                saveas(gcf,figName)
                saveas(gcf,pngName)
                obj.Magnetization.RoiPosition = magPos;
            end
            
        end
        
        function PlotCosSquare(obj)
            %% Read parameters from properties.
            y = obj.YList;
            pRange = obj.PlotRange;
            dataAnaPath = obj.DataAnalysisPath;
            y = y(pRange(1):pRange(2));
            xLabel = '$y$ position [$\mu$m]';
            yLabel = '$\langle\cos^2(\alpha)\rangle$';
            
            %% Read data
            cosName = fullfile(dataAnaPath,'cos.mat');
            if exist(cosName,'file')
                load(cosName,'cosData')
            else
                obj.PlotCos
                load(cosName,'cosData')
            end
            
            cos2 = mean(cosData.^2,2);
            
            %% Plot
            figName = fullfile(dataAnaPath,'cos2.fig');
            pngName = fullfile(dataAnaPath,'cos2.png');
            figure(2)
            plot(y,cos2)
            xlabel(xLabel,'interpreter','latex')
            ylabel(yLabel,'interpreter','latex')
            saveas(gcf,figName)
            saveas(gcf,pngName)
            
        end
        
    end
end

