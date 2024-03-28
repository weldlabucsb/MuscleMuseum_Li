function parameterListSorted = sortBecExpParameter(parameterList)
%SORTBECEXPTRIALNAME Summary of this function goes here
%   Detailed explanation goes here

parameterList(parameterList == "RunIndex" | parameterList == "CiceroLogTime") = [];
parameterList = sort(parameterList);
parameterListSorted = ["RunIndex";"CiceroLogTime";parameterList];

end

