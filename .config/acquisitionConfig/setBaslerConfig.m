function setBaslerConfig(acq)
%SETBASLERCONFIG set Basler camera configuration
%   Input must be an "Acquisition" object. The following setup is for
%   regular BEC experiment data taking.
arguments
    acq Acquisition
end

vid = acq.VideoInput;
vid.FramesPerTrigger = 1; %Set frames per trigger
vid.FramesAcquiredFcnCount = acq.ImageGroupSize;
vid.LoggingMode = 'memory'; %Set logging to memory
src = getselectedsource(vid); %Create adaptor source
src.TMTimestampMode = 'Binary'; %Set timestamp mode
src.ShutterMode = 'GlobalResetRelease';
if acq.IsExternalTriggered == true
    if obj.IsExternalTriggered == true
        triggerconfig(vid, 'hardware', 'DeviceSpecific', 'DeviceSpecific'); %Configure trigger type and mode
        vid.TriggerRepeat = inf;
        src.TriggerSelector = 'FrameStart';
        src.TriggerSource = 'Line1';
        src.TriggerActivation = 'RisingEdge';
        src.TriggerMode = 'on';
        src.ExposureMode = 'Timed';
    end
end

end

