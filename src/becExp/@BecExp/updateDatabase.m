function updateDatabase(obj)
obj.displayLog("Updating the database entry.")
sData = struct(obj);
tData = struct2table(sData,AsArray=true);
tDataCicero = struct2table(obj.CiceroData,AsArray=true);
tDataHardware = struct2table(obj.HardwareData,AsArray=true);
rf = rowfilter('SerialNumber');
rf = rf.SerialNumber == obj.SerialNumber;
pgUpdate(obj.Writer,obj.DatabaseTableName,tData,rf);
if ~isempty(tDataCicero)
    pgUpdate(obj.Writer,obj.DatabaseTableName,tDataCicero,rf,isForceArray = true);
end
if ~isempty(tDataHardware)
    pgUpdate(obj.Writer,obj.DatabaseTableName,tDataHardware,rf,isForceArray = true);
end
end