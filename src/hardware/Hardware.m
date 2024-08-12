classdef (Abstract) Hardware < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties(SetAccess = protected)
        Name string % Nickname of the device
        Manufacturer string % Manufacturer of the device
        Model string % Model number
        Memory double % How many sample points the device can store
        NChannel double % How many channels the device has
        ResourceName string % Interfaces (like VISA) require a resource name to identify the device
        DataType string {mustBeMember(DataType,{'uint8','double'})}= "uint8"
        ParentPath string
        DataPath string % Folder to save the object
        DisabledProperty string % Properties that are not implemented for specific models
    end

    methods
        function obj = Hardware(resourceName,name)
            arguments
                resourceName string
                name string = string.empty
            end
            obj.ResourceName = resourceName;
            obj.Name = name;

            % Set logging folder
            load("Config.mat","ComputerConfig")
            obj.ParentPath = ComputerConfig.HardwareLogOrigin;
            if isfolder(obj.ParentPath)
                obj.DataPath = fullfile(obj.ParentPath,name);
                createFolder(obj.DataPath);
            else
                warning("Can not find the hardware log folder. Check your setConfig")
            end
        end
    end

    methods (Access = protected)
        function saveObject(obj)
            if isfolder(obj.DataPath)
                t = string(datetime('now','Format','yyyyMMddHHmmss'));
                save(fullfile(obj.DataPath,obj.Name + "_" + t),'obj')
            end
        end
    end
end

