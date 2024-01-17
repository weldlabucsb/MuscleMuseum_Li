function pause(obj)
%PAUSE Summary of this function goes here
%   Detailed explanation goes here
obj.displayLog("Pausing data acquisition and real-time analysis.")
if obj.IsAutoAcquire
    obj.Acquisition.pauseCamera;
else
    obj.Watcher.Enabled = false;
end
obj.Analyzer.Enabled = false;
end

