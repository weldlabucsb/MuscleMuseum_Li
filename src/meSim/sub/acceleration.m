function a = acceleration(gradH,rho0,hbaroverm)
%ACCEL Summary of this function goes here
%   Detailed explanation goes here
a = zeros(1,3); %Acceleration
b = zeros(1,3); %Random fluctuation
for ii=1:3
    a(ii) = trace(rho0*gradH{ii});
    b(ii) = randn*sqrt(trace(rho0*gradH{ii}^2)-a(ii)^2);
end
a = -hbaroverm*(a+b);
end
