function deleteRun(obj,runIdx)
%DELETERUN Summary of this function goes here
%   Detailed explanation goes here
if isempty(runIdx)
    return
elseif obj.IsAcquiring
    obj.displayLog("Still saving images. Can not delete now.")
    return
end
obj.displayLog("Deleting Run " + join("#"+string(runIdx),", ") + ".")
runIdx = round(runIdx);
NComp = obj.NCompletedRun;
dataPath = obj.DataPath;
dataFormat = obj.DataFormat;
dataPrefix = obj.DataPrefix;
ciceroLogPath = obj.CiceroLogPath;
hardwareLogPath = obj.HardwareLogPath;

%% Validate input run numbers
if any(runIdx<1)
    error("Run number has to be greater than zero.")
end

if any(runIdx>NComp)
    warning("Input run numbers are greater than the number of completed runs. Will try to delete residual files.")
    obj.DeletedRunParameterList = [obj.DeletedRunParameterList,obj.ScannedParameterList(runIdx(runIdx<=NComp))];
    obj.NCompletedRun = NComp - sum(runIdx<=NComp);
else
    try
    obj.DeletedRunParameterList = [obj.DeletedRunParameterList,obj.ScannedParameterList(runIdx(runIdx<=NComp))];
    catch
    end
    obj.NCompletedRun = NComp - numel(runIdx);
end

if obj.NCompletedRun > 0
    obj.NRun = obj.NCompletedRun;
else
    obj.NRun = 1;
end

%% Delete image files
fList = dir(fullfile(dataPath,"*"+dataFormat));
imageList = string({fList.name});
if ~isempty(imageList)
    imageNumberList = arrayfun(@(x) str2double(regexp(x,'\d*','match')),imageList);
    deleteList = imageList(ismember(imageNumberList,runIdx));
    for ii = 1:numel(deleteList)
        deleteFile(fullfile(dataPath,deleteList(ii)))
    end
end

%% Rename the rest of the image files
fList = dir(fullfile(dataPath,"*"+dataFormat));
oldImageList = string({fList.name});
if ~isempty(oldImageList)
    oldImageNumbers = zeros(1,numel(oldImageList));
    for ii = 1:numel(oldImageList)
        str = split(oldImageList(ii),"_");
        oldImageNumbers(ii) = str2double(regexp(str(2),'\d*','match'));
    end
    [oldImageNumbers,idx] = sort(oldImageNumbers);
    oldImageList = oldImageList(idx);
    newImageNumbers = cumsum([1,logical(diff(oldImageNumbers))]);
    for ii = 1:numel(oldImageList)
        str = split(oldImageList(ii),"_");
        str(2) = newImageNumbers(ii);
        newImageName = strjoin(str,"_");
        if oldImageList(ii) ~= newImageName
            try
                movefile(fullfile(dataPath,oldImageList(ii)),fullfile(dataPath,newImageName),'f')
            catch me
                warning(me.message)
            end
        end
    end
end

%% Delete CiceroData
if ~isempty(obj.CiceroData)
    if numel(obj.CiceroData.IterationNum) ~= NComp
        warning("CiceroData size is different from the completed run number. Will try to read Cicero log files.")
        obj.CiceroData = obj.readCiceroLog(1:NComp);
    end
    if numel(obj.CiceroData.IterationNum) ~= NComp
        warning("CiceroData size is different from the completed run number. Will not delete corresponding data in CiceroData.")
    else
        deleteIdx = runIdx(runIdx<=NComp);
        sData = obj.CiceroData;
        mData = cell2mat(struct2cell(sData));
        mData(:,deleteIdx) = [];
        obj.CiceroData = cell2struct(num2cell(mData,2),fieldnames(obj.CiceroData));
        obj.CiceroLogTime(deleteIdx) = [];
    end
end

%% Delete Cicero files
fList = dir(fullfile(ciceroLogPath,"*.clg"));
cLogList = string({fList.name});
if ~isempty(cLogList)
    cLogNumberList = arrayfun(@(x) str2double(regexp(x,'\d*','match')),cLogList);
    deleteList = cLogList(ismember(cLogNumberList,runIdx));
    for ii = 1:numel(deleteList)
        deleteFile(fullfile(ciceroLogPath,deleteList(ii)))
    end
end

%% Rename the rest of the Cicero files
fList = dir(fullfile(ciceroLogPath,"*.clg"));
oldCLogList = string({fList.name});
if ~isempty(oldCLogList)
    oldCLogNumbers = zeros(1,numel(oldCLogList));
    for ii = 1:numel(oldCLogList)
        str = split(oldCLogList(ii),"_");
        oldCLogNumbers(ii) = str2double(regexp(str(2),'\d*','match'));
    end
    [oldCLogNumbers,idx] = sort(oldCLogNumbers);
    oldCLogList = oldCLogList(idx);
    newCLogNumbers = cumsum([1,logical(diff(oldCLogNumbers))]);
    for ii = 1:numel(oldCLogList)
        str = split(oldCLogList(ii),"_");
        str(2) = newCLogNumbers(ii);
        newCLogName = strjoin(str,"_") + ".clg";
        if oldCLogList(ii) ~= newCLogName
            movefile(fullfile(ciceroLogPath,oldCLogList(ii)),fullfile(ciceroLogPath,newCLogName),'f')
        end
    end
end

%% Delete HardwareData
if ~isempty(obj.HardwareData)
    sData = obj.HardwareData;
    mData = cell2mat(struct2cell(sData));
    if size(mData,2) ~= NComp
        warning("HardwareData size is different from the completed run number. Will not delete corresponding data in HardwareData.")
    else
        deleteIdx = runIdx(runIdx<=NComp);
        mData(:,deleteIdx) = [];
        obj.HardwareData = cell2struct(num2cell(mData,2),fieldnames(obj.HardwareData));
    end
end

%% Delete hardware log files
fList = dir(fullfile(hardwareLogPath));
fList = fList(~[fList.isdir]);
hLogList = string({fList.name});
if ~isempty(hLogList)
    hLogNumberList = arrayfun(@(x) str2double(regexp(x,'\d*','match')),hLogList);
    deleteList = hLogList(ismember(hLogNumberList,runIdx));
    for ii = 1:numel(deleteList)
        deleteFile(fullfile(hardwareLogPath,deleteList(ii)))
    end
end

%% Rename the rest of the hardware log files
fList = dir(fullfile(hardwareLogPath));
fList = fList(~[fList.isdir]);
oldHLogList = string({fList.name});
if ~isempty(oldHLogList)
    oldHLogNumbers = zeros(1,numel(oldHLogList));
    for ii = 1:numel(oldHLogList)
        str = split(oldHLogList(ii),"_");
        oldHLogNumbers(ii) = str2double(regexp(str(2),'\d*','match'));
    end
    [oldHLogNumbers,idx] = sort(oldHLogNumbers);
    oldHLogList = oldHLogList(idx);
    newHLogNumbers = cumsum([1,logical(diff(oldHLogNumbers))]);
    for ii = 1:numel(oldHLogList)
        str = split(oldHLogList(ii),"_");
        str(2) = newHLogNumbers(ii);
        newHLogName = strjoin(str,"_");
        if oldHLogList(ii) ~= newHLogName
            try
                movefile(fullfile(hardwareLogPath,oldHLogList(ii)),fullfile(hardwareLogPath,newHLogName),'f')
            catch me
                warning(me.message)
            end
        end
    end
end

%% Reset existed log file number
obj.countExistedLog

%% Refresh
obj.refresh;

end

