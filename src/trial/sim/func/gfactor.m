function gJ = gfactor(gS,gL,S,L,J)
%GFACTOR Summary of this function goes here
%   Detailed explanation goes here
if J == 0
    gJ = 0;
else
gJ = gL + (gS-gL).*(J.*(J+1)+S.*(S+1)-L.*(L+1))./(2.*J.*(J+1));
end
end

