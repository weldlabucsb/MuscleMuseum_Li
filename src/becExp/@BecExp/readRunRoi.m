function roiData = readRunRoi(obj,runIdx)
%READRUNROI Summary of this function goes here
%   Detailed explanation goes here
runIdx = string(runIdx(:));
nRun = numel(runIdx);
runPath = fullfile(obj.DataPath,obj.DataPrefix) + "_" + runIdx ...
    + ["_atom","_light","_dark"] + obj.DataFormat;
acq = obj.Acquisition;
roi = obj.Roi;
roiSize = roi.CenterSize(3:4);
roiData = zeros([roiSize,nRun,3]);
p = gcp('nocreate');
if isempty(p)
    for ii = 1:nRun
        for jj = 1:3
            roiData(:,:,ii,jj) = roi.select(acq.killBadPixel(double(imread(runPath(ii,jj)))));
        end
    end
else
    parfevalOnAll(@warning,0,'off','all');
    parfor ii = 1:nRun
        for jj = 1:3
            roiData(:,:,ii,jj) = roi.select(acq.killBadPixel(double(imread(runPath(ii,jj)))));
        end
    end
    parfevalOnAll(@warning,0,'on','all');
end
end

