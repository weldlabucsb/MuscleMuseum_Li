t = Tiff('myfile.tif','w');
setTag(t,'ImageWidth',100);
setTag(t,'ImageLength',100);
setTag(t,'Photometric',Tiff.Photometric.MinIsBlack)
setTag(t,'BitsPerSample',16);
setTag(t,'SamplesPerPixel',1);
setTag(t,'Compression',Tiff.Compression.None);
setTag(t,'PlanarConfiguration',Tiff.PlanarConfiguration.Chunky)

data = uint16(round(rand(100,100)*500));
write(t,data)


    