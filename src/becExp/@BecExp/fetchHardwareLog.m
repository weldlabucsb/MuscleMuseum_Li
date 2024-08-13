function fetchHardwareLog(obj,runIdx)
obj.displayLog("Reading scope data for run #" + num2str(runIdx) + ".")
hwApp = get(findall(0, 'Tag', "HwControlPanel"), 'RunningAppInstance');
if ~isempty(hwApp)
    if isvalid(hwApp)
        hwApp.readScope;
    end
end
obj.displayLog("Fetching the hardware log files for run #" + num2str(runIdx) + ".")
existedLogNum = obj.ExistedHardwareLogNumber; % Number of old log files.
hardwareList = obj.HardwareList;
dataPrefix = obj.DataPrefix;

% Scan the origin folder to find if a new log file is created.
newLogNum = arrayfun(@countFileNumberJava,hardwareList.DataPath) - existedLogNum;
if any(newLogNum>1)
    warning('>1 hardware log files found.')
end
hardwareList(newLogNum ~= 1,:) = [];
if isempty(hardwareList)
    obj.displayLog("No hardware data found.")
    return
end

% Get the newest log file.
newLogPath = arrayfun(@findLatestFile,hardwareList.DataPath,UniformOutput=false);

% Try moving the log file to the data path.
for ii = 1:numel(newLogPath)
    if ~isempty(newLogPath{ii})
        obj.displayLog("Fetching " + hardwareList.Name(ii))
        [~,~,ext] = fileparts(newLogPath{ii});
        movefile(newLogPath{ii},...
            fullfile(obj.HardwareLogPath,dataPrefix + "_" + num2str(runIdx)) + "_" + hardwareList.Name(ii) + ext,'f');
    end
end

end
