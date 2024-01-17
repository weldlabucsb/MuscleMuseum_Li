classdef Gui < handle
    %GUI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        Path
        Location
        Size
        IsEnabled logical = true
    end

    properties (Transient)
        App matlab.apps.AppBase
    end
    
    methods
        function obj = Gui(NameValueArgs)
            %GUI Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                NameValueArgs.name
                NameValueArgs.fpath
                NameValueArgs.loc
                NameValueArgs.size
                NameValueArgs.isEnabled logical = true
            end
            obj.Name = NameValueArgs.name;
            obj.Path = NameValueArgs.fpath;
            obj.Location = NameValueArgs.loc;
            obj.Size = NameValueArgs.size;
            obj.IsEnabled = NameValueArgs.isEnabled;
        end
        
        function initialize(obj,varargin)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if ~obj.IsEnabled
                return
            end

            allfigs = findall(0,'Type','figure'); 
            app2Handle = findall(allfigs, 'Name', obj.Name);
            close(app2Handle)
            try
                obj.App = feval(obj.Name,varargin{:});
            catch
                obj.App = eval(obj.Name);
            end
            SS = get(0,'screensize');

            if isstring(obj.Size)
                switch obj.Size
                    case "small"
                        fWidth = SS(3)/4.1;
                        fHeight = SS(4)/2.1;
                    case "medium"
                        fWidth = SS(3)/3.1;
                        fHeight = SS(4)/2.1;
                    case "large"
                        fWidth = SS(3)/3.1 * 1.5;
                        fHeight = SS(4)/2.1 *1.5;
                    case "largetall"
                        fWidth = SS(3)/3.1 * 1.5;
                        fHeight = SS(4)/1.1;
                    case "full"
                        fWidth = SS(3)/1.1;
                        fHeight = SS(4)/1.1;
                end
            else
                fWidth = obj.Size(1) * SS(3);
                fHeight = obj.Size(2) * SS(4);
            end

            if isstring(obj.Location)
                switch obj.Location
                    case "eastnorthwest"
                        loc = [SS(3)/2,-1];
                    otherwise
                        loc = obj.Location;
                end
            else
                loc = [obj.Location(1) * SS(3),obj.Location(2) * SS(4)];
            end

            obj.App.UIFigure.Position = [200,600,fWidth,fHeight];
            obj.App.UIFigure.Name = obj.Name;
            movegui(obj.App.UIFigure,loc);
        end

        function update(obj)
            if obj.IsEnabled
                obj.App.update
            end
        end

        function close(obj)
            if isvalid(obj.App)
                obj.App.delete
            end
        end
    end
end

