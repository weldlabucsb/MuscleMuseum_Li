atom = Alkali("Lithium7");
h = Constants.SI("hbar") * 2 * pi;
l = sqrt(h/atom.mass);
sim = SeSim1DRun(...
    totalTime = 20e-3,...
    timeStep = 1e-6,...
    spaceRange = 160e-6,...
    spaceStep = 160e-6 * 1e-4,...
    mass = atom.mass);
x = sim.SpaceList;
sigma = 10e-6;
k = 10 * atom.mass * (160e-6 / 20e-3) / h;
ic = InitialCondition(sim);
ic.WaveFunction = exp(-(x).^2 / sigma^2 + 1i*k*x);
sim.InitialCondition = ic;

a = 0.02;
% F = a * atom.mass / 1;

F = 1 * 1e-4 * 100 * Constants.SI("muB");

% V = F * (x(end) - abs(x)).' / h;
V = F * x.' / h;
% V = F * 0.0050 * sin(2*pi / 4e-2 * x.') / h;
V = 0;

sim.Potential = @(t) V;
sim.start