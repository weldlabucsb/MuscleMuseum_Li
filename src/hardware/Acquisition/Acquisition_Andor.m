classdef Acquisition_Andor < Acquisition 
 
    %Acquisition_Andor Acquisition class.
    %   Child Class of the Acquisition class to allow for connection to
    %   Andor.
    %   Requires modification of code since there is a proprietary SDK for
    %   Andor in contrast to the other cameras that can be accessed through
    %   the VideoInput class.

    
    methods
        
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
                ret=AndorInitialize('');
                CheckError(ret);
            catch ME
                msg = ['Camera connection failed. Check if the camera is connected. To connect to Andor cameras,', ...
                     ' you may need to restart MATLAB. Error message from MATLAB:',newline,...
                    ME.message];
                error(msg)
            end
            % obj.VideoInput = vid; %No videoinput object compatible with
            % it.
        end

        function setCameraParameter(obj)
            %Set camera parameters using the predefined configuration
            %functions.
            % if isempty(obj.VideoInput)
            %     error('Camera not connected. Try the "connectCamera" method first.')
            % end
            configFun = obj.ConfigFun;
            configFun(obj);
        end

        function setCallback(obj,callbackFunc) %%% Do not use for Acquisition_Andor, we shall for now disable AutoAcquire until this is figured out.
            %Set camera callback function.
            % if isempty(obj.VideoInput)
            %     error('Camera not connected. Try the "connectCamera" method first.')
            % end
            % vid = obj.VideoInput;
            % vid.FramesAcquiredFcn = callbackFunc;
        end

        function startCamera(obj)
            %Start camera recording
            % if isempty(obj.VideoInput)
            %     error('Camera not connected. Try the "connectCamera" method first.')
            % end
           [ret] = StartAcquisition();                   
            CheckWarning(ret);
        end

        function pauseCamera(obj)
            %Pause camera recording
            % vid = obj.VideoInput;
            % stop(vid);
            
            [ret] = AbortAcquisition();                   
            CheckWarning(ret);
        end

        function stopCamera(obj)
            %Stop camera recording
            % vid = obj.VideoInput;
            % stop(vid);
            % delete(vid);
            % clear vid;
            [ret] = AbortAcquisition();                   
            CheckWarning(ret);
            [ret] = AndorShutDown();
            CheckWarning(ret);
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

        

    end
    methods (Access = private, Hidden)
        setConfigProperty(obj,struct)
    end
end

