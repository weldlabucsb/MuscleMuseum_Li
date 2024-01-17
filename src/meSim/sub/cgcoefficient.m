function cg = cgcoefficient(j1,m1,j2,m2,j3,m3)
% Calculate the C-G coefficient <j1,m1;j2,m2|j3,m3>. See Steck's notes 
% Eq. (7.51)

if (m3~=(m1+m2)) || (j3<abs(j1-j2)) || (j3 > j1+j2) || abs(m1)>j1 || abs(m2)>j2 || abs(m3)>j3
    cg = 0;
else
    nmin = max([j2-j3-m1,j1+m2-j3,0]);
    nmax = min([j1-m1,j2+m2,j1+j2-j3]);
    a = sqrt(factorial(j1+j2-j3) * factorial(j1+j3-j2) * factorial(j2+j3-j1) / factorial(j1+j2+j3+1));
    b = sqrt((2*j3+1) * factorial(j1+m1) * factorial(j1-m1) * factorial(j2+m2) * factorial(j2-m2) * factorial(j3+m3) * factorial(j3-m3));
    c = 0;
    for n = nmin:nmax
        c = c + (-1)^n / (factorial(j1-m1-n) * factorial(j3-j2+m1+n) * factorial(j2+m2-n) * factorial(j3-j1-m2+n) * factorial(j1+j2-j3-n) * factorial(n));
    end
    cg = a*b*c;
end

end

