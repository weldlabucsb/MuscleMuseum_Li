% function testFileWatcher

clear
close all
%% Setup sample data
testPath = findFunctionPath();
samplePath = fullfile(testPath,"sampleData");
sampleLogPath = fullfile(testPath,"sampleData","logfiles");
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

watchPath = pwd;
obj = tt();
% obj.wtch = System.IO.FileSystemWatcher(watchPath);
% fileObj.Filter = "*"+".tif";
% obj.wtch.EnableRaisingEvents = true;
% fileObj = b.createWatcher;
obj.createWatcher
obj.createLister


% addlistener(obj.Watcher,'Created', @(src,event) onChanged(src,event,obj));


%% Copy files to mimic data acquisition

for iRun = 1:2
    pause(1)
    copyfile(fullfile(samplePath,sampleDataName((iRun-1)*3+1)+'.tif'),fullfile(pwd,sampleDataName((iRun-1)*3+1)+'.tif'))
    pause(0.1)
    copyfile(fullfile(samplePath,sampleDataName((iRun-1)*3+2)+'.tif'),fullfile(pwd,sampleDataName((iRun-1)*3+2)+'.tif'))
    pause(0.1)
    copyfile(fullfile(samplePath,sampleDataName((iRun-1)*3+3)+'.tif'),fullfile(pwd,sampleDataName((iRun-1)*3+3)+'.tif'))
    % copyfile(fullfile(sampleLogPath,sampleLogList(iRun)),fullfile(b.CiceroLogOrigin,sampleLogList(iRun)))
end


% function onChanged(~,~,objj)
% % disp(source)
% % disp('found new file')
% % disp(source.Path)
% % disp(source.NotifyFilter)
% % disp(arg.FullPath.ToString())
% % objj.ii = objj.ii +1;
% % if objj.ii==3
%     % disp('yes')
%     notify(objj,'test')
%     % objj.ii = 0;
% % end
% end

