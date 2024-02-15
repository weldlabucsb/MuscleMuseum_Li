classdef (Abstract) SpaceSim < Sim
    %TIMESIM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SpaceOrigin double = [0;0;0] % in meters
        SpaceRange double {mustBePositive} % in meters
        NSpaceStep double {mustBePositive,mustBeInteger}
        Dimension (1,1) double {mustBeInteger,mustBeInRange(Dimension,1,3)} = 1
    end
    
    methods
        function obj = SpaceSim(trialName,config)
            %TIMESIM Construct an instance of this class
            %   Detailed explanation goes here
            obj@Sim(trialName,config);
        end
        
    end
end

