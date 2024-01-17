function setYLimit(ax,maxUpperLimit,isSymmetric)
%SETYLIMIT Summary of this function goes here
%   Detailed explanation goes here
Limit1 = ax(1).YLim;
Limit3 = ax(3).YLim;
yLimit = min(max(Limit1(2),Limit3(2)),maxUpperLimit);
if isSymmetric
    axLimit = [-yLimit,yLimit];
else
    axLimit = [0,yLimit];
end
ax(1).YLim = axLimit;
ax(2).YLim = axLimit;
ax(3).YLim = axLimit;
end

