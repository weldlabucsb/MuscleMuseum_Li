function ax = renderSubplot(nSub,isSpin1)
%RENDERSUBPLOT Summary of this function goes here
%   Detailed explanation goes here
ax = gobjects(1,3);
labels = ["$m=+1$","$m=0$","$m=-1$"];
for iSub = 1:nSub
    ax(iSub) = subplot(nSub,1,iSub);
    pos = ax(iSub).Position;
    pos(1) = pos(1)+0.01;
    pos(2) = pos(2)+0.01*iSub;
    pos(4) = pos(4)-0.01;
    ax(iSub).Position = pos;
    yPos = pos(2);
    height = pos(4);
    if isSpin1
        annotation('textbox', [0.01, yPos+height/2, 0, 0], 'string', labels(iSub),'interpreter','latex','fontsize',13)
    end
end
end

