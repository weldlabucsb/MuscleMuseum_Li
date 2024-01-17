function fitresult_b = fitDipoleTrap(data,nbin,initialGuess,climits,isDisp)
%fit_2D_bimodal Fits a subset of the matrix M to a condensate, extracting the
%absolute center of the cloud and its widths along radial and axial direcitons.
%Both the thermal and condensate components are considered here. See
%Ketterle <Making, probing and understanding BEC>, Eq. (44). Pay attention
%to the convention: the horizonal axis in each image is in y direction,
%which is the axial; the vertical aixs in each image is in x
%direction, which is the radial axis.
% Outputs:
% fitresult.od_c, OD of condensate
% fitresult.x0_c, condensate radial position
% fitresult.wx_c, condensate radial width
% fitresult.y0_c, condensate axial position
% fitresult.wy_c, condensate axial width
% fitresult.wx_t, thermal cloud radial width
% fitresult.wy_t, thermal cloud axial width
% fitresult.od_t, OD of thermal cloud

%% Fitting preparation.
tt = 0;
data = data(1:nbin:end,1:nbin:end);
imsizex = size(data,1);
imsizey = size(data,2);
xlist = 1:imsizex;
ylist = 1:imsizey;
[y,x,z] = prepareSurfaceData(ylist,xlist,data); %For surface fitting
[yy,xx] = meshgrid(ylist,xlist); %For plotting

% imagesc(flip(data,1))

%% Fitting
% Define bimodal function.
fitfun_b = fittype(@(od_c,x0_c,wx_c,y0_c,wy_c,wx_t,wy_t,od_t,theta,y,x) ...
    (od_c*max(0,1-(x.*cos(theta)+y.*sin(theta)-x0_c).^2/wx_c.^2-(-x.*sin(theta)+y.*cos(theta)-y0_c).^2/wy_c.^2).^1.5 ...
    +od_t*g2(exp(-(x.*cos(theta)+y.*sin(theta)-x0_c).^2/wx_t.^2-(-x.*sin(theta)+y.*cos(theta)-y0_c).^2/wy_t.^2))), ...
    'independent',{'y','x'},'dependent','z'); % Bimodal
options_b = fitoptions(fitfun_b);

% Now allow both to vary
iG = cell2mat(struct2cell(initialGuess));
options_b.StartPoint = iG;
options_b.Lower = zeros(1,9);
options_b.Lower(9) = -2*iG(9);
options_b.Upper = iG*2;
fitresult_b = fit([y,x],z,fitfun_b,options_b);
if isDisp
disp(fitresult_b)
end


fitdata = feval(fitresult_b,yy,xx);
center = round([fitresult_b.x0_c,fitresult_b.y0_c]);

if isDisp
    %% Plot experimental data
    figure(1);
    imagesc(flip(data,1));
    title(['Optical Depth, Experimental Data, t = ',num2str(tt),' ms'])
    xlabel('Axial (y) position in pixel')
    ylabel('Radial (x) position in pixel')
    colorbar
    caxis(climits);
    movegui('northwest')
    
    %% Plot fit result
    figure(2)
    imagesc(flip(fitdata,1))
    title(['Optical Depth, Fit Result, t = ',num2str(tt),' ms'])
    xlabel('Axial (y) position in pixel')
    ylabel('Radial (x) position in pixel')
    colorbar
    caxis(climits);
    movegui('north')
    
    %% PLot residual
    figure(3)
    imagesc(flip(fitdata-data,1))
    title(['Optical Depth, Fit Residual, t = ',num2str(tt),' ms'])
    xlabel('Axial (y) position in pixel')
    ylabel('Radial (x) position in pixel')
    colorbar
    caxis(climits);
    movegui('northeast')
    
    %% Plot radial distribution
    figure(4)
    plot(xlist,data(:,center(2)),xlist,fitdata(:,center(2)));
    xlabel('Radial (x) position in pixel')
    ylabel('Optical depth')
    title(['Radial Distribution At the Center, t = ',num2str(tt),' ms'])
    movegui('southwest')
    legend('Experimental Data','Fit Result')
    
    %% Plot axial distribution
    figure(5)
    plot(ylist,data(center(1),:),ylist,fitdata(center(1),:));
    xlabel('Axial (y) position in pixel')
    ylabel('Optical depth')
    title(['Axial Distribution At the Center, t = ',num2str(tt),' ms'])
    movegui('south')
    legend('Experimental Data','Fit Result')
end

end

