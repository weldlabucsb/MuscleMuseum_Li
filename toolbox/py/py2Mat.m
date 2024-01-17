function matVar = py2Mat(pyVar)
%PY2MAT Summary of this function goes here
%   Detailed explanation goes here
switch class(pyVar)
    case "py.int"
        matVar = int32(pyVar);
    case "py.str"
        matVar = string(pyVar);
    case "py.list"
        try
            matVar = double(pyVar);
        catch
            matVar = string(pyVar);
        end
    case "py.tuple"
        switch class(pyVar{1})
            case "py.int"
                try
                    matVar = int32(pyVar);
                catch
                    matVar = cell(pyVar);
                end
            case "py.str"
                try
                    matVar = string(pyVar);
                catch
                    matVar = cell(pyVar);
                end
            case "double"
                try
                    matVar = double(pyVar);
                catch
                    matVar = cell(pyVar);
                end
            case "logical"
                try
                    matVar = logical(pyVar);
                catch
                    matVar = cell(pyVar);
                end
            otherwise
                matVar = cell(pyVar);
        end
    otherwise
        matVar = pyVar;
end
end

