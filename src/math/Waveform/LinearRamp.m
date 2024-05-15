classdef LinearRamp < Waveform
    %LINEARRAMP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Slope
    end
    
    methods
        function obj = LinearRamp(options)
            %LINEARRAMP Construct an instance of this class
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
        end
        
        function func = TimeFunc(obj)
            
        end
    end
end

