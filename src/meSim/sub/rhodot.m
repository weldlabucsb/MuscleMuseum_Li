function rhod = rhodot(H,rho,Gamma,d0)
%RHODOT Summary of this function goes here
%   Detailed explanation goes here
rhod = -1i*(H*rho-rho*H)+Gamma*(d0*rho*d0'-1/2*(d0'*d0*rho+rho*(d0'*d0)));
end

