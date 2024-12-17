function [phi,pop] = aiPhaseAnalytical(ol,F,alpha,freq)
%AIPHASEANALYTICAL Summary of this function goes here
%   Detailed explanation goes here
%% Parameters
hbar = Constants.SI("hbar");
h = hbar * 2 * pi;
omega = 2 * pi * freq;
V0 = h * ol.Depth;
A = ol.AmpModCoupling;
qList = ol.QuasiMomentumList;
dq = qList(2) - qList(1);
E = h * ol.BandEnergy;

%% Resonant quasi-momentum
qR = ol.computeTransitionQuasiMomentum1D(freq,1,2);
[~,qRIdx] = min(abs(qList-qR));
[~,qRIdx2] = min(abs(qList+qR));

%% Sweep speed
Ed = E(3,:);
Ep = E(2,:);
Apd = squeeze(A(2,3,:));
dEdq = gradient(Ed-Ep,dq);
v = F ./ hbar^2 .* abs(dEdq(qRIdx));

%% Rabi and population
Omega = alpha * V0 * abs(Apd(qRIdx)) / hbar;
delta = Omega^2 / 4 ./ v;
PList = exp(-2*pi*delta);

%% Stokes phase
gammaarg = sym(1-1i*delta);
gammaList = double(gamma(gammaarg));
phiS = pi/4 + delta .* (log(delta) - 1) + angle(gammaList);

%% Dynamical phase
dE = Ed - Ep;
dE = dE - omega * hbar;
phiD = trapz(qList(qRIdx:end),dE(qRIdx:end)) + trapz(qList(1:qRIdx2),dE(1:qRIdx2));
phiD = phiD ./ F;

%% Output
phi = phiD/2 + phiS - pi/2;
pop = 4*PList .* (1-PList) .* (sin(phi)).^2;

end

