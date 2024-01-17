imaqreset;
vid = videoinput("gentl", 1,'Mono8');
info = imaqhwinfo(vid);
% width_res = info.MaxWidth;
% height_res = info.MaxHeight;
% v.ROIPosition = [width_res/2 height_res/2 1280 1280];
src = getselectedsource(vid);
% src.AutoTargetBrightness = 0.5019608;
% src.ExposureTime = 1000;
% src.LineSelector = "Line3";
% src.LineMode = "Output";
% img = getsnapshot(v);
triggerconfig(vid, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
src.TriggerSelector = 'FrameStart';
src.TriggerSource = 'Line1';
src.TriggerActivation = 'RisingEdge';
src.TriggerMode = 'on';
src.ExposureMode = 'Timed';
src.ExposureTime = 35;
% set(vid,'Timeout',20); 
fileName = 'test\testCamera\run';
vid.FramesAcquiredFcnCount = 1;
vid.FramesAcquiredFcn = {@saveImageData, fileName};

vid.TriggerRepeat = 2;
vid.FramesPerTrigger = 1;
start(vid)
wait(vid, 20)
% img = getdata(vid,3);
        
imaqreset;
