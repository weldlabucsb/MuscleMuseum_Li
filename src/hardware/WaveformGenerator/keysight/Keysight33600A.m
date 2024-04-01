classdef Keysight33600A < WaveformGenerator
    %KEYSIGHT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private,Transient)
        VisaDevice
    end
    
    methods
        function obj = Keysight33600A(resourceName,name)
            %KEYSIGHT Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                resourceName string
                name string = string.empty
            end
            obj@WaveformGenerator(resourceName,name);
            obj.Manufacturer = "Keysight";
            obj.Model = "33600A";
            obj.NChannel = 2;
            obj.Memory = 4e6;
            obj.SamplingRate = 64e6;
            obj.TriggerSource = "External";
            obj.TriggerMode = "Rise";
        end
        
        function connect(obj)
            obj.VisaDevice = visadev(obj.ResourceName);
        end

        function set(obj)
            v = obj.VisaDevice;
            v.ByteOrder = "little-endian";
            configureTerminator(v,"LF")
            writeline(v,"*CLS") % Clear status
            for ii = 1:obj.NChannel
                sourceStr = "SOURce" + string(ii);
                outputStr = "OUTPut" + string(ii);
                triggerStr = ":TRIGger" + string(ii);
                writeline(v,outputStr + " 0") % Stop output
                writeline(v,sourceStr + ":DATA:VOLatile:CLEar") % Clear volatile memory
                writeline(v,"FORM:BORD SWAP") % Swaps byte order to LSB
                writeline(v, sprintf(sourceStr + ':FUNCtion:ARBitrary:SRATe %g MHZ', obj.SamplingRate * 1e-6)); % Sampling rate
                writeline(v, sprintf(sourceStr + ':VOLTage:HIGH %g', 2.0)); % Voltage high
                writeline(v, sprintf(sourceStr + ':VOLTage:LOW %g', -2.0)); % Voltage low
                writeline(v, sprintf(sourceStr + ':VOLTage:OFFset %g', 0)); % Voltage offset
                writeline(v, sprintf(sourceStr + ':FUNCtion:ARBitrary:PTPeak %g', 2)); % Set arbitray waveform p2p
                writeline(v, sprintf(outputStr + ':MODE GATed')); % Gating the output
                switch obj.TriggerSource
                    case "External"
                        writeline(v, triggerStr + ":SOURce EXT");
                    case "Internal"
                        writeline(v, triggerStr + ":SOURce BUS");
                end
            end
        end

        function upload(obj)
            
        end
    end
end

