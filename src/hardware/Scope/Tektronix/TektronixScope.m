classdef (Abstract) TektronixScope < Scope
    %TEKTRONIXOSCILLOSCOPE Summary of this class goes here
    %   Detailed explanation goes here
    properties (SetAccess = protected,Transient)
        Oscilloscope Oscilloscope % MATLAB Quick-Control Oscilloscope object
    end

    methods
        function obj = TektronixScope(resourceName,name)
            arguments
                resourceName string
                name string = string.empty
            end
            obj@Scope(resourceName,name);
            obj.Manufacturer = "Tektronix";
        end

        function connect(obj)
            obj.Oscilloscope = oscilloscope;
            obj.Oscilloscope.Resource = obj.ResourceName;
            connect(obj.Oscilloscope)
        end
    end
end

