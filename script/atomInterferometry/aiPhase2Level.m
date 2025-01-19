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
% ol.DepthKd = 5.9637 * Er;
ol.updateIntensity;
V0 = h * ol.DepthKd;

nq = 50000;
maxband = 2;
ol.computeAll1D(nq,maxband);
qList = ol.QuasiMomentumList;
A = ol.AmpModCoupling;
X = ol.BerryConnection;
Apd = squeeze(A(2,3,:));
App = squeeze(A(2,2,:));
Add = squeeze(A(3,3,:));
E = h * ol.BandEnergy;
Ep = E(2,:);
Ed = E(3,:);

%% Set up AI parameters
omegaDrive = 143.2231e3 * 2 * pi;
% omegaDrive = 75.2639e3 * 2 * pi;
alpha = 0.035;
% alpha = 0.0679;
Omega = alpha * V0 * Apd / hbar;
Omegapp = alpha * V0 * App / hbar;
Omegadd = alpha * V0 * Add / hbar;

q0 = 0.7 * kL;
tTotal = 3.33e-3;
% tTotal = 8e-3;

%% Force
bList = num2cell(linspace(1.2e-2,1.35e-2,96));
niB = 543.6e-4; %non-interacting feshbach field
bField = cellfun(@(x) MagneticField(...
    bias = [0;0;niB],...
    gradient = [0,0,0;0,0,0;0,x,0]),bList,'UniformOutput',false);
M = atom.mass;
load simData.mat

mp = MagneticPotential(atom,bField{1});
stateIdx = mp.StateIndex;
stateList = atom.(mp.Manifold).StateList;
mJ = stateList.MJ(stateIdx);
gJ = stateList.gJ(stateIdx);
mI = stateList.MI(stateIdx);
gI = stateList.gI(stateIdx);
muB = Constants.SI("muB");
h = Constants.SI("hbar") * 2 * pi;
hbar = Constants.SI("hbar");
prefactor = (mJ * gJ + mI * gI) * muB / h;
FList0 = abs(h * prefactor * cell2mat(bList));

%% Time evolution with RWA
dt = 1e-7;
t = 0;
nt = round(tTotal / dt);
psi = [0;1];
pop = zeros(1,nt);
for tt = 1:nt
    qt = mod(q0 + FList0(1) * t / hbar + kL,2*kL) - kL;
    Ept = interp1(qList,Ep,qt,'linear','extrap');
    Edt = interp1(qList,Ed,qt,'linear','extrap');
    Omegat = interp1(qList,Omega,qt,'linear','extrap');
    H = [Edt - hbar * omegaDrive , -hbar * Omegat / 2;...
        -hbar * Omegat.' / 2, Ept];
    psi = expm(-1i * H * dt / hbar) * psi;
    psi = psi / sqrt((psi'*psi));
    pop(tt) = abs(psi(1))^2;
    t = t + dt;
end
plot((0:dt:(tTotal-dt))*1e3,pop)

%% Time evolution without RWA
dt = 1e-7;
t = 0;
nt = round(tTotal / dt);
psi = [0;1];
pop = zeros(1,nt);
for tt = 1:nt
    qt = mod(q0 + FList0(1) * t / hbar + kL,2*kL) - kL;
    Ept = interp1(qList,Ep,qt,'linear','extrap');
    Edt = interp1(qList,Ed,qt,'linear','extrap');
    Omegat = interp1(qList,Omega,qt,'linear','extrap');
    Omegappt = interp1(qList,Omegapp,qt,'linear','extrap');
    Omegaddt = interp1(qList,Omegadd,qt,'linear','extrap');
    cc = cos(omegaDrive * t);
    ee = exp(-1i*2*omegaDrive*t);
    H = [Edt - hbar * omegaDrive - hbar * cc *Omegaddt , -hbar * Omegat / 2 * (1+ee');...
        -hbar * Omegat.' / 2  * (1+ee), Ept - hbar * cc *Omegappt];
    psi = expm(-1i * H * dt / hbar) * psi;
    psi = psi / sqrt((psi'*psi));
    pop(tt) = abs(psi(1))^2;
    t = t + dt;
end
plot((0:dt:(tTotal-dt))*1e3,pop)

%% Time evolution without RWA, plot fringe

dt = 1e-7;
nt = round(tTotal / dt);
pop = zeros(1,numel(FList0));
parfor ff = 1:numel(FList0)
    F = FList0(ff);
    t = 0;
    psi = [0;1];
    for tt = 1:nt
        qt = mod(q0 + F * t / hbar + kL,2*kL) - kL;
        Ept = interp1(qList,Ep,qt,'linear','extrap');
        Edt = interp1(qList,Ed,qt,'linear','extrap');
        Omegat = interp1(qList,Omega,qt,'linear','extrap');
        Omegappt = interp1(qList,Omegapp,qt,'linear','extrap');
        Omegaddt = interp1(qList,Omegadd,qt,'linear','extrap');
        cc = cos(omegaDrive * t);
        ee = exp(-1i*2*omegaDrive*t);
        H = [Edt - hbar * omegaDrive - hbar * cc *Omegaddt , -hbar * Omegat / 2 * (1+ee');...
            -hbar * Omegat.' / 2  * (1+ee), Ept - hbar * cc *Omegappt];
        psi = expm(-1i * H * dt / hbar) * psi;
        psi = psi / sqrt((psi'*psi));
        t = t + dt;
    end
    pop(ff) = abs(psi(1))^2;
end

%%
plot(FList0*a / hbar /2 /pi,pop,FList0*a / hbar /2 /pi,bandPop(:,3))
xlabel("$f_{\mathrm{B}}$",'Interpreter','latex')
ylabel("$d$ band population",'Interpreter','latex')
legend("2-level w/o RWA","Fourier-space TDSE")
render

