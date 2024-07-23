classdef TekTronix1104 < TektronixScope
    %TEKTRONIX1104 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = TekTronix1104(resourceName,name)
            arguments
                resourceName string
                name string = string.empty
            end
            obj@TektronixScope(resourceName,name)
            obj.Model = "1104";
            obj.SamplingRateMax = 1e9;
            obj.NChannel = 4;
            obj.IsEnabled = true(1,obj.NChannel);
            obj.VerticalOffset = zeros(1,obj.NChannel);
            obj.VerticalCoupling = repmat("DC",1,obj.NChannel);
            obj.VerticalRange = repmat(10,1,obj.NChannel);
        end
        
    end
end

