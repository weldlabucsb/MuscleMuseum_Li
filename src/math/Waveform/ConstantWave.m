classdef ConstantWave < PeriodicWaveform
    %CONSTANTWAVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = ConstantWave(options)
            %CONSTANTWAVE Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                options.samplingRate double = [];
                options.startTime double = 0;
                options.duration double = [];
                options.offset double = 0;
            end
            field = string(fieldnames(options));
            for ii = 1:numel(field)
                if ~isempty(options.(field(ii)))
                    obj.(capitalizeFirst(field(ii))) = options.(field(ii));
                end
            end
            if ~isempty(obj.SamplingRate)
                obj.Frequency = obj.SamplingRate;
            end
        end
        
        function func = TimeFunc(obj)
            td = obj.Duration;
            t0 = obj.StartTime;
            offset = obj.Offset;
            func = @tFunc;
            function waveOut = tFunc(t)
                waveOut = (t>=t0 & t<=(t0+td)) .* offset;
            end
        end
    end
end

