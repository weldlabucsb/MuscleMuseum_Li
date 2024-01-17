classdef MuWaveRabi < ParameterScan
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Transition
        Frequency
        Omega
    end
    
    methods
        function obj = MuWaveRabi(start,stop,step,nRepetition,isNormalize,transition,frequency)
            obj@ParameterScan('muWaveRabi',start,stop,step,nRepetition,isNormalize)
            obj.ParameterName = 'Pulse duration';
            obj.ParameterUnit = '$\mu\mathrm{s}$';
            obj.ParameterPlotTitle = {['Microwave Rabi Oscilation, Frequency Offset = ',...
                num2str(frequency),' $\mathrm{kHz}$'],['$m = ',num2str(transition(1))...
                ' \rightarrow m = ',num2str(transition(2)),'$']};
            obj.Transition = transition;
            obj.RoiSize = [600 800];
            obj.RoiPosition = [512 512];
            obj.Frequency = frequency;
            obj.Update
        end
        
        function Fit(obj)
            t = obj.FitList;
            startIdx = obj.FitStartIndex;
            stopIdx = obj.FitStopIndex;
            popuMat = obj.ShowPopuMat;
            popuMat = popuMat(startIdx:stopIdx);
            dataAnaPath = obj.DataAnalysisPath;
            paraLabel = obj.ParameterLabel;
            paraTitle = obj.ParameterPlotTitle;
            
            figPath = fullfile(dataAnaPath,'fit.fig');
            pngPath = fullfile(dataAnaPath,'fit.png');
            
            aGuess = max(popuMat);
            omegaGuess = pi/max(t);
            fitFun = fittype(@(a,Omega,c,t) a.*1/2.*(1-cos(Omega.*t))+c,'independent',{'t'});
            fitOption = fitoptions(fitFun);
            fitOption.StartPoint = [aGuess,omegaGuess,0];
            fitOption.Lower = [0,0,0];
            fitOption.Upper = [aGuess*2,omegaGuess*3,aGuess/4];
            
            fitResult = fit(t',popuMat,fitFun,fitOption);
            obj.FitResult = fitResult;
            omega = fitResult.Omega;
            omega = omega*1e3;
            obj.Omega = omega;
            
            figure(2)
            plot(fitResult,t',popuMat)
            xlabel(paraLabel,'interpreter','latex')
            ylabel('Optical depth','interpreter','latex')
            paraTitle{2} = [paraTitle{2},', $\Omega=2\pi\times',num2str(omega/2/pi),'~\mathrm{kHz}$'];
            title(paraTitle,'interpreter','latex')
            
            saveas(gcf,figPath);
            saveas(gcf,pngPath);
        end
        
    end
end

