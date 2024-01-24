% This is a function to set the configuration file
function setConfig
%% Find the repo path
configPath = findFunctionPath();
[repoPath,~,~] = fileparts(configPath);
configName = fullfile(configPath,'Config.mat');

%% Set the main data path
% mainPath = fullfile(repoPath,'test','testData');
mainPath = "C:\data";

%% Set the computer configuration
BecExpControlComputerName = "WOODHOUSE";
BecExpParentPath = "B:\_Li\_LithiumData";
BecExpDatabaseName = "lithium_experiment";
BecExpDatabaseTableName = "main";
CiceroComputerName = "GOB";
CiceroLogOrigin = "\\169.254.203.255\RunLogs";
ComputerConfig = table(BecExpControlComputerName,BecExpParentPath,...
    BecExpDatabaseName,BecExpDatabaseTableName,CiceroComputerName,CiceroLogOrigin);
save(configName,"ComputerConfig",'-mat')

%% Set the acquisition configuration
Name = [
    "TOP";
    "XODT";
    "SBB";
    "GREEN";
    "ODT"]; %Named after their locations on the machine table
CameraType = [
    "PCO";
    "Basler";
    "Basler";
    "Basler";
    "Basler"];
AdaptorName = [
    "pcocameraadaptor_r2023a";
    "gentl";
    "gentl";
    "gentl";
    "gentl"]; %MATLAB adaptors for camera connection
DeviceID = int32([0;1;1;1;1]);
SerialNumber = int32([ ...
    924; ...
    21663581; ...
    21975809; ...
    24528051; ...
    21750852]);
ExposureTime = [30;35;35;35;35] * 1e-6; % in SI unit
IsExternalTriggered = [true;true;true;false;true];
PixelSize = [6.5;2.2;2.2;2.2;2.2] * 1e-6; % in SI unit
ImageSize = int32([ ...
    2160,2560; ...
    1080,1920; ...
    1080,1920; ...
    1080,1920; ...
    1080,1920]);
Magnification = [500/200;100/250;500/300;1;100/250]; % need to double check
ImageGroupSize = [3;3;3;1;3]; %How many frames are grouped as a data set. In BEC experiments we take three images.
ConfigFun = {
    @setPcoConfig;
    @setBaslerConfig;
    @setBaslerConfig;
    @setBaslerConfig;
    @setBaslerConfig};
load("quantumEfficiency.mat","pcoQE")
QuantumEfficiencyData = {
    pcoQE;
    [];
    [];
    [];
    [];
};
BadRow = {
    1081;
    [];
    [];
    [];
    []
};
BitsPerSample = [16;8;8;8;8]; % How many bits per pixel
AcquisitionConfig = table(Name,CameraType,AdaptorName,DeviceID,...
    SerialNumber,ExposureTime,IsExternalTriggered,PixelSize,...
    ImageSize,BadRow,Magnification,ImageGroupSize,ConfigFun,QuantumEfficiencyData,BitsPerSample);
save(configName,"AcquisitionConfig",'-mat','-append')

%% Set the ROI configuration
RoiConfig = readtable("roi.csv.xlsx",'TextType','string');
save(configName,"RoiConfig",'-mat','-append')

%% Set the BEC experiment configuration

%copy the .dll for Cicero log reading
dsLibPath = fullfile(matlabroot,'\bin\win64\DataStructures.dll');
if ~exist(dsLibPath,'file')
    try
        copyfile(fullfile(configPath,"datastructures","DataStructures.dll"),...
            fullfile(matlabroot,'\bin\win64\DataStructures.dll'),'f');
    catch
        error("No permission to copy file. Try runing MATLAB as admin.")
    end
end

BecExpConfig.ParentPath = ComputerConfig.BecExpParentPath; % use test data path
BecExpConfig.DataPrefix = "run";
BecExpConfig.DataFormat = ".tif";
BecExpConfig.IsAutoDelete = false;
BecExpConfig.DatabaseName = ComputerConfig.BecExpDatabaseName;
BecExpConfig.DatabaseTableName = ComputerConfig.BecExpDatabaseTableName;
BecExpConfig.CiceroLogOrigin = ComputerConfig.CiceroLogOrigin;
BecExpConfig.DataGroupSize = 3;
BecExpConfig.IsAutoAcquire = true;
BecExpConfig.OdColormap = {jet};
BecExpConfig.AtomName = "Lithium7";
BecExpConfig.ControlAppName = "BecControl";

becExpType = readtable("becExpType.csv.xlsx",'TextType','string');
BecExpConfig = [becExpType,repmat(struct2table(BecExpConfig),size(becExpType,1),1)];
BecExpParameterUnit = readtable("parameterUnit.csv.xlsx",'TextType','string');
BecExpConfig = join(BecExpConfig,BecExpParameterUnit,'Keys',{'ScannedParameter','ScannedParameter'});

load("FringeRemovalMaskConfig.mat","FringeRemovalMaskConfig")
TrialName = BecExpConfig.TrialName(find(~ismember(BecExpConfig.TrialName,FringeRemovalMaskConfig.TrialName)));
FringeRemovalMask = cell(numel(TrialName),1);
FringeRemovalMaskConfig = [FringeRemovalMaskConfig;table(TrialName,FringeRemovalMask)];
BecExpConfig = join(BecExpConfig,FringeRemovalMaskConfig);

save(configName,"BecExpConfig","BecExpParameterUnit",'-mat','-append')

%% Set the BEC experiment local test configuration
BecExpLocalTestConfig = BecExpConfig;
BecExpLocalTestConfig.ParentPath(:) = fullfile("C:\data","becExp");
BecExpLocalTestConfig.CiceroLogOrigin(:) = fullfile(repoPath,"test","testData","testLogFiles");
BecExpLocalTestConfig.IsAutoAcquire(:) = false;
BecExpLocalTestConfig.IsAutoDelete(:) = false;

save(configName,"BecExpLocalTestConfig",'-mat','-append')

%% Set the master equation simulation configuration
MeSimConfig.ParentPath = fullfile("C:\data","meSim");
MeSimConfig.DataPrefix = "run";
MeSimConfig.DataFormat = ".mat";
MeSimConfig.IsAutoDelete = false;
MeSimConfig.DatabaseName = "simulation";
MeSimConfig.DatabaseTableName = "master_equation_simulation";
MeSimConfig.DataGroupSize = 1;

MeSimType = readtable("meSimType.csv.xlsx",'TextType','string');
MeSimConfig = [MeSimType,repmat(struct2table(MeSimConfig),size(MeSimType,1),1)];

% atomDataPath = fullfile(getenv('USERPROFILE'),"Documents","AtomData","AtomData.mat");
for ii = 1:size(MeSimConfig,1)
    try
        atomList(ii,1) = Alkali(MeSimConfig.Atom(ii));
    catch
        atomList(ii,1) = Divalent(MeSimConfig.Atom(ii));
    end
end

MeSimConfig.Atom = [];
MeSimConfig.Atom = atomList;
MeSimOutput = readtable("meSimOutput.csv.xlsx",'TextType','string');
save(configName,"MeSimConfig","MeSimOutput",'-mat','-append')

end