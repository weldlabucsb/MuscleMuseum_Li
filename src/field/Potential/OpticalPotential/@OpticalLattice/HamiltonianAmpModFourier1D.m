function H = HamiltonianAmpModFourier1D(obj,q,wf)
%HAMILTONIANMOD Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj OpticalLattice
    q double
    wf Waveform
end
nMax = obj.BandIndexMaxFourier;
V0 = obj.Depth / obj.RecoilEnergy;
kL = obj.Laser.AngularWavenumber;
jVec = 1-nMax:2:nMax-1;
trigMat = -gallery('tridiag',nMax,1,2,1);
modFunc = wf.TimeFunc;
Hp = diag((jVec + q / kL).^2);
HV0 = trigMat * V0 / 4;
H = @(t) HFunc(t);
    function Htotal = HFunc(t)
        HV = HV0 * (1 + modFunc(t));
        Htotal = Hp + HV;
    end
end

