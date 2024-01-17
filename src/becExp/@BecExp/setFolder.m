function setFolder(obj)
%SETFOLDER This method creates data storage folders and sets up data
%analysis paths.
%   The data are stored in the folder:
%   [ParentPath]\year\year.month\month.day\[datafolder]
%   [datafolder] is named as "idx1 - Name_idx2" where idx1 indicates
%   it is the idx1-th data taken this day, and idx2 indicates it is the
%   idx2-th data taken this day with the same Name.

%% Look at the watch
t = obj.DateTime;
mm = num2str(t.Month,'%02u');
dd = num2str(t.Day,'%02u');
yyyy = num2str(t.Year);

%% Delimiters
dateDelimiter = '.'; %These delimiters are arbitrary.
indexDelimiter = '-';
trialDelimiter = '_';

%% Create date folder
obj.DatePath = string(fullfile(obj.ParentPath,yyyy,[yyyy,dateDelimiter,mm], ...
    [mm,dateDelimiter,dd]));
createFolder(obj.DatePath); %Create the Date folder if it doesn't exist.

%% Find trial index
todaystr = string(datetime("today",Format='yyyy-MM-dd'));
if obj.IsAutoDelete == true %Delete trials with no data collected 
    query = "SELECT ""SerialNumber"" FROM " + obj.DatabaseTableName + " WHERE ""DateTime"" >= '" + todaystr + "'" + " AND " +...
        """DateTime"" <= '" + todaystr + " 23:59:59" + "'" + " AND ""NCompletedRun"" = 0;";
    emptyData = pgFetch(obj.Writer,query);
    deleteTrial(obj.Writer,obj.DatabaseTableName,emptyData.SerialNumber,true) %Delete folders with no data.
end

query = "SELECT ""SerialNumber"" FROM " + obj.DatabaseTableName + " WHERE ""Name"" = '" + obj.Name + "'" + " AND " +...
    """DateTime"" >= '" + todaystr + "'" + " AND " +...
    """DateTime"" <= '" + todaystr + " 23:59:59" + "';";
todayData = pgFetch(obj.Writer,query);
obj.TrialIndex = size(todayData,1) + 1;

%% Find data folder index
newestFolderList = sortNewestFolder(obj.DatePath);
newestFolderList = newestFolderList(cellfun(@(x) contains(x,indexDelimiter),{newestFolderList.name}));
if isempty(newestFolderList)
    folderIndex = 1;
else
    str = split(newestFolderList(1).name,indexDelimiter);
    folderIndex = str2double(regexp(str{1},'\d*','match'));
    folderIndex = folderIndex(1) + 1;
end

%% Create data folders
obj.DataPath = fullfile(obj.DatePath,num2str(folderIndex,'%02u')+" "+indexDelimiter+" "+ ...
    obj.Name+trialDelimiter+num2str(obj.TrialIndex));
obj.DataAnalysisPath = fullfile(obj.DataPath,'dataAnalysis');
obj.ObjectPath = fullfile(obj.DataAnalysisPath, ...
    obj.Name+yyyy+mm+dd+trialDelimiter+num2str(obj.TrialIndex)+'.mat');
obj.CiceroLogPath = fullfile(obj.DataPath,'logFiles');

createFolder(obj.DataPath);
createFolder(obj.DataAnalysisPath);
createFolder(obj.CiceroLogPath);

end

