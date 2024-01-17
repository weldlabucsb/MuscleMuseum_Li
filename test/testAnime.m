close all
data = rand(10,10,5)*250;
% data = uint8(data);
F(5) = struct('cdata',[],'colormap',[]);
f = figure;

for ii = 1:5
    imagesc(gca,data(:,:,ii))
    drawnow;
    F(ii) = getframe(f);
end
figure
m = movie(F,1,1);