classdef Keysight33600A < KeysightWaveformGenerator
    %KEYSIGHT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = Keysight33600A(resourceName,name)
            %KEYSIGHT Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                resourceName string
                name string = string.empty
            end
            obj@KeysightWaveformGenerator(resourceName,name);
            obj.Model = "33600A";
            obj.NChannel = 2;
            obj.IsOutput = [true,true];
            obj.Memory = 4e6;
            obj.SamplingRate = 64e6;
            obj.WaveformList = cell(1,obj.NChannel);
        end
    
    end
end

