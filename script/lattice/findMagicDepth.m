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

nDepth = 100;
nq = 200;
qmin = 0.4 * kL;
qmax = 1.6 * kL;
Vmin = 0;
Vmax = 10 * Er;
depthList = linspace(0,Vmax,nDepth);
qList = linspace(qmin,qmax,nq);
UList = zeros(1,nDepth);
dq = qList(2) - qList(1);

for ii = 1:nDepth
    ol.DepthSpec = depthList(ii);
    eList = ol.computeTransitionFrequency1D(qList,1,2);
    UList(ii) = sum(eList) * dq;
end

plot(depthList/Er,gradient(UList),depthList/Er,zeros(1,nDepth))
xlabel("$V_0 / E_{\mathrm{R}}$",'Interpreter','latex')
ylabel("$\partial\langle \Delta E \rangle / \partial V_0$ [arb.]",'Interpreter','latex')
render
[~,idx] = min(abs(gradient(UList)));
magicDepth = depthList(idx);
disp("Magic depth: " + string(magicDepth/Er) + " Er")
ol.DepthSpec = magicDepth;
disp("Modulation Frequency: " + string(ol.computeTransitionFrequency1D(qmin,1,2) / 1e3) + " kHz")

