function multiplier = unit2SI(unitString)
%Convert a unit string to SI unit multiplier
arguments
    unitString string
end
switch unitString
    case "\mu s"
        multiplier = 1e-6;
    case "ms"
        multiplier = 1e-3;
    case "\mu V"
        multiplier = 1e-6;
    case "mV"
        multiplier = 1e-3;
    case "kHz"
        multiplier = 1e3;
    case "MHz"
        multiplier = 1e6;
    case "GHz"
        multiplier = 1e9;
    otherwise
        multiplier = 1;
end

