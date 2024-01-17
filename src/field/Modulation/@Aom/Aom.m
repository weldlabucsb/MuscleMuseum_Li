classdef Aom < handle
    %AOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RfFrequency %RF circular frequency in MHz
    end
    
    methods
        function obj = Aom(omegaRf)
            %AOM Construct an instance of this class
            %   Detailed explanation goes here
            obj.RfFrequency = omegaRf;
        end
        
        function shift = shiftSP(obj,order)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            shift = order*obj.RfFrequency;
        end

        function shift = shiftDP(obj,order)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            shift = 2*order*obj.RfFrequency;
        end
    end
end

