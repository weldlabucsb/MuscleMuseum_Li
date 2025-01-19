% x = 0:0.01:10;
% x0 = 3.5;
% y = (tanh((x - x0) * pi) + 1)/2;
% y = 1-y;
% y = y.*sin(x * 10 * pi);
% plot(x,y) 
x = -10:10; 
y = [repmat(-1,1,10) 0 repmat(1,1,10)]; 
xq1 = -10:.01:10;
p = pchip(x,y,xq1);
s = spline(x,y,xq1);
m = makima(x,y,xq1);
plot(x,y,'o',xq1,p,'-',xq1,s,'-.',xq1,m,'--')
render