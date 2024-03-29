function obj = loadMeSim(serialNumber)
%LOADBECEX Summary of this function goes here
%   Detailed explanation goes here
load("Config.mat","MeSimConfig");
databaseName = MeSimConfig.DatabaseName(1);
databaseTableName = MeSimConfig.DatabaseTableName(1);
conn = createReader(databaseName);
obj = loadTrial(conn,databaseTableName,serialNumber);
end

