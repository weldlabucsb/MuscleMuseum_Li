classdef (Abstract) Sim < Trial
    %SIMULATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Output
        WallTime double = 11.5*3600
        SimRun
    end

    properties(Dependent,Hidden)
        UncompletedRunIndex
    end
  
    methods
        function obj = Sim(trialName,config)
            %SIMULATION Construct an instance of this class
            %   Detailed explanation goes here
            obj@Trial(trialName,config);
        end

        function uRunIdx = get.UncompletedRunIndex(obj) 
            uRunIdx = find(~[obj.SimRun.IsCompleted]);
        end

        function check(obj,isWarning)
            arguments
                obj Sim
                isWarning logical = true
            end
            for ii = 1:obj.NRun
                obj.SimRun(ii).check(isWarning);
            end
            obj.NCompletedRun = sum([obj.SimRun.IsCompleted]);
            obj.update
        end

        function start(obj)
            obj.check(false)
            uRunIdx = obj.UncompletedRunIndex;
            if numel(uRunIdx)>1
                parfevalOnAll(@warning,0,'off','all');
                parfor ii = 1:numel(uRunIdx)
                    try
                        obj.SimRun(uRunIdx(ii)).start;
                    catch 
                    end
                end
            elseif numel(uRunIdx) == 1
                obj.SimRun(uRunIdx).start
            elseif numel(uRunIdx) == 0
                disp("All runs are completed.")
            end
            obj.check
            if numel(uRunIdx)>0
                obj.start
            end
        end
    end
    
    methods (Hidden)
        setFolder(obj)
        % setConfigProperty(obj,struct)
    end
end

