function [phi,pop] = aiPhaseFloquet(ol,F,alpha,freq)
%AIPHASEANALYTICAL Summary of this function goes here
%   Detailed explanation goes here
%% Parameters
hbar = Constants.SI("hbar");
h = hbar * 2 * pi;
qList = ol.QuasiMomentumList;
E = h * ol.BandEnergy;
kL = ol.Laser.AngularWavenumber;

%% Resonant quasi-momentum
qR = ol.computeTransitionQuasiMomentum1D(freq,1,2);
qR2 = 2*kL - qR;
qList2 = linspace(qR-0.1*kL,qR2+0.1*kL,1000); % for Floquet calculation
dq = qList2(2) - qList2(1);
[~,qRIdx0] = min(abs(qList-qR));
[~,qRIdx] = min(abs(qList2-qR));
[~,qRIdx2] = min(abs(qList2-qR2));

%% Compute the crossing energy
Epc = E(2,qRIdx0);
Edc = E(3,qRIdx0);
if Epc/h >= -freq/2 && Epc/h <= freq/2
    Ec = Epc;
else
    Ec = Edc;
end

%% Compute Floquet bands
wf = SineWave(amplitude = alpha * 2,frequency = freq,startTime=0,duration = 0.2,samplingRate=1e7);
[EF,~] = ol.computeFloquetAmpMod1D(qList2,1:2,wf);

%% Find Floquet energy
EEF = EF(1:2,:) * h;
EFp = EEF(EEF<Ec);
EFd = EEF(EEF>Ec);
EFp = EFp(:);
EFd = EFd(:);

%% Sweep speed
Delta = EFd(qRIdx) - EFp(qRIdx);
ddEd = gradient(gradient(EFd,dq),dq);
v = sqrt(2*Delta*abs(ddEd(qRIdx))) .* F ./ hbar;

%% LZ probability
delta = Delta^2./4./v /hbar;
PList = exp(-2*pi*delta);

%% Stokes phase
gammaarg = sym(1-1i*delta);
gammaList = double(gamma(gammaarg));
phiS = -pi/4 + delta .* (log(delta) - 1) + angle(gammaList);

%% Dynamical phase
phiDd = trapz(qList2(qRIdx:qRIdx2),EFd(qRIdx:qRIdx2))./F;
phiDp = trapz(qList2(qRIdx:qRIdx2),EFp(qRIdx:qRIdx2))./F;
phiD = phiDd - phiDp;

%% Output
phi = phiD + 2 * phiS;
pop = 2*PList .* (1-PList) .* (1+cos(phi));

end

