function writebinblock2(device,data,precision,header)
%WRITEBINBLOCK2 Summary of this function goes here
%   This function will mimic the behavior of the old binblockwrite
%   function. MATLAB's new writebinblock function can not include the
%   header, that's why I write this function.
arguments
    device
    data
    precision
    header = []
end
%% Change data precision
if ~isa(data,precision)
    if isa(data,'numeric')
        data = typecast(data,precision);
    else
        switch precision
            case "uint8"
                data = uint8(data);
        end
    end
end

%% Construct header
binblockHeader = ['#' , num2str(numel(num2str(numel(data)))) , num2str(numel(data))];
if ~isempty(header)
    header = char(header);
    binblockHeader = [header,binblockHeader];
end
switch precision
    case "uint8"
        binblockHeader = uint8(binblockHeader);
end

%% Write into the device
write(device,[binblockHeader,data],precision)

end

