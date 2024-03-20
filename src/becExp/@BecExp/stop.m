function stop(obj)
obj.displayLog(" ")
obj.displayLog("Trial #" + string(obj.SerialNumber) + ": Stopping data acquisition and real-time analysis.")

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

if obj.Od.FringeRemovalMethod == "None" || isempty(obj.Od.FringeRemovalMask)
    obj.displayLog("Saving the figures.")
    for ii = 1:numel(obj.AnalysisMethod)
        obj.(obj.AnalysisMethod(ii)).finalize;
        obj.(obj.AnalysisMethod(ii)).save;
        obj.(obj.AnalysisMethod(ii)).close;
    end
else
    obj.displayLog("Refreshing and Saving the figures.")
    for ii = 1:numel(obj.AnalysisMethod)
        obj.(obj.AnalysisMethod(ii)).refresh;
        obj.(obj.AnalysisMethod(ii)).save;
        obj.(obj.AnalysisMethod(ii)).close;
    end
end

obj.update;

end