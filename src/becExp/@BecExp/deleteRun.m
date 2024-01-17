function deleteRun(obj,runIdx)
%DELETERUN Summary of this function goes here
%   Detailed explanation goes here
if isempty(runIdx)
    return
end
obj.displayLog("Deleting Run " + join("#"+string(runIdx),", ") + ".")
runIdx = round(runIdx);
NComp = obj.NCompletedRun;
dataPath = obj.DataPath;
dataFormat = obj.DataFormat;
dataPrefix = obj.DataPrefix;
ciceroLogPath = obj.CiceroLogPath;

%% Validate input run numbers
if any(runIdx<1)
    error("Run number has to be greater than zero.")
end

if any(runIdx>NComp)
    warning("Input run numbers are greater than the number of completed runs. Will try to delete residual files.")
    obj.DeletedRunParameterList = [obj.DeletedRunParameterList,obj.ScannedParameterList(runIdx(runIdx<=NComp))];
    obj.NCompletedRun = NComp - sum(runIdx<=NComp);
else
    obj.DeletedRunParameterList = [obj.DeletedRunParameterList,obj.ScannedParameterList(runIdx(runIdx<=NComp))];
    obj.NCompletedRun = NComp - numel(runIdx);
end

%% Delete image files
fList = dir(fullfile(dataPath,"*"+dataFormat));
imageList = string({fList.name});
if ~isempty(imageList)
    for ii = 1:numel(runIdx)
        prefix = dataPrefix + "_" + string(runIdx(ii));
        deleteIdx = arrayfun(@(x) contains(x,prefix),imageList);
        deleteList = imageList(deleteIdx);
        for jj = 1:numel(deleteList)
            deleteFile(fullfile(dataPath,deleteList(jj)))
        end
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
            movefile(fullfile(dataPath,oldImageList(ii)),fullfile(dataPath,newImageName),'f')
        end
    end
end

%% Delete CiceroData
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

%% Delete Cicero files
fList = dir(fullfile(ciceroLogPath,"*.clg"));
cLogList = string({fList.name});
if ~isempty(cLogList)
    for ii = 1:numel(runIdx)
        prefix = dataPrefix + "_" + string(runIdx(ii));
        deleteIdx = arrayfun(@(x) contains(x,prefix),cLogList);
        deleteList = cLogList(deleteIdx);
        for jj = 1:numel(deleteList)
            deleteFile(fullfile(ciceroLogPath,deleteList(jj)))
        end
    end
end

%% Rename the rest of the image files
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
        newCLogName = strjoin(str,"_");
        if oldCLogList(ii) ~= newCLogName
            movefile(fullfile(ciceroLogPath,oldCLogList(ii)),fullfile(ciceroLogPath,newCLogName),'f')
        end
    end
end

end

