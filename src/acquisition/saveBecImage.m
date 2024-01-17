function saveBecImage(vid,~,becExp)
% saveBecImage saves acquired becExp images to drives and trigger the
% becExp's "NewRunFinished" event.
%
% saveImageData is a callback function fired by a videoinput
% FramesAvailable event. It typically acquires three images and saves them
% as "atom","light","dark", for the calculation of absorption and OD. After
% that, it transfers the data to becExp and triggers the event
% "NewRunFinished" for the following data analysis.

%% Get data from camera
mData = getdata(vid,3);

%% Name the data
nn = num2str(becExp.NCompletedRun + 1);
imageName = fullfile(becExp.DataPath,becExp.DataPrefix) + "_" + nn;
imageFormat = becExp.DataFormat;
imageLabel = ["_atom";"_light";"_dark"];

%% Write the data to files
for ii = 1:3
    fullFilePath = imageName + imageLabel(ii) + imageFormat;
    if imageFormat == ".tif"
        t = Tiff(fullFilePath,'w');
        setTag(t,'ImageWidth',becExp.Acquisition.ImageSize(1));
        setTag(t,'ImageLength',becExp.Acquisition.ImageSize(2));
        setTag(t,'Photometric',Tiff.Photometric.MinIsBlack)
        setTag(t,'BitsPerSample',16);
        setTag(t,'SamplesPerPixel',1);
        setTag(t,'Compression',Tiff.Compression.None);
        setTag(t,'PlanarConfiguration',Tiff.PlanarConfiguration.Chunky)
        setTag(t,'RowsPerStrip',1)
        write(t,mData(:,:,ii));
    else
        imwrite(mData(:,:,ii), fullFilePath);
    end
end

%% Transfer data to becExp and trigger the event
becExp.TempData = becExp.Acquisition.killBadPixel(double(mData));
notify(becExp,'NewRunFinished')

end