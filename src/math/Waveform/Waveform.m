classdef (Abstract) Waveform < handle
    %WAVEFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SamplingRate % In Hz
        Timing double = 0 % Start time, in s
        Duration % How long of the waveform, in s
        Amplitude double = 0% Peak-to-peak amplitude, usually in Volts.
        Offset double = 0 % Offest, usually in Volts.
    end
    
    methods
        function obj = Waveform()
            %WAVEFORM Construct an instance of this class
            %   Detailed explanation goes here
            
        end
        
    end
end

