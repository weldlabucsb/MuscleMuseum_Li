function [data,metadata] = pgReadHook(connect,query,optsObject,maxRows,preservenames,isVarNameRuleSpecified)
%SQLREADHOOK read table from a database

% Copyright 2022 The MathWorks, Inc.

extraArgs = cell(0);
if ~isempty(optsObject)
    extraArgs = [extraArgs,{optsObject}];
end
if maxRows > 0
    extraArgs = [extraArgs,{'MaxRows',maxRows}];
end
if isVarNameRuleSpecified
    extraArgs = [extraArgs,{'VariableNamingRule',preservenames}];
end

try
    [data,metadata] = pgFetch(connect,query,extraArgs{:});
catch e
    throwAsCaller(e);
end

end

