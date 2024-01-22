function removeAnalysis(obj,removeAnalysisList)
%REMOVEANALYSIS Summary of this function goes here
%   Detailed explanation goes here
if ~isstring(removeAnalysisList)
    error('Input must be a string.')
end
removeAnalysisList = rmmissing(removeAnalysisList);
if isempty(removeAnalysisList)
    return
end

removeAnalysisList = removeAnalysisList(ismember(removeAnalysisList,obj.AnalysisMethod));
for ii = 1:numel(removeAnalysisList)
    obj.(removeAnalysisList(ii)).close;
end

obj.AnalysisMethod(obj.AnalysisMethod == removeAnalysisList) = [];
obj.sortAnalysis;

end

