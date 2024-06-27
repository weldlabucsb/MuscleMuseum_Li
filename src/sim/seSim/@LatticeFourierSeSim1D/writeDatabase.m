function writeDatabase(obj)
sData = struct(obj);
sData = rmfield(sData,{'SimRun'});
tData = struct2table(sData,AsArray=true);
pgWrite(obj.Writer,obj.DatabaseTableName,tData);
end
