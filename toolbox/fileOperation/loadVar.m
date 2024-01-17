function obj = loadVar(fileName,varName)
% Output the variable in the file
if nargin == 1
    C = struct2cell(load(fileName));
elseif nargin == 2
    C = struct2cell(load(fileName,varName));
end
obj = C{1};
end

