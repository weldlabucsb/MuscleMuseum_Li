function [date1,date2,mm,dd,yyyy] = dateDetail(date)
%TODAY Summary of this function goes here
%   Detailed explanation goes here
date1 = date;
mm = num2str(month(date),'%02u');
dd = num2str(day(date),'%02u');
yyyy = num2str(year(date));
date2 = [mm,num2str(day(date),'%02d'),yyyy(3:4)];
end

