function data = findTimeRangeData(conn,databaseTableName,startTime,endTime)
%findTimeRangeData Fetch data from database that were taken between startTime and
%endTime. The data in the database must have the DateTime row that
%specifies the time when the data was taken. startTime and endTime must be
%MATLAB datetime objects.

rf = rowfilter("DateTime");

% If only date not time is specified, assume the last day is covered in the
% search.
if timeofday(startTime) == duration() && timeofday(endTime) == duration()
    endTime.Hour = 23;
    endTime.Minute = 59;
    endTime.Second = 59;
end
rf = rf.DateTime>=startTime & rf.DateTime<=endTime;
data = pgRead(conn,databaseTableName,Rowfilter=rf);
end

