function RabiMatrix = rabiMatrix(atom,laser,isAveraged,transition)
%Calculate the (reduced) Rabi-frequency using the atomic and laser
%properties

arguments
    atom
    laser
    isAveraged (1,1) = 0
    transition = 'D2';
end

Omega = rabi(atom,laser,isAveraged,transition); %Reduced Rabi frequency
pol = {laser.Polarization};
phi = [laser.Phase];
c = {laser.Coupling};
nlaser = numel(laser);
if transition == "D2"
    Sigma = atom.DipoleOperator{2};
    A = atom.JumpOperator{2};
else
    Sigma = atom.DipoleOperator{1};
    A = atom.JumpOperator{1};
end

N = size(Sigma{1},1);

% Spherical bases
ee = cell(1,3);
ee{1} = [1 -1i 0]/sqrt(2); %e_minus
ee{2} = [0 0 1]; %e_zero
ee{3} = -[1 1i 0]/sqrt(2);  %e_plus

% Laser coupling
Sigmal = cell(nlaser,3);
for ii = 1:nlaser
    if isempty(c{ii})
        for kk = 1:3
            Sigmal{ii,kk} = Sigma{kk};
        end
    else
        for kk = 1:3
            Sigmal{ii,kk} = sparse(N,N);
            for jj = 1:size(c{ii},1)
                Sigmal{ii,kk} = Sigmal{ii,kk} + A{c{ii}(jj,1),c{ii}(jj,2),kk};
            end
        end
    end
end


RabiMatrix = zeros(N);
for kk = 1:nlaser
    for qq = 1:3
        RabiMatrix = RabiMatrix+Omega(kk)*Sigmal{kk,qq}*(pol{kk}*ee{qq}')*exp(1i*phi(kk));
    end
end
RabiMatrix = RabiMatrix + RabiMatrix';
RabiMatrix = sparse(RabiMatrix);
end

