function vecComp = sphericalBasisComponent(vec,q)
%SPHERICALBASISCOMPONENT Summary of this function goes here
%   Detailed explanation goes here
vecComp = dot(vec,sphericalBasis(q));
end

