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
Vmin = 0.1 * Er;
Vmax = 10 * Er;
nDepth = 2000;
depthList = linspace(Vmin,Vmax,nDepth);

%% Compute full band integrated energy
nq = 1000;
qmin = - kL;
qmax = kL;
qList = linspace(qmin,qmax,nq);
U0List = zeros(1,nDepth);
for ii = 1:nDepth
    ol.DepthSpec = depthList(ii);
    eList = ol.computeTransitionFrequency1D(qList,1,2);
    U0List(ii) = trapz(qList,eList);
end

%% Compute partial band integrated energy
nq = 1000;
qr = 0.39;
qmin = qr * kL;
qmax = (2-qr) * kL;
qList = linspace(qmin,qmax,nq);
UList = zeros(1,nDepth);

for ii = 1:nDepth
    ol.DepthSpec = depthList(ii);
    eList = ol.computeTransitionFrequency1D(qList,1,2);
    UList(ii) = trapz(qList,eList);
end

%% Compute magic depth
nFullBand = 1;
Utotal = UList + U0List * nFullBand;
dUdV = gradient(Utotal);
[~,idx] = min(abs(dUdV));
magicDepth = depthList(idx);

%% Plot
plot(depthList/Er,dUdV,depthList/Er,zeros(1,nDepth))
xlabel("$V_0 / E_{\mathrm{R}}$",'Interpreter','latex')
ylabel("$\partial\langle \Delta E \rangle / \partial V_0$ [arb.]",'Interpreter','latex')
render
disp("Magic depth: " + string(magicDepth/Er) + " Er")
ol.DepthSpec = magicDepth;
disp("Modulation Frequency: " + string(ol.computeTransitionFrequency1D(qmin,1,2) / 1e3) + " kHz")

