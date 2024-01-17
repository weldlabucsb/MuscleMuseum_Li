classdef Acquisition < handle & matlab.mixin.SetGetExactNames
    %Acquisition Acquisition class.
    %   Detailed explanation goes here

    properties (SetAccess = private)
        Name string %Nickname/label of the acquisition
        CameraType string %Producer of the camera
        AdaptorName string %MATLAB camera adaptor
        DeviceID int32 %To distinguish devices if multiple devices are connected through the same adaptor
        SerialNumber int32 %Camera serial number
        PixelSize double %In microns
        ImageSize uint32 % size x * size y
        BadRow uint32 % rows that have bad pixels
        BadColumn uint32 % columns that have bad pixels
        Magnification double
        VideoInput %MATLAB camera connection
        ConfigFun function_handle %Configure the camera parameters. Must be pre-defined.
        QuantumEfficiencyData double = [] %Quantum efficiency data from the company. First column: wavelength. Second column: quantum efficiency.
    end

    properties (Constant, Hidden)
        BadWidth = 1
    end

    properties
        ExposureTime double %In micro-seconds
        IsExternalTriggered logical
        ImageGroupSize int32 %Specify the number of frames that must be acquired before we save the images
        ImagePath {mustBeFolder} = "." %Where to save the generated images
        ImagePrefix string = "run" %How to name the images
        ImageFormat string = "tif" %Image format
    end

    properties (Dependent)
        PixelSizeReal
    end

    methods
        function obj = Acquisition(acqName)
            %Acquisition Construct an instance of the Acquisition class
            %   Acquisition handles mainly the camera parameters and the
            %   data acquisition process. Given "cameraName", the 
            %   constructor load the configuration and set the acquisition
            %   parameters properly.
            load("Config.mat","AcquisitionConfig")
            setConfigProperty(obj,table2struct(AcquisitionConfig(AcquisitionConfig.Name==acqName,:)))
        end

        function qe = QuantumEfficiency(obj,lambda)
            qeData = obj.QuantumEfficiencyData;
            if isempty(qeData)
                qe = 1;
            elseif lambda < min(qeData(:,1)) || lambda > max(qeData(:,1))
                qe = 0;
            else
                qe = interp1(qeData(:,1),qeData(:,2),lambda,'linear');
            end
        end

        function connectCamera(obj)
            %Connect to the camera. Return the VideoInput object.
            try
                vid = videoinput(obj.AdaptorName,obj.DeviceID);
            catch ME
                msg = ['Camera connection failed. Check if the camera is connected. To connect to Basler cameras,', ...
                     ' you may need to restart MATLAB. Error message from MATLAB:',newline,...
                    ME.message];
                error(msg)
            end
            obj.VideoInput = vid;
        end

        function setCameraParameter(obj)
            %Set camera parameters using the predefined configuration
            %functions.
            if isempty(obj.VideoInput)
                error('Camera not connected. Try the "connectCamera" method first.')
            end
            configFun = obj.ConfigFun;
            configFun(obj);
        end

        function setCallback(obj,callbackFunc)
            %Set camera callback function.
            if isempty(obj.VideoInput)
                error('Camera not connected. Try the "connectCamera" method first.')
            end
            vid = obj.VideoInput;
            vid.FramesAcquiredFcn = callbackFunc;
        end

        function startCamera(obj)
            %Start camera recording
            if isempty(obj.VideoInput)
                error('Camera not connected. Try the "connectCamera" method first.')
            end
            vid = obj.VideoInput;
            start(vid);
        end

        function pauseCamera(obj)
            %Pause camera recording
            vid = obj.VideoInput;
            stop(vid);
        end

        function stopCamera(obj)
            %Stop camera recording
            vid = obj.VideoInput;
            stop(vid);
            delete(vid);
            clear vid;
        end

        function imageDataKilled = killBadPixel(obj,imageData)
            if ~all(size(imageData,1,2) == obj.ImageSize)
                error("Image data size is wrong.")
            end
            imageDataKilled = imageData;
            nDim = ndims(imageData);
            C=repmat({':'},1,nDim-2);
            bW = obj.BadWidth;
            if ~isempty(obj.BadRow)
                bR = obj.BadRow;
                for ii = 1:numel(bR)
                    replace = (imageDataKilled(bR(ii)-bW-1,:,C{:})+imageDataKilled(bR(ii)+bW+1,:,C{:}))/2;
                    imageDataKilled(bR(ii)-bW:bR(ii)+bW,:,C{:}) = repmat(replace,2*bW + 1,1);
                    % slope = (imageDataKilled(bR(ii)+bW+1,:,C{:}) - imageDataKilled(bR(ii)-bW-1,:,C{:}))/(2*bW+2);
                    % for jj = 1:(2*bW+1)
                    %     imageDataKilled(jj + bR(ii)-bW-1,:,C{:}) = imageDataKilled(bR(ii)-bW-1,:,C{:}) + slope * jj;
                    % end
                end
            end
            if ~isempty(obj.BadColumn)
                for ii = 1:numel(obj.BadColumn)
                    replace = (imageDataKilled(:,obj.BadColumn(ii)-obj.BadWidth-1,C{:})+imageDataKilled(:,obj.BadColumn(ii)+obj.BadWidth+1,C{:}))/2;
                    imageDataKilled(:,obj.BadColumn(ii)-obj.BadWidth : obj.BadColumn(ii)+obj.BadWidth,C{:}) = repmat(replace,1,2*obj.BadWidth + 1);
                end
            end
        end

        function px = get.PixelSizeReal(obj)
            px = obj.PixelSize / obj.Magnification;
        end

    end
    methods (Access = private, Hidden)
        setConfigProperty(obj,struct)
    end
end

