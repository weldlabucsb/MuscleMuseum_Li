classdef (Abstract) TimeSim < Sim
    %TIMESIM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        InitialTime double = 0
        TotalTime (1,1) double
        TimeStep (1,1) double
        SavePeriod = 1
        AveragePeriod = 1
    end
    
    methods
        function obj = TimeSim(trialName,config)
            %TIMESIM Construct an instance of this class
            %   Detailed explanation goes here
            obj@Sim(trialName,config);
        end
        
    end
end

