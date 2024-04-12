function [unionList,unionLimit,patchLimit] = findIntervalUnion(intervalList)
%SORTOVERLAPRANGE Summary of this function goes here
%   sortOverlapRange computes the unions of a list of intervals.
%   intervalList: a list of intervals. Must be a 2*N or N*2 matrix. For
%   each interval, the lower limit goes first.
%   union: a cell of unions. Each cell member collects the indexes of
%   intervals that have overlaps.
%   unionLimit: a 2*n or n*2 array, where n is the number of unions. Each
%   rwo/column represents the interval of the union.
arguments
    intervalList double
end

%% Check input
if ~ismatrix(intervalList)
    error("Wrong input dimension.")
elseif ~any(size(intervalList) == 2)
    error("Input must be a 2*N or N*2 matrix.")
else
    if size(intervalList,2) == 2
        intervalList = intervalList.';
        isTrans = true;
    else
        isTrans = false;
    end
    if any(diff(intervalList) < 0)
        error("The lower limit must be smaller than the upper limit.")
    end
end

%% Initialization
nInterval = size(intervalList,2);
[~,idx] = sort(intervalList(1,:));
intervalList = intervalList(:,idx);
unionList = {idx(1)};
unionLimit = intervalList(:,1);
unionIdx = 1;

%% Compute unions
for ii = 2:nInterval
    if intervalList(1,ii) < unionLimit(2,unionIdx)
        unionList{unionIdx} = [unionList{unionIdx},idx(ii)];
        unionLimit(2,unionIdx) = max(intervalList(2,ii),unionLimit(2,unionIdx));
    else
        unionIdx = unionIdx + 1;
        unionList{unionIdx} = idx(ii);
        unionLimit(:,unionIdx) = intervalList(:,ii);
    end
end

%% Compute patches
nUnion = size(unionLimit,2);
patchLimit = zeros(2,nUnion-1);
for ii = 1:(nUnion-1)
    patchLimit(:,ii) = [unionLimit(2,ii);unionLimit(1,ii+1)];
end

%% Organize output
for ii = 1:unionIdx
    unionList{ii} = sort(unionList{ii});
    if isTrans
        unionList{ii} = unionList{ii}.';
    end
end

if isTrans
    unionList = unionList.';
    unionLimit = unionLimit.';
    patchLimit = patchLimit.';
end

end

