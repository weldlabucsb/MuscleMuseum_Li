function t = quoteTableColumn(t)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
nVariable = numel(t.Properties.VariableNames);
for ii = 1:nVariable
    t.Properties.VariableNames(ii) = {['"',t.Properties.VariableNames{ii},'"']};
end
end

