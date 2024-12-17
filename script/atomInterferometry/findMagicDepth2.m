%% Set up parameters
atom = Alkali("Lithium7");
laser = GaussianBeam( ...
    wavelength = 1064e-9,...
    direction = [0;1;0],...
    polarization = [0;0;1],...
    power = 1, ...
    waist = 110e-6 ...
    );
ol = OpticalLattice(atom,laser);
kL = laser.AngularWavenumber;
Er = ol.RecoilEnergy;
Vmin = 8.3458 * Er;
Vmax = 9.3458 * Er;
nDepth = 100;
depthList = linspace(Vmin,Vmax,nDepth);

%% Compute full band integrated energy
% nq = 1000;
% qmin = - kL;
% qmax = kL;
% qList = linspace(qmin,qmax,nq);
% U0List = zeros(1,nDepth);
% for ii = 1:nDepth
%     ol.DepthSpec = depthList(ii);
%     eList = ol.computeTransitionFrequency1D(qList,1,2);
%     U0List(ii) = trapz(qList,eList);
% end

%% Force
bList = num2cell(1.2317e-2);
niB = 543.6e-4; %non-interacting feshbach field
bField = cellfun(@(x) MagneticField(...
    bias = [0;0;niB],...
    gradient = [0,0,0;0,0,0;0,x,0]),bList,'UniformOutput',false);
M = atom.mass;
load simData.mat

mp = MagneticPotential(atom,bField{1});
stateIdx = mp.StateIndex;
stateList = atom.(mp.Manifold).StateList;
mJ = stateList.MJ(stateIdx);
gJ = stateList.gJ(stateIdx);
mI = stateList.MI(stateIdx);
gI = stateList.gI(stateIdx);
muB = Constants.SI("muB");
h = Constants.SI("hbar") * 2 * pi;
hbar = Constants.SI("hbar");
prefactor = (mJ * gJ + mI * gI) * muB / h;
F = abs(h * prefactor * cell2mat(bList));

%% Compute partial band integrated energy
nq = 5000;
freq = 143.2231e3;
alpha = 0.035;
phiList = zeros(1,nDepth);

for ii = 1:nDepth
    ol.DepthSpec = depthList(ii);
    ol.computeAll1D(nq,2)
    phiList(ii) = aiPhaseFloquet(ol,F,alpha,freq);
    disp(ii)
end

%% Compute magic depth
% nFullBand = 1;
% Utotal = phiList + U0List * nFullBand;
dphidV = gradient(phiList);
[~,idx] = min(abs(dphidV));
magicDepth = depthList(idx);

%% Plot
plot(depthList/Er,dphidV,depthList/Er,zeros(1,nDepth))
xlabel("$V_0 / E_{\mathrm{R}}$",'Interpreter','latex')
ylabel("$\partial\langle \Delta E \rangle / \partial V_0$ [arb.]",'Interpreter','latex')
render
disp("Magic depth: " + string(magicDepth/Er) + " Er")
ol.DepthSpec = magicDepth;
% disp("Modulation Frequency: " + string(ol.computeTransitionFrequency1D(qmin,1,2) / 1e3) + " kHz")

%% Plot 2
openfig("Magic_Depth.fig")
ax = gca;
l = ax.Children;
datax = l(2).XData;
datay = l(2).YData;
[~,idx] = min(abs(gradient(datay)));
magicDepth2 = datax(idx);

close all
figure
xlabel("$V_0/E_{\mathrm{R}}$",Interpreter="latex")
yyaxis left
plot(depthList/Er,phiList,repmat(magicDepth/Er,1,100),linspace(min(phiList)*0.5,max(phiList)*1.5,100))
ylim([min(phiList)*0.999,max(phiList)])
ylabel("Floquet LZ, $\phi^{\mathrm{I}}$ [Rad]",Interpreter="latex")
yyaxis right
plot(datax,datay,repmat(magicDepth2,1,100),linspace(min(datay)*0.5,max(datay)*1.5,100))
ylim([0,max(datay)*1.05])
ylabel("TDSE, $P$ band population",Interpreter="latex")
% xlim([min(datax),max(datax)])
xlim([8.6,9])
render
l = findobj(gcf,'Type','Line');
co = colororder;
l(3).Color = co(1,:);
l(3).LineStyle = '--';
l(4).Color = co(1,:);
l(4).LineStyle = '-';
l(1).LineStyle = '--';
l(2).LineStyle = '-';

ax = gca;
ax.Position(1) = ax.Position(1) * 1.01;

%% PLot 2
l = plot(depthList/Er,phiList,repmat(magicDepth/Er,1,100),linspace(min(phiList)*0.5,max(phiList)*1.5,100));
l(2).LineStyle = '--';
ylim([min(phiList)*0.999,190.6])
xlim([8.6,9])
xlabel("Lattice depth ($E_{\mathrm{R}}$)",Interpreter="latex")
ylabel("$\phi^{\mathrm{I}}$ (Rad)",Interpreter="latex")
render

