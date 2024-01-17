function data = findTodayData(conn,databaseTableName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data = findTimeRangeData(conn,databaseTableName,datetime("today"),datetime("today"));
end

