classdef TTT < handle
    %TTT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Watcher
    end
    
    methods
        function obj = TTT()
            %TTT Construct an instance of this class
            %   Detailed explanation goes here
            % obj.Property1 = inputArg1 + inputArg2;
        end
        
        function createWatcher(obj)
            obj.Watcher = System.IO.FileSystemWatcher(pwd);
            obj.Watcher.Filter = "*"+".tif";
            obj.Watcher.EnableRaisingEvents = true;
            addlistener(obj.Watcher,'Created', @(src,event) onChanged(src,event,obj));
            function onChanged(~,~,obj)
                % obj.TempDataName = [obj.TempDataName string(evt.FullPath.ToString())];
                % disp(numel(obj.TempDataName))
                notify(obj,'test');
                % if numel(obj.TempDataName) == obj.DataGroupSize
                %     disp('newrun')
                %     notify(obj,'NewRunFinished');
                %     obj.TempDataName = [];
                %     obj.NCompletedRun = obj.NCompletedRun + 1;
                %     if obj.NCompletedRun > obj.NRun
                %         obj.NRun = obj.NCompletedRun;
                %     end
                % end
            end
        end
    end
    events
        test %Triggered when a new run is detected.
    end
end

