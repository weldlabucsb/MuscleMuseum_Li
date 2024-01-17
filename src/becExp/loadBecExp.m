function obj = loadBecExp(serialNumber)
%LOADBECEX Summary of this function goes here
%   Detailed explanation goes here
load("Config.mat","BecExpConfig");
databaseName = BecExpConfig.DatabaseName(1);
databaseTableName = BecExpConfig.DatabaseTableName(1);
conn = createReader(databaseName);
obj = loadTrial(conn,databaseTableName,serialNumber);
end

