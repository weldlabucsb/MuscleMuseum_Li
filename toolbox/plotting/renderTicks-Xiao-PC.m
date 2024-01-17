function renderTicks(image,x,y)
ax = image.Parent;
stepTest = [5,10,20,50,100,200,500,1000];
xLim = image.XData;
yLim = image.YData;
xRatio = (max(x)-min(x))/(max(xLim)-min(xLim));
yRatio = (max(y)-min(y))/(max(yLim)-min(yLim));

xStep = (max(x)-min(x))/7;
yStep = (max(y)-min(y))/7;

[~,idx] = min(abs(stepTest-xStep));
xStep = stepTest(idx);
[~,idx] = min(abs(stepTest-yStep));
yStep = stepTest(idx);

xTickLabel = ceil(x(1)/xStep)*xStep:xStep:x(end);
yTickLabel = ceil(y(1)/yStep)*yStep:yStep:y(end);
xTick = 1+(xTickLabel-x(1))/xRatio;
yTick = 1+(yTickLabel-y(1))/yRatio;
xTickLabel = cellfun(@num2str,num2cell(xTickLabel,1),'UniformOutput',false);
yTickLabel = cellfun(@num2str,num2cell(yTickLabel,1),'UniformOutput',false);

ax.XTickMode = 'manual';
ax.XTick = xTick;
ax.XTickLabel = xTickLabel;
ax.YTickMode = 'manual';
ax.YTick = yTick;
ax.YTickLabel = yTickLabel;
end

