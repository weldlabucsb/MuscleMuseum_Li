function output = decompfactor(Jg,Je,k,Fe,Fg,I)
output = (-1)^(Fe+Jg+k+I) * sqrt((2*Fe+1)*(2*Jg+1)) * wignersixj(Jg,Je,k,Fe,Fg,I);
end

