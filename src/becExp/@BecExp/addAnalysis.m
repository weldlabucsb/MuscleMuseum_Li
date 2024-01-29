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
        switch newAnalysisList(ii)
            case "Od"
                obj.Od.CLim = [0,obj.ConfigParameter.OdCLim];
                obj.Od.Colormap = obj.ConfigParameter.OdColormap;
                obj.Od.FringeRemovalMask = obj.ConfigParameter.FringeRemovalMask;
                obj.Od.FringeRemovalMethod = obj.ConfigParameter.FringeRemovalMethod;
            case "Imaging"
                obj.Imaging.ImagingStage = obj.ConfigParameter.ImagingStage;
            case "Ad"
                obj.Ad.AdMethod = obj.ConfigParameter.AdMethod;
                obj.Ad.CLim = [0,obj.ConfigParameter.AdCLim];
            case "DensityFit"
                obj.DensityFit.FitMethod = obj.ConfigParameter.DensityFitMethod;
            case "AtomNumber"
                obj.AtomNumber.YLim = [0,obj.ConfigParameter.AtomNumberYLim];
            case "CenterFit"
                obj.CenterFit.FitMethod = [0,obj.ConfigParameter.CenterFitMethod];
        end
    end

    obj.AnalysisMethod = [obj.AnalysisMethod(:);newAnalysisList(:)];
    obj.sortAnalysis;
end

