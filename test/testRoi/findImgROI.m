function [Rload0,ROItrim,vec]=findImgROI(theta,ROI,width0,height0)
%FINDIMGROI Summary of this function goes here
%   Detailed explanation goes here

doDebug=0;
%% Definition
R=@(theta) [cosd(-theta) -sind(-theta);
    sind(-theta) cosd(-theta)];
findCorners=@(width,height) ...
    ceil([-width width width -width;
        -height -height height height]/2); 
findCenter=@(width,height) ...
    ceil([width;height]/2);

%% 
c0=findCenter(width0,height0);          % Center of original
e0=findCorners(width0,height0);         % Corners of original
e1=R(theta)*e0;                         % Corners in rotated frame
c1=ceil([max(e1(1,:))-min(e1(1,:)); ... % Center of rotated image
    max(e1(2,:))-min(e1(2,:))]/2);

Ratomv1=[ROI(3) ROI(4) ROI(4) ROI(3);    % ROI vector in rotated frame
    ROI(1) ROI(1) ROI(2) ROI(2)]+repmat([1;1],[1 4]);

Ratomv0=repmat(c0,[1 4])+...             % ROI vector in original frame
    R(-theta)*(Ratomv1-repmat(c1,[1 4]));

Rload0=[min(Ratomv0(2,:)) ...           % ROI to load image which includes
    max(Ratomv0(2,:)) ...                % the rotated ROI
    min(Ratomv0(1,:)) ...
    max(Ratomv0(1,:))];

Rloadv0=[Rload0(3) Rload0(4) ...        % ROI to load vector
    Rload0(4) Rload0(3);
    Rload0(1) Rload0(1) ...
    Rload0(2) Rload0(2)];

Rloadv1=R(theta)*(Rloadv0-repmat(c0,[1 4]));

%% Trim ROI
width=Rload0(4)-Rload0(3);
height=Rload0(2)-Rload0(1);
width2=ROI(4)-ROI(3);
height2=ROI(2)-ROI(1);

e1bar=floor([-width width width -width;
        -height -height height height]/2);    
e2bar=R(theta)*e1bar;
c2=ceil([max(e2bar(1,:))-min(e2bar(1,:)); ...
    max(e2bar(2,:))-min(e2bar(2,:))]/2);

ROItrim=[c2(2)-height2/2 c2(2)+height2/2 ...
    c2(1)-width2/2 c2(1)+width2/2];
ROItrim=ROItrim+[1 1 0 0];

if ROItrim(1)<1
    ROItrim(1)=1;
end
if ROItrim(3)<1
    ROItrim(3)=1;
end
%% Other
vec=struct;
vec.c1=c1;
vec.e1=e1;
vec.Ratomv1=Ratomv1;
vec.c2=c2;
vec.Rloadv1=Rloadv1;

%% 
if doDebug
    figure(1);
    clf
    subplot(221)
    axis equal tight

    hold on
    plot(e0(1,:)+c0(1),e0(2,:)+c0(2),'ko--','MarkerFaceColor','k');
    plot(Ratomv0(1,:),Ratomv0(2,:),'ko--','MarkerFaceColor','b');
    plot(Rloadv0(1,:),Rloadv0(2,:),'ko--','MarkerFaceColor','g');
    xlim([-5 width0+5]);
    ylim([-5 height0+5]);

    subplot(222)
    axis equal tight

    hold on
    p1=plot(e1(1,:)+c1(1),e1(2,:)+c1(2),'ko--','MarkerFaceColor','k');
    plot(Ratomv0(1,:),Ratomv0(2,:),'ko--','MarkerFaceColor','b');
    xlim([min(p1.XData) max(p1.XData)])
    ylim([min(p1.YData) max(p1.YData)])

    subplot(223)
    axis equal tight

    hold on
    plot(e0(1,:)+c0(1),e0(2,:)+c0(2),'ko--','MarkerFaceColor','k');
    plot(Ratomv0(1,:),Ratomv0(2,:),'ko--','MarkerFaceColor','b');
    plot(Rloadv0(1,:),Rloadv0(2,:),'ko--','MarkerFaceColor','g');
    xlim([Rload0(3) Rload0(4)]);
    ylim([Rload0(1) Rload0(2)]);

    subplot(224)
    axis equal tight
    hold on
    A=zeros(height0,width0);
    A=imrotate(A,theta);
    A(ROI(1):ROI(2),ROI(3):ROI(4))=1;
    imagesc(A);
    plot(Ratomv1(1,:),Ratomv1(2,:),'ko--','MarkerFaceColor','b');

end
end

