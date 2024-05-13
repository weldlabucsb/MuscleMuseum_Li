function updateHardware(obj)
%UPDATEHARDWARE Summary of this function goes here
%   Detailed explanation goes here
hwApp = get(findall(0, 'Tag', "HwControlPanel"), 'RunningAppInstance');
if ~isempty(hwApp)
    if isvalid(hwApp)
        hardwareData = table2cell(hwApp.CurrentVariableList);
        hardwareData = cell2struct(hardwareData(:,2),string(hardwareData(:,1)));
        if isempty(obj.HardwareData)
            obj.HardwareData = hardwareData;
        else
            f = fields(obj.HardwareData);
            for ii = 1:numel(f)
                obj.HardwareData.(f{ii}) = [obj.HardwareData.(f{ii}),hardwareData.(f{ii})];
            end
        end
        hwApp.update
    end
end

end

