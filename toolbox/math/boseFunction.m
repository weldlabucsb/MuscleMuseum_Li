function g = boseFunction(z,p)
%g2 Bose function
%   Polynomial approximate formula

g = 0;
for l = 1:10000
    g = g + z.^l ./ l.^p; 
end

end

