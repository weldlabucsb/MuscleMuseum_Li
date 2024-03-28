function writeDatabase(obj)
sData = struct(obj);
sData = rmfield(sData,{'SimRun'});
sData.SpaceOrigin = sData.SpaceOrigin.';
sData.SpaceStep = sData.SpaceStep.';
sData.SpaceRange = sData.SpaceRange.';
tData = struct2table(sData,AsArray=true);
pgWrite(obj.Writer,obj.DatabaseTableName,tData);
end
