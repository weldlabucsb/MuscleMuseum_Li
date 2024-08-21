function updateScopeData(obj)
%UPDATESCOPEDATA Summary of this function goes here
%   Detailed explanation goes here
fullValueName = string.empty;
if contains(obj.ScannedParameter,"Scope","IgnoreCase",true)
    fullValueName = [fullValueName,obj.ScannedParameter];
end
if isprop(obj,"ScopeValue") && ~isempty(obj.ScopeValue.FullValueName)
    fullValueName = [fullValueName,obj.ScopeValue.FullValueName];
end
if isempty(fullValueName)
    return
end
currentRunNumber = obj.NCompletedRun;
for kk = 1:numel(fullValueName)
    C = strsplit(fullValueName(kk),"_");
    scopeName = C(1);
    channelName = C(2);
    valueName = C(3);
    channelNumber = double(regexp(channelName,'\d*','Match'));
    if isfield(obj.ScopeData,fullValueName(kk)) && numel(obj.ScopeData.(fullValueName(kk))) == (currentRunNumber - 1)
        obj.ScopeData.(fullValueName(kk))(end+1) = readRun(currentRunNumber,scopeName,valueName,channelNumber);
    elseif isfield(obj.ScopeData,fullValueName(kk)) && numel(obj.ScopeData.(fullValueName(kk))) == currentRunNumber
        continue
    else
        for ii = 1:currentRunNumber
            obj.ScopeData(1).(fullValueName(kk))(ii) = readRun(ii,scopeName,valueName,channelNumber);
        end
    end
end
    function value = readRun(runIdx,sName,vName,cNumber)
        try
            scopeData = loadVar(fullfile(obj.HardwareLogPath,obj.DataPrefix + "_" + num2str(runIdx)) + "_" + sName + ".mat");
        catch
            error(sName+" has no data fetched in HardwareLogPath.")
        end
        if ~scopeData.IsEnabled(cNumber)
            error("Channel"+cNumber+" of "+sName+" was disabled.")
        end
        valueIdx = (cNumber == find(scopeData.IsEnabled));
        try
            valueList = scopeData.(vName);
        catch
            error(vName + " is not a valid scope value.")
        end
        value = valueList(valueIdx);
    end
end

