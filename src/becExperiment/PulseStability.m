classdef PulseStability < ParameterScan
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Frequency
        PulseDuration
    end
    
    methods
        function obj = PulseStability(start,stop,step,nRepetition,isNormalize,frequency,pulseDuration)
            obj@ParameterScan('pulseStability',start,stop,step,nRepetition,isNormalize)
            obj.ParameterName = 'Run Number';
            obj.ParameterUnit = '';
%             obj.ParameterPlotTitle = ['RF Rabi Oscilation, Frequency = ',num2str(frequency),...
%                 ' $\mathrm{kHz}$'];
            obj.Frequency = frequency;
            obj.PulseDuration = pulseDuration;
            obj.Update
        end
        
        function PlotStability(obj)
            %% Read parameters from properties.
            dataAnaPath = obj.DataAnalysisPath;
            expName = obj.ExperimentName;
            nSets = obj.NDataSets;
%             plotTitle = obj.ParameterPlotTitle;
            nRoi = obj.NRoi;
            f = obj.Frequency;
            T = obj.PulseDuration;
            
            %% Calculate population
            popuMatPath = fullfile(dataAnaPath,[expName,'.mat']);
            if exist(popuMatPath,'file')
                load(popuMatPath,'popuMat')
            else
                popuMat = cell2mat(arrayfun(@(x) obj.ShowPopu(x),(1:nSets)','UniformOutput',false));
            end
            
            %% Calculate Std
            avePopu = mean(popuMat,1);
            stdPopu = 2*std(popuMat,0,1);
            plotTitle = {['Pulse Stability Test. $f=',num2str(f),'~\mathrm{kHz}$, $T=',num2str(T),'~\mu\mathrm{s}$'],...
                ['$p_{m=1}=',num2str(avePopu(1)),'\pm',num2str(stdPopu(1)),'$,'],...
                ['$p_{m=0}=',num2str(avePopu(2)),'\pm',num2str(stdPopu(2)),'$,'],...
                ['$p_{m=-1}=',num2str(avePopu(3)),'\pm',num2str(stdPopu(3)),'$']};
            
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
            ax = gca;
            ax.Legend.Location = 'best';
            
            saveas(gcf,figPath)
            saveas(gcf,pngPath)
            
        end
    end
end