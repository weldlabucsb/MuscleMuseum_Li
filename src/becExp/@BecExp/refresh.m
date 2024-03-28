function refresh(obj,anaylsisName)
%REFRESH Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj BecExp
    anaylsisName string = string.empty
end
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
    if isempty(anaylsisName)
        for ii = 1:nAnalysis
            obj.(obj.AnalysisMethod(ii)).refresh;
        end
    elseif ~isscalar(anaylsisName)
        error("Input must be a string scalar.")
    elseif ~ismember(anaylsisName,vertcat(obj.AnalysisOrder{:}))
        warning(anaylsisName + " is not in AnalysisOrder. Will refresh all.")
        for ii = 1:nAnalysis
            obj.(obj.AnalysisMethod(ii)).refresh;
        end
    else
        % First refresh [anaylsisName]
        if ismember(anaylsisName,obj.AnalysisMethod)
            obj.(anaylsisName).refresh
        end

        % Then refresh everthing after [anaylsisName]
        orderIdx = find(cellfun(@(x) any(anaylsisName==x),obj.AnalysisOrder));
        afterAnalysis = obj.AnalysisOrder(orderIdx+1:end);
        afterAnalysis = vertcat(afterAnalysis{:});
        if ~isempty(afterAnalysis)
            aMethodIdx = find(ismember(obj.AnalysisMethod,afterAnalysis),1);
            if ~isempty(aMethodIdx)
                for ii = aMethodIdx:nAnalysis
                    obj.(obj.AnalysisMethod(ii)).refresh;
                end
            else
                % Refresh everthing that are not in AanalysisOrder
                extraAnalysis = obj.AnalysisMethod(~ismember(obj.AnalysisMethod,vertcat(obj.AnalysisOrder{:})));
                for ii = 1:numel(extraAnalysis)
                    obj.(extraAnalysis(ii)).refresh;
                end
            end
        end
    end

end

