function rdir = angdist(pol)
%ANGDIST Summary of this function goes here
%   Detailed explanation goes here
while 1
    rnd = rand(1,3);
    rnd = rnd*2-1;
    r = norm(rnd);
    rdir = rnd/r;
    if r>1
        continue
    elseif r^3 <= (1-abs(pol*rdir')^2)
        return
    end
end
end

