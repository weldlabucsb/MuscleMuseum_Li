function [Hal,gradH] = hamiltonian_al_a(N,nlaser,Omega,Delta,phi,direc,center,w0,k,waveform,pol,d,ee,r,t)
%HAMILTONIAN_AL Summary of this function goes here
%   Detailed explanation goes here
Hal = sparse(N,N);
gradH = {Hal,Hal,Hal};
for kk=1:nlaser
    switch waveform(kk)
        case 1
            for qq = 1:3
                Hal = Hal+Omega(kk)/2*d{kk,qq}*(pol{kk}*ee{qq}')*exp(1i*Delta(kk)*t+1i*phi(kk)-1i*k*direc{kk}*r.'); %the atom-laser couping Hamiltonian
            end
            for ii =1:3
                for qq = 1:3
                    gradH{ii} = gradH{ii}+1/2*Omega(kk)*d{kk,qq}*(pol{kk}*ee{qq}')*exp(1i*Delta(kk)*t+1i*phi(kk)-1i*k*direc{kk}*r.')*(-1i*k*direc{kk}(ii)); %the gradient for the Hamiltonian
                end
            end
        case 2
            [amp,gd] = gaussiantr(r,w0(kk),k,direc{kk},center{kk});
            %                             gd =gaussian_grad(r,w0(kk),k,direc{kk},center{kk});
            %                             amp = gaussian_prof(r,w0(kk),k,direc{kk},center{kk});
            for qq = 1:3
                Hal = Hal+Omega(kk)/2*d{kk,qq}*(pol{kk}*ee{qq}')*exp(1i*Delta(kk)*t+1i*phi(kk))*amp; %the atom-laser couping Hamiltonian
            end
            for ii = 1:3
                for qq = 1:3
                    gradH{ii} = gradH{ii}+1/2*Omega(kk)*d{kk,qq}*(pol{kk}*ee{qq}')*exp(1i*Delta(kk)*t+1i*phi(kk))*gd(ii); %the gradient for the Hamiltonian
                end
            end
    end
end
Hal=Hal+Hal';
for ii =1:3
    gradH{ii} = gradH{ii}+gradH{ii}';
end
end

