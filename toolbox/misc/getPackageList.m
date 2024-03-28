function packageList = getPackageList()
%GETPACKAGE Summary of this function goes here
%   Detailed explanation goes here
pk = ver;
packageList = string({pk.Name});
end

