%% Constants
hbar = Constants.SI("hbar");
h = hbar * 2 * pi;
g = 9.81;

%% Compute lattice properties
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
ol.updateIntensity;
V0 = h * ol.DepthKd;

nq = 20000;
maxband = 2;
ol.computeAll1D(nq,maxband);
qList = ol.QuasiMomentumList;
A = ol.AmpModCoupling;
X = ol.BerryConnection;
Apd = squeeze(A(2,3,:));
App = squeeze(A(2,2,:));
Add = squeeze(A(3,3,:));

%% Set up AI parameters
omegaDrive = 143.2231e3 * 2 * pi;
alpha = 0.035;
Omega = alpha * V0 * Apd / hbar;
qi = 0.7 * kL;
tTotal = 3.3e-3;

%% Time evolution



