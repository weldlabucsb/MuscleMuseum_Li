atom = Alkali("Lithium7");
sim = SeSim1DRun(...
    totalTime = 10,...
    timeStep = 1e-4,...
    nSpaceStep = 2^10,...
    spaceRange = 1e-2,...
    mass = atom.mass);
x = sim.SpaceList;
ic = InitialCondition(sim);
ic.WaveFunction = exp(-x.^2 / 0.001^2);
sim.InitialCondition = ic;

a = 0.02;
F = a * atom.mass / 100;
h = Constants.SI("hbar") * 2 * pi;
V = F * (x(end)-abs(x)).' / h;

sim.Potential = @(t) V;
sim.start