classdef (Abstract) SimRun < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        DataPath string
        DataAnalysisPath string
        DataPrefix string = "run"
        DataFormat string = ".mat"
        Output table
        RunIndex uint32 = int32(1)
        IsCompleted logical = false
        WallTime double = 11.5*3600
    end

    properties (Dependent)
        RunPath string
    end
    
    methods
        function obj = SimRun(sim)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                sim = [] 
            end
            if ~isempty(sim)
                if isa(sim,"Sim")
                    obj.DataPath = sim.DataPath;
                    obj.DataAnalysisPath = sim.DataAnalysisPath;
                    obj.DataPrefix = sim.DataPrefix;
                    obj.DataPrefix = sim.DataPrefix;
                    obj.Output = sim.Output;
                    obj.WallTime = sim.WallTime;
                else
                    error("Input must be an object of the Sim class")
                end
            end
        end
        
        function fPath = get.RunPath(obj)
            if ~isempty(obj.DataPath) && ~isempty(obj.DataPrefix)
                fPath = fullfile(obj.DataPath,obj.DataPrefix+num2str(obj.RunIndex)+obj.DataFormat);
            else
                error("Can not find DataPath or DataPrefix. Specify DataPath or DataPrefix for SimRun.")
            end
        end
        
        function data = readRun(obj,varName)
            data = loadVar(obj.RunPath,varName);
        end
    end
end

