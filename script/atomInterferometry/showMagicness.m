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
U0List = zeros(3,nDepth);
for ii = 1:nDepth
    ol.DepthSpec = depthList(ii);
    eList = ol.computeTransitionFrequency1D(qList,0,1);
    U0List(1,ii) = trapz(qList,eList);
end
for ii = 1:nDepth
    ol.DepthSpec = depthList(ii);
    eList = ol.computeTransitionFrequency1D(qList,1,2);
    U0List(2,ii) = trapz(qList,eList);
end
for ii = 1:nDepth
    ol.DepthSpec = depthList(ii);
    eList = ol.computeTransitionFrequency1D(qList,0,2);
    U0List(3,ii) = trapz(qList,eList);
end

%% Plot
plot(depthList/Er,U0List/Er/2/kL)
xlabel("$V_0 / E_{\mathrm{R}}$",'Interpreter','latex')
ylabel("$\langle \Delta E \rangle / E_{\mathrm{R}}$",'Interpreter','latex')
legend("$S \leftrightarrow P$","$P \leftrightarrow D$","$S \leftrightarrow D$")
render

