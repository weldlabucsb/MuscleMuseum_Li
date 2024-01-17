function roiData = selectRoi(data,roiSize,roiPosition)
a = roiSize(1);
b = roiSize(2);
fa = floor(a/2);
ca = ceil(a/2)-1;
fb = floor(b/2);
cb = ceil(b/2)-1;
nRoi = numel(roiPosition)-1;

xPos = roiPosition(1:nRoi);
yPos = roiPosition(end);

roiData = zeros(a,b,nRoi);
for iRoi = 1:nRoi
    roiData(:,:,iRoi) = data(xPos(iRoi)-fa:xPos(iRoi)+ca,yPos-fb:yPos+cb);
end
roiData = squeeze(roiData);
end

