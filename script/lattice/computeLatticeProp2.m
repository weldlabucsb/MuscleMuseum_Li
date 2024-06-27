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
ol.DepthKd = 8.8458 * Er;

nDepth = 1000;
nq = 2^12;
qmin = - kL;
qmax =  kL;
qList = linspace(qmin,qmax,nq);
xRange = 100e-06;
nx = 2^12;
xList = linspace(-xRange / 2,xRange / 2,nx);

maxband = 2;
% [E,phi,u] = ol.computeBand1D(qList,maxband,xList);
tic
ol.computeAll1D(nq,maxband)
toc
% X = ol.computeBerryConnection1D(qList,maxband);
% plot(qList/kL,abs(squeeze(X(1,2,:))) ./ a , qList/kL,abs(squeeze(X(1,3,:))) ./ a , qList/kL,abs(squeeze(X(2,3,:))) ./ a);
% A = ol.computeAmpModCoupling1D(qList,maxband);
% ol.compute
% plot(qList/kL,abs(squeeze(A(1,2,:))),qList/kL,abs(squeeze(A(1,3,:))),qList/kL,abs(squeeze(A(2,3,:))));
% plot(qList/kL,(squeeze(A(1,2,:))),qList/kL,(squeeze(A(1,3,:))),qList/kL,(squeeze(A(2,3,:))));
