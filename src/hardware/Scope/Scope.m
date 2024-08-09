classdef (Abstract) Scope < Hardware
    %WAVEFORMGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        Duration double {mustBePositive} = 0.1 %The time in seconds that corresponds to the record length
        NSample double {mustBeInteger,mustBePositive} = 2500 % How many data points to collect
        TriggerMode string {mustBeMember(TriggerMode,{'Normal','Auto'})} = "Normal"
        TriggerSource string = "External"
        TriggerSlope string {mustBeMember(TriggerSlope,{'Rise','Fall'})} = "Rise"
        TriggerLevel double = 0.1
        IsEnabled logical
        VerticalCoupling string {mustBeMember(VerticalCoupling,{'DC','AC'})} = "DC"
        VerticalOffset double = 0
        VerticalRange double = 10
    end

    properties (SetAccess = protected)
        SamplingRateMax
        Sample
        SampleUnit
        NSampleMax
    end

    properties (Dependent)
        TimeList
        SamplingRate
    end
    
    methods
        function obj = Scope(resourceName,name)
            arguments
                resourceName string
                name string = string.empty
            end
            obj@Hardware(resourceName,name)
        end

        function tL = get.TimeList(obj)
            tL = linspace(0,obj.Duration,obj.NSample);
        end

        function sR = get.SamplingRate(obj)
            sR = obj.NSample / obj.Duration;
        end

        function plot(obj,ax)
            arguments
                obj Scope
                ax = []
            end
            t = obj.TimeList;
            data = obj.Sample.SampleData;
            if isempty(ax)
                figure(8672)
                plot(t,data)
                xlabel("Time [s]",'Interpreter','latex')
                ylabel("Sample Data ["+ obj.SampleUnit + "]",'Interpreter','latex')
                cName = "Channel " + string(find(obj.IsEnabled));
                legend(cName(:),'Interpreter','latex')
                render
            elseif isa(ax,"matlab.graphics.axis.Axes")
                plot(ax,t,data)
                xlabel("Time [s]",'Interpreter','latex')
                ylabel("Sample Data ["+ obj.SampleUnit + "]",'Interpreter','latex')
                cName = "Channel " + string(find(obj.IsEnabled));
                legend(cName(:),'Interpreter','latex')
            else
                error("ax must be a MATLAB graphicx axis object.")
            end
        end
        
    end

    methods (Abstract)
        connect(obj)
        set(obj)
        read(obj)
        close(obj)
        status = check(obj)
    end
end

