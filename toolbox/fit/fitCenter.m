function [y0,wy] = fitCenter(data)

%FITCENTER Summary of this function goes here
%   Detailed explanation goes here
[a,b] = size(data);
fitFun = fittype(@(od,x0,wx,c,x) od.*(max(1-((x-x0).^2)./wx.^2-c,0)).^(3/2),...
    'independent','x');
fitOption1 = fitoptions(fitFun);
fitOption1.StartPoint = [1,a/2,a/2,0.1];
fitOption1.Lower = [0,0,0,0];
fitOption1.Upper = [3,a,a*2,1];
fitOption1.MaxFunEvals = 6000;
fitOption1.MaxIter = 6000;
fitOption1.TolFun = 10^-8;
fitOption1.TolX = 10^-8;

fitOption2 = fitoptions(fitFun);
fitOption2.StartPoint = [1,b/2,b/2,0.1];
fitOption2.Lower = [0,0,0,0];
fitOption2.Upper = [3,b,b*2,1];
fitOption2.MaxFunEvals = 6000;
fitOption2.MaxIter = 6000;
fitOption2.TolFun = 10^-8;
fitOption2.TolX = 10^-8;

th = 2;
x0 = a/2;
y0 = b/2;
nfits = 0;
while th>0.5 && nfits < 50
    y0_old = y0;
    fitOption1.StartPoint = [1,x0,a/2,0.1];
    
    fitY = interp2(data,y0,1:a);
    fitResult = fit((1:a)',fitY,fitFun,fitOption1);
    x0 = fitResult.x0;
%     plot(fitResult,(1:a)',data(:,round(y0)))
    fitOption2.StartPoint = [1,y0,a/2,0.1];
    
%     pause(1)
    
    fitY = interp2(data,1:b,x0);
    fitResult = fit((1:b)',fitY',fitFun,fitOption2);
    y0 = fitResult.x0;
    th = abs(y0-y0_old);
    nfits = nfits+1;
%     plot(fitResult,(1:b)',data(round(x0),:)')
    
%     pause(1)
%     disp(y0)
end
wy = fitResult.wx;
end

