function freq = computeTransitionFrequency1D(obj,q,n1,n2)
% Compute transition frequencies between Bloch states.
% q: Quasimomentum [p/hbar] in unit of 1/meter. q can be a 1 * N array
% n1: The band index 1. Start from zero. So n = 0 means the s band.
% n2: The band index 2.
% freq: The transition frequencies. If q is an array, freq is also an
% array with the same size.
arguments
    obj OpticalLattice
    q double {mustBeVector}
    n1 double {mustBeVector,mustBeInteger,mustBeNonnegative}
    n2 double {mustBeVector,mustBeInteger,mustBeNonnegative}
end
E = obj.computeBand1D(q,[n1,n2]);
freq = abs(E(2,:) - E(1,:));
end