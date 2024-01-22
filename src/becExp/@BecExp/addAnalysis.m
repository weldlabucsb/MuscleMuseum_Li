function addAnalysis(obj,newAnalysisList)
%ADDANALYSIS Summary of this function goes here
%   Detailed explanation goes here
if ~isstring(newAnalysisList)
    error('Input must be a string.')
end
if ~all(ismember(newAnalysisList,vertcat(obj.AnalysisOrder{:})))
    warning('Input are not all listed in AnalysisOrder.')
end
newAnalysisList = rmmissing(newAnalysisList);
if isempty(newAnalysisList)
    return
end

for ii = 1:numel(newAnalysisList)
    if ~isprop(obj,newAnalysisList(ii))
        addprop(obj,newAnalysisList(ii));
        obj.(newAnalysisList(ii)) = eval(newAnalysisList(ii) + "(obj)");
    end
end

obj.AnalysisMethod = [obj.AnalysisMethod(:);newAnalysisList(:)];
obj.sortAnalysis;
end

