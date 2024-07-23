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
            obj.SampleUnit = "V";
        end

        function connect(obj)
            obj.Oscilloscope = oscilloscope;
            obj.Oscilloscope.Resource = obj.ResourceName;
            obj.Oscilloscope.connect
        end

        function set(obj)
            obj.Oscilloscope.AcquisitionTime = obj.Duration;
            obj.Oscilloscope.WaveformLength = obj.NSample;
            obj.Oscilloscope.TriggerMode = lowerFirst(obj.TriggerMode);
            if obj.TriggerSlope == "Rise"
                obj.Oscilloscope.TriggerSlope = "rising";
            else
                obj.Oscilloscope.TriggerSlope = "falling";
            end
            obj.Oscilloscope.TriggerLevel = obj.TriggerLevel;
            obj.Oscilloscope.TriggerSource = obj.TriggerSource;
            for ii = 1:obj.NChannel
                cName = "Channel" + num2str(ii);
                if ~obj.IsEnabled(ii)
                    disableChannel(obj.Oscilloscope,cName)
                else
                    enableChannel(obj.Oscilloscope,cName)
                    setVerticalCoupling(obj.Oscilloscope,cName,obj.VerticalCoupling(ii))
                    setVerticalOffset(obj.Oscilloscope,cName,obj.VerticalOffset(ii))
                    setVerticalRange(obj.Oscilloscope,cName,obj.VerticalRange(ii))
                end
            end
        end

        function read(obj)
            obj.Sample = obj.Oscilloscope.readWaveform;
        end

        function close(obj)
            obj.Oscilloscope.disconnect
        end

        function status = check(obj)

        end
    end
end

