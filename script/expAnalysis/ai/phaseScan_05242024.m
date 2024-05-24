%% Pathclose all
parentPath = "G:\My Drive\Work\Inteferometry\data\";
dataPath = parentPath + string(1:4) + ".fig";
dataPath = dataPath([1,3,4]);

xvList = [.2655,.2,.1];
xvList = 4.88 - xvList;
fbList = xvList / xvList(1) * 90.87;
atom = Alkali("Lithium7");
h = Constants.SI("hbar") * 2 * pi;

aList = fbList * h / (1064e-9 / 2) / atom.mass / 9.81;
aList = arrayfun(@(x) string(num2str(x,"%.4f")),aList);

%%
fig0 = figure(1024);
ax = gca;
for ii = 1:numel(dataPath)
    fig = openfig(dataPath(ii));
    copyobj(fig.Children(2).Children(2),ax)
    close(fig)
end
figure(fig0)
xlabel("Phase [Radians]",'Interpreter','latex')
ylabel("$P$ band relative population",'Interpreter','latex')
box on
ax.XTick = [0,pi/2,pi,3*pi/2,2*pi];
ax.XTickLabel = ["0","$\pi /2$","$\pi$","$3\pi /2$","$2\pi$"];
ax.TickLabelInterpreter = "latex";
axis([0,2*pi,0.2,0.8])

l = ax.Children;
for ii = 1:numel(l)
    data = [l(ii).XData.',l(ii).YData.'];
    fitData = SineFit1D(data);
    fitData.Upper(2) = 1 / 2 / pi;
    fitData.Lower(2) = 1 / 2 / pi;
    fitData.StartPoint(2) = 1 / 2 / pi;
    fitData.do;
    hold on
    plot(ax,fitData.FitPlotData(:,1),fitData.FitPlotData(:,2))
    hold off
end

legend("$" + aList(1)+"g$","$" + aList(2)+"g$","$" + aList(3)+"g$",'Interpreter','latex')
co = colororder(ax);
render
markers = {'o','diamond','square','^'};
for ii = 1:numel(l)
    l(ii).LineStyle = "none";
    l(ii).MarkerFaceColor = co(ii,:);
    l(ii).MarkerEdgeColor = co(ii,:) * 0.5;
    l(ii).Marker = markers{ii};
    l(ii).Color =  co(ii,:) * 0.5;
end

%% Save
saveas(gcf,parentPath + "AI_Phase_Scan.fig")
saveas(gcf,parentPath + "AI_Phase_Scan.png","png")
