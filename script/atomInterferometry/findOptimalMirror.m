close all
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

nPower = 100;
nq = 11;
powerList = linspace(0.1,1,nPower);
qList = linspace(0,kL,nq);
depthList = zeros(1,nPower);
freqList = zeros(nq,nPower);

for jj = 1:nq
    for ii = 1:nPower
        ol.Laser.Power = powerList(ii);
        freqList(jj,ii) = ol.computeTransitionFrequency1D(qList(jj),0,1);
        depthList(ii) = ol.DepthLu;
    end
end

plot(depthList,freqList/1e3)
xlabel("Lattice Depth [$E_{\mathrm{R}}$]",Interpreter="latex")
ylabel("Transition Frequency [$\mathrm{kHz}$]",Interpreter="latex")
axis([-inf,inf,-inf,inf])
legend("$q=" + string(qList/kL) + "$")
render