function mpSorted = sortMonitor()
%SORTMONITOR Summary of this function goes here
%   This functions sorts the monitor dimensions. The primary monitor will
%   go the first row. The monitor to its right will go the next row. The
%   monitor to its left will go the third row.
mp = get(0, 'MonitorPositions');
nMonitor = size(mp,1);
if nMonitor == 1
    mpSorted = mp;
else
    pos = mp(:,1:2);
    primeIdx = find(prod(pos==1,2));
    if nMonitor == 2
        mpSorted = mp([primeIdx,3-primeIdx],:);
    else
        rightMonitor = mp(mp(:,1)>1,:);
        leftMonitor = mp(mp(:,1)<1,:);
        mpSorted = [mp(primeIdx,:);rightMonitor;leftMonitor];
        % mpSorted = [mp(primeIdx:end,:);mp(1:(primeIdx-1),:)];
    end
end

