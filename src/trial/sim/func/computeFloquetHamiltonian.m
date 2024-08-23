function HF = computeFloquetHamiltonian(H,T)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
arguments
    H function_handle
    T double {mustBeScalarOrEmpty}
end
nt = 1e3;
tList = linspace(0,T,nt);
tList(end) = [];
dt = tList(2) - tList(1);
dim = size(H(0),1);
U = eye(dim);
for tt = 1:(nt-1)
    t = tList(tt);
    Ht = H(t);
    U = expm(-1i * Ht * dt) * U;
end
HF = 1i * logm(U) / T;

end

