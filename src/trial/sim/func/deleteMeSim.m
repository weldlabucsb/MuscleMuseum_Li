function deleteMeSim(serialNumber,isForceDelete)
%LOADBECEX Summary of this function goes here
%   Detailed explanation goes here
arguments
    serialNumber
    isForceDelete = false
end
load("Config.mat","MeSimConfig");
databaseName = MeSimConfig.DatabaseName(1);
databaseTableName = MeSimConfig.DatabaseTableName(1);
conn = createReader(databaseName);
deleteTrial(conn,databaseTableName,serialNumber,isForceDelete);
end

