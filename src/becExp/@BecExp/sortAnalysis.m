function analysisListSorted = sortAnalysis(obj)
%SORTANALYSIS Summary of this function goes here
%   We need to run different analysis in certain order so we have to sort
%   the analysis methods
analysisList = obj.AnalysisMethod;
analysisListSorted = rmmissing(unique(analysisList(:)));
analysisOrder = obj.AnalysisOrder;
analysisOrder = vertcat(analysisOrder{:});
extraAnalysis = analysisListSorted(~ismember(analysisListSorted,analysisOrder));
analysisListSorted = [analysisOrder(ismember(analysisOrder,analysisListSorted));...
    extraAnalysis];
obj.AnalysisMethod = analysisListSorted(:).';
end

