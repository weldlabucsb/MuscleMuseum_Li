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
nq = 2e4;
ol.computeAll1D(nq,2)
Fjn = ol.BlochStateFourier;
lambda = laser.Wavelength;

%%
qi = 0.7*kL;
% tTotal=3.33e-3;
tTotal = 18.9e-3;
driveFreq = 143.2231e3;
wf = SineWave(amplitude = 0.035 * 2,frequency = driveFreq,startTime=0,duration = 0.2,samplingRate=1e7);
% wf = SineWave(amplitude = 0.02071 * 2,frequency = driveFreq,startTime=0,duration = 0.2,samplingRate=1e7);
qList = linspace(-kL,kL,nq);
% [EF,VF] = ol.computeFloquetAmpMod1D(qList,1:2,wf);
[EF,VF] = ol.computeFloquetAmpMod1D(qList,0:2,wf);
save('FData.mat','EF',"VF",'ol')

%% Force
% bList = num2cell(linspace(1.2e-2,1.35e-2,1000));
bList = num2cell(linspace(1.2e-2/3,1.35e-2/3,1000));
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
qIdx = [find(qList/kL>=0.7), find(qList/kL<=-0.7 & qList/kL>-1)];
EEF = EF(1:2,qIdx) * h;
EFp = EEF(EEF/h<-4.8e4);
EFd = EEF(EEF/h>-4.8e4);
EFp = EFp(:);
EFd = EFd(:);
qList2 = [qList(qList/kL>=0.7),2 * kL + qList(qList/kL<=-0.7 & qList/kL>-1)];
plot(qList2/kL,EFp,qList2/kL,EFd)

%% Find Floquet bands
Vp = VF(:,1:2,qIdx);
Vp = Vp(:,EEF/h<-4.8e4);
Vd = VF(:,1:2,qIdx);
Vd = Vd(:,EEF/h>-4.8e4);

FFp = squeeze(Fjn(:,2,qIdx))/sqrt(2 / lambda);
FFd = squeeze(Fjn(:,3,qIdx))/sqrt(2 / lambda);
U = cell(1,numel(qIdx));

P = zeros(1,numel(qIdx));
lambda = laser.Wavelength;
for qq = 1:numel(qIdx)
    VV = squeeze(Vp(:,qq));
    FF = squeeze(Fjn(:,2,qIdx(qq)));
    P(qq) = abs(VV'*FF)^2 * lambda/2;
    U{qq} = [FFd(:,qq)'*Vd(:,qq),FFd(:,qq)'*Vp(:,qq);...
        FFp(:,qq)'*Vd(:,qq),FFp(:,qq)'*Vp(:,qq)];
end
% plot(qList2/kL,P)

%% 2-band LZ
NF = 10000;
A = ol.AmpModCoupling;
X = ol.BerryConnection;
a = lambda/2;
FList = linspace(FList0(1),FList0(end),NF);
omegaBList = FList * a / hbar;
% qR = 0.80 * kL;
omegaDrive = driveFreq * 2 * pi;
qR = ol.computeTransitionQuasiMomentum1D(omegaDrive /2 / pi,1,2);
V0 = h * ol.Depth;
Apd = squeeze(A(2,3,:));
[~,qRIdx] = min(abs(qList-qR));
[~,qRIdx2] = min(abs(qList+qR));

E = h * ol.BandEnergy;
Ed = E(3,:);
Ep = E(2,:);
dq = qList(2) - qList(1);
dEdq = gradient(Ed-Ep,dq);
alphaList = 1 / (V0) / abs(Apd(qRIdx)) .*...
    sqrt(log(4)/pi.*FList.*abs(dEdq(qRIdx)));

tList = (FList ./ hbar^2 * abs(dEdq(qRIdx))).^(-1/2);

vList = FList ./ hbar^2 * abs(dEdq(qRIdx));
% alpha = 0.035;
% alpha = 0.058;
alpha = 0.02071;
Omega = alpha * V0 * abs(Apd(qRIdx)) / hbar;
deltaList = Omega^2 / 4 ./ vList;
PList = exp(-2*pi*deltaList);

BSshift = Omega^2 / 4 / omegaDrive / 2 / pi;

gammaarg = sym(1-1i*deltaList);
gammaList = double(gamma(gammaarg));
phiS = pi/4 + deltaList .* (log(deltaList) - 1) + angle(gammaList);

OmegaList = alpha * V0 * [Apd(qRIdx:end-1);Apd(1:qRIdx2)] / hbar;
EdList = [Ed(qRIdx:end-1),Ed(1:qRIdx2)];
EpList = [Ep(qRIdx:end-1),Ep(1:qRIdx2)];
dEList = zeros(1,numel(EpList));

parfor ii = 1:length(EdList)
    H = [EdList(ii)-omegaDrive * hbar, - hbar*OmegaList(ii)/2;...
        - hbar*OmegaList(ii).'/2,EpList(ii)];
    e = eig(H);
    dEList(ii) = diff(e);
end


[~,qRIdx] = min(abs(qList-qR));
[~,qRIdx2] = min(abs(qList+qR));
dE = Ed - Ep;
dE = dE - omegaDrive * hbar;
% phiD = trapz(qList(qRIdx:end),dE(qRIdx:end)) + trapz(qList(1:qRIdx2),dE(1:qRIdx2));
phiD = trapz(qList(qRIdx:end-1),dEList(1:length(qList(qRIdx:end-1)))) +...
    trapz(qList(1:qRIdx2),dEList((length(qList(qRIdx:end-1))+1):end));
phiD = phiD ./ FList;

pop2band = 4*PList .* (1-PList) .* (sin(phiD/2 + phiS - pi/2)).^2;

%% Floquet LZ
qR = ol.computeTransitionQuasiMomentum1D(driveFreq,1,2);
[~,qRIdx] = min(abs(qList2-qR));
[~,qRIdx2] = min(abs(qList2+qR-2*kL));
Delta = EFd(qRIdx) - EFp(qRIdx);
dq = qList2(2) - qList2(1);
dEd = gradient(EFd,dq);
ddEd = gradient(gradient(EFd,dq),dq);

% fit to get the second-order derivative
% qIdx3 = qList2/kL<0.805 & qList2/kL>0.797;
% qList3 = qList2(qIdx3);
% Ed3 = Ed(qIdx3);
% fitFun = fittype(@(a,b,q) Ed(qRIdx)+b.*(q-qR) + 1/2*a*(q-qR).^2,'independent', {'q'},...
%                 'coefficients', {'a','b'});
% fo = fitoptions(fitFun);
% fo.StartPoint = [ddEd(qRIdx),dEd(qRIdx)];
% fitResult = fit(qList3(:),Ed3(:),fitFun,fo);
% plot(fitResult,qList3(:),Ed3(:))

v = sqrt(2*Delta*abs(ddEd(qRIdx))) * FList0 / hbar;
delta = Delta^2./4./v /hbar;
gammaarg = sym(1-1i*delta);
gammaList = double(gamma(gammaarg));
phiS = -pi/4 + delta .* (log(delta) - 1) + angle(gammaList);
P = exp(-2*pi*delta);
phiDd = trapz(qList2(qRIdx:qRIdx2),EFd(qRIdx:qRIdx2));
% phiDd = phiDd ./ FList0;
phiDp = trapz(qList2(qRIdx:qRIdx2),EFp(qRIdx:qRIdx2));
% phiDp = phiDp ./ FList0;

psi = [0;1];
popF = zeros(1,numel(FList0));
for ii = 1:numel(FList0)
    qf = qi + FList0(ii) * tTotal / hbar;
    [~,qfIdx] = min(abs(qList2-qf));
    T = [sqrt(1-P(ii))*exp(-1i*phiS(ii)),-sqrt(P(ii));...
        sqrt(P(ii)),sqrt(1-P(ii))*exp(1i*phiS(ii))];
    D = diag([exp(-1i*phiDd/FList0(ii)),exp(-1i*phiDp/FList0(ii))]);
    psiF = T*D*T*psi;
    popF(ii) = abs(psiF(1))^2;
end

%% Load TDSE result
trialNumber = 25;
obj = loadTrial(createReader("simulation"),"lattice_fourier_simulation_1d",trialNumber);
data = obj.readBand(1);
fB = FList0*a/h;

%% Plot
% popF = 4 .* P.* (1-P).*(sin(phiS-phiD/2)).^2;
% load simDataF
% load simData2L.mat
% plot(fB,pBandPop,FList0*lambda/2/h,popF,fB2,1-dPop2,omegaBList/2/pi,1-pop2band)
plot(fB,data,fB,popF,omegaBList/2/pi,1-pop2band)
% legend('Exact Fourier TDSE','Floquet LZ','2-level simulation','2-level LZ')
legend('Exact Fourier TDSE','Floquet LZ','2-level LZ')
xlabel('$f_\mathrm{B}$')
ylabel('$p$ band population')
xlim([fB(1),fB(end)])
render



