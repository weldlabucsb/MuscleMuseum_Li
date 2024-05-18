classdef (Abstract) Waveform < handle
    %WAVEFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SamplingRate double {mustBePositive} = 1 % In Hz
        StartTime double = 0 % Start time, in s
        Duration double {mustBePositive} % How long of the waveform, in s
        Amplitude double = 0 % Peak-to-peak amplitude, usually in Volts.
        Offset double = 0 % Offest, usually in Volts.
        Scan table = table(string.empty,string.empty, 'VariableNames',{'ParameterName','VariableName'}) % For scanning in Hardware control
    end

    properties (Dependent)
        EndTime
        TimeStep
        NSample
        Sample
    end
    
    methods
        function obj = Waveform()
            %WAVEFORM Construct an instance of this class
            %   Detailed explanation goes here
            
        end

        function te = get.EndTime(obj)
            te = obj.StartTime + obj.Duration;
        end

        function nS = get.NSample(obj)
            nS = floor(obj.Duration * obj.SamplingRate) + 1;
        end

        function dt = get.TimeStep(obj)
            dt = 1/obj.SamplingRate;
        end

        function s = get.Sample(obj)
            tFunc = obj.TimeFunc;
            t = obj.StartTime : obj.TimeStep : obj.EndTime;
            s = tFunc(t);
        end
        
        function plot(obj)
            t = obj.StartTime : obj.TimeStep : obj.EndTime;
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

