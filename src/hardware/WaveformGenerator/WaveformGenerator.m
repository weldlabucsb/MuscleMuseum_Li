classdef (Abstract) WaveformGenerator < handle
    %WAVEFORMGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SamplingRate double
        TriggerSource string {mustBeMember(TriggerSource,{'External','Software','Immediate'})} = "External"
        TriggerSlope string {mustBeMember(TriggerSlope,{'Rise','Fall'})} = "Rise"
        OutputMode string {mustBeMember(OutputMode,{'Gated','Normal'})} = "Normal"
        WaveformList cell
    end
    
    properties(SetAccess = protected)
        Name string % Nickname of the device
        Manufacturer string % Manufacturer of the device
        Model string % Model number
        Memory double % How many sample points the device can store
        NChannel double % How many channels the device has
        ResourceName string % Interfaces (like VISA) require a resource name to identify the device
        DataType string {mustBeMember(DataType,{'uint8','double'})}= "uint8"
    end
    
    methods
        function obj = WaveformGenerator(resourceName,name)
            arguments
                resourceName string
                name string = string.empty
            end
            obj.ResourceName = resourceName;
            obj.Name = name;
        end
        
    end

    methods (Abstract)
        connect(obj)
        set(obj)
        upload(obj)
    end
end

