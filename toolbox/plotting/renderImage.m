function renderImage(image,colorLimits,map,isShowAxes)
ax = image.Parent;
if isShowAxes == 0
    ax.Visible = 'off';
end
ax.YDir = 'normal';
ax.Colormap = map;
clim(ax,colorLimits)
imgSize = size(image.CData);
colorbar(ax)
% ax.Units = 'pixels';
pos3 = ax.Position(3);
ax.Position(3) = ax.Position(4)*imgSize(2)/imgSize(1);
ax.Position(1) = ax.Position(1)+((pos3-ax.Position(3)))/2;
tit = ax.Title;
tit.Visible = 'on';
tit.FontSize = 15;
end

