classdef Oscillation < Tof
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = Oscillation(start,stop,step,nRepetition)
            obj@Tof('oscillation',start,stop,step,nRepetition,0)
            obj.ParameterName = 'Hold time';
            obj.ParameterUnit = '$\mathrm{ms}$';
            obj.RoiSize = [500,1022];
            obj.RoiPosition = [727,512];
            
            iG.od_c = 0.7448; %OD of condensate
            iG.x0_c = 151.2; %condensate radial position
            iG.wx_c = 109.2; %condensate radial width
            iG.y0_c = 516.7; %condensate axial position
            iG.wy_c = 342.8; %condensate axial width
            iG.wx_t = 179.2; %thermal cloud radial width
            iG.wy_t = 400.8; %thermal cloud axial width
            iG.od_t = 0.2122; %OD of thermal cloud
            
            obj.InitialGuess = iG;
            obj.Update
        end

    end
end

