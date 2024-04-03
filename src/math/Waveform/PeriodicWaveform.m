classdef (Abstract) PeriodicWaveform < Waveform
    %PERIODICWAVEFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Frequency % In Hz
        Phase % In radians
    end

    properties(Dependent)
        Period % In s
        NPeriod
    end
    
    methods
        function obj = PeriodicWaveform()
            %PERIODICWAVEFORM Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function T = get.Period(obj)
            T = 1 / obj.Frequency;
        end

        function nP = get.NPeriod(obj)
            nP = obj.Duration / obj.Period;
        end

        function set.Phase(obj,val)
            obj.Phase = mod(val,2*pi);
        end
    end
end

