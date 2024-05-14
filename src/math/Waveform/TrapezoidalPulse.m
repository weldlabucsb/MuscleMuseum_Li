classdef TrapezoidalPulse < PartialPeriodicWaveform & ConstantTop
    %SINEWAVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

    end
    
    methods
        function obj = TrapezoidalPulse(options)
            %SINEWAVE Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                options.samplingRate double = [];
                options.startTime double = 0;
                options.duration double = [];
                options.amplitude double = [];
                options.offset double = 0;

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
            t0 = obj.StartTime;
            te = obj.EndTime;
            offset = obj.Offset;
            tr = obj.RiseTime;
            tf = obj.FallTime;
            if tf == 0
                func = @trFunc;
            elseif tr == 0
                func = @tfFunc;
            else
                func = @tFunc;
            end
            function waveOut = tFunc(t)
                waveOut = (t>=t0 & t<=(te)) .* ...
                    (((t-t0)./(tr)-1) .* (t<=(t0+tr)) - (t-(te-tf))./(tf) .* (t>=(te-tf)) + 1) .*...
                    amp  + offset;
            end
            function waveOut = trFunc(t)
                waveOut = (t>=t0 & t<=(te)) .* ...
                    (((t-t0)./(tr)-1) .* (t<=(t0+tr)) + 1) .*...
                    amp  + offset;
            end
            function waveOut = tfFunc(t)
                waveOut = (t>=t0 & t<=(te)) .* ...
                    (- (t-(te-tf))./(tf) .* (t>=(te-tf)) + 1) .*...
                    amp  + offset;
            end
        end
    end
end

