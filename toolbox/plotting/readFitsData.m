function data = readFitsData(path,prefix,index)
fileName = fullfile(path,[prefix,num2str(index),'.fits']);
if exist(fileName,'file')
    data = fitsread(fileName);
else 
    data = [];
end
end

