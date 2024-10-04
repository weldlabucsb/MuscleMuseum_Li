% This is a function to set the configuration file
function setConfig
disp(newline + "Setting configurations...")
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
HardwareLogOrigin = "B:\_Li\_LithiumData\HardwareLogs";
ComputerConfig = table(BecExpControlComputerName,BecExpParentPath,...
    BecExpDatabaseName,BecExpDatabaseTableName,CiceroComputerName,...
    CiceroLogOrigin,HardwareLogOrigin);
save(configName,"ComputerConfig",'-mat')

%% Set the database configuration
Name = [
    "lithium_experiment";...
    "simulation";...
    ];
Table = {
"main";    
["master_equation_simulation",...
    "gross_pitaevskii_equation_simulation",...
    "schrodinger_equation_simulation",...
    "fokker_planck_equation_simulation",...
    "lattice_schrodinger_equation_simulation_1d",...
    "lattice_fourier_simulation_1d"]...
    };
DatabaseConfig = table(Name,Table);

Name = ["localhost";"128.111.8.45"];
Port = [5432;5432];
Username = ["postgres";"postgres";];
Password = ["SupermassiveBlackHole";"SupermassiveBlackHole"];
DatabaseServerConfig = table(Name,Port,Username,Password);
save(configName,"DatabaseConfig","DatabaseServerConfig",'-mat','-append')

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
ExposureTime = [30;70;70;70;70] * 1e-6; % in SI unit
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

%% Set the waveform generator configuration
Name = [
    "LatticeMod";...
    "XvWingMod";...
    % "GreenWallMod"
    ];
DeviceModel = [
"Keysight33600A";...
"Keysight33500B";...
% "SpectrumAWG"
];
ResourceName = [
"USB0::0x0957::0x5607::MY59000681::0::INSTR";...
"USB0::0x0957::0x2807::MY59003843::0::INSTR";...
% "TCPIP::172.16.0.0::inst0"
];
WaveformGeneratorConfig = table(Name,DeviceModel,ResourceName);
save(configName,"WaveformGeneratorConfig",'-mat','-append')

%% Set the scope configuration
Name = [
    "LatticeScope"
    ];
DeviceModel = [
"TekTronix1104"
];
ResourceName = [
"USB0::0x0699::0x03B4::C011351::0::INSTR"
];
ScopeConfig = table(Name,DeviceModel,ResourceName);
save(configName,"ScopeConfig",'-mat','-append')

%% Set the hardware list
Name = [WaveformGeneratorConfig.Name;ScopeConfig.Name];
Type = [repmat("WaveformGenerator",numel(WaveformGeneratorConfig.Name),1);...
    repmat("Scope",numel(ScopeConfig.Name),1)];
DataPath = fullfile(ComputerConfig.HardwareLogOrigin,Name);
HardwareList = table(Name,Type,DataPath);
save(configName,"HardwareList",'-mat','-append')

%% Set the ROI configuration
RoiConfig = readtable("roi.csv.xlsx",'TextType','string');
RoiConfig.SubRoiSeparation = cell2mat(arrayfun(@str2num,RoiConfig.SubRoiSeparation,'UniformOutput',false));
RoiConfig.SubRoiNRowColumn = cell2mat(arrayfun(@str2num,RoiConfig.SubRoiNRowColumn,'UniformOutput',false));
RoiConfig.SubRoiCenterSize = arrayfun(@str2num,string(RoiConfig.SubRoiCenterSize),'UniformOutput',false);
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
% Assign empty masks 
TrialName = BecExpConfig.TrialName(find(~ismember(BecExpConfig.TrialName,FringeRemovalMaskConfig.TrialName)));
FringeRemovalMask = cell(numel(TrialName),1);
FringeRemovalMaskConfig = [FringeRemovalMaskConfig;table(TrialName,FringeRemovalMask)];
BecExpConfig = join(BecExpConfig,FringeRemovalMaskConfig);

save(configName,"BecExpConfig","BecExpParameterUnit",'-mat','-append')

%% Set the BEC experiment local test configuration
BecExpLocalTestConfig = BecExpConfig;
BecExpLocalTestConfig.DatabaseName(:) = "lithium_experiment_local";
BecExpLocalTestConfig.ParentPath(:) = fullfile(mainPath,"becExp");
BecExpLocalTestConfig.CiceroLogOrigin(:) = fullfile(repoPath,"test","testData","testLogFiles");
BecExpLocalTestConfig.IsAutoAcquire(:) = false;
BecExpLocalTestConfig.IsAutoDelete(:) = false;

save(configName,"BecExpLocalTestConfig",'-mat','-append')

%% Set the master equation simulation configuration
MeSimConfig.ParentPath = fullfile(mainPath,"meSim");
MeSimConfig.DataPrefix = "run";
MeSimConfig.DataFormat = ".mat";
MeSimConfig.IsAutoDelete = false;
MeSimConfig.DatabaseName = "simulation";
MeSimConfig.DatabaseTableName = "master_equation_simulation";
MeSimConfig.DataGroupSize = 1;

MeSimType = readtable("meSimType.csv.xlsx",'TextType','string');
MeSimConfig = [MeSimType,repmat(struct2table(MeSimConfig),size(MeSimType,1),1)];

MeSimOutput = readtable("meSimOutput.csv.xlsx",'TextType','string');
save(configName,"MeSimConfig","MeSimOutput",'-mat','-append')

%% Set the lattice schrodinger equation simulation configuration
% LatticeSeSim1DConfig.ParentPath = fullfile(mainPath,"latticeSeSim1D");
% LatticeSeSim1DConfig.DatabaseName = "simulation";
LatticeSeSim1DConfig.ParentPath = fullfile("B:\__Lab Member Folders\Xiao\SimulationData","latticeSeSim1D");
LatticeSeSim1DConfig.DatabaseName = "simulation";
LatticeSeSim1DConfig.DataPrefix = "run";
LatticeSeSim1DConfig.DataFormat = ".mat";
LatticeSeSim1DConfig.IsAutoDelete = false;
LatticeSeSim1DConfig.DatabaseTableName = "lattice_schrodinger_equation_simulation_1d";
LatticeSeSim1DConfig.DataGroupSize = 1;

LatticeSeSim1DType = readtable("latticeSeSim1DType.csv.xlsx",'TextType','string');
LatticeSeSim1DConfig = [LatticeSeSim1DType,repmat(struct2table(LatticeSeSim1DConfig),size(LatticeSeSim1DType,1),1)];

LatticeSeSim1DOutput = readtable("latticeSeSim1DOutput.csv.xlsx",'TextType','string');
save(configName,"LatticeSeSim1DConfig","LatticeSeSim1DOutput",'-mat','-append')

%% Set the lattice Fourier schrodinger equation simulation configuration
% LatticeFourierSeSim1DConfig.ParentPath = fullfile(mainPath,"latticeFourierSeSim1D");
% LatticeFourierSeSim1DConfig.DatabaseName = "simulation_local";
LatticeFourierSeSim1DConfig.ParentPath = fullfile("B:\__Lab Member Folders\Xiao\SimulationData","latticeFourierSeSim1D");
LatticeFourierSeSim1DConfig.DatabaseName = "simulation";
LatticeFourierSeSim1DConfig.DataPrefix = "run";
LatticeFourierSeSim1DConfig.DataFormat = ".mat";
LatticeFourierSeSim1DConfig.IsAutoDelete = false;
LatticeFourierSeSim1DConfig.DatabaseTableName = "lattice_fourier_simulation_1d";
LatticeFourierSeSim1DConfig.DataGroupSize = 1;

LatticeFourierSeSim1DType = readtable("latticeFourierSeSim1DType.csv.xlsx",'TextType','string');
LatticeFourierSeSim1DConfig = [LatticeFourierSeSim1DType,repmat(struct2table(LatticeFourierSeSim1DConfig),size(LatticeFourierSeSim1DConfig,1),1)];

LatticeFourierSeSim1DOutput = readtable("latticeFourierSeSim1DOutput.csv.xlsx",'TextType','string');
save(configName,"LatticeFourierSeSim1DConfig","LatticeFourierSeSim1DOutput",'-mat','-append')


disp("Done.")
end