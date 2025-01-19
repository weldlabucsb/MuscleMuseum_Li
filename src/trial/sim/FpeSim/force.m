function F = force(omega,delta,v)
%Caculate the mean force on a two-level atom in a standing wave. omega,
%delta are Rabi frequency and detuning, in the unit of the natural
%linewidth Gamma. omega is the single laser beam Rabi frequency (not the
%standing wave Rabi frequency!). v is the velocity in the unit of Gamma/k
%where k is the wave number. The output is the force in the unit of
%hbar*k*Gamma.

%We follow this paper:  Minogin V G, Serimaa O T. Resonant light pressure
%forces in a strong standing laser wave[J]. Optics Communications, 1979,
%30(3): 373-379.

%Subtleties in this paper: 1. The Rabi frequency and natural linewdith in
%the paper have half of the values of the conventional definition. 2.
%Detuning is denoted as Omega instead of Delta.

%Our unit is Gamma=k=hbar=1.

V0 = omega/2;
G = 2*V0^2*4; %Eq.20
N = 2^7; %Maximum iteration

%Eq.19
p = zeros(1,N);
for nn = 0:N
    n1 = nn;
    n2 = nn;
    if mod(nn,2) == 0
        n1 = n1 + 1;
    else
        n2 = n2 + 1;
    end
    p(nn+1) = (1/2 + 1i.*n1.*v)./(1 + 1i.*n2.*v)./(delta.^2+(1/2+1i*n1.*v).^2);
end
p = G*p/2;

%Eq.18
p = flip(p);
Q = 0;
for ii = 1:numel(p)
    Q = p(ii)./(1+Q);
end

A = delta./(1/2+1i*v).*Q; %Eq.17
F = -imag(A)./(1+2.*real(Q)); %Eq.16a
end