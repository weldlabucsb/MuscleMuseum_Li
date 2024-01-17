function mData = readRun(obj,runIdx)
runIdx = string(runIdx(:));
runPath = fullfile(obj.DataPath,obj.DataPrefix) + "_" + runIdx ...
    + ["_atom","_light","_dark"] + obj.DataFormat;
mData = zeros([obj.Acquisition.ImageSize,numel(runIdx),3]);
for ii = 1:numel(runIdx)
    for jj = 1:3
        mData(:,:,ii,jj) = imread(runPath(ii,jj));
    end
end
mData = double(mData);
mData = obj.Acquisition.killBadPixel(mData);
end
