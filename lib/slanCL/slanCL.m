function colorList=slanCL(type,num)
% @author : slandarer
% -----------------------
% type : type of color list
% num  : number of colors
if nargin<2
    num=[];
end
if nargin<1
    type=1;
end
slanCL_Data=load('slanCL_Data.mat');
% disp(slanCL_Data.Author);
colorList=slanCL_Data.Color{type}./255;
N=size(colorList,1);
if isempty(num)
else
    colorList=colorList(mod(num-1,N)+1,:);
    colorList=colorList.*(.9.^(floor((num-1)./N).'));
end
end