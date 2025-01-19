function [E,grad] = gaussiantr(r,w0,k,direc,center)
rr = r-center;
theta = direc(1);
phi = direc(2);
c1 = cos(theta);
s1 = sin(theta);
c2 = cos(phi);
s2 = sin(phi);
A1 = [c1 0 -s1;0 1 0;s1 0 c1];
A2 = [c2 s2 0;-s2 c2 0;0 0 1];
A = A1*A2;
rr = (A*rr.').';
E = gaussian_prof(rr,w0,k);
grad = gaussian_grad(rr,w0,k);
grad = (A.'*grad.').';
end

