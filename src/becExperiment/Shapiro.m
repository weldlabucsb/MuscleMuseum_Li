classdef Shapiro < ParameterScan
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

    end
    
    methods
        function obj = Shapiro(start,stop,step,nRepetition,isNormalize)
            obj@ParameterScan('Shapiro',start,stop,step,nRepetition,isNormalize)
            obj.ParameterName = 'Modulation frequency';
            obj.ParameterUnit = '$\mathrm{Hz}$';
%             obj.ParameterPlotTitle = {['Microwave Spectrum, Pulse duration = ',num2str(pulseDuration),...
%                 ' $\mu\mathrm{s}$'],['$m = ',num2str(transition(1))...
%                 ' \rightarrow m = ',num2str(transition(2)),'$']};
%             obj.Transition = transition;
%             obj.RoiSize = [600 800];
%             obj.RoiPosition = [512 512];
%             obj.PulseDuration = pulseDuration;
            obj.Update
        end
    end
end

