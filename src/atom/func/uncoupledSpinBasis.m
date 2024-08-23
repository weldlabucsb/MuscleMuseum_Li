function b = uncoupledSpinBasis(j1,mj1,j2,mj2)
%uncoupledSpinBasis Convert coupled spin basis to uncoupled.
%   j1 and j2 couple to get j3. Get the uncoupled angular
%   momentum spin eigen-basis |j1,mj1,j2,mj2> under the j3 basis |j3,mj3>

j3 = totalAngularMomentum(j1,j2);
j3List = angularMomentumList(j3);
mj3List = magneticAngularMomentum(j3);
nn = numel(mj3List);
b = zeros(nn,1);
for ii = 1:nn
    if mj3List(ii) == mj1 + mj2
        b(ii) = cgcoefficient(j1,mj1,j2,mj2,j3List(ii),mj3List(ii));
    end
end
end

