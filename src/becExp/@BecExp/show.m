function show(obj)
%SHOW Summary of this function goes here
%   Detailed explanation goes here
for ii = 1:numel(obj.AnalysisMethod)
    obj.(obj.AnalysisMethod(ii)).show;
end
end

