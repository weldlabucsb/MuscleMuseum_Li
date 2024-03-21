function fastStop(obj)
obj.displayLog(" ")
obj.displayLog("Trial #" + string(obj.SerialNumber) + ": Stopping data acquisition and real-time analysis. Will not force refresh.")

if obj.IsAutoAcquire
    obj.Acquisition.stopCamera;
else
    obj.Watcher.Enabled = false;
end
obj.Analyzer.Enabled = false;

if obj.NCompletedRun == 0
    obj.displayLog("No run has been acquired. Deleting this trial.")
    for ii = 1:numel(obj.AnalysisMethod)
        obj.(obj.AnalysisMethod(ii)).close;
    end
    deleteBecExp(obj.SerialNumber,true)
    obj.delete
    return
end

obj.displayLog("Saving the figures.")
for ii = 1:numel(obj.AnalysisMethod)
    obj.(obj.AnalysisMethod(ii)).finalize;
    obj.(obj.AnalysisMethod(ii)).save;
    obj.(obj.AnalysisMethod(ii)).close;
end

obj.update;

end