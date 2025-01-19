function obj = setObjFromTable(obj,t)
%SETOBJFROMTABLE Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj
    t 
end
if isa(t,'table')
    if size(t,1) ~= 1
        error("table can only have one row.")
    else
        t = table2struct(t);
    end
elseif isa(t,'struct')
    if numel(t) ~= 1
        error("t can only have one element.")
    end
else
    error("t must be either a struct or a table.")
end
propList = getPublicProperty(class(obj));
fieldList = string(fieldnames(t));
propList = intersect(propList,fieldList);
for ii = 1:numel(propList)
    obj.(propList(ii)) = t.(propList(ii));
end
end

