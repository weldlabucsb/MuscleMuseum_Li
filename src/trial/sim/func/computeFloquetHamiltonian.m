function HF = computeFloquetHamiltonian(H,T,nt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
arguments
    H function_handle
    T double {mustBeScalarOrEmpty,mustBePositive}
    nt double {mustBePositive,mustBeInteger} = 20
end
% Check if H is a matrix valued function
try
    dim = size(H(0),1);
catch
    error("H must be a matrix valued function handle")
end

tList = linspace(0,T,nt);
tList(end) = [];
dt = tList(2) - tList(1);
U = eye(dim);
for tt = 1:(nt-1)
    t = tList(tt);
    U = expm(-1i * 2 * pi * H(t) * dt) * U;
end
HF = 1i * logm(U) / T / 2 / pi; %In unit of Hz
HF = (HF + HF') / 2; %make it Hermitian

end

