function saveObjs(fileName,varargin)
%SAVEOBJS Summary of this function goes here
%   Detailed explanation goes here
varList = evalin('caller','whos');
varClasses = convertCharsToStrings({varList.class});

idx = 0;
for iArg = 1:numel(varargin)
    idx = ((varClasses == varargin{iArg}) | idx);
end

varList = varList(idx);
varNames = {varList.name};
for iVar = 1:numel(varNames)
    varNames{iVar} = ['''',varNames{iVar},''''];
    if iVar ~= numel(varNames)
        varNames{iVar} = [varNames{iVar},','];
    end
end

path = findFunctionPath(2);
fileName = fullfile(path,fileName);
evalin('caller',['save(''',fileName,''',',varNames{:},')']);
end

