%%
atom = Alkali("Lithium7");
laser = GaussianBeam( ...
    wavelength = 1064e-9,...
    direction = [0;1;0],...
    polarization = [0;0;1],...
    power = 1, ...
    waist = 110e-6 ...
    );
ol = OpticalLattice(atom,laser);
kL = ol.Laser.AngularWavenumber;
Er = ol.RecoilEnergy;
ol.DepthSpec = 8.8458 * Er;
ol.updateIntensity;
nq = 2000;
ol.computeAll1D(nq,3)
Fjn = ol.BlochStateFourier;

%%
driveFreq = 143.2231e3;
wf = SineWave(amplitude = 0.035 * 2,frequency = driveFreq,startTime=0,duration = 0.1,samplingRate=1e7);
qList = linspace(-kL,kL,nq);
[E,V] = ol.computeFloquetAmpMod1D(qList,1:2,wf);

%%
P = zeros(1,nq);
for qq = 1:nq
    VV = squeeze(V(:,1,qq));
    FF = squeeze(Fjn(:,2,qq));
    P(qq) = abs(VV'*FF)^2;
end
plot(qList,P)

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

%% Find Floquet energy
EE = E(:,qList/kL>0.7);
Ep = EE(EE<-4.8e4);
Ed = EE(EE>-4.8e4);
Ep = Ep(:);
Ed = Ed(:);
qList2 = qList(qList/kL>0.7);

%% Time evolution without RWA
q0 = 0.75 * kL;
dt = 1e-7;
t = 0;
tTotal = 1.2e-3;
F = FList0(1);
nt = round(tTotal / dt);
psi = [0;1];
pop = zeros(1,nt);
for tt = 1:nt
    qt = mod(q0 + F * t / hbar + kL,2*kL) - kL;
    Ept = interp1(qList2,Ep,qt,'linear','extrap');
    Edt = interp1(qList2,Ed,qt,'linear','extrap');
    H = [Edt, 500;...
        500, Ept];
    psi = expm(-1i * H * dt * 2 * pi) * psi;
    psi = psi / sqrt((psi'*psi));
    pop(tt) = abs(psi(1))^2;
    t = t + dt;
end
plot((0:dt:(tTotal-dt))*1e3,pop)
