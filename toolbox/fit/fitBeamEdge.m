function fitresult = fitBeamEdge(data,initialGuess,climits)
% x1 = ROIcenter(1)-ROIsize(1)/2;
% x2 = ROIcenter(1)+ROIsize(1)/2;
% y1 = ROIcenter(2)-ROIsize(2)/2;
% y2 = ROIcenter(2)+ROIsize(2)/2;
% data = data(x1:nbin:x2,y1:nbin:y2); %Form the sub-matrix to be fit. Do coarse graining also.
data = double(data);
imsizex = size(data,1);
imsizey = size(data,2);
xlist = 1:imsizex;
ylist = 1:imsizey;
[y,x,z] = prepareSurfaceData(ylist,xlist,data); %For surface fitting
[yy,xx] = meshgrid(ylist,xlist); %For plotting

%% Fitting
fitFun = fittype(@(I0,wx,wy,x0,y0,d,a,theta_e,theta_b,y,x) 1/2*(tanh((x.*cos(theta_e)+y.*sin(theta_e)-d)./a)+1).*...
    I0.*exp(-2.*((x.*cos(theta_b)+y.*sin(theta_b)-x0).^2./wx.^2+(-x.*sin(theta_b)+y.*cos(theta_b)-y0).^2./wy.^2)),...
    'independent',{'y','x'},'dependent','z');
options = fitoptions(fitFun);
iG = cell2mat(struct2cell(initialGuess));

options.StartPoint = iG;
options.Lower = [zeros(1,7),-3*iG(8),-3*iG(9)];
options.Upper = 3*iG;
fitresult = fit([y,x],z,fitFun,options);
fitdata = feval(fitresult,yy,xx);
disp(fitresult)

%% Plot experimental data
figure(1);
imagesc(data)
axis normal
title('Beam Profile Data')
xlabel('Axial (y) position in pixel')
ylabel('Radial (x) position in pixel')
colorbar
caxis(climits);
movegui('northwest')
cl = caxis;
climits = cl;

%% Plot fit result
figure(2)
imagesc(fitdata)
axis normal
title('Fit Result')
xlabel('Axial (y) position in pixel')
ylabel('Radial (x) position in pixel')
colorbar
caxis(climits);
movegui('north')

%% PLot residual
figure(3)
imagesc(fitdata-data)
axis normal
title('Fit Residual')
xlabel('Axial (y) position in pixel')
ylabel('Radial (x) position in pixel')
colorbar
climits = [-climits(2),climits(2)];
caxis(climits);
movegui('northeast')

end

