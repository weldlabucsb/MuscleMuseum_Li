classdef Eom < handle
    %AOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RfFrequency %RF circular frequency in MHz
    end
    
    methods
        function obj = Eom(omegaRf)
            %AOM Construct an instance of this class
            %   Detailed explanation goes here
            obj.RfFrequency = omegaRf;
        end
        
        function shift = shift(obj,order)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            shift = order*obj.RfFrequency;
        end
    end
end

