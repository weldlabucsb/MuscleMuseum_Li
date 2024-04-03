classdef SineWave < PeriodicWaveform
    %SINEWAVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = SineWave(options)
            %SINEWAVE Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                options.amplitude double = [];
                options.frequency double = [];
                options.phase double = 0;
                options.timing double = 0;
                options.duration double = [];
                options.offset double = 0;
                options.samplingRate double = [];
            end
            field = string(fieldnames(options));
            for ii = 1:numel(field)
                if ~isempty(options.(field(ii)))
                    obj.(capitalizeFirst(field(ii))) = options.(field(ii));
                end
            end
        end
        
        function func = TimeFunc(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            amp = obj.Amplitude;
            freq = obj.Frequency;
            td = obj.Duration;
            t0 = obj.Timing;
            phi = obj.Phase;
            off = obj.Offset;
            func = @tFunc;
            function modAmp = tFunc(t)
                modAmp = (t>=t0 & t<=(t0+td)) .* ...
                    (amp .* sin(2 * pi .* freq .* (t-t0) + phi) + off);
            end
        end
    end
end

