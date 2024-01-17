clear
close all
%% Setup sample data
testPath = findFunctionPath();
samplePath = fullfile(testPath,"testData","sampleData");
sampleLogPath = fullfile(testPath,"testData","sampleData","logfiles");
nRun = countFileNumber(samplePath)/3;

sampleDataList = dir(samplePath);
sampleDataList = sampleDataList(~[sampleDataList.isdir]);
sampleDataList = struct2cell(sampleDataList);
[~,sampleDataName,~] = fileparts(sampleDataList(1,:));
[~,idx] = sort(str2double(string((regexp(sampleDataName,'[^\_]*$','match')))));
sampleDataName = string(sampleDataName(idx));

sampleLogList = string(ls(sampleLogPath));
sampleLogList = sampleLogList(3:end);
sampleLogList = sort(sampleLogList);

createFolder(fullfile(testPath,"testData","testLogFiles"));
createFolder(fullfile(testPath,"testData","becExp"));

%% Start experiment
setTestConfig;
b = BecExp("EvapDTof",isLocalTest=true);
deleteFolder(b.CiceroLogOrigin);
mkdir(b.CiceroLogOrigin);
b.start;

%% Copy files to mimic data acquisition

for iRun = 1:3
    pause(0.3)
    copyfile(fullfile(samplePath,sampleDataName((iRun-1)*3+1)+'.tif'),fullfile(b.DataPath,sampleDataName((iRun-1)*3+1)+'.tif'))
    pause(0.1)
    copyfile(fullfile(samplePath,sampleDataName((iRun-1)*3+2)+'.tif'),fullfile(b.DataPath,sampleDataName((iRun-1)*3+2)+'.tif'))
    pause(0.1)
    copyfile(fullfile(samplePath,sampleDataName((iRun-1)*3+3)+'.tif'),fullfile(b.DataPath,sampleDataName((iRun-1)*3+3)+'.tif'))
    copyfile(fullfile(sampleLogPath,sampleLogList(iRun)),fullfile(b.CiceroLogOrigin,sampleLogList(iRun)))
end
pause(0.5)
b.stop;