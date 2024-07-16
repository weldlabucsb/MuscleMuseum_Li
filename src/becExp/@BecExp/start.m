function start(obj)
obj.displayLog(" ")
obj.displayLog("Trial #" + string(obj.SerialNumber) + ": Starting data acquisition and real-time analysis.")
obj.countExistedLog

if obj.IsAutoAcquire
    obj.Acquisition.connectCamera;
    obj.Acquisition.setCameraParameter;
    obj.Acquisition.setCallback(@(src,evt) saveBecImage(src,evt,obj));
    obj.Acquisition.startCamera;
else
    obj.createWatcher;
    obj.Watcher.Enabled = true;
end

obj.Analyzer.Enabled = true;
analysisMethod = obj.AnalysisMethod;

obj.displayLog("Initializing the figures.")
for ii = 1:numel(analysisMethod)
    obj.(analysisMethod(ii)).initialize;
end

end
