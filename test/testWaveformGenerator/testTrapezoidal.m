x = 0:0.1:10;
m = 1;
l = 0;
c = 1/2;
a = 1;
w = a/pi * (asin(sin((pi/m)*x+l))+acos(cos((pi/m)*x+l)))-a/2+c;
w = a/pi * (asin(sin((pi/m)*x+l)))-a/2+c
plot(x,w)