function obj = loadTrial(conn,databaseTableName,serialNumber)
%LOADTRIAL Summary of this function goes here
%   Detailed explanation goes here
if isempty(serialNumber)
    return
end
serialNumber = serialNumber(:).';
query = "SELECT ""ObjectPath"" FROM "+databaseTableName+" WHERE ""SerialNumber"" in ("+...
    regexprep(num2str(serialNumber),'\s+',',')+")";
data = pgFetch(conn,query);
warning off
obj = arrayfun(@(fName) loadVar(fName,"obj"),data.ObjectPath);
warning on
end

