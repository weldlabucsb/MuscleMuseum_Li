function A = cgmatrix(Jg,Je,sI)
%A = cgmat(Jg,Je,sI)
%Calculate the C-G matrices for a Jg to Je transition.
%"Jg" is the ground state elctronic angular momentum. "Je" is  
%the excited state elctronic angular momentum. "sI" is the
%nuclear spin quantum number. The output "A" is cell array.
%A{ii,jj,p} represents the C-G matrix of coupling between 
%Fg(ii) and Fe(jj) with p "polarization". Here p=1 is sigma
%minus coupling, p=2 is pi coupling, p=3 is sigma plus coupling.
%Fg(ii) is the iith total angular momentum quantum number of 
%the ground state. Similar for Fe(jj).
%
%The convention here for the state vector is that, the excited states
%is listed first and then the ground states. For K39 D1 system, the state
%vector is: [(F'=1,mF'=1);(F'=1,mF'=0);(F'=1,mF'=-1);(F'=2,mF'=2);
%(F'=2,mF'=1);(F'=2,mF'=0);(F'=2,mF'=-1);(F'=2,mF'=-2);(F=1,mF=1);(F=1,mF=0)
%(F=1,mF=-1);(F=2,mF=2);(F=2,mF=1);(F=2,mF=0);(F=2,mF=-1);(F=2,mF=-2)]
%
%Examples: 
%For K39 D1 line, Jg=0.5, Je=0.5, sI=1.5
%A=cgmat(0.5,0.5,1.5). To obtain C-G matrix of F=1 - F'=2 
%sigma plus coupling, one needs to call A{1,2,3}.
%
%For K40 D1 line, Jg=0.5, Je=0.5, sI=4
%A=cgmat(0.5,0.5,4). To obtain C-G matrix of F=9/2 - F'=7/2 
%pi coupling, one needs to call A{2,1,2}.


Fg=abs(sI-Jg):1:(sI+Jg); %List of total angular momentum of the ground state
Fe=abs(sI-Je):1:(sI+Je); %List of total angular momentum of the excited state

Ng=2*Fg+1; %List of number of substates of the ground state
Ne=2*Fe+1; %List of number of substates of the excited state
NN=sum(Ng)+sum(Ne); %Dimension of the Hilbert space of the Fg - Fe manifold
nhfg=size(Fg,2); %Number of different total angular momentums of the ground state
nhfe=size(Fe,2); %Number of different total angular momentums of the excited state

A=cell(nhfg,nhfe,3); 

for ii=1:nhfg
    for jj=1:nhfe 
        %C-G coefficients, calculated using qo toolbox developed by Dr. Tan. 
        %For more information, see "A Quantum Optics Toolbox for Matlab 5"
        %by Dr, Tan, page 32-33
        [am,a0,ap]= murelf(Fg(ii),Fe(jj),Jg,Je,sI); 

        B=zeros(NN);        
        Bm=mat2cell(B,[Ne,Ng],[Ne,Ng]);
        B0=mat2cell(B,[Ne,Ng],[Ne,Ng]);  
        Bp=mat2cell(B,[Ne,Ng],[Ne,Ng]);
        
        Bm{nhfe+ii,jj}=am;
        B0{nhfe+ii,jj}=a0;
        Bp{nhfe+ii,jj}=ap;
  
        A{ii,jj,1}=cell2mat(Bm);
        A{ii,jj,2}=cell2mat(B0);
        A{ii,jj,3}=cell2mat(Bp);           
    end
end

end

