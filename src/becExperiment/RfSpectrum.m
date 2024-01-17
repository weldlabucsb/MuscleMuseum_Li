classdef RfSpectrum < ParameterScan
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PulseDuration
    end
    
    methods
        function obj = RfSpectrum(start,stop,step,nRepetition,isNormalize,pulseDuration)
            obj@ParameterScan('rfSpectrum',start,stop,step,nRepetition,isNormalize)
            obj.ParameterName = 'Frequency';
            obj.ParameterUnit = '$\mathrm{kHz}$';
            obj.ParameterPlotTitle = ['RF Spectrum, Pulse Duration = ',num2str(pulseDuration),...
                ' $\mu\mathrm{s}$'];
            obj.PulseDuration = pulseDuration;
            obj.Update
        end
    end
end

