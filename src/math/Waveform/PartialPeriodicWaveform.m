classdef (Abstract) PartialPeriodicWaveform < Waveform
    %PERIODICWAVEFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Amplitude double = 0 % Peak-to-peak amplitude, usually in Volts.
        Offset double = 0 % Offest, usually in Volts.
        Frequency double {mustBePositive} % In Hz
        Phase double % In radians
        RiseTime double {mustBeNonnegative} % In s
        FallTime double {mustBeNonnegative} % In s
    end

    properties (Dependent)
        PeriodicStartTime
        PeriodicDuration
        PeriodicEndTime
        Period % In s
        NPeriod
        NRepeat
        DurationOneCycle
        EndTimeAllCycle
        SampleOneCycle
        SampleExtra
        SampleBefore
        SampleAfter
    end

    properties (Constant)
        NCycle = 10
    end
    
    methods
        function obj = PartialPeriodicWaveform()
            %PERIODICWAVEFORM Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function t0P = get.PeriodicStartTime(obj)
            t0P = obj.StartTime + obj.RiseTime;
        end

        function tdP = get.PeriodicDuration(obj)
            tdP = obj.Duration - obj.RiseTime - obj.FallTime;
        end

        function teP = get.PeriodicEndTime(obj)
            teP = obj.PeriodicStartTime + obj.PeriodicDuration;
        end
        
        function T = get.Period(obj)
            if isa(obj,"ConstantTop")
                T = 1 / obj.SamplingRate * 10;
            else
                T = 1 / obj.Frequency;
            end
        end

        function nP = get.NPeriod(obj)
            nP = obj.PeriodicDuration / obj.Period;
        end

        function nR = get.NRepeat(obj)
            if obj.NPeriod <= obj.NCycle
                nR = 1;
            else
                nR = floor(obj.NPeriod / obj.NCycle);
            end
        end

        function tC = get.DurationOneCycle(obj)
            tC = (obj.Period * obj.NCycle);
        end

        function s = get.SampleOneCycle(obj)
            if obj.NRepeat == 1
                s = obj.Sample;
            else
                tFunc = obj.TimeFunc;
                t = obj.PeriodicStartTime : obj.TimeStep : (obj.PeriodicStartTime + obj.DurationOneCycle - obj.TimeStep);
                s = tFunc(t);
            end
        end

        function teC = get.EndTimeAllCycle(obj)
            if obj.NRepeat == 1
                teC = obj.PeriodicEndTime;
            else
                teC = obj.DurationOneCycle * obj.NRepeat + obj.PeriodicStartTime - obj.TimeStep;
            end
        end

        function s = get.SampleExtra(obj)
            tFunc = obj.TimeFunc;
            if isa(obj,"ConstantTop")
                s = [];
            elseif abs(obj.PeriodicEndTime - obj.EndTimeAllCycle) <= obj.TimeStep
                s = [];
            else
                t = (obj.EndTimeAllCycle + obj.TimeStep) : obj.TimeStep : obj.PeriodicEndTime;
                s = tFunc(t);
            end
        end

        function s = get.SampleBefore(obj)
            if abs(obj.PeriodicStartTime - obj.StartTime) <= obj.TimeStep
                s = [];
            else
                t = obj.StartTime:obj.TimeStep:(obj.PeriodicStartTime - obj.TimeStep);
                tFunc = obj.TimeFunc;
                s = tFunc(t);
            end
        end

        function s = get.SampleAfter(obj)
            if abs(obj.PeriodicEndTime - obj.EndTime) <= obj.TimeStep
                s = obj.SampleExtra;
            else
                t = (obj.PeriodicEndTime + obj.TimeStep):obj.TimeStep:obj.EndTime;
                tFunc = obj.TimeFunc;
                s = tFunc(t);
                s = [obj.SampleExtra,s];
            end
        end

        function plotOneCycle(obj)
            figure(10843)
            t = obj.PeriodicStartTime : obj.TimeStep : (obj.PeriodicStartTime + obj.DurationOneCycle - obj.TimeStep);
            s = obj.SampleOneCycle;
            plot(t,s)
            xlabel("Time [s]",Interpreter="latex")
            ylabel("Signal",Interpreter="latex")
            render
        end

        function plotExtra(obj)
            s = obj.SampleExtra;
            if isempty(s)
                return
            end
            figure(10844)
            t = (obj.EndTimeAllCycle + obj.TimeStep) : obj.TimeStep : obj.PeriodicEndTime;            
            plot(t,s)
            xlabel("Time [s]",Interpreter="latex")
            ylabel("Signal",Interpreter="latex")
            render
        end
    end
end

