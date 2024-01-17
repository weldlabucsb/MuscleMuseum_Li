function runLocalTest(testCiceroLogOrigin,samplePath,dataPath,pauseTime)
%RUNLOCALTEST Summary of this function goes here
%   Detailed explanation goes here
sampleLogPath = fullfile(samplePath,"logfiles");
sampleLogPath2 = fullfile(samplePath,"logFiles");

sampleDataList = dir(samplePath);
sampleDataList = sampleDataList(~[sampleDataList.isdir]);
sampleDataList = struct2cell(sampleDataList);
[~,sampleDataName,~] = fileparts(sampleDataList(1,:));
[~,idx] = sort(str2double(string((regexp(sampleDataName,'[^\_]*$','match')))));
sampleDataName = string(sampleDataName(idx));

sampleLogList = string(ls(sampleLogPath));
sampleLogList = sampleLogList(3:end);
sampleLogList = sort(sampleLogList);

sampleLogList2 = string(ls(sampleLogPath2));
sampleLogList2 = sampleLogList2(3:end);
sampleLogList2 = sort(sampleLogList2);



for iRun = 1:numel(sampleLogList)
    pause(pauseTime)
    copyfile(fullfile(samplePath,sampleDataName((iRun-1)*3+1)+'.tif'),fullfile(dataPath,sampleDataName((iRun-1)*3+1)+'.tif'))
    pause(0.1)
    copyfile(fullfile(samplePath,sampleDataName((iRun-1)*3+2)+'.tif'),fullfile(dataPath,sampleDataName((iRun-1)*3+2)+'.tif'))
    pause(0.1)
    copyfile(fullfile(samplePath,sampleDataName((iRun-1)*3+3)+'.tif'),fullfile(dataPath,sampleDataName((iRun-1)*3+3)+'.tif'))
    try
        copyfile(fullfile(sampleLogPath,sampleLogList(iRun)),fullfile(testCiceroLogOrigin,sampleLogList(iRun)))
    catch
        copyfile(fullfile(sampleLogPath2,sampleLogList2(iRun)),fullfile(testCiceroLogOrigin,sampleLogList2(iRun)))
    end
end
end

