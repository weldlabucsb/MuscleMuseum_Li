classdef (Abstract) Waveform < handle
    %WAVEFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SamplingRate % In Hz
        Timing double = 0 % Start time, in s
        Duration % How long of the waveform, in s
        Amplitude double = 0 % Peak-to-peak amplitude, usually in Volts.
        Offset double = 0 % Offest, usually in Volts.
    end

    properties (Dependent)
        TimeStep
        NSample
        Sample
    end
    
    methods
        function obj = Waveform()
            %WAVEFORM Construct an instance of this class
            %   Detailed explanation goes here
            
        end

        function nS = get.NSample(obj)
            nS = floor(obj.Duration * obj.SamplingRate) + 1;
        end

        function dt = get.TimeStep(obj)
            dt = 1/obj.SamplingRate;
        end

        function s = get.Sample(obj)
            tFunc = obj.TimeFunc;
            t = obj.Timing : obj.TimeStep : (obj.Duration + obj.Timing);
            s = tFunc(t);
        end
        
        function plot(obj)
            t = obj.Timing : obj.TimeStep : (obj.Duration + obj.Timing);
            s = obj.Sample;
            plot(t,s)
            xlabel("Time [s]",Interpreter="latex")
            ylabel("Signal",Interpreter="latex")
            render
        end
    end

    methods (Abstract)
        TimeFunc(obj)
    end

end

