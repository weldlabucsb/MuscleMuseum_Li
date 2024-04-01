function wgObj = getWG(name)
%GETWG Summary of this function goes here
%   Detailed explanation goes here
load("Config.mat","WaveformGeneratorConfig")
wgConfig = WaveformGeneratorConfig(WaveformGeneratorConfig.Name == name,:);
if ~isempty(wgConfig)
    wgObj = feval(wgConfig.DeviceModel,wgConfig.ResourceName,wgConfig.Name);
else
    error("No device named [" + name + "] found in Config. Check your setConfig.")
end
end

