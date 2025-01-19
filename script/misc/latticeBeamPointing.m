close all
t = readtable("C:\Users\WOODHOUSE\Downloads\7_Calculation_Beam-Wander-Log.csv");
tStamp = t.Timestamp;
xData = t.X__m_;
yData = t.Y__m_;
xData = xData - mean(xData) - 400;
yData = yData - mean(yData) + 700;
idx = yData < 100 & yData >0 & xData < 50 & xData >-50;
% idx = 1:numel(yData);
plot(tStamp(idx),xData(idx),tStamp(idx),yData(idx))
xlabel("Time")
ylabel("Beam position [$\mu \mathrm{m}$]",'Interpreter','latex')
legend("$x$","$y$",'interpreter','latex')
ylim([0,100])
render