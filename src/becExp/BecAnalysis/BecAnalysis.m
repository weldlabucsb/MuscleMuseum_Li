classdef (Abstract) BecAnalysis < handle & matlab.mixin.SetGetExactNames
    %BECANALYSIS Summary of this class goes here
    %   Detailed explanation goes here

    properties 
        Chart Chart
        Gui Gui
    end
    
    properties (SetAccess = protected)
        BecExp BecExp
    end
    
    methods 
        function obj = BecAnalysis(becExp)
            obj.BecExp = becExp;
        end
    end
    
    methods
        
        function initialize(obj)
            for ii = 1:numel(obj.Chart)
                obj.Chart(ii).initialize;
            end
            for ii = 1:numel(obj.Gui)
                obj.Gui(ii).initialize(obj.BecExp);
            end
        end

        function update(obj,runIdx)
            obj.updateData(runIdx);
            obj.updateFigure(runIdx);
        end

        function updateData(obj,runIdx)

        end

        function updateFigure(obj,runIdx)

        end

        function finalize(obj)
            
        end

        function save(obj)
            for ii = 1:numel(obj.Chart)
                obj.Chart(ii).save;
            end
        end

        function show(obj)
            for ii = 1:numel(obj.Gui)
                obj.Gui(ii).initialize(obj.BecExp);
            end
            for ii = 1:numel(obj.Chart)
                obj.Chart(ii).show;
            end
        end
        
        function browserShow(obj)
            mp = sortMonitor;
            monitorIndex = 1;
            if size(mp,1) > 1
                appHandle = get(findall(0, 'Tag', obj.BecExp.ControlAppName), 'RunningAppInstance');
                if ~isempty(appHandle)
                    if isvalid(appHandle)
                        monitorIndex = 2;
                    end
                end
            end
            for jj = 1:numel(obj.Gui)
                obj.Gui(jj).Monitor = monitorIndex;
            end
            for jj = 1:numel(obj.Chart)
                obj.Chart(jj).IsBrowser = true;
                obj.Chart(jj).Monitor = monitorIndex;
            end
            obj.show
        end

        function refresh(obj)
            obj.initialize
            for runIdx = 1:obj.BecExp.NCompletedRun
                obj.updateData(runIdx)
            end
            obj.updateFigure(runIdx)
            obj.finalize
        end

        function toggle(obj,isEnabled)
            for ii = 1:numel(obj.Gui)
                obj.Gui(ii).IsEnabled = isEnabled;
            end
            for ii = 1:numel(obj.Chart)
                obj.Chart(ii).IsEnabled = isEnabled;
            end
        end

        function close(obj)
            for ii = 1:numel(obj.Gui)
                obj.Gui(ii).close;
            end
            for ii = 1:numel(obj.Chart)
                obj.Chart(ii).close;
            end
        end
    end

end

