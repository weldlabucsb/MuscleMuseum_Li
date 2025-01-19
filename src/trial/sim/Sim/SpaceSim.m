classdef (Abstract) SpaceSim < Sim
    %TIMESIM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SpaceOrigin double = [0;0;0] % in meters
        SpaceRange double {mustBePositive} % in meters
        SpaceStep double {mustBePositive}
        Dimension (1,1) double {mustBeInteger,mustBeInRange(Dimension,1,3)} = 1
        BoundaryCondition string {mustBeMember(BoundaryCondition,{'Periodic','Dirichlet','Neumann'})} = "Periodic"
    end
    
    methods
        function obj = SpaceSim(trialName,config)
            %TIMESIM Construct an instance of this class
            %   Detailed explanation goes here
            obj@Sim(trialName,config);
        end
        
    end
end

