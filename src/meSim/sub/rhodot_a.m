function rhod = rhodot_a(H,rho,Gamma,N,d0,Jg,Je)
%RHODOT Summary of this function goes here
%   Detailed explanation goes here
a = -1i*(H*rho-rho*H);
b = sparse(N,N);
for qq = 1:3
    b = b+d0{qq}*rho*d0{qq}'-1/2*(d0{qq}'*d0{qq}*rho+rho*(d0{qq}'*d0{qq}));
end
rhod = a + Gamma * (2*Je+1)/(2*Jg+1) * b;
end

