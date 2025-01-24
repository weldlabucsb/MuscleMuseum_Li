classdef SpectrumDN2662_02 < SpectrumWaveformGenerator
    %KEYSIGHT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = SpectrumDN2662_02(resourceName,name)
            %KEYSIGHT Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                resourceName string
                name string = string.empty
            end
            obj@SpectrumWaveformGenerator(resourceName,name);
            obj.Model = "DN2662_02";
            obj.NChannel = 2;
            obj.IsOutput = [true,true];
            obj.Memory = 2e9;
            obj.SamplingRate = 1.25e9;
            obj.WaveformList = cell(1,obj.NChannel);
            obj.DisabledProperty = ["TriggerSlope","OutputMode","OutputLoad"];
        end
            
    end
end

