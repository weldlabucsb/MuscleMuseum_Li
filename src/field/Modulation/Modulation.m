classdef Modulation < handle
    %MODULATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Depth
        Frequency
        Duration
        Timing
    end
    
    methods
        function obj = Modulation(options)
            %MODULATION Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                options.depth double
                options.frequency double
                options.duration double
                options.timing double
            end
            field = string(fieldnames(options));
            for ii = 1:numel(field)
                if ~isempty(options.(field(ii)))
                    obj.(capitalizeFirst(field(ii))) = options.(field(ii));
                end
            end
        end
        
        function func = timeFunc(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            alpha = obj.Depth;
            freq = obj.Frequency;
            tMod = obj.Duration;
            t0 = obj.Timing;
            func = @tFunc;
            function modAmp = tFunc(t)
                modAmp = (t>=t0 & t<=(t0+tMod)) .* ...
                    alpha .* sin(2 * pi .* freq .* t);
            end
        end
    end
end

