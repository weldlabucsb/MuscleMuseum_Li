function [Hal,gradH] = hamiltonian_al(N,nlaser,Omega,Delta,phi,direc,center,w0,k,waveform,d,r,t)
%HAMILTONIAN_AL Summary of this function goes here
%   Detailed explanation goes here
Hal = zeros(N);
gradH = {Hal,Hal,Hal};
for kk=1:nlaser
    switch waveform(kk)
        case 1
            Hal = Hal+Omega(kk)/2*d{kk}*exp(1i*Delta(kk)*t+1i*phi(kk)-1i*k*direc{kk}*r.'); %the atom-laser couping Hamiltonian
            for ii =1:3
                gradH{ii} = gradH{ii}+1/2*Omega(kk)*exp(1i*Delta(kk)*t+1i*phi(kk)-1i*k*direc{kk}*r.')*d{kk}*(-1i*k*direc{kk}(ii)); %the gradient for the Hamiltonian
            end
        case 2
            [amp,gd] = gaussiantr(r,w0(kk),k,direc{kk},center{kk});
            %                             gd =gaussian_grad(r,w0(kk),k,direc{kk},center{kk});
            %                             amp = gaussian_prof(r,w0(kk),k,direc{kk},center{kk});
            Hal = Hal+Omega(kk)/2*d{kk}*exp(1i*Delta(kk)*t+1i*phi(kk))*amp; %the atom-laser couping Hamiltonian
            for ii = 1:3
                gradH{ii} = gradH{ii}+1/2*Omega(kk)*exp(1i*Delta(kk)*t+1i*phi(kk))*d{kk}*gd(ii); %the gradient for the Hamiltonian
            end
    end
end
Hal=Hal+Hal';
for ii =1:3
    gradH{ii} = gradH{ii}+gradH{ii}';
end
end

