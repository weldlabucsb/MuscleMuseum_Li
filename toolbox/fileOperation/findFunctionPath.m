function path = findFunctionPath(level)
%FINDFUNCTIONPATH Return the path name of the function
%   By default, when "findFunctionPath" is called from the other function, it
%   returns the path of the function's file. If "level" is set to larger
%   than 1, it returns the path of the upper caller's file.
arguments
    level(1,1) int32 {mustBeFinite} = 1;
end
st = evalin('caller','dbstack');
funName = st(level+1).name;
funFileName = evalin('caller',['which(''',funName,''')']);
[path,~,~] = fileparts(funFileName);
end

