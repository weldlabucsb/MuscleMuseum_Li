classdef (Abstract) PeriodicWaveform < Waveform
    %PERIODICWAVEFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Amplitude double = 0 % Peak-to-peak amplitude, usually in Volts.
        Offset double = 0 % Offest, usually in Volts.
        Frequency double {mustBePositive} % In Hz
        Phase double % In radians
    end

    properties (Dependent)
        Period % In s
        NPeriod
        NRepeat
        DurationOneCycle
        EndTimeAllCycle
        SampleOneCycle
        SampleExtra
    end

    properties (Constant)
        NCycle = 10
    end
    
    methods
        function obj = PeriodicWaveform()
            %PERIODICWAVEFORM Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function T = get.Period(obj)
            if isa(obj,"ConstantTop")
                T = 1 / obj.SamplingRate * 10;
            else
                T = 1 / obj.Frequency;
            end
        end

        function nP = get.NPeriod(obj)
            nP = obj.Duration / obj.Period;
        end

        function nR = get.NRepeat(obj)
            if obj.NPeriod <= obj.NCycle
                nR = 1;
            else
                nR = floor(obj.NPeriod / obj.NCycle);
            end
        end

        function tC = get.DurationOneCycle(obj)
            tC = obj.Period * obj.NCycle;
        end

        function s = get.SampleOneCycle(obj)
            % if obj.NRepeat == 1
                % s = obj.Sample;
            % else
                tFunc = obj.TimeFunc;
                t = obj.StartTime : obj.TimeStep : (obj.StartTime + obj.DurationOneCycle - obj.TimeStep);
                s = tFunc(t);
            % end
        end

        function teC = get.EndTimeAllCycle(obj)
            if obj.NRepeat == 1
                teC = obj.EndTime;
            else
                teC = obj.DurationOneCycle * obj.NRepeat + obj.StartTime - obj.TimeStep;
            end
        end

        function s = get.SampleExtra(obj)
            tFunc = obj.TimeFunc;
            if isa(obj,"ConstantTop")
                s = [];
            elseif abs(obj.EndTime - obj.EndTimeAllCycle) <= obj.TimeStep
                s = [];
            else
                t = (obj.EndTimeAllCycle + obj.TimeStep) : obj.TimeStep : obj.EndTime;
                s = tFunc(t);
            end
        end

        function plotOneCycle(obj)
            figure(10843)
            t = obj.StartTime : obj.TimeStep : (obj.StartTime + obj.DurationOneCycle - obj.TimeStep);
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
            t = (obj.EndTimeAllCycle + obj.TimeStep) : obj.TimeStep : obj.EndTime;            
            plot(t,s)
            xlabel("Time [s]",Interpreter="latex")
            ylabel("Signal",Interpreter="latex")
            render
        end
    end
end

