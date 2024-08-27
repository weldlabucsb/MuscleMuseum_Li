function gaussian_gen
% gaussian_gen 


%% 1
% syms w0 k
% r = sym('r',[1,3]);
% direc = sym('direc',[1,2]);
% center = sym('direc',[1 3]);
% 
% x = r(1);
% y = r(2);
% z = r(3);
% lambda = 2*pi/k;
% zR = pi*w0^2/lambda;
% rho = sqrt(x^2+y^2);
% R = z*(1+(zR/z)^2);
% psi = atan(z/zR);
% w = w0*sqrt(1+(z/zR)^2);
% E = w0/w*exp(-rho^2/w^2)*exp(-1i*(k*z+k*rho^2/(2*R)-psi));
% gE = gradient(E,r);
% limE(r,k,w0) = limit(E,z,0);
% limgE= limit(gE,z,0);
% 
% E = piecewise(z==0,limE,E);
% gE = [piecewise(z==0,limgE(1),gE(1)),piecewise(z==0,limgE(2),gE(2)),piecewise(z==0,limgE(3),gE(3))];
% E(r,k,w0) = E;
% gE(r,k,w0) = gE;
% % gE2(r,k,w0)=gE;
% % E2(r,k,w0) = piecewise(z==0,limE,E);
% % gE2 = [piecewise(z==0,limgE(1),gE(1)),piecewise(z==0,limgE(2),gE(2)),piecewise(z==0,limgE(3),gE(3))];
% 
% theta = direc(1);
% phi = direc(2);
% c1 = cos(theta);
% s1 = sin(theta);
% c2 = cos(phi);
% s2 = sin(phi);
% A1 = [c1 0 -s1;0 1 0;s1 0 c1];
% A2 = [c2 s2 0;-s2 c2 0;0 0 1];
% A = A1*A2;
% rr = r - center;
% rr = (A*rr.').';
% E2 = E(rr(1),rr(2),rr(3),k,w0);
% gE2 = gE(rr(1),rr(2),rr(3),k,w0);
% % gE3 = [piecewise(rr(3)==0,limgE1(rr(1),rr(2),rr(3),k,w0),gE(1)),piecewise(rr(3)==0,limgE2(rr(1),rr(2),rr(3),k,w0),gE(2)),piecewise(rr(3)==0,limgE3(rr(1),rr(2),rr(3),k,w0),gE(3))];
% % gE3 = piecewise(rr(3)==0;
% gE2 = (A.'*gE2.').';
% 
% matlabFunction(gE2,'File','.\gaussian_grad','Vars',{r,w0,k,direc,center});
% matlabFunction(E2,'File','.\gaussian_prof','Vars',{r,w0,k,direc,center});

%% 2

syms w0 k
r = sym('r',[1,3]);
x = r(1);
y = r(2);
z = r(3);
lambda = 2*pi/k;
zR = pi*w0^2/lambda;
rho = sqrt(x^2+y^2);
R = z*(1+(zR/z)^2);
psi = atan(z/zR);
w = w0*sqrt(1+(z/zR)^2);
E = w0/w*exp(-rho^2/w^2)*exp(-1i*(k*z+k*rho^2/(2*R)-psi));
gE = gradient(E,[x y z]);
limE = limit(E,z,0);
limgE = limit(gE,z,0);
E = piecewise(z==0,limE,E);
gE = [piecewise(z==0,limgE(1),gE(1)),piecewise(z==0,limgE(2),gE(2)),piecewise(z==0,limgE(3),gE(3))];
matlabFunction(gE,'File','.\gaussian_grad','Vars',{r,w0,k});
matlabFunction(E,'File','.\gaussian_prof','Vars',{r,w0,k});

%% 3

% syms w0 k direc
% r = sym('r',[1,3]);
% x = r(1);
% y = r(2);
% z = r(3);
% z0 = direc*z;
% lambda = 2*pi/k;
% zR = pi*w0^2/lambda;
% rho = sqrt(x^2+y^2);
% R = z0*(1+(zR/z0)^2);
% psi = atan(z0/zR);
% w = w0*sqrt(1+(z0/zR)^2);
% E = w0/w*exp(-rho^2/w^2)*exp(-1i*(k*z0+k*rho^2/(2*R)-psi));
% gE = gradient(E,[x y z]);
% limE = limit(E,z,0);
% limgE = limit(gE,z,0);
% E = piecewise(z==0,limE,E);
% gE = [piecewise(z==0,limgE(1),gE(1)),piecewise(z==0,limgE(2),gE(2)),piecewise(z==0,limgE(3),gE(3))];
% matlabFunction(gE,'File','.\gaussian_grad','Vars',{r,w0,k,direc});
% matlabFunction(E,'File','.\gaussian','Vars',{r,w0,k,direc});
end
