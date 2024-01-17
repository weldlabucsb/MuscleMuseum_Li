function t = updateTable(t,prop,value)
%UPDATETABLE Summary of this function goes here
%   Detailed explanation goes here
arguments
    t table
    prop string
    value
end
propList = string(t.Properties.VariableNames);
if ismember(prop,propList)
    t.(prop) = value;
end
end

