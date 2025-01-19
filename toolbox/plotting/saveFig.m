function saveFig(parentPath,name,fig)
%SAVEFIG Summary of this function goes here
%   Detailed explanation goes here
arguments
    parentPath string
    name string
    fig = gcf
end
fig.Renderer = 'painters';
savefig(fig,fullfile(parentPath,name))
exportgraphics(fig,fullfile(parentPath,name)+".png",'Resolution',1000)
% savePDF(fig,fullfile(parentPath,name))
exportgraphics(fig,fullfile(parentPath,name)+".pdf",'ContentType','vector')
saveas(fig,fullfile(parentPath,name)+".svg",'svg')
% saveas(fig,fullfile(parentPath,name)+".eps",'epsc')
end

