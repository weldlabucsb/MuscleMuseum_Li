classdef TrapezoidalSinePulse < PartialPeriodicWaveform
    %SINEWAVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

    end
    
    methods
        function obj = TrapezoidalSinePulse(options)
            %SINEWAVE Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                options.samplingRate double = [];
                options.startTime double = 0;
                options.duration double = [];
                options.amplitude double = [];
                options.offset double = 0;

                options.frequency double = [];
                options.phase double = 0;

                options.riseTime double = 0;
                options.fallTime double = 0;
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
            % td = obj.Duration;
            t0 = obj.StartTime;
            te = obj.EndTime;
            phi = obj.Phase;
            offset = obj.Offset;
            tr = obj.RiseTime;
            tf = obj.FallTime;
            func = @tFunc;
            function waveOut = tFunc(t)
                waveOut = (t>=t0 & t<=(te)) .* ...
                    ((((t-t0)./(tr)-1) .* (t<=(t0+tr)) - (t-(te-tf))./(tf) .* (t>=(te-tf)) + 1) .*...
                    (amp ./2 .* sin(2 * pi .* freq .* (t-t0) + phi)) + offset);
            end
        end
    end
end

