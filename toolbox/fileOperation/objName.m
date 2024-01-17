function [oN,aN] = objName(parentPath,date,experimentName,experimentIndex)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[~,date2,mm,dd,yyyy] = dateDetail(date);
oN = fullfile(parentPath,yyyy,[mm,'.',dd],[experimentName,'_',experimentIndex],...
    'dataAnalysis',[experimentName,date2,'_',experimentIndex,'.mat']);
aN = fullfile(parentPath,'archive',experimentName,...
    [experimentName,date2,'_',experimentIndex,'.mat']);
end

