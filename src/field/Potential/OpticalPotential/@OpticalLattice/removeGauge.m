function removeGauge(obj)
%REMOVEGAUGE Summary of this function goes here
%   Detailed explanation goes here
X = obj.BoCouplingList;
q = obj.QuasiMomentumList;
x = obj.SpaceList;
sz = size(X);
nBand = sz(1);
nq = sz(3);
dq = q(2) - q(1);
dx = x(2) - x(1);
lambda = obj.Laser.Wavelength;
cellIdx = x < lambda/4 & x >= -lambda/4;
phase = zeros(nBand,nq);
for nIdx = 1:nBand
    Xnn = X(nIdx,nIdx,:);
    phase(nIdx,:) = cumtrapz(q,Xnn);
end
phase = exp(1i * phase);

phi = obj.BlochStateList;
u = obj.BlochStatePeriodicList;

for nIdx = 1:nBand
    for qq = 1:nq
        phi(:,qq,nIdx) = phi(:,qq,nIdx) * phase(nIdx,qq);
        u(:,qq,nIdx) = u(:,qq,nIdx) * phase(nIdx,qq);
    end
end
phi = phi ./ sqrt(sum(abs(phi).^2,1) * dx);
u = u ./ sqrt(sum(abs(u(cellIdx,:,:)).^2,1) * dx);

obj.BlochStateList = phi;
obj.BlochStatePeriodicList = u;

end

