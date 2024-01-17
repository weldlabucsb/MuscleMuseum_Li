function writeDatabase(obj)
sData = struct(obj);
tData = struct2table(sData,AsArray=true);
pgWrite(obj.Writer,obj.DatabaseTableName,tData);
end
