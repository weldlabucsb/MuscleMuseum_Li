classdef (Abstract) PeriodicWaveform < Waveform
    %PERIODICWAVEFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Frequency % In Hz
        Phase % In radians
    end

    properties (Dependent)
        Period % In s
        NPeriod
        NRepeat
        SampleOneCycle
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
            T = 1 / obj.Frequency;
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

        function s = get.SampleOneCycle(obj)
            tFunc = obj.TimeFunc;
            t = obj.StartTime : obj.TimeStep : (obj.Period * obj.NCycle);
            s = tFunc(t);
        end

        function set.Phase(obj,val)
            obj.Phase = mod(val,2*pi);
        end

        function plotOneCycle(obj)
            t = obj.StartTime : obj.TimeStep : (obj.Period * obj.NCycle);
            s = obj.SampleOneCycle;
            plot(t,s)
            xlabel("Time [s]",Interpreter="latex")
            ylabel("Signal",Interpreter="latex")
            render
        end
    end
end

