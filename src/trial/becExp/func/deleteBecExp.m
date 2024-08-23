function deleteBecExp(serialNumber,isForceDelete)
%LOADBECEX Summary of this function goes here
%   Detailed explanation goes here
arguments
    serialNumber
    isForceDelete = false
end
load("Config.mat","BecExpConfig");
databaseName = BecExpConfig.DatabaseName(1);
databaseTableName = BecExpConfig.DatabaseTableName(1);
conn = createWriter(databaseName);
deleteTrial(conn,databaseTableName,serialNumber,isForceDelete);
end

