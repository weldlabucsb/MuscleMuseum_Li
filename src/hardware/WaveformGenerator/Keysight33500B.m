classdef Keysight33500B < KeysightWaveformGenerator
    %KEYSIGHT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = Keysight33500B(resourceName,name)
            %KEYSIGHT Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                resourceName string
                name string = string.empty
            end
            obj@KeysightWaveformGenerator(resourceName,name);
            obj.Model = "33500B";
            obj.NChannel = 2;
            obj.IsOutput = [true,true];
            obj.Memory = 16e6;
            obj.SamplingRate = 250e6;
            obj.WaveformList = cell(1,obj.NChannel);
        end
            
    end
end

