function countExistedLog(obj)
%COUNTEXISTEDLOG Summary of this function goes here
%   Detailed explanation goes here
obj.ExistedCiceroLogNumber = countFileNumber(obj.CiceroLogOrigin,".clg");
obj.ExistedHardwareLogNumber = arrayfun(@countFileNumber,obj.HardwareList.DataPath);
end

