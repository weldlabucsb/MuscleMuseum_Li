function D = diffu(omega,delta,v)
%Caculate the diffusion on a two-level atom in a standing wave. omega,
%delta are Rabi frequency and detuning, in the unit of the natural
%linewidth Gamma. omega is the single laser beam Rabi frequency (not the
%standing wave Rabi frequency!). v is the velocity in the unit of Gamma/k
%where k is the wave number. The output is the diffusion in the unit of
%(hbar*k)^2*Gamma.

%We follow this paper:  Berg-Sorenson K, Castin Y, Bonderup E, et al.
%Momentum diffusion of atoms moving in laser fields[J]. Journal of Physics
%B: Atomic, Molecular and Optical Physics, 1992, 25(20): 4195.

%Our unit is Gamma=k=hbar=1.

omega = omega*2; %standing wave Rabi frquency

%A.10
Q0 = [-1,0,0;0,-1/2,-delta;0,delta,-1/2];
Qp = [0,0,-omega;0,0,0;omega/4,0,0];
Qm = Qp;
iden = eye(3);

N = 32; %Maximum iteration

%% Zeroth order equation
a0 = zeros(3,N);
a0(:,1) = [-1;0;0];
H0 = zeros(3,3,N);
r0 = zeros(3,N+1);
w0 = zeros(3,N);

%A.6
for ii = 0:N-2
    nn = N - ii;
    H0(:,:,nn-1) = (1i*(nn-1)*v*iden-Q0-Qm*H0(:,:,nn))^(-1)*Qp;
    r0(:,nn) = (1i*(nn-1)*v*iden-Q0-Qm*H0(:,:,nn))^(-1)*(Qm*r0(:,nn+1)-a0(:,nn));
end

w0(:,1) = (Q0+Qm*H0(:,:,1)+Qp*conj(H0(:,:,1)))^(-1)*(a0(:,1)-Qm*r0(:,2)-Qp*conj(r0(:,2))); %A.5

%A.4
for ii = 2:N
    w0(:,ii) = H0(:,:,ii-1)*w0(:,ii-1) + r0(:,ii);
end

%% First-order equation

%extend the zeroth-order result to have negative idexed values.
w0e = [conj(flip(w0,2)),w0];
w0e(:,N) = [];
w0e = [zeros(3,1),w0e,zeros(3,1)];

H1 = zeros(3,3,N);
r1 = zeros(3,N+1);
w1 = zeros(3,N);
FWm = zeros(1,N);
FWR = zeros(1,N);
FWI = zeros(1,N);

%A.13
for ii = 1:N
    for jj = 2:2*N
        nn = ii-1;
        mm = jj-N-1;
        if nn-mm > N-1 || nn-mm <1-N
            FWm(ii) = 0;
            FWR(ii) = 0;
            FWI(ii) = 0;
        else
            FWm(ii) = FWm(ii) + w0e(1,nn-mm+N+1) * (w0e(2,mm+N)-w0e(2,mm+N+2));
            FWR(ii) = FWR(ii) + w0e(2,nn-mm+N+1) * (w0e(2,mm+N)-w0e(2,mm+N+2));
            FWI(ii) = FWI(ii) + w0e(3,nn-mm+N+1) * (w0e(2,mm+N)-w0e(2,mm+N+2));
        end
    end
end

%A.12
a1 = [FWm;FWR;FWI];
a1 = 1i*omega/2*a1;
a1(2,2) = a1(2,2) - 1i*omega/8;

%A.6
for ii = 0:N-2
    nn = N - ii;
    H1(:,:,nn-1) = (1i*(nn-1)*v*iden-Q0-Qm*H1(:,:,nn))^(-1)*Qp;
    r1(:,nn) = (1i*(nn-1)*v*iden-Q0-Qm*H1(:,:,nn))^(-1)*(Qm*r1(:,nn+1)-a1(:,nn));
end

w1(:,1) = (Q0+Qm*H1(:,:,1)+Qp*conj(H1(:,:,1)))^(-1)*(a1(:,1)-Qm*r1(:,2)-Qp*conj(r1(:,2))); %A.5

%A.4
for ii = 2:N
    w1(:,ii) = H1(:,:,ii-1)*w1(:,ii-1) + r1(:,ii);
end

D = 1/4*(4*omega*imag(w1(2,2))+2/5*(1-w0(1,1))); %A.9

end