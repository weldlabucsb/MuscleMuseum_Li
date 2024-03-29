function updateDatabase(obj)
sData = struct(obj);
tData = struct2table(sData,AsArray=true);
rf = rowfilter('SerialNumber');
rf = rf.SerialNumber == obj.SerialNumber;
pgUpdate(obj.Writer,obj.DatabaseTableName,tData,rf);
end