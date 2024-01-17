classdef PlaneWave < Laser
    %PLANEWAVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Direction
    end
    
    methods
        function obj = PlaneWave(nlaser)
            if nargin ~= 0
                obj(1,nlaser) = PlaneWave;
            end
        end
        
    end
end

