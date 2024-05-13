classdef TanhSinePulse < PartialPeriodicWaveform
    %SINEWAVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

    end
    
    methods
        function obj = TanhSinePulse(options)
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
            t0 = obj.StartTime;
            te = obj.EndTime;
            phi = obj.Phase;
            offset = obj.Offset;
            tr = obj.RiseTime;
            tf = obj.FallTime;
            trCenter = t0 + tr / 2;
            tfCenter = te - tf / 2;
            func = @tFunc;
            function waveOut = tFunc(t)
                waveOut = (t>=t0 & t<=(te)) .* ...
                    ((tanh((t-trCenter)./(tr).* 2 * pi) - 1)./2 .* (t<=(t0+tr))...
                    - (tanh((t-tfCenter)./(tf).* 2 * pi) + 1)./2 .* (t>=(te-tf)) + 1) .*...
                    (amp ./2 .* sin(2 * pi .* freq .* (t-t0) + phi) + offset);
            end
        end
    end
end

