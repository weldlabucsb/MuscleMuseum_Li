classdef LinearRamp < TrapezoidalPulse
    %LINEARRAMP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StartValue double = 0
        StopValue double = 0
        RampTime double = 0
    end
    
    methods
        function obj = LinearRamp(options)
            %LINEARRAMP Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                options.samplingRate double = [];
                options.startTime double = 0;
                options.duration double = [];
                options.startValue double = 0;
                options.stopValue double = 0;
                options.rampTime double = 0;
            end
            field = string(fieldnames(options));
            for ii = 1:numel(field)
                if ~isempty(options.(field(ii)))
                    obj.(capitalizeFirst(field(ii))) = options.(field(ii));
                end
            end
            obj.FallTime = 0;
        end

        function set.RampTime(obj,val)
            obj.RampTime = val;
            obj.RiseTime = val;
        end

        function set.StartValue(obj,val)
            obj.StartValue = val;
            obj.Offset = val;
            obj.Amplitude = obj.StopValue - val;
        end

        function set.StopValue(obj,val)
            obj.StopValue = val;
            obj.Offset = obj.StartValue;
            obj.Amplitude = val - obj.StartValue;
        end
        
    end
end

