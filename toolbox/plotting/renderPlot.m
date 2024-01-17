function renderPlot(chartLine,xLabel,yLabel)
%RENDERPLOT Summary of this function goes here
%   Detailed explanation goes here
ax = chartLine.Parent;
xlabel(ax,xLabel,'interpreter','latex','fontsize',12)
ylabel(ax,yLabel,'interpreter','latex','fontsize',12)
end
