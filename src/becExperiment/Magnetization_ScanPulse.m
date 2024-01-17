classdef Magnetization_ScanPulse < ParameterScan
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MagnetizationAxis = [-0.15,0.15]
        DensityAxis = [0.7,1.3]
        HoldTime
        Power
    end
    
    methods
        function obj = Magnetization_ScanPulse(start,stop,step,nRepetition,isNormalize,holdTime,power)
            obj@ParameterScan('magnetization_scanPulse',start,stop,step,nRepetition,isNormalize)
            obj.ParameterName = 'Pulse Duration';
            obj.ParameterUnit = '$\mu\mathrm{s}$';
            obj.HoldTime = holdTime;
            obj.Power = power;
            obj.Update
        end
        
        function varargout = ShowMag(obj,setNumber)
            %% Read parameters from properties.
            nSets = obj.NDataSets;
            y = obj.YList;
            magAxis = obj.MagnetizationAxis;
            densAxis = obj.DensityAxis;
            
            %% Return data
            if nargin == 2
                aveData = obj.ShowAve(setNumber);
                magData = (aveData(:,1) - aveData(:,3))/2;
                densData = (aveData(:,1) + aveData(:,3))/2;
                varargout{1} = magData;
                varargout{2} = densData;
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
        
        function magMat = ShowMagMat(obj)
            nSets = obj.NDataSets;
%             dataAnaPath = obj.DataAnalysisPath;
%             expName = obj.ExperimentName;
            magMat = cell2mat(arrayfun(@(x) obj.ShowMag(x),(1:nSets),'UniformOutput',false));
%             save(fullfile(dataAnaPath,[expName,'.mat']),'magMat')
        end
        
    end
end

