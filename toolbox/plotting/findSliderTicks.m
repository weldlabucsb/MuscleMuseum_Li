function ticks = findSliderTicks(nList)
nMax = max(nList);
nMin = min(nList);
if nMax <= 10
    ticks = sort(nList);
elseif nMax > 10 && nMax <= 50
    ticks = 5 * floor(min(nList)/5) : 5 : max(nList);
elseif nMax > 50 && nMax <= 100
    ticks = 10 * floor(min(nList)/10) : 10 : max(nList);
elseif nMax > 100 && nMax <= 200
    ticks = 20 * floor(min(nList)/20) : 20 : max(nList);
elseif nMax > 200
    ticks = 50 * floor(min(nList)/50) : 50 : max(nList);
end
    ticks(1) = nMin;
    ticks(end) = nMax;
end

