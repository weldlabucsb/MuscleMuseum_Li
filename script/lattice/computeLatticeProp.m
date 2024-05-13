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
lambda = laser.Wavelength;
a = lambda / 2;
Er = ol.RecoilEnergy;
ol.DepthKd = 8 * Er;

nDepth = 1000;
nq = 2^12;
qmin = - kL;
qmax =  kL;
qList = linspace(qmin,qmax,nq);
xRange = 100e-06;
nx = 2^12;
xList = linspace(-xRange / 2,xRange / 2,nx);

maxband = 2;
% ol.computeAll1D(qList,maxband,xList)


