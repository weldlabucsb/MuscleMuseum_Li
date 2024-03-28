function logi = isTimeUnit(unitString)
%ISTIMEUNIT Summary of this function goes here
%   Detailed explanation goes here
if unitString == "s" || unitString == "ms" || unitString == "\mu s"
    logi = true;
else
    logi = false;
end
end

