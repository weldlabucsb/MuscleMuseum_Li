function sixj = wignersixj(j1,j2,j3,l1,l2,l3)
% Calculate the Wigner 6-j symbole:
%{j1 j2 j3;l1 l2 l3}. See Steck's notes, page 306

if constraint(j1,j2,j3) && constraint(j1,l2,l3) && constraint(l1,j2,l3) && constraint(l1,l2,j3)
    J = j1+j2+j3;
    k1 = j1+l2+l3;
    k2 = l1+j2+l3;
    k3 = l1+l2+j3;
    m1 = j1+j2+l1+l2;
    m2 = j2+j3+l2+l3;
    m3 = j3+j1+l3+l1;
    nmin = max([J,k1,k2,k3]);
    nmax = min([m1,m2,m3]);  
    x = Delta(j1,j2,j3) * Delta(j1,l2,l3) * Delta(l1,j2,l3) * Delta(l1,l2,j3);
    y = 0;
    for n = nmin:nmax
        y = y + (-1)^n * factorial(n+1) / (factorial(n-J) * factorial(n-k1) * factorial(n-k2) * factorial(n-k3) * factorial(m1-n) * factorial(m2-n) * factorial(m3-n));
    end   
    sixj = x*y;   
else
    sixj = 0;
end

    function delta = Delta(a,b,c)
        delta = sqrt(factorial(a+b-c) * factorial(b+c-a) * factorial(c+a-b) / factorial(a+b+c+1));
    end

    function c = constraint(j1,j2,j3)
        c = abs(j1-j2)<=j3 && j3<=j1+j2 && abs(j1-j3)<=j2 && j2<=j1+j3 && abs(j3-j2)<=j1 && j1<=j3+j2;
    end
end

