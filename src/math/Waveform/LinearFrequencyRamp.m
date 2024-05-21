classdef LinearFrequencyRamp < Waveform
    %LINEARRAMP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StartFrequency double {mustBePositive} % Linear frequency in Hz
        StopFrequency double {mustBePositive} % Linear frequency in Hz
        Phase double
    end
    
    methods
        function obj = LinearFrequencyRamp(options)
            %LINEARRAMP Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                options.samplingRate double = [];
                options.startTime double = 0;
                options.duration double = [];
                options.offset double = 0;
                options.amplitude double = 0;

                options.phase double = 0;
                options.startFrequency double = 1;
                options.stopFrequency double = 2;
            end
            field = string(fieldnames(options));
            for ii = 1:numel(field)
                if ~isempty(options.(field(ii)))
                    obj.(capitalizeFirst(field(ii))) = options.(field(ii));
                end
            end
        end
        
        function func = TimeFunc(obj)
            amp = obj.Amplitude;
            freqi = obj.StartFrequency;
            freqf = obj.StopFrequency;
            td = obj.Duration;
            t0 = obj.StartTime;
            phi = obj.Phase;
            offset = obj.Offset;
            func = @tFunc;
            function waveOut = tFunc(t)
                waveOut = (t>=t0 & t<=(t0+td)) .* ...
                    (amp ./2 .* sin(2 * pi .* (freqi + (freqf-freqi) ./ td .* (t-t0)) .* (t-t0) + phi) + offset);
            end
        end
    end
end

