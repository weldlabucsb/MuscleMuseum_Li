classdef PchipSinePulse < PartialPeriodicWaveform
    %SINEWAVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

    end
    
    methods
        function obj = PchipSinePulse(options)
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

            % for sampling the pchip function
            tsr = linspace(t0,t0+tr,3);
            dt = tsr(2) - tsr(1);
            ssr = ((tsr-t0)./(tr)-1);
            tsr = [tsr(1)-2 * dt tsr(1)-dt tsr tsr(end)+dt tsr(end)+dt * 2];
            ssr = [-1 -1 ssr 0 0];

            tsf = linspace(te-tf,te,3);
            dt = tsf(2) - tsf(1);
            ssf = (tsf-(te-tf))./(tf);
            tsf = [tsf(1)-2 * dt tsf(1)-dt tsf tsf(end)+dt tsf(end)+2*dt];
            ssf = [0 0 ssf 1 1];

            func = @tFunc;
            function waveOut = tFunc(t)
                waveOut = (t>=t0 & t<=(te)) .* ...
                    (pchip(tsr,ssr,t) .* (t<=(t0+tr)) - pchip(tsf,ssf,t) .* (t>=(te-tf)) + 1) .*...
                    (amp ./2 .* sin(2 * pi .* freq .* (t-t0) + phi) + offset);
            end
        end
    end
end

