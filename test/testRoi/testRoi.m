clear
data = imread("C:\Program Files\MATLAB\R2023a\toolbox\images\imdata\moon.tif");
[w,h] = size(data);
pos = [200,350,200,350 ];
ang = 20;
roi = Roi(position = pos,angle=ang,imageSize=[w,h]);
data1 = roi.select(data);
figure(1)
imagesc(data1)

[ROIload,ROITrim]=findImgROI(ang,pos,w,h);

data2=double(imread("C:\Program Files\MATLAB\R2023a\toolbox\images\imdata\moon.tif",...
    'PixelRegion',{[ROIload(1),ROIload(2)],[ROIload(3),ROIload(4)]}));
data2 = imrotate(data2,ang);
ROITrim=floor(ROITrim);
data2=data2(ROITrim(1):ROITrim(2),ROITrim(3):ROITrim(4));
figure(2)
imagesc(data2)