function refresh(obj)
%REFRESH Summary of this function goes here
%   Detailed explanation goes here
if obj.IsHoldRefresh
    obj.displayLog("Refresh is on hold.")
    return
end

nAnalysis = numel(obj.AnalysisMethod);
if obj.NCompletedRun < 1
    obj.displayLog("No run has been acquired. Initializing the figures instead.")
    for ii = 1:nAnalysis
        obj.(obj.AnalysisMethod(ii)).initialize;
    end
else
    obj.displayLog("Refreshing the figures.")
    for ii = 1:nAnalysis
        obj.(obj.AnalysisMethod(ii)).refresh;
    end
end

end

