function resume(obj)
%RESUME Summary of this function goes here
%   Detailed explanation goes here
obj.displayLog("Resuming data acquisition and real-time analysis.")

obj.ExistedCiceroLogNumber = countFileNumber(obj.CiceroLogOrigin,".clg");

if obj.IsAutoAcquire
    obj.Acquisition.startCamera;
else
    obj.Watcher.Enabled = true;
end
obj.Analyzer.Enabled = true;
end

