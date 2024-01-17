function Omega = rabi(atom,laser,isAveraged,transition)
%Calculate the (reduced) Rabi-frequency using the atomic and laser
%properties

arguments
    atom
    laser
    isAveraged (1,1) = 0
    transition = 'D2';
end
if class(atom) == "AlkaliAtom"
    if transition == "D2"
        Isat = atom.ReducedSaturationIntensity(2);
        Gamma = atom.NatuaralLinewidth(2);
    else
        Isat = atom.ReducedSaturationIntensity(1);
        Gamma = atom.NatuaralLinewidth(1);
    end
elseif class(atom) == "ArtificialAtom"
    Isat = atom.SaturationIntensity;
    Gamma = atom.NatuaralLinewidth;
end

if isAveraged==0
    I = [laser.Intensity];
else
    I = [laser.IntensityAveraged];
end
Omega = sqrt(I/Isat/2).*Gamma;
end

