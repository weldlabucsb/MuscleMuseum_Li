classdef Roi < handle
    %ROI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name string
        ImageSize (1,2) double
        ImageSizeRotated (1,2) double %Image size after rotation. By default we use the "loose" bounding box option of the imrotate function
        YXBoundary (1,4) double = [1,1024,1,1024] %[Y1,Y2,X1,X2]
        Angle (1,1) double = 0 % In degrees
        CenterSize (1,4) double = [512.5,512.5,1024,1024] %[centerY,centerX,sizeY,sizeX]
        SubRoiCenterSize double % N * 4 array or 1 * 4 array. In the full image basis.
        SubRoiNRowColumn (1,2) double = [1,1]
        SubRoiSeparation (1,2) double = [100,100] 
    end

    properties (Dependent)
        XList
        YList
        CornerList
        NSub
    end

    properties (SetAccess = protected)
        IsSubRoi logical = false
        SubRoi Roi
    end
    
    methods
        function obj = Roi(roiName,options)
            %ROI Construct an instance of the Roi class
            %   Detailed explanation goes here
            arguments
                roiName string = []
                options.yxBoundary uint32 = []
                options.angle double = []
                options.centerSize double = []
                options.imageSize uint32 = []
                options.subRoiCenterSize double = []
                options.subRoiNRowColumn double = [1,1]
                options.subRoiSeparation double = [100,100]
                options.isSubRoi logical = false
            end
            
            warning off
            obj.IsSubRoi = options.isSubRoi;
            
            if ~isempty(roiName)
                % If ROI name is specified, load ROI from Config, unless
                % the name is "Full". For "Full" ROI one has to specify the
                % image size explicitly.
                obj.Name = roiName;  
                if roiName ~= "Full"
                    load("Config.mat","RoiConfig")
                    configParameter = RoiConfig(RoiConfig.Name == roiName,:);
                    obj.ImageSize = [configParameter.ImageSizeY,configParameter.ImageSizeX];
                    obj.Angle = configParameter.Angle;
                    obj.YXBoundary = [configParameter.Y1,configParameter.Y2,...
                        configParameter.X1,configParameter.X2];

                    % set sub-ROI
                    obj.SubRoiNRowColumn = configParameter.SubRoiNRowColumn;
                    obj.SubRoiSeparation = configParameter.SubRoiSeparation;
                    obj.SubRoiCenterSize = configParameter.SubRoiCenterSize{1};
                else
                    if isempty(options.imageSize)
                        error("For full size ROI, imageSize has to be set.")
                    else
                        obj.ImageSize = options.imageSize;
                    end
                    if ~isempty(options.angle)
                        obj.Angle = options.angle;
                    else
                        obj.Angle = 0; %Angle is zero by default
                    end
                    obj.YXBoundary = [1,obj.ImageSizeRotated(1),1,obj.ImageSizeRotated(2)];

                    % set sub-ROI
                    obj.SubRoiNRowColumn = options.subRoiNRowColumn;
                    obj.SubRoiSeparation = options.subRoiSeparation;
                    obj.SubRoiCenterSize = options.subRoiCenterSize;
                end
            else
                % If ROI name is not specified, set ROI properties
                % according to the input.
                if ~isempty(options.imageSize)
                    obj.ImageSize = options.imageSize;
                end

                if ~isempty(options.angle)
                    obj.Angle = options.angle;
                else
                    obj.Angle = 0; % Angle is zero by default.
                end

                if ~isempty(options.yxBoundary)
                    % YXBoundary input is preferably used than CenterSize
                    obj.YXBoundary = options.yxBoundary; 
                elseif ~isempty(options.centerSize)
                    obj.CenterSize = options.centerSize;
                end

                % set sub-ROI
                obj.SubRoiNRowColumn = options.subRoiNRowColumn;
                obj.SubRoiSeparation = options.subRoiSeparation;
                obj.SubRoiCenterSize = options.subRoiCenterSize;
            end
            warning on
        end

        function set.YXBoundary(obj,val)
            if numel(val) == 4 && sum(abs(val - obj.YXBoundary))>eps
                val = round(val(:).');
                if any(val<1)
                    % Check if the YXBoundary is larger than 0.
                    warning("ROI yxBoundary input value should be larger than 0.")
                    val(val<1) = 1;
                end
                if ~isempty(obj.ImageSizeRotated)
                    % Check if the YXBoundary is smaller than the image size (after rotation).
                    y = val(1:2);
                    if any(y>obj.ImageSizeRotated(1))
                        warning("ROI yxBoundary input value should be smaller than or equal to the image size.")
                        y(y>obj.ImageSizeRotated(1)) = obj.ImageSizeRotated(1);
                    end
                    x = val(3:4);
                    if any(x(x>obj.ImageSizeRotated(2)))
                        warning("ROI yxBoundary input value should be smaller than or equal to the image size.")
                        x(x>obj.ImageSizeRotated(2)) = obj.ImageSizeRotated(2);
                    end
                    val = [y,x];
                end
                if val(1) < val(2) && val(3) < val(4)
                    % If YXBoundary values are meaningful, overwrite the
                    % YXBoundary and the CenterSize settings. Otherwise the
                    % input is ignored.
                    obj.YXBoundary = val;
                    obj.CenterSize = [mean(obj.YXBoundary(1:2)),...
                        mean(obj.YXBoundary(3:4)),...
                        diff(obj.YXBoundary(1:2))+1,...
                        diff(obj.YXBoundary(3:4))+1];
                    obj.setSub;
                else
                    warning("ROI yxBoundary input should yield Y1 < Y2 and X1 < X2.")
                end
            end
        end

        function set.CenterSize(obj,val)
            if numel(val) == 4 && sum(abs(val - obj.CenterSize)) > eps
                center = round(val(1:2));
                a = val(3);
                b = val(4);
                if all([center,a,b]>=1)

                    % Tailor the ROI size according to the image size
                    % (after rotation)
                    if ~isempty(obj.ImageSizeRotated) &&...
                            (center(1) > obj.ImageSizeRotated(1) || center(2) > obj.ImageSizeRotated(2) ||...
                            a > obj.ImageSizeRotated(1) || b > obj.ImageSizeRotated(2))
                        warning("ROI center/size input should be smaller than image size.")
                        return
                    end
                    if center(1) - floor(a/2) < 1
                        warning("ROI size out of bound. Tailored to yield imge size.")
                        a = center(1)*2-1;
                    end
                    if ~isempty(obj.ImageSizeRotated) && center(1)+ceil(a/2)-1 > obj.ImageSizeRotated(1)
                        warning("ROI size out of bound. Tailored to yield imge size.")
                        a = min((obj.ImageSizeRotated(1) - center(1))*2 + 1,a);
                    end
                    if center(2) - floor(b/2) < 1
                        warning("ROI size out of bound. Tailored to yield imge size.")
                        b = center(2)*2-1;
                    end
                    if ~isempty(obj.ImageSizeRotated) && center(2)+ceil(b/2)-1 > obj.ImageSizeRotated(2)
                        warning("ROI size out of bound. Tailored to yield imge size.")
                        b = min((obj.ImageSizeRotated(2) - center(2))*2 + 1,b);
                    end
                    
                    % Calculate YXBoundary from CenterSize
                    fa = floor(a/2);
                    ca = ceil(a/2)-1;
                    fb = floor(b/2);
                    cb = ceil(b/2)-1;
                    yxBoundary = [center(1)-fa,center(1)+ca,...
                    center(2)-fb,center(2)+cb];

                    obj.CenterSize = [mean(yxBoundary(1:2)),...
                        mean(yxBoundary(3:4)),...
                        diff(yxBoundary(1:2))+1,...
                        diff(yxBoundary(3:4))+1];
                    obj.YXBoundary = yxBoundary;
                    obj.setSub;
                else
                    warning("ROI center/size input should be larger than 0.")
                end
            end
        end

        function set.Angle(obj,val)
            if obj.IsSubRoi
                obj.Angle = 0;
                obj.ImageSizeRotated = obj.ImageSize;
                return
            end
            if numel(val) == 1
                val = mod(val,360);
                obj.Angle = val;
                if ~isempty(obj.ImageSize)
                    % Set image size after rotation.
                    if obj.Angle == 0
                        obj.ImageSizeRotated = obj.ImageSize;
                    else
                        emptyImg = zeros(obj.ImageSize);
                        emptyImgR = imrotate(emptyImg,obj.Angle);
                        obj.ImageSizeRotated = size(emptyImgR);
                    end
                    yxb = obj.YXBoundary; % check if the boundaries are still within the ROI
                    if yxb(2) > obj.ImageSizeRotated(1)
                        warning("Y boundary too large after rotation. Tailored to yield the image size (after rotation).")
                        yxb(2) = obj.ImageSizeRotated(1);
                    end
                    if yxb(4) > obj.ImageSizeRotated(2)
                        warning("X boundary too large after rotation. Tailored to yield the image size (after rotation).")
                        yxb(4) = obj.ImageSizeRotated(2);
                    end
                    obj.YXBoundary = yxb;
                    obj.setSub;
                else
                    obj.ImageSizeRotated = [];
                end
            end
        end
        
        function set.SubRoiCenterSize(obj,val)
            obj.SubRoiCenterSize = val;
            obj.setSub;
        end

        function set.SubRoiNRowColumn(obj,val)
            obj.SubRoiNRowColumn = val;
            obj.setSub;
        end

        function set.SubRoiSeparation(obj,val)
            obj.SubRoiSeparation = val;
            obj.setSub;
        end

        function setSub(obj)
            obj.SubRoi = Roi.empty;
            if isempty(obj.SubRoiCenterSize)
                return
            end
            nSubCenterSize = size(obj.SubRoiCenterSize,1);
            if nSubCenterSize >= 2
                for ii = 1:nSubCenterSize
                    subCenter = obj.SubRoiCenterSize(ii,1:2);
                    subCenterInRoiCoord = obj.noRotationFull2Roi(subCenter);
                    subSize = obj.SubRoiCenterSize(ii,3:4);
                    subCenterSize = [subCenterInRoiCoord,subSize];
                    obj.SubRoi(ii) = Roi(centerSize=subCenterSize,...
                            imageSize=obj.CenterSize(3:4),...
                            isSubRoi=true);
                    isFit(ii) = all(abs(obj.SubRoi(ii).CenterSize(3:4) - obj.SubRoiCenterSize(ii,3:4))<=1);
                end
                obj.SubRoi(~isFit) = [];
            else
                subCenter = obj.SubRoiCenterSize(1,1:2);
                subCenterInRoiCoord = obj.noRotationFull2Roi(subCenter);
                subSize = obj.SubRoiCenterSize(1,3:4);

                subRoiSep = obj.SubRoiSeparation;
                nRow = round(obj.SubRoiNRowColumn(1));
                centerRow = nRow/2 + 1/2;
                nColumn = round(obj.SubRoiNRowColumn(2));
                centerColumn = nColumn/2 + 1/2;
                for ii = 1:nRow
                    for jj = 1:nColumn
                        subCenter = subCenterInRoiCoord;
                        subCenter(1) = subCenter(1) + (ii-centerRow) * subRoiSep(1);
                        subCenter(2) = subCenter(2) + (jj-centerColumn) * subRoiSep(2);
                        subCenterSize = [subCenter,subSize];
                        obj.SubRoi(ii,jj) = Roi(centerSize=subCenterSize,...
                            imageSize=obj.CenterSize(3:4),...
                            isSubRoi=true);
                        isFit(ii,jj) = all(abs(obj.SubRoi(ii,jj).CenterSize(3:4) - obj.SubRoiCenterSize(1,3:4))<=1);
                    end
                end
                obj.SubRoi(~isFit) = [];
            end

        end
        
        function roiData = select(obj,mData)
            mDataSize = size(mData,1,2);
            if ~isempty(obj.ImageSize)
                if any(mDataSize ~= obj.ImageSize)
                    error("Input data size does not match the ROI ImageSize.")
                end
            end

            pos = obj.YXBoundary;
            nDim = ndims(mData);
            if ~obj.Angle == 0
                mData = imrotate(mData,obj.Angle,'bilinear','loose');
            end
            C=repmat({':'},1,nDim-2);
            roiData = mData(pos(1):pos(2),pos(3):pos(4),C{:});
        end

        function subRoiData = selectSub(obj,mData)
            mDataSize = size(mData,1,2);
            if all(mDataSize == obj.CenterSize(3:4))
                mainRoiData = mData;
            else
                mainRoiData = obj.select(mData);
            end
            nSub = numel(obj.SubRoi);
            if nSub == 0
                subRoiData = {mainRoiData};
            else
                subRoiData = cell(nSub,1);
                for ii = 1:nSub
                    subRoiData{ii} = obj.SubRoi(ii).select(mainRoiData);
                end
            end
        end
        
        function grid(obj,nRow,nColumn)
            roiSize = obj.CenterSize(3:4);
            if roiSize(1) < 3 * nRow || roiSize(2) < 3 * nColumn
                error("ROI size is to small to be grided.")
            end
            rowSize = round((roiSize(1) - 2 * nRow) / nRow) + 2;
            columnSize = round((roiSize(2) - 2 * nColumn) / nColumn) + 2;
            y1 = 1:rowSize:(1 + rowSize * (nRow-1));
            y2 = rowSize:rowSize:(rowSize * nRow);
            x1 = 1:columnSize:(1 + columnSize * (nColumn-1));
            x2 = columnSize:columnSize:(columnSize * nColumn);
            y2(end) = roiSize(1);
            x2(end) = roiSize(2);

            subRoi = Roi.empty;
            for ii = 1:nRow
                for jj = 1:nColumn
                    subRoi(ii,jj) = Roi(yxBoundary=[y1(ii),y2(ii),x1(jj),x2(jj)]);
                end
            end
            obj.SubRoi = subRoi;
        end
        
        function roiCoord = full2Roi(obj,fullCoord)
            yxBoundary = obj.YXBoundary;
            roiSize = obj.CenterSize(3:4);
            roiUpperLeft = [yxBoundary(1),yxBoundary(3)];
            roiUpperLeft = reshape(roiUpperLeft,size(fullCoord));
            roiCoord = fullCoord - roiUpperLeft + 1;
            roiCoord(roiCoord<1) = 1;
            if roiCoord(1) > roiSize(1)
                roiCoord(1) = roiSize(1);
            end
            if roiCoord(2) > roiSize(2)
                roiCoord(2) = roiSize(2);
            end
        end

        function fullCoord = roi2Full(obj,roiCoord)
            yxBoundary = obj.YXBoundary;
            roiUpperLeft = [yxBoundary(1),yxBoundary(3)];
            roiUpperLeft = reshape(roiUpperLeft,size(roiCoord));
            fullCoord = roiCoord + roiUpperLeft - 1;
        end

        function roiCoord = noRotationFull2Roi(obj,noRotFullCoord)
            imageCenter = (1 + obj.ImageSizeRotated)/2;
            imageCenterNoRotation = (1 + obj.ImageSize)/2;
            fullCoordRelative = noRotFullCoord - imageCenterNoRotation;
            rotationMatrix = [cosd(obj.Angle),-sind(obj.Angle);...
                sind(obj.Angle),cosd(obj.Angle)];
            fullCoordRotated = rotationMatrix * fullCoordRelative(:);
            fullCoordRotated = imageCenter + fullCoordRotated.';
            roiCoord = round(obj.full2Roi(fullCoordRotated));
        end

        function noRotFullCoord = roi2NoRotationFull(obj,roiCoord)
            noRotFullCoord = obj.roi2Full(roiCoord);
            imageCenter = (1 + obj.ImageSizeRotated)/2;
            imageCenterNoRotation = (1 + obj.ImageSize)/2;
            rotationMatrix = [cosd(obj.Angle),-sind(obj.Angle);...
                sind(obj.Angle),cosd(obj.Angle)];
            fullCoordRelative = noRotFullCoord - imageCenter;
            fullCoordRelativeNoRotation = rotationMatrix.' * fullCoordRelative(:);
            noRotFullCoord = round(fullCoordRelativeNoRotation.' + imageCenterNoRotation);
        end

        function fullCoord = noRotationFull2Full(obj,noRotFullCoord)
            fullCoord = obj.roi2Full(obj.noRotationFull2Roi(noRotFullCoord));
        end

        function noRotFullCoord = full2NoRotationFull(obj,fullCoord)
            noRotFullCoord = obj.roi2NoRotationFull(obj.full2Roi(fullCoord));
        end

        function mask = createMask(obj,maskPoints)
            roiSize = obj.CenterSize(3:4);
            roiMaskPoints = zeros(size(maskPoints));
            for ii = 1:size(maskPoints,1)
                roiMaskPoints(ii,:) = obj.noRotationFull2Roi(maskPoints(ii,:));
            end
            mask = ~poly2mask(roiMaskPoints(:,2),roiMaskPoints(:,1),roiSize(1),roiSize(2));
        end

        function logi = isInRoi(obj,fullCoord)
            yxBoundary = obj.YXBoundary;
            logi = fullCoord(1) >= yxBoundary(1) && fullCoord(1) <= yxBoundary(2) &&...
                fullCoord(2) >= yxBoundary(3) && fullCoord(2) <= yxBoundary(4);
        end

        function logi = isNoRotationFullInRoi(obj,noRotFullCoord)
            imageCenterNoRotation = (1 + obj.ImageSize)/2;
            imageCenter = (1 + obj.ImageSizeRotated)/2;
            fullCoordRelative = noRotFullCoord - imageCenterNoRotation;
            rotationMatrix = [cosd(obj.Angle),-sind(obj.Angle);...
                sind(obj.Angle),cosd(obj.Angle)];
            fullCoordRotated = rotationMatrix * fullCoordRelative(:);
            fullCoordRotated = fullCoordRotated.' + imageCenter;
            logi = obj.isInRoi(fullCoordRotated);
        end

        function rotate(obj,rotateAngle)
            if obj.IsSubRoi
                warning("Can not rotate sub-ROI.")
                return
            end
            % Rotate the ROI about the ROI center
            imageCenter = (1 + obj.ImageSizeRotated)/2;
            roiCenter = obj.CenterSize(1:2);
            roiCenterRelative = roiCenter - imageCenter;
            rotationMatrix = [cosd(rotateAngle),-sind(rotateAngle);...
                sind(rotateAngle),cosd(rotateAngle)];
            roiCenterRelativeAfterRotation = ...
                rotationMatrix * roiCenterRelative(:);

            emptyImg = zeros(obj.ImageSize);
            emptyImgR = imrotate(emptyImg,rotateAngle + obj.Angle);

            imageCenterAfterRotation = (1 + size(emptyImgR))/2;
            roiCenterAfterRotation = ...
               roiCenterRelativeAfterRotation.' + imageCenterAfterRotation;

            oldYXB = obj.YXBoundary;
            oldYXBRelative = ...
                [oldYXB(1) - roiCenter(1),...
                oldYXB(2) - roiCenter(1),...
                oldYXB(3) - roiCenter(2),...
                oldYXB(4) - roiCenter(2)];
            newYXB = ...
                [oldYXBRelative(1) + roiCenterAfterRotation(1),...
                oldYXBRelative(2) + roiCenterAfterRotation(1),...
                oldYXBRelative(3) + roiCenterAfterRotation(2),...
                oldYXBRelative(4) + roiCenterAfterRotation(2)];
            obj.Angle = obj.Angle + rotateAngle;
            obj.YXBoundary = newYXB;
            obj.setSub;
        end
    
        function xList = get.XList(obj)
            xList = (obj.YXBoundary(3):obj.YXBoundary(4)).';
        end

        function yList = get.YList(obj)
            yList = (obj.YXBoundary(1):obj.YXBoundary(2)).';
        end
    
        function cList = get.CornerList(obj)
            yxBound = obj.YXBoundary;
            cList = [yxBound(1),yxBound(3);yxBound(2),yxBound(3);...
                yxBound(2),yxBound(4);yxBound(1),yxBound(4)];
        end

        function val = get.NSub(obj)
            val = numel(obj.SubRoi);
        end

        function s = saveobj(obj)
            s = struct();
            s.Name = obj.Name;
            s.ImageSize = obj.ImageSize;
            s.ImageSizeRotated = obj.ImageSizeRotated;
            s.YXBoundary = obj.YXBoundary;
            s.Angle = obj.Angle;
            s.SubRoiCenterSize = obj.SubRoiCenterSize;
            s.SubRoiNRowColumn = obj.SubRoiNRowColumn;
            s.SubRoiSeparation = obj.SubRoiSeparation;
            s.IsSubRoi = obj.IsSubRoi;
        end
    end
    
    methods (Static)
        function obj = loadobj(s)
            if isstruct(s)
                newObj = Roi(...
                yxBoundary = s.YXBoundary,...
                angle = s.Angle,...
                imageSize = s.ImageSize,...
                isSubRoi = s.IsSubRoi,...
                subRoiCenterSize = s.SubRoiCenterSize,...
                subRoiNRowColumn = s.SubRoiNRowColumn,...
                subRoiSeparation = s.SubRoiSeparation...
                );
                newObj.Name = s.Name;
                obj = newObj;
            else
                obj = s;
            end
        end
    end
end

