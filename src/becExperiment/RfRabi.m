classdef RfRabi < ParameterScan
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Frequency
    end
    
    methods
        function obj = RfRabi(start,stop,step,nRepetition,isNormalize,frequency)
            obj@ParameterScan('rfRabi',start,stop,step,nRepetition,isNormalize)
            obj.ParameterName = 'Pulse duration';
            obj.ParameterUnit = '$\mu\mathrm{s}$';
            obj.ParameterPlotTitle = ['RF Rabi Oscilation, Frequency = ',num2str(frequency),...
                ' $\mathrm{kHz}$'];
            obj.Frequency = frequency;
            obj.Update
        end
    end
end

