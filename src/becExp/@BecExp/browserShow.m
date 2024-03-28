function browserShow(obj)
%SHOW Summary of this function goes here
%   Detailed explanation goes here
mp = sortMonitor;
monitorIndex = 1;
if size(mp,1) > 1
    appHandle = get(findall(0, 'Tag', obj.ControlAppName), 'RunningAppInstance');
    if ~isempty(appHandle)
        if isvalid(appHandle)
            monitorIndex = 2;
        end
    end
end
for ii = 1:numel(obj.AnalysisMethod)
    for jj = 1:numel(obj.(obj.AnalysisMethod(ii)).Gui)
        obj.(obj.AnalysisMethod(ii)).Gui(jj).Monitor = monitorIndex;
    end
    for jj = 1:numel(obj.(obj.AnalysisMethod(ii)).Chart)
        obj.(obj.AnalysisMethod(ii)).Chart(jj).IsBrowser = true;
        obj.(obj.AnalysisMethod(ii)).Chart(jj).Monitor = monitorIndex;
    end
    obj.(obj.AnalysisMethod(ii)).show;
end
end

