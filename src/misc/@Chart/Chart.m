classdef Chart < handle
    %CHART Summary of this class goes here
    %   Detailed explanation goes here

    properties (SetAccess = protected)
        Name string
        Number double
        Path string
        Location
        Size
        IsGif logical = false
    end

    properties
        IsEnabled logical = true
    end

    properties (Transient)
        Figure matlab.ui.Figure
        Image matlab.graphics.primitive.Image
    end

    methods

        function obj = Chart(NameValueArgs)
            arguments
                NameValueArgs.name
                NameValueArgs.num
                NameValueArgs.fpath
                NameValueArgs.loc
                NameValueArgs.size
                NameValueArgs.isGif logical = false
                NameValueArgs.isEnabled logical = true
            end
            obj.Name = NameValueArgs.name;
            obj.Number = NameValueArgs.num;
            obj.Path = NameValueArgs.fpath;
            obj.Location = NameValueArgs.loc;
            obj.Size = NameValueArgs.size;
            obj.IsGif = NameValueArgs.isGif;
            obj.IsEnabled = NameValueArgs.isEnabled;
        end

        function fig = initialize(obj)
            if ~obj.IsEnabled
                fig = [];
                return
            end

            obj.Figure = figure(obj.Number);
            clf(obj.Figure);

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

            obj.Figure.OuterPosition = [200,600,fWidth,fHeight];
            obj.Figure.NumberTitle = "off";
            obj.Figure.ToolBar = "figure";
            obj.Figure.MenuBar = "none";

            obj.Figure.Name = obj.Name;
            movegui(obj.Figure,loc);
            fig = obj.Figure;
        end

        function save(obj)
            if ~obj.IsEnabled
                return
            end

            if ~obj.IsGif
                % Check if figure is valid
                if ~isvalid(obj.Figure)
                    warning("Figure [" + obj.Name+"]" + " was not found." + ...
                        " It might have been closed.")
                    return
                end
                % Check if image is too large
                img = findobj(obj.Figure,'type','image');
                nEle = 0;
                for ii = 1:numel(img)
                    nEle = nEle + numel(img.CData);
                end

                if nEle < 0.5*10^9
                    saveas(obj.Figure,obj.Path,'fig')
                else
                    warning("Image size too large. " + ...
                        "Figure [" + obj.Name+"]" + " was not saved as .fig")
                end
                saveas(obj.Figure,obj.Path,'png')
            end
        end

        function show(obj)
            if ~obj.IsEnabled
                return
            end

            if ~obj.IsGif
                figPath = obj.Path + ".fig";
                if isfile(figPath)
                    fig = obj.initialize;
                    src = openfig(figPath,"invisible");
                    warning off
                    copyobj(allchild(src),fig)
                    warning on
                    % obj.Figure = fig;
                end
            else
                % gifPath = obj.Path + ".gif";
                % if isfile(gifPath)
                %     winopen(gifPath)
                % end
            end
        end
    
        function close(obj)
            if ~obj.IsEnabled
                return
            end

            if ~obj.IsGif
                close(figure(obj.Number))
            else

            end
        end
    end
end

