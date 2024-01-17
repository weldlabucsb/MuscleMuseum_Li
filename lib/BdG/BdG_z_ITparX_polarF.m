% Implicit imaginary time propagation method to figure out the ground state 
% wave function
MyPar = parpool('local',48);
%% parameters
n_Gmax = 15;
n_Bmax = 30;
dt = 1;
%
c0 = 500;
c2 = -0.005*c0;
q = 2*abs(c2);
%m = 0;
g = 0;
p = 0;
d0 = 20; % length of the box trap (assume infinite high square well)
%% propagation
% initial
phi_p0 = zeros(n_Gmax,1);
phi_p0(1) = 1/sqrt(3);
phi_z0 = zeros(n_Gmax,1);
phi_z0(1) = 1/sqrt(3);
phi_m0 = zeros(n_Gmax,1);
phi_m0(1) = 1/sqrt(3);
M = 0;
%%%%%%%%%%%%
psi_x = @(n,x) sqrt(2/d0).*sin(n*pi*x./d0);
syms x
%%%%%%%%%%%% Hamiltonian
index = 1:n_Gmax;
mode = 2*index - 1;
H_ed_one = spdiags((mode)'.^2*pi.^2/(2*d0^2),0,n_Gmax,n_Gmax);
V_p = zeros(n_Gmax,n_Gmax);
V_z = zeros(n_Gmax,n_Gmax);
V_m = zeros(n_Gmax,n_Gmax);
n_p = zeros(n_Gmax,n_Gmax);
n_z = zeros(n_Gmax,n_Gmax);
n_m = zeros(n_Gmax,n_Gmax);
F_p = zeros(n_Gmax,n_Gmax);
F_m = zeros(n_Gmax,n_Gmax);
%% main propagation process for searching the ground state
U_p = phi_p0;
U_z = phi_z0;
U_m = phi_m0;
mu_r = 100;
for time = 1:1000
    U = [U_p;U_z;U_m];
    H_ed = kron(sparse(1,1,1,3,3),H_ed_one + (-p+q)*speye(n_Gmax)) +...
           kron(sparse(2,2,1,3,3),H_ed_one) +...
           kron(sparse(3,3,1,3,3),H_ed_one + (p+q)*speye(n_Gmax));
    parfor j = 1:n_Gmax
        for i = 1:n_Gmax
            nl = mode(i);
            nr = mode(j);
            V_p(i,j) = IntegralD0(g,0,d0,nl,nr);
            V_z(i,j) = IntegralD0(g,0,d0,nl,nr);
            V_m(i,j) = IntegralD0(g,0,d0,nl,nr);
            n_p(i,j) = IntegralD1(conj(U_p),U_p,nl,nr,mode,d0);
            n_z(i,j) = IntegralD1(conj(U_z),U_z,nl,nr,mode,d0);
            n_m(i,j) = IntegralD1(conj(U_m),U_m,nl,nr,mode,d0);
            F_p(i,j) = IntegralD1(conj(U_z),U_m,nl,nr,mode,d0);
            F_m(i,j) = IntegralD1(conj(U_z),U_p,nl,nr,mode,d0);
        end
    end
    H_end = kron(sparse(1,1,1,3,3),V_p + (c0+c2)*n_p + (c0+c2)*n_z + (c0-c2)*n_m) + kron(sparse(1,2,1,3,3),c2*conj(F_p)) + ...
            kron(sparse(2,1,1,3,3),c2*F_p) + kron(sparse(2,2,1,3,3),V_z + (c0+c2)*n_p + c0*n_z + (c0+c2)*n_m) + kron(sparse(2,3,1,3,3),c2*F_m) +...
            kron(sparse(3,2,1,3,3),c2*conj(F_m)) + kron(sparse(3,3,1,3,3),V_m + (c0-c2)*n_p + (c0+c2)*n_z + (c0+c2)*n_m);
    %%%%%%%%%
    D = speye(3*n_Gmax) + H_ed*dt + H_end*dt;
    U = D\U;
    %%%%%%%%% normalization
    U = U./norm(U);
    U_p = U(1:n_Gmax);
    U_z = U(n_Gmax+1:2*n_Gmax);
    U_m = U(2*n_Gmax+1:3*n_Gmax);
    %%%%%%%%%%%%%%%%%%%%%%%%%
    res_M = sum((abs(U_p).^2-abs(U_m).^2));
    p = p - 0.05*(M - res_M);
    %%%%%%%%% ground state chemical potential
    mu = U'*(H_ed + H_end)*U;
    delta = mu - mu_r;
    %%%%%%%%%%%%% break condition
    if abs(delta) < 1e-7
        break
    else
        mu_r = mu;
    end
end
%delete(MyPar);
%% plot
phi_gp = sum(U_p(:).*psi_x(mode(:),x));
phi_gz = sum(U_z(:).*psi_x(mode(:),x));
phi_gm = sum(U_m(:).*psi_x(mode(:),x));
%% Bogoliubov excitation spectrum
%%%%%%%%%%%%%%%%%%%% parameters for excitation
m = 0*c0;
p = 0;
full_mode = 1:n_Bmax;
H_ed_one = spdiags((full_mode)'.^2*pi.^2/(2*d0^2),0,n_Bmax,n_Bmax);
%%%%%%%%%%%%%%%%%%%% eigen_H
H_bd = kron(sparse(1,1,1,3,3),H_ed_one + (-p + q - mu)*speye(n_Bmax)) +...
       kron(sparse(2,2,1,3,3),H_ed_one - mu*speye(n_Bmax)) +...
       kron(sparse(3,3,1,3,3),H_ed_one + (p + q - mu)*speye(n_Bmax));
%%%%%%%%%%%%%%%%%%%% non-eigen_H
V_p = zeros(n_Bmax,n_Bmax);
V_z = zeros(n_Bmax,n_Bmax);
V_m = zeros(n_Bmax,n_Bmax);
n_p = zeros(n_Bmax,n_Bmax);
n_z = zeros(n_Bmax,n_Bmax);
n_m = zeros(n_Bmax,n_Bmax);
F_p = zeros(n_Bmax,n_Bmax);
F_m = zeros(n_Bmax,n_Bmax);
F_z = zeros(n_Bmax,n_Bmax);
parfor j = 1:n_Bmax
    for i = 1:n_Bmax
        nl = i;
        nr = j;
        V_p(i,j) = IntegralD0(g,m,d0,nl,nr);
        V_z(i,j) = IntegralD0(g,0,d0,nl,nr);
        V_m(i,j) = IntegralD0(g,-m,d0,nl,nr);
        n_p(i,j) = IntegralD1(conj(U_p),U_p,nl,nr,mode,d0);
        n_z(i,j) = IntegralD1(conj(U_z),U_z,nl,nr,mode,d0);
        n_m(i,j) = IntegralD1(conj(U_m),U_m,nl,nr,mode,d0);
        F_p(i,j) = IntegralD1(conj(U_z),U_m,nl,nr,mode,d0);
        F_m(i,j) = IntegralD1(conj(U_z),U_p,nl,nr,mode,d0);
        F_z(i,j) = IntegralD1(conj(U_m),U_p,nl,nr,mode,d0);
    end
end
%%%%%%%%%%%%%
H_And = kron(sparse(1,1,1,3,3),V_p + (c0+c2)*n_p + (c0+c2)*n_z) + kron(sparse(1,2,1,3,3),c0*F_m + c2*conj(F_p)) + kron(sparse(1,3,1,3,3),(c0 - c2)*F_z) +...
        kron(sparse(2,1,1,3,3),c0*conj(F_m) + c2*F_p) + kron(sparse(2,2,1,3,3),V_z + 2*c0*n_z + c2*(n_p + n_m)) + kron(sparse(2,3,1,3,3),c0*conj(F_p) + c2*F_m) +...
        kron(sparse(3,1,1,3,3),(c0 - c2)*conj(F_z)) + kron(sparse(3,2,1,3,3),c0*F_p+c2*conj(F_m)) + kron(sparse(3,3,1,3,3),V_m + (c0+c2)*n_m + (c0+c2)*n_z);
%%%%%%%%%%%%%
H_Bnd = kron(sparse(1,1,1,3,3),(c0 + c2)*n_p) + kron(sparse(1,2,1,3,3),(c0 + c2)*F_m) + kron(sparse(1,3,1,3,3),c2*n_z + (c0 - c2)*F_z) +...
        kron(sparse(2,1,1,3,3),(c0 + c2)*F_m) + kron(sparse(2,2,1,3,3),c0*n_z + 2*c2*F_z) + kron(sparse(2,3,1,3,3), (c0 + c2)*F_p) +...
        kron(sparse(3,1,1,3,3),c2*n_z + (c0 - c2)*F_z) + kron(sparse(3,2,1,3,3),(c0 + c2)*F_p) + kron(sparse(3,3,1,3,3),(c0 + c2)*n_m);
%%%%%%%%%%%%%
%H_And = kron(sparse(1,1,1,3,3),V_p + (c0+c2)*n_z) + kron(sparse(2,2,1,3,3),V_z + 2*c0*n_z) + kron(sparse(3,3,1,3,3),V_m + (c0+c2)*n_z);
%%%%%%%%%%%%%
%H_Bnd = kron(sparse(1,3,1,3,3),c2*n_z) + kron(sparse(2,2,1,3,3),c0*n_z) + kron(sparse(3,1,1,3,3),c2*n_z);
%%%%%%%%%%%%% Bogoliubov matrix
M = kron(sparse(1,1,1,2,2),H_bd + H_And) + kron(sparse(1,2,1,2,2),H_Bnd) +...
    kron(sparse(2,1,1,2,2),-H_Bnd) + kron(sparse(2,2,1,2,2),-H_bd - H_And);
E_spectrum = eig(full(M));
E_sort = sort(E_spectrum(:),'ComparisonMethod','real');
disp(E_sort);
%% save
delete(MyPar)
save('BdG_E_spectrum_M.mat','U','E_spectrum');
%% functions
function D0 = IntegralD0(g,m,d0,nl,nr)
    %V = @(x) m*c0*x;
    intfunc = @(x) sin(nl*pi*x./d0).*(g*x + m*x).*sin(nr*pi*x./d0);
    D0 = 2/d0*integral(intfunc,0,d0);
end

function D1 = IntegralD1(a1,a2,nl,nr,mode,d0)
    %mode = 1:n_max;
    intfunc = @(x) kron(a1(:).*sin(mode(:)*pi*x./d0),a2(:).*sin(mode(:)*pi*x./d0)).*...
                   (sin(nl*pi*x./d0).*sin(nr*pi*x./d0));
    D1 = (2/d0).^2*sum(integral(intfunc,0,d0,'ArrayValue',true));
end