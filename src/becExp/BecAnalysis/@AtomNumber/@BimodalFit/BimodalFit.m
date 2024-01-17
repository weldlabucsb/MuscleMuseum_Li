classdef BimodalFit < BecAnalysis
    %OD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       
    end
    
    methods
        function obj = BimodalFit(becExp)
            %OD Construct an instance of this class
            %   Detailed explanation goes here
            obj@BecAnalysis(becExp)
            obj.Chart(1) = Chart(...
                name = "Bimodal fit",...
                num = 28, ...
                fpath = fullfile(becExp.DataAnalysisPath,"BimodalFit"),...
                loc = [0.00001,0.032],...
                size = [0.3966,0.3509]...
                );
        end
        
        function initialize(obj)
            initialize@BecAnalysis(obj);
        end

    end
end

