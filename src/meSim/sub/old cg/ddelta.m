function D = ddelta(a,b,c)
D = factorial(a+b-c)*factorial(b+c-a)*factorial(c+a-b)/factorial(a+b+c+1);