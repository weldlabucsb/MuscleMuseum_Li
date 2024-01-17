%%
B = MagneticField(bias=[0,0,720e-4]);
atom = Alkali("Lithium7");
[s,U1] = atom.D2Excited.BiasDressedStateList(B);
% ee = s.Energy + s.EnergyShift;
% hfs = atom.DGround.HFSCoefficient;
% a = hfs(1);
% b = hfs(2);

%%
I = 3/2;
J = 3/2;
nI = 2*I+1;
nJ = 2*J + 1;
U2 = uncoupledSpinBasisTransformation(J,I);
IO = spinMatrices(I);
JO = spinMatrices(J);
Iz = kron(eye(nJ),IO{3});
Jz = kron(JO{3},eye(nI));
mIList = diag(Iz);
mJList = diag(Jz);
mIList = round(2*mIList)/2;
mJList = round(2*mJList)/2;

nn = nI*nJ;
U3 = zeros(nn,nn);
kk = 1;
for ii = 1:nn
        mI = mIList(ii);
        mJ = mJList(ii);
        idx = s(abs(s.MI - mI)<1e-10 & abs(s.MJ - mJ)<1e-10,:).Index;
        U3(:,idx) = U2(:,kk);
        kk = kk + 1;
end

