classdef SeSim1D < TimeSim & SpaceSim
    %SESIM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = SeSim1D(trialName,config)
            %SESIM Construct an instance of this class
            %   Detailed explanation goes here
            % obj.Property1 = inputArg1 + inputArg2;
            obj@TimeSim(trialName,config);
        end
        
        setConfigProperty(obj,s)
        updateDatabase(obj)
        writeDatabase(obj)
    end
end

