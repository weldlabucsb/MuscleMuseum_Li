function isFetched = fetchCiceroLog(obj,runIdx)
obj.displayLog("Fetching the Cicero log file for run #" + num2str(runIdx) + ".")
newLogNum = 0; % Number of new log files.
t = 0; % Total pause time.
tPause = 0.1; % Pause time.
existedLogNum = obj.ExistedCiceroLogNumber; % Number of old log files.
originPath = obj.CiceroLogOrigin;
dataPrefix = obj.DataPrefix;
isFetched = false; % Error flag

% Scan the origin folder to find if a new log file is created.
while newLogNum<1 && t<10
    pause(tPause)
    newLogNum = countFileNumberJava(originPath,".clg") - existedLogNum;
    if newLogNum>1
        obj.displayLog(">1 log files found")
        return
    end
    t = t + tPause;
end

if t>= 10
    obj.displayLog("Can not find a log file in 10 seconds")
    return
end

% Get the newest log file.
logList = string(ls(originPath));
logList = logList(3:end);
logList = sort(logList);
newLogPath = fullfile(originPath,logList(end));
obj.CiceroLogTime(runIdx) = datetime;

% Try moving the log file to the data path.
t = 0;
moveStatus = false;
tPause2 = 0.5;
while t<5 && ~moveStatus
    pause(tPause2)
    try
        moveStatus = movefile(newLogPath,...
            fullfile(obj.CiceroLogPath,dataPrefix + "_" + num2str(runIdx)+".clg"),'f');
    catch
    end
    t = t+tPause2;
end

if t >= 5
    obj.displayLog("Can not move the log file in 5 seconds")
    return
end

isFetched = true;

end
