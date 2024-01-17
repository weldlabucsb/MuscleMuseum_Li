classdef tt < TTT
    %TT Summary of this class goes here
    %   Detailed explanation goes here

    properties
        ii
        ls
    end

    methods
        function obj = tt()
            obj@TTT();
            %TT Construct an instance of this class
            %   Detailed explanation goes here
            obj.ii = 0;
        end

        function createLister(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.ls = addlistener(obj,'test', @(src,event) onChanged2(src,event));
            function onChanged2(~,~)
                % disp(source)
                % disp('found new file')
                % disp(source.Path)
                % disp(source.NotifyFilter)
                % disp(arg.FullPath.ToString())
                disp('oo')
            end
        end
    end

end

