function fitResult = fitMagSoliton(y,magData,isPostive)
%FITMAGSOLITON Summary of this function goes here
%   Detailed explanation goes here
if isPostive
    fitFun = fittype(@(U,xi_s,x_c,x) sqrt(1-U.^2)./cosh(sqrt(1-U.^2).*(x-x_c)./xi_s),'independent','x');
else
    fitFun = fittype(@(U,xi_s,x_c,x) -sqrt(1-U.^2)./cosh(sqrt(1-U.^2).*(x-x_c)./xi_s),'independent','x');
end
options = fitoptions(fitFun);
options.StartPoint = [0.9,1,y(round(numel(y)/2))];
options.Lower = [0,0,y(1)];
options.Upper = [1,2,y(end)];
y = reshape(y,[],1);
magData = reshape(magData,[],1);
fitResult = fit(y,magData,fitFun,options);
end

