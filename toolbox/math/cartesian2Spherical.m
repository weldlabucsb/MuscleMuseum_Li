function sVec = cartesian2Spherical(cVec)
%CART Summary of this function goes here
%   Detailed explanation goes here
if numel(cVec) == 3
    sVec = [sphericalBasisComponent(cVec,1);...
        sphericalBasisComponent(cVec,0);...
        sphericalBasisComponent(cVec,-1)];
    sVec = reshape(sVec,size(cVec));
else
    error("Vector size must be 3")
end
end

