function stop(obj)
obj.displayLog(" ")
obj.displayLog("Trial #" + string(obj.SerialNumber) + ": Stopping data acquisition and real-time analysis.")

if obj.NCompletedRun == 0
obj.displayLog("No run has been acquired. Deleting this trial.")
deleteBecExp(obj.SerialNumber,true)
obj.delete
return
end

if obj.IsAutoAcquire
    obj.Acquisition.stopCamera;
else
    obj.Watcher.Enabled = false;
end
obj.Analyzer.Enabled = false;
obj.update;

obj.displayLog("Saving the figures.")
for ii = 1:numel(obj.AnalysisMethod)
    obj.(obj.AnalysisMethod(ii)).finalize;
    obj.(obj.AnalysisMethod(ii)).save;
    obj.(obj.AnalysisMethod(ii)).close;
end
end