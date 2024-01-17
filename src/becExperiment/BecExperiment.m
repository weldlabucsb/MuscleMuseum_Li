classdef (Abstract) BecExperiment < handle
    %BECEXPERIMENT A class for handling BEC experiments image data.
    %   This class is designed for spin-1, quasi 1D BEC experiemnts. The
    %images are assumed as absorption images only. We assume the vertical
    %direction of an image is x direction and the horizontal direction of
    %an image is y direction. The images are taken from a Andor camera.
    %   This class is abstract so construction can only be done from
    %subclasses. 
    %   When constructed, create a data storage folder according the 
    %date and the experiment type. Also it will create a dataAnalysis 
    %folder under the data folder. The object is saved to that folder when 
    %the construction is finished. A temperate txt file is also created to
    %tell Andor program where to save the images. A correponding archive
    %folder is created if it is not exist.
    %   General image processing methods are defined here, including
    %selecting ROI, calculating optical depth and calculating axial atom
    %number distribution.
    %   All the Show### methods have two functions. When there is no input
    %arguement, they will show the corresponding figures. When there is a
    %input number, it will return the corresponding data.
    
    properties
        DataPrefix = 'run' % Data prefix assigned in Andor.
        DataType = 'fits' % Data type.
        DataSize = [1024 1024] % Data size in pixel.
        RoiSize = [200,600] % X and Y ROI sizes in pixel.
        RoiPosition = [730,515,319,510] % The last element is the ROI center in y direction. The rest are the ROI centers in x direction for each spin component
        PixelSize = 1.295 % Pixel size.
        FirstRunIndex = 1 % The index of the first image to read
        TiltAngle = -0.007208
        IsTiltCompensation = 1
        MinimumAbsorption = 0;
        PlotRadius % In microns.  
        RoiPosition2
        TempRoiPosition = []
        TempRoiSize = []
        OdAxis = [0,1.5];
        Description
        RoiSize2
    end
    
    properties (SetAccess = private)
        ExperimentDate % The date when the experiment is done.
    end
    
    properties (SetAccess = private, Hidden)
        DatePath
    end
    
    properties 
        DataPath
        DataAnalysisPath    
    end
    
    properties (SetAccess = protected, Hidden)
        ExperimentIndex
        ExperimentName
        ObjName
        ArchiveName
        IsChanged = 1
    end
    
    properties (Constant, Hidden)
        ParentPath = 'C:\data\bec_exp'
        TempPath = 'C:\data\bec_exp'
        TempFileName = 'C:\data\bec_exp\temp.txt'
    end
    
    properties (Dependent)
        YList
        RoiLim % [xmin_p1,xmax_p1,ymin_p1,ymax_p1;...zero;...m1]
%         RoiSize2
    end
    
    properties (Dependent, Hidden)
        NRoi
    end
    
    methods
        
        function obj = BecExperiment(expName)
            % Create folders and tell Andor where to save the images. 
            %% Create folder names based on date.
            date = datestr(now,23);
            [date1,date2,mm,dd,yyyy] = dateDetail(date);
            datePath = fullfile(obj.ParentPath,yyyy,[mm,'.',dd]);
            createFolder(datePath);
            deleteEmptyFolders(datePath,1)
            idx = findFolderIndex(datePath,expName,'_');
            dataPath = fullfile(datePath,[expName,'_',num2str(idx)]);
            dataAnaPath = fullfile(dataPath,'dataAnalysis');
            objName = fullfile(dataAnaPath,[expName,date2,'_',num2str(idx),'.mat']);
            
            %% Create the corresponding archive folder name.
            achPath = fullfile(obj.ParentPath,'archive',expName);
            createFolder(achPath);
            [~,name,~] = fileparts(objName);
            achName = fullfile(achPath,[name,'.mat']);
            
            %% Write values into properties.
            obj.ExperimentName = expName;
            obj.ExperimentDate = date1;
            obj.DatePath = datePath;
            obj.ExperimentIndex = idx;
            obj.DataPath = dataPath;
            obj.DataAnalysisPath = dataAnaPath;
            obj.ObjName = objName;
            obj.ArchiveName = achName;
            
            %% Create folders.
            createFolder(dataPath);
            createFolder(dataAnaPath);
            
            %% Tell Andor the data path.
            fileID = fopen(obj.TempFileName,'w');
            fprintf(fileID,'%s',obj.DataPath);
            fclose(fileID);
            
        end
        
        function y = get.YList(obj)
            roiSize = obj.RoiSize;
            roiPos = obj.RoiPosition;
            dataSize = obj.DataSize;
            pix = obj.PixelSize;
            y = (1:dataSize(2))*pix;
            y = y(roiPos(2)-floor(roiSize(2)/2):roiPos(2)+ceil(roiSize(2)/2)-1);
        end
        
        function set.PlotRadius(obj,value)
            obj.PlotRadius = value;
            obj.IsChanged = 1;
        end
        
        function nRoi = get.NRoi(obj)
            roiPos = obj.RoiPosition;
            nRoi = numel(roiPos)-1;
        end
        
        function roiLim = get.RoiLim(obj)
           roiSize = obj.RoiSize;
           roiPosition = obj.RoiPosition;
           a = roiSize(1);
           b = roiSize(2);
           fa = floor(a/2);
           ca = ceil(a/2)-1;
           fb = floor(b/2);
           cb = ceil(b/2)-1;
           nRoi = numel(roiPosition)-1;
           roiLim = zeros(nRoi,4);
           
           xPos = roiPosition(1:nRoi);
           yPos = roiPosition(end);
           for iRoi = 1:nRoi
               roiLim(iRoi,:) = [xPos(iRoi)-fa,xPos(iRoi)+ca,yPos-fb,yPos+cb];
           end
        end
        
%         function roiSize2 = get.RoiSize2(obj)
%            pix = obj.PixelSize;
%            roiSize = obj.RoiSize;
%            pRadius = obj.PlotRadius;
%            if isempty(pRadius)
%                roiSize2 = [];
%            else
%                roiSize2(1) = round(2*pRadius/pix);
%                roiSize2(2) = roiSize(2);
%            end
%         end
        
        function Update(obj)
            save(obj.ObjName,'obj')
        end
        
        function Archive(obj)
            save(obj.ArchiveName,'obj')
        end
        
        function Delete(obj)
            choice = input('Do you want to delete this experiment? Y/N [Y]:','s');
            if choice == 'Y'
                rmdir(obj.DataPath,'s')
                achName = obj.ArchiveName;
                deleteFile(achName)
            end
        end
        
        function UpdatePath(obj)
            choice = input('Do you want to update the Andor save path? Y/N [Y]:','s');
            if choice == 'Y'
                fileID = fopen(obj.TempFileName,'w');
                fprintf(fileID,'%s',obj.DataPath);
                fclose(fileID);
            end
        end
        
        function varargout = ShowImage(obj,runNumber)
            %% Read parameters from properties.
            nRuns = obj.NRuns;
            dataPath = obj.DataPath;
            prefix = obj.DataPrefix;
            iniIndex = obj.FirstRunIndex;
            isTiltComp = obj.IsTiltCompensation;
            tiltAngle = obj.TiltAngle;
            imgSize = obj.DataSize;
            daPath = obj.DataAnalysisPath;
            
            %% Return data
            if nargin == 2
                varargout{1} = returnValue(runNumber);
                return
            end
            
            %% Initialize the figure.
            fig = renderFigure(1,[1024,1024],'center');
            
            data0 = returnValue(1);
            img = imagesc(data0);
            tit = title('Absorption Image Preview, Run 1');
            renderImage(img,[0,1],gray,0)
            hold on 
            marker = plot(512,512,'+','MarkerSize',20,'Color','r','LineWidth',1.5);
            hold off
            marker.PickableParts = 'none';
            
            ax = fig.CurrentAxes;
            pos = ax.Position;
            ax.Position = [pos(1)+0.1,pos(2)+0.1,pos(3)-0.1,pos(4)-0.1];
            pos = ax.Position;
            
            subplot('Position',[pos(1),pos(2)-0.12,pos(3),0.1])
            l1 = plot(1:imgSize(2),data0(512,:));
            axis([1,imgSize(1),0,1])
            
            subplot('Position',[pos(1)-0.12,pos(2),0.1,pos(4)])
            l2 = plot(data0(:,512),1:imgSize(1));
            axis([0,1,1,imgSize(1)])
            
            %% Create GUIs
            [slider,editbox] = createUis(fig,nRuns,'run');
            tex = uicontrol('Parent',fig,'Style','text','Position',[50,100,100,50],...
    'String',{'X = 512', 'Y = 512',['Data = ',num2str(data0(512,512))]},'FontSize',8);
            saveButton = uicontrol('Parent',fig,'Style','pushbutton','Position',[15,25,100,50],'String','save');
            slider.Callback = @(es,ed) setHandles(img,tit,slider,editbox,l1,l2,marker,tex,es.Value);
            editbox.Callback = @(es,ed) setHandles(img,tit,slider,editbox,l1,l2,marker,tex,es.String);
            saveButton.Callback ={@setButton,editbox};
            img.ButtonDownFcn = {@setClick,marker,l1,l2,tex};
            fig.KeyPressFcn = {@setKey,marker,l1,l2,tex};
            
            %% Define the callback functions.
            function setHandles(img,tit,slider,box,l1,l2,marker,tex,n)
                if class(n) == "char"
                    n = str2double(n);
                    if n>nRuns || n<1 || isnan(n)
                        return
                    end
                end
                n = round(n);            
                tit.String = ['Absorption Image Preview, Run ',num2str(n)];
                n = n + iniIndex - 1;
                data = returnValue(n);
                img.CData = data;
                box.String = num2str(n);
                slider.Value = n;
                
                xpos = round(marker.YData);
                ypos = round(marker.XData);
                l1.YData = data(xpos,:);
                l2.XData = data(:,ypos);
                tex.String = {['X = ',num2str(xpos)],['Y = ',num2str(ypos)],['Data = ',num2str(data(xpos,ypos))]};
            end
            
            function setClick(src,ev,marker,l1,l2,tex)
                p = round(ev.IntersectionPoint);
                data = src.CData;
                marker.XData = p(1);
                marker.YData = p(2);
                l1.YData = data(p(2),:);
                l2.XData = data(:,p(1));
                tex.String = {['X = ',num2str(p(2))],['Y = ',num2str(p(1))],['Data = ',num2str(data(p(2),p(1)))]};
            end   
            
            function setKey(~,ev,marker,l1,l2,tex)
                key = ev.Key;
                switch key
                    case "uparrow"
                        marker.YData = marker.YData + 1;
                    case "downarrow"
                        marker.YData = marker.YData - 1;
                    case "leftarrow"
                        marker.XData = marker.XData - 1;
                    case "rightarrow"
                        marker.XData = marker.XData + 1;
                    otherwise
                        return
                end
                data = img.CData;
                p(1) = marker.XData;
                p(2) = marker.YData;
                l1.YData = data(p(2),:);
                l2.XData = data(:,p(1));
                tex.String = {['X = ',num2str(p(2))],['Y = ',num2str(p(1))],['Data = ',num2str(data(p(2),p(1)))]};
            end
            
            function setButton(~,~,editbox)
                n = editbox.String;
                if class(n) == "char"
                    nn = str2double(n);
                    if nn>nRuns || nn<1 || isnan(nn)
                        return
                    end
                end
                createFolder(fullfile(daPath,'runImages'));
                imgName = fullfile(daPath,'runImages',['run',n,'.png']);
                fig2 = figure;
                fig2.Position(4) = fig2.Position(3);
                copyobj(ax,fig2)
                fig2.CurrentAxes.Position = [0,0,1,1];
                axis image
                l = findobj(fig2,'Type','Line');
                delete(l);
                saveas(fig2,imgName)
                close(fig2)
            end
                        
            %% Define the return function.
            function data = returnValue(run)
                runNumber2 = run+iniIndex-1;
                data = readFitsData(dataPath,prefix,runNumber2); %Read data
                if isempty(data)
                    data = zeros(imgSize);
                end
                if isTiltComp
                    data = imrotate(data,tiltAngle/pi*180,'bilinear','crop'); %Rotate
                end
            end
            
        end
        
        function varargout = ShowOD(obj,runNumber)
            %% Read parameters from properties.
            nRuns = obj.NRuns;
            absorpMin = obj.MinimumAbsorption;
            imgSize = obj.DataSize;
            odAxis = obj.OdAxis;
            
            %% Return data
            if nargin == 2
                varargout{1} = returnValue(runNumber);
                return
            end
            
            %% Initialize the figure.
            fig = renderFigure(1,[1024,1024],'center');
            
            odData0 = returnValue(1);   
            img = imagesc(odData0);
            tit = title('Optical Depth Image Preview, Run 1');
            renderImage(img,odAxis,parula,0)
            hold on
            marker = plot(512,512,'+','MarkerSize',20,'Color','r','LineWidth',1.5);
            hold off
            marker.PickableParts = 'none';
            
            ax = fig.CurrentAxes;
            pos = ax.Position;
            ax.Position = [pos(1)+0.1,pos(2)+0.1,pos(3)-0.1,pos(4)-0.1];
            pos = ax.Position;
            
            subplot('Position',[pos(1),pos(2)-0.12,pos(3),0.1])
            l1 = plot(1:imgSize(2),odData0(512,:));
            axis([1,imgSize(1),odAxis(1),odAxis(2)])
            
            subplot('Position',[pos(1)-0.12,pos(2),0.1,pos(4)])
            l2 = plot(odData0(:,512),1:imgSize(1));
            axis([odAxis(1),odAxis(2),1,imgSize(1)])
            
            %% Create GUIs
            [slider,editbox] = createUis(fig,nRuns,'run');
            tex = uicontrol('Parent',fig,'Style','text','Position',[50,100,100,50],...
    'String',{'X = 512', 'Y = 512',['Data = ',num2str(odData0(512,512))]},'FontSize',8);
            editbox2 = uicontrol('Parent',fig,'Style','edit','Position',[940,185,50,30],...
    'String',num2str(odAxis(1)), 'min',1, 'max',0,'FontSize',11);
            editbox3 = uicontrol('Parent',fig,'Style','edit','Position',[940,845,50,30],...
    'String',num2str(odAxis(2)), 'min',1, 'max',0,'FontSize',11);
            slider.Callback = @(es,ed) setHandles(img,tit,slider,editbox,l1,l2,marker,tex,es.Value);
            editbox.Callback = @(es,ed) setHandles(img,tit,slider,editbox,l1,l2,marker,tex,es.String);
            img.ButtonDownFcn = {@setClick,marker,l1,l2,tex};
            editbox2.Callback = {@setCAxis,img,l1,l2};
            editbox3.Callback = {@setCAxis2,img,l1,l2};
            fig.KeyPressFcn = {@setKey,marker,l1,l2,tex};
            
            %% Define the callback function.
            function setHandles(img,tit,slider,box,l1,l2,marker,tex,n)
                if class(n) == "char"
                    n = str2double(n);
                    if n>nRuns || n<1 || isnan(n)
                        return
                    end
                end
                n = round(n);
                odData = returnValue(n);
                img.CData = odData;
                tit.String = ['Optical Depth Image Preview, Run ',num2str(n)];
                box.String = num2str(n);
                slider.Value = n;
                
                xpos = round(marker.YData);
                ypos = round(marker.XData);
                l1.YData = odData(xpos,:);
                l2.XData = odData(:,ypos);
                tex.String = {['X = ',num2str(xpos)],['Y = ',num2str(ypos)],['Data = ',num2str(odData(xpos,ypos))]};
            end
            
            function setClick(src,ev,marker,l1,l2,tex)
                p = round(ev.IntersectionPoint);
                data = src.CData;
                marker.XData = p(1);
                marker.YData = p(2);
                l1.YData = data(p(2),:);
                l2.XData = data(:,p(1));
                tex.String = {['X = ',num2str(p(2))],['Y = ',num2str(p(1))],['Data = ',num2str(data(p(2),p(1)))]};
            end
            
            function setCAxis(src,~,img,l1,l2)
                clim1 = str2double(src.String);
                clim2 = img.Parent.CLim(2);
                if clim1>=clim2 || isnan(clim1)
                    return
                else
                    img.Parent.CLim(1) = clim1;
                    l1.Parent.YLim(1) = clim1;
                    l2.Parent.XLim(1) = clim1;
                end
            end
            
            function setCAxis2(src,~,img,l1,l2)
                clim2 = str2double(src.String);
                clim1 = img.Parent.CLim(1);
                if clim1>=clim2 || isnan(clim2)
                    return
                else
                    img.Parent.CLim(2) = clim2;
                end
                l1.Parent.YLim(2) = clim2;
                l2.Parent.XLim(2) = clim2;
            end
            
            function setKey(~,ev,marker,l1,l2,tex)
                key = ev.Key;
                switch key
                    case "uparrow"
                        marker.YData = marker.YData + 1;
                    case "downarrow"
                        marker.YData = marker.YData - 1;
                    case "leftarrow"
                        marker.XData = marker.XData - 1;
                    case "rightarrow"
                        marker.XData = marker.XData + 1;
                    otherwise
                        return
                end
                data = img.CData;
                p(1) = marker.XData;
                p(2) = marker.YData;
                l1.YData = data(p(2),:);
                l2.XData = data(:,p(1));
                tex.String = {['X = ',num2str(p(2))],['Y = ',num2str(p(1))],['Data = ',num2str(data(p(2),p(1)))]};
            end
            
            %% Define the return function.
            function odData = returnValue(run)
                odData = absorp2OD(obj.ShowImage(run),absorpMin);
            end
            
        end
        
        function varargout = ShowRoi(obj,runNumber)
            %% Read parameters from properties.
            roiSize = obj.RoiSize;
            roiPos = obj.RoiPosition;
            nRuns = obj.NRuns;
            nRoi = obj.NRoi;
            roiSize2 = obj.RoiSize2;
            roiPos2 = obj.RoiPosition2;
            roiPosTemp = obj.TempRoiPosition;
            roiSizeTemp = obj.TempRoiSize;
            odAxis = obj.OdAxis;
            
            %% Return data
            if nargin == 2
                varargout{1} = returnValue(runNumber);
                return
            end
            
            %% Initialize the figure.
            fig = renderFigure(1,[1024,1024],'center');
            tit = sgtitle('ROI preview, Run 1');
            roiData0 = returnValue(1);
            
            if nRoi == 3
                ax = renderSubplot(3,1);
                img = gobjects(1,3);
                for iSpin = 1:3
                    img(iSpin) = imagesc(ax(iSpin),roiData0(:,:,iSpin));
                    renderImage(img(iSpin),odAxis,parula,0);
                end
            else
                ax = gca;
                img = imagesc(ax,roiData0(:,:));
                renderImage(img,odAxis,parula,0)
            end
                
            %% Create GUIs
            [slider,editbox] = createUis(fig,nRuns,'run');
            slider.Callback = @(es,ed) setHandles(img,tit,slider,editbox,es.Value);
            editbox.Callback = @(es,ed) setHandles(img,tit,slider,editbox,es.String);
            
            %% Define the callback function.
            function setHandles(img,tit,slider,box,n)
                if class(n) == "char"
                    n = str2double(n);
                    if n>nRuns || n<1 || isnan(n)
                        return
                    end
                end
                n = round(n);
                roiData = returnValue(n);
                for ii = 1:nRoi
                    img(ii).CData = roiData(:,:,ii);
                end
                tit.String = ['ROI Preview, Run ',num2str(n)];
                box.String = num2str(n);
                slider.Value = n;
            end
            
            %% Define the return function.
            function roiData = returnValue(run)
                if ~isempty(roiPosTemp)
                    roiPos = roiPosTemp;
                    if ~isempty(roiSizeTemp)
                        roiSize = roiSizeTemp;
                    end
                elseif ~isempty(roiPos2)
                    roiPos = roiPos2(run,:);
                    roiSize = roiSize2;
                end
                data = obj.ShowOD(run);
                roiData = selectRoi(data,roiSize,roiPos);
            end
            
        end
        
        function varargout = ShowAD(obj,runNumber)
            %% Read parameters from properties.
            roiSize = obj.RoiSize;
            roiPos = obj.RoiPosition;
            nRoi = numel(roiPos)-1;
            nRuns = obj.NRuns;
            pix = obj.PixelSize;
            y = (1:roiSize(2))*pix;
            
            %% Return data
            if nargin == 2
                roiData = obj.ShowRoi(runNumber);
                axialData = squeeze(sum(roiData,1));
                varargout{1} = axialData;
                return
            end
            
            %% Initialize the figure.
            fig = renderFigure(1,[1024,1024],'center');
            tit = sgtitle('Axial Distribution, Run 1');
            roiData0 = obj.ShowRoi(1);
            axialData0 = squeeze(sum(roiData0,1));
            
            ax = renderSubplot(3,1);
            cl = gobjects(1,3);
            for iSpin = 1:3
                cl(iSpin) = plot(ax(iSpin),y,axialData0(:,iSpin));
                renderPlot(cl(iSpin),'$y$ position ($\mu\mathrm{m}$)','Optical Depth')
            end
            setYLimit(ax,300,0);
            
            [slider,editbox] = createUis(fig,nRuns,'run');
            
            %% Define the callback function.
            slider.Callback = @(es,ed) setHandles(cl,tit,es.Value);
            editbox.Callback = @(es,ed) setHandles(cl,tit,es.String);
            function setHandles(h,t,n)
                if class(n) == "char"
                    n = str2double(n);
                    if n>nRuns || n<1 || isnan(n)
                        return
                    end
                end
                n = round(n);
                roiData = obj.ShowRoi(n);
                axialData = squeeze(sum(roiData,1));
                for ii = 1:3
                    h(ii).YData = axialData(:,ii);
                end
                t.String = ['ROI Preview, Run ',num2str(n)];
            end
            
        end
        
    end
    
end

