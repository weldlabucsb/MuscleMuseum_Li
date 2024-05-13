atom = Alkali("Lithium7");
laser = GaussianBeam( ...
    wavelength = 1064e-9,...
    direction = [0;1;0],...
    polarization = [0;0;1],...
    power = 0.8, ...
    waist = 110e-6 ...
    );
ol = OpticalLattice(atom,laser);
kL = laser.AngularWavenumber;
hbar = Constants.SI("hbar");
h = hbar * 2 * pi;
Er = h * ol.RecoilEnergy;



lambda = laser.Wavelength;
V0 = h * ol.Depth;
m = atom.mass;
omegaB = 2*pi*100;

Delta = 2*sqrt(V0*Er);
% kappa = 2*hbar^3 * omegaB * kL / m / Delta^2 / lambda 
kappa = 8/pi^2 * hbar *omegaB / Er / (Delta/Er)^2;
exp(-1/kappa)