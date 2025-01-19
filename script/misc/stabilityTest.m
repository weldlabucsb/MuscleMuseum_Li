%% MRC
t = readtable("Powertest_2024-12-16T17-44-16.csv");
t0 = t.ms * 1e-3;
v0 = t.I1_V_;
% figure
% plot(tMRC,vMRC);

% T = 24.050445;
T = 26.6320;
tIni = 49.645;
dt = 1;
tiList = tIni:T:t0(end);
tMRC = zeros(size(tiList));
vMRC = zeros(size(tiList));
vMRCstd = zeros(size(tiList));
for ii = 1:numel(tiList)
    idx = t0 >= tiList(ii) & t0 <= (tiList(ii)+dt);
    tMRC(ii) = mean(t0(idx));
    vMRC(ii) = mean(v0(idx));
    vMRCstd(ii) = std(v0(idx));
end
vMRCMean = mean(vMRC);
figure
errorbar(tMRC-tMRC(1),(vMRC-vMRCMean)/vMRCMean,vMRCstd/vMRCMean,'.')
hold on

%% Scope
fig = openfig("scopeData.fig");
ax = gca;
l = ax.Children;
tScope = l(1).XData(2:end);
vScope = l(2).YData(2:end);
vScopeMean = mean(vScope);
vScopeStd = l(1).YData(2:end);
close(fig)
errorbar(tScope-tScope(1),(vScope-vScopeMean)/vScopeMean,vScopeStd/vScopeMean,'.')


%% Power Meter
t2 = readtable("PM_LogData.txt");
t0 = t2.Var1;
t0 = seconds(t0 - t0(1));
v0 = t2.Var2;
tIni = 18.458;
% T = (71.651-18.458)/2;
T = 26.6320;
dt = 0.5;
tiList = tIni:T:t0(end);
tPM = zeros(size(tiList));
vPM = zeros(size(tiList));
for ii = 1:numel(tiList)
    idx = t0 >= tiList(ii)-dt & t0 <= (tiList(ii)+0.3);
    tPM(ii) = mean(t0(idx));
    vPM(ii) = max(v0(idx));
    % plot(t0(idx),v0(idx))
end
vPMMean = mean(vPM);
% figure
l = plot(tPM-tPM(1),(vPM-vPMMean)/vPMMean,'.');
legend("MRC","Scope","Power Meter")
xlabel("Time [s]")
ylabel("Normalized Deviation")
render

co = colororder;
l.Color = co(1,:);
l.Marker = "+";
