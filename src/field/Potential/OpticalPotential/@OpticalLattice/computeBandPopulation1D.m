function pop = computeBandPopulation1D(obj,psicj,n,x)
% Calculate band population for wavefunction psi.
% psicj: The wavefunctions. It is recommended to input the
% conjugate of psi. psicj is assumed to be a npsi * length(x)
% matrix, where npsi the number of wavefunctions we want to
% compute band population.
% n: Maximum band index. By default we calculate up to the d
% band.
% x: The sampling 1D spatial grids in unit of meter. Must be
% the same size as the wave function.
% pop: Output band population as a npsi * n+1 matrix.
arguments
    obj OpticalLattice
    psicj double
    n double {mustBeInteger,mustBeNonnegative} = 2
    x double {mustBeVector} = []
end

%% Input validation
if ~ismatrix(psicj)
    error("Incorrect dimension of psi.")
elseif isempty(x)
    if ~isempty(obj.SpaceList)
        nx = numel(obj.SpaceList);
    else
        error("Need to specify x.")
    end
else
    nx = numel(x);
end
if size(psicj,1) == nx
    psicj = psicj'; % The spatial dimension of psi must be the second dimension.
elseif size(psicj,2) ~= nx
    error("Incorrect dimension of psi.")
end

%% Get bands
if ~isempty(x)
    dx = x(2) - x(1); % Spatial grid size
    kL = obj.Laser.AngularWavenumber;
    dk = 2 * pi / numel(x) / dx; % Momentum grid size
    q = -kL:dk:kL; % Sampling quasi-momentum
    [~,~,phi] = obj.computeBand1D(q,0:n,x);
else
    phi = obj.BlochStateList;
    if n > max(obj.BandIndexMax)
        error("n is too large. Change BandIndexMax or reset n.")
    end
end

%% Compute population
pop = zeros(size(psicj,1),n+1);
for nIdx = 1:(n+1)
    pop(:,nIdx) = sum(abs(psicj * phi(:,:,nIdx) * dx).^2,2);
end

end