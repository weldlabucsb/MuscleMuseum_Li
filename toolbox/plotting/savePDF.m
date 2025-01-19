function savePDF(h,filename)
%SAVEPDF Summary of this function goes here
%   Detailed explanation goes here
if nargin==1
    h = gcf;
end
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,filename,'-dpdf','-r0')
% print(h,filename,'-fillpage','-dpdf')
end 

