function fitresult = fitBeam(data,ROIsize,ROIcenter,nbin,initialGuess,climits,isDisp)
x1 = ROIcenter(1)-ROIsize(1)/2;
x2 = ROIcenter(1)+ROIsize(1)/2;
y1 = ROIcenter(2)-ROIsize(2)/2;
y2 = ROIcenter(2)+ROIsize(2)/2;
data = data(x1:nbin:x2,y1:nbin:y2); %Form the sub-matrix to be fit. Do coarse graining also.

imsizex = size(data,1);
imsizey = size(data,2);
xlist = 1:imsizex;
ylist = 1:imsizey;
[y,x,z] = prepareSurfaceData(ylist,xlist,data); %For surface fitting
[yy,xx] = meshgrid(ylist,xlist); %For plotting

%% Fitting
fitfun = fittype(@(I0,wx,wy,x0,y0,y,x) I0*exp(-2.*((x-x0).^2./wx.^2+(y-y0).^2./wy.^2)),'independent',{'y','x'},'dependent','z');
options = fitoptions(fitfun);
iG = cell2mat(struct2cell(initialGuess));

options.StartPoint = iG;
options.Lower = zeros(1,5);
options.Upper = 3*iG;
fitresult = fit([y,x],z,fitfun,options);
fitdata = feval(fitresult,yy,xx);


if isDisp
    disp(fitresult)
    %% Plot experimental data
    figure(1);
    imagesc(flip(data,1));
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
    imagesc(flip(fitdata,1))
    title('Fit Result')
    xlabel('Axial (y) position in pixel')
    ylabel('Radial (x) position in pixel')
    colorbar
    caxis(climits);
    movegui('north')
    
    %% PLot residual
    figure(3)
    imagesc(flip(fitdata-data,1))
    title('Fit Residual')
    xlabel('Axial (y) position in pixel')
    ylabel('Radial (x) position in pixel')
    colorbar
    climits = [-climits(2),climits(2)];
    caxis(climits);
    movegui('northeast')
    
end

end

