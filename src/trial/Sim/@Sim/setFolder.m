function setFolder(obj)
%SETFOLDER This method creates data storage folders and sets up data
%analysis paths.
%   The data are stored in the folder:
%   [ParentPath]\Name\datafolder
%   [datafolder] is named as "yyyymmdd_idx1" where idx1 indicates
%   it is the idx1-th data taken this day

%% Look at the watch
t = obj.DateTime;
mm = string(num2str(t.Month,'%02u'));
dd = string(num2str(t.Day,'%02u'));
yyyy = string(num2str(t.Year));

%% Delimiters
trialDelimiter = '_';

%% Create trial folder
obj.TrialPath = string(fullfile(obj.ParentPath,obj.Name));
createFolder(obj.TrialPath); %Create the Date folder if it doesn't exist.

%% Find trial index
if obj.IsAutoDelete == true %Delete trials with no data collected 
    query = "SELECT ""SerialNumber"" FROM " + obj.DatabaseTableName + " WHERE ""NCompletedRun"" = 0;";
    emptyData = pgFetch(obj.Writer,query);
    deleteTrial(obj.Writer,obj.DatabaseTableName,emptyData.SerialNumber,true) %Delete folders with no data.
end

query = "SELECT ""SerialNumber"" FROM " + obj.DatabaseTableName + " WHERE ""Name"" = '" + obj.Name + "'";
todayData = pgFetch(obj.Writer,query);
obj.TrialIndex = size(todayData,1) + 1;

%% Create data folders
obj.DataPath = fullfile(obj.TrialPath,...
    yyyy+mm+dd+trialDelimiter+num2str(obj.TrialIndex));
obj.DataAnalysisPath = fullfile(obj.DataPath,'dataAnalysis');
obj.ObjectPath = fullfile(obj.DataAnalysisPath, ...
    obj.Name+yyyy+mm+dd+trialDelimiter+num2str(obj.TrialIndex)+'.mat');

createFolder(obj.DataPath);
createFolder(obj.DataAnalysisPath);

end

