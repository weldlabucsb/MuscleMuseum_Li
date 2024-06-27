function pop = computeBandPopulationFourier1D(obj,ucj,q,n)
% Calculate band population for wavefunction u.
% ucj: The conjugate of the Fourier space wave function u.
% ucj is assumed to be a nu * nFourierComponent
% matrix, where nu the number of wavefunctions we want to
% compute band population.
% q: The sampling quasi-momentum in unit of 1/meter. 
% n: Maximum band index. By default we calculate up to the d
% band.
% pop: Output band population as a nu * (n+1) * nq matrix.
arguments
    obj OpticalLattice
    ucj double
    q double {mustBeVector} = 0
    n double {mustBeInteger,mustBeNonnegative} = 2
end

%% Input validation
if ~ismatrix(ucj)
    error("Incorrect dimension of ucj.")
else
    nMax = size(ucj,2);
end

if numel(q) > 1
    if numel(q) ~= size(ucj,1)
        error("Incorrect dimension of q")
    end
end

%% Get bands
[~,Fjn] = obj.computeBand1D(q,0:(nMax - 49)/2 - 1);

%% Renormalize ucj
lambda = obj.Laser.Wavelength;
ucj = ucj ./ sqrt(sum(ucj .* conj(ucj),2));
ucj = ucj * sqrt(2 / lambda);

%% Compute population
pop = zeros(size(ucj,1),n+1);
if numel(q) == 1
    for nIdx = 1:(n+1)
        pop(:,nIdx) = abs(ucj * Fjn(:,nIdx)).^2;
    end
else
    for nIdx = 1:(n+1)
        for qIdx = 1:numel(q)
            pop(qIdx,nIdx) = abs(ucj(qIdx,:) * Fjn(:,nIdx,qIdx)).^2;
        end
    end
end
pop = pop * lambda^2 / 4;

end