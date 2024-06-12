function qRes = computeTransitionQuasiMomentum1D(obj,freq,n1,n2)
% Compute transition frequencies between Bloch states.
% q: Quasimomentum [p/hbar] in unit of 1/meter. q can be a 1 * N array
% n1: The band index 1. Start from zero. So n = 0 means the s band.
% n2: The band index 2.
% freq: The transition frequencies. If q is an array, freq is also an
% array with the same size.
arguments
    obj OpticalLattice
    freq double {mustBeVector}
    n1 double {mustBeVector,mustBeInteger,mustBeNonnegative}
    n2 double {mustBeVector,mustBeInteger,mustBeNonnegative}
end
if ~isempty(obj.BandEnergy)
    E = obj.BandEnergy;
    q = obj.QuasiMomentumList;
else
    nq = 2^12;
    kL = obj.Laser.AngularWavenumber;
    q = linspace(-kL,kL,nq+1);
    q(end) = [];
    E = obj.computeBand1D(q,max([n1,n2]));
end

qIdx = q<=0;
q = q(qIdx);
E = E(:,qIdx);
dE = abs(E(n2+1,:) - E(n1+1,:));
bandDist = max(dE);
bandGap = min(dE);
tol = bandDist / 1e8;
err = tol * 10;
qRes = zeros(1,numel(freq));
for ii = 1:numel(freq)
    if freq(ii) > bandDist || freq(ii) < bandGap
        qRes(ii) = NaN;
    else
        [~,resIdx] = sort(abs(freq(ii) - dE));
        resIdx = resIdx(1:2);
        q1 = q(resIdx(1));
        q2 = q(resIdx(2));
        E1err = abs(dE(resIdx(1)) - freq(ii));
        E2err = abs(dE(resIdx(2)) - freq(ii));
        while err > tol
            qResTemp = (q1 + q2) / 2;
            EE = obj.computeBand1D(qResTemp,max([n1,n2]));
            Emid = abs(EE(n2+1,:) - EE(n1+1,:));
            err = abs(Emid - freq(ii));
            if E1err > E2err
                q1 = qResTemp;
                E1err = err;
            else
                q2 = qResTemp;
                E2err = err;
            end
        end
        qRes(ii) = qResTemp;
    end
end

qRes = -qRes;


end