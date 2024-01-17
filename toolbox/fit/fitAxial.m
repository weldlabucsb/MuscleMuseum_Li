function fitResult = fitAxial(y,axialDist)

fitfun  = fittype(@(a,y0,c,yc,yy) a*3/8*pi*(((yy-yc)./y0).^2-1).^2+c,'independent','yy');
options = fitoptions(fitfun);
iG = [max(axialDist),(max(y)-min(y))/2,(axialDist(1)+axialDist(end))/2,50];
options.StartPoint = iG;
options.Lower = [0,0,0,0];
options.Upper = iG*2;

y = reshape(y,[],1);
axialDist = reshape(axialDist,[],1);
fitResult = fit(y,axialDist,fitfun,options);
end

