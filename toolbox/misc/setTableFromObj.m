function t = setTableFromObj(obj,t)
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
    isTable = true;
elseif isa(t,'struct')
    if numel(t) ~= 1
        error("t can only have one element.")
    end
    isTable = false;
else
    error("t must be either a struct or a table.")
end
propList = getPublicProperty(class(obj));
fieldList = string(fieldnames(t));
propList = intersect(propList,fieldList);
for ii = 1:numel(propList)
    t.(propList(ii)) = obj.(propList(ii));
end
if isTable
    t = struct2table(t);
end

end

