function updateDatabase(obj)
obj.displayLog("Updating the database entry.")
sData = struct(obj);
tData = struct2table(sData,AsArray=true);
tDataCicero = struct2table(obj.CiceroData,AsArray=true);
rf = rowfilter('SerialNumber');
rf = rf.SerialNumber == obj.SerialNumber;
pgUpdate(obj.Writer,obj.DatabaseTableName,tData,rf);
if ~isempty(tDataCicero)
    pgUpdate(obj.Writer,obj.DatabaseTableName,tDataCicero,rf,isForceArray = true);
end
end