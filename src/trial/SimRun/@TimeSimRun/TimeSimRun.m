classdef (Abstract) TimeSimRun < SimRun
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        InitialTime double = 0
        TotalTime (1,1) double
        TimeStep (1,1) double
        SavePeriod = 1
        AveragePeriod = 1
        InitialCondition InitialCondition
    end

    properties(Dependent)
        NTimeStep
        TimeList
        NDataRow
        NDataRowMemory
    end
    
    methods
        function obj = TimeSimRun(timeSim)
            arguments
                timeSim = []
            end
            obj@SimRun(timeSim)
            if ~isempty(timeSim)
                if isa(timeSim,"TimeSim")
                    obj.InitialTime = timeSim.InitialTime;
                    obj.TotalTime = timeSim.TotalTime;
                    obj.TimeStep = timeSim.TimeStep;
                    obj.SavePeriod = timeSim.SavePeriod;
                    obj.AveragePeriod = timeSim.AveragePeriod;
                else
                    error("Input must be an object of the TimeSim class")
                end
            end
        end

        function nTimeStep = get.NTimeStep(obj)
            nTimeStep = numel(obj.TimeList);
        end

        function tList = get.TimeList(obj)
            tList = obj.InitialTime : obj.TimeStep : obj.TotalTime;
        end

        function nDataRow = get.NDataRow(obj)
            nDataRow = floor(obj.NTimeStep / obj.AveragePeriod);
        end

        function nDataRowMemory = get.NDataRowMemory(obj)
            nDataRowMemory = floor(obj.SavePeriod / obj.AveragePeriod);
        end

        function check(obj,isWarning)
            arguments
                obj TimeSimRun
                isWarning logical = true
            end
            try
                matObj = matfile(obj.RunPath,'Writable',true);
                [nRow,~] = size(matObj,'Time');
                if nRow == obj.NDataRow
                    obj.IsCompleted = true;
                elseif isWarning
                    warning("Run" + num2str(obj.RunIndex) + " was not completed")
                end
            catch
                if isWarning
                    warning("Run" + num2str(obj.RunIndex) + " was not completed")
                end
            end
        end
        
    end
end

