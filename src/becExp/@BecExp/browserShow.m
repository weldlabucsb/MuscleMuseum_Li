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
    obj.(obj.AnalysisMethod(ii)).show(true,monitorIndex);
end
end

