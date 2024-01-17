classdef MuWaveSpectrum < ParameterScan
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Transition
        PulseDuration
    end
    
    methods
        function obj = MuWaveSpectrum(start,stop,step,nRepetition,isNormalize,transition,pulseDuration)
            obj@ParameterScan('muWaveSpectrum',start,stop,step,nRepetition,isNormalize)
            obj.ParameterName = 'Offset frequency';
            obj.ParameterUnit = '$\mathrm{kHz}$';
            obj.ParameterPlotTitle = {['Microwave Spectrum, Pulse duration = ',num2str(pulseDuration),...
                ' $\mu\mathrm{s}$'],['$m = ',num2str(transition(1))...
                ' \rightarrow m = ',num2str(transition(2)),'$']};
            obj.Transition = transition;
            obj.RoiSize = [600 800];
            obj.RoiPosition = [512 512];
            obj.PulseDuration = pulseDuration;
            obj.Update
        end
    end
end

