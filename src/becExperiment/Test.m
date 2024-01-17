classdef Test < BecExperiment
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        NRuns
    end
    
    methods
        function obj = Test(nRuns)
            obj@BecExperiment('Test')
            obj.NRuns = nRuns;
            obj.Update
        end
    end
end

