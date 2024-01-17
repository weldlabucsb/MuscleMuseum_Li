classdef BecParameter < Tof
    %RFSPECTRUM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = BecParameter(start,stop,step,nRepetition)
            obj@Tof('becParameter',start,stop,step,nRepetition,0)
            obj.ParameterName = 'TOF time';
            obj.ParameterUnit = '$\mathrm{ms}$';
            obj.RoiPosition = [512,512];
            obj.RoiSize = [1022,1022];
            
            iG.od_c = 1.583; %OD of condensate
            iG.x0_c = 488.2; %condensate radial position
            iG.wx_c = 54.61; %condensate radial width
            iG.y0_c = 525.1; %condensate axial position
            iG.wy_c = 459; %condensate axial width
            iG.wx_t = 400; %thermal cloud radial width
            iG.wy_t = 600; %thermal cloud axial width
            iG.od_t = 0.3571; %OD of thermal cloud
            
            obj.InitialGuess = iG;
            obj.Update
        end
        
        function FitParameter(obj)
            %% Read parameters from properties. 
            shape = obj.Shape;
            t = obj.FitList;
            nFit = obj.NFit;
            startIdx2 = obj.FitStartIndex2;
            stopIdx2 = obj.FitStopIndex2;
            pix = obj.PixelSize;
            daPath = obj.DataAnalysisPath;
            
            %% Input Parameters
            load AtomData Sodium
            hbaroverm = Sodium.HbarOverMass; %Reduced Planck constant divided by mass
            kboverm = Sodium.KbOverMass;
            a0 = Constants.Micro('a0'); %Bohr raidus in micron
            a11_T = 54.54*a0;
            a12_T = 50.78*a0;
            gamma_T = sqrt((a11_T-a12_T)/(a11_T+a12_T));
            deltaa_L = 1.65*a0;
            gamma_L = sqrt(deltaa_L/(a11_T+a12_T));
            sigma = 0.1662; %Cross section
            
            %% Unit conversion
            shape = shape(:,startIdx2:stopIdx2);
            shape(2:7,:) = shape(2:7,:)*pix; %Convert length to microns.
            t = t*1e3; %Convert time to micro-sec
            t = t(startIdx2:stopIdx2);
            
%             t = t(21:end);
%             shape = shape(:,21:end);
            
            %% Fit to get the slopes
            lfit = fit(t'.^2,shape(3,:)'.^2,'poly1');
            k_c = lfit.p1;
            error = fitError(lfit);

            figure(6)
            plot(lfit,t'.^2,shape(3,:)'.^2)
            xlabel('t^2 in \mus^2')
            ylabel('wx_c^2 in \mum^2')
            title(['Condensate. Slope=',num2str(k_c),'\pm',num2str(error(1))])
            saveas(gcf,fullfile(daPath,'condensate.fig'))
            saveas(gcf,fullfile(daPath,'condensate.png'))
            
            figure(9)
            plot(t',shape(3,:)','.')
            xlabel('t in \mus')
            ylabel('wx_c in \mum')
            title('Condensate')
            
            lfit = fit(t'.^2,shape(6,:)'.^2,'poly1');
            k_t = lfit.p1;
            error = fitError(lfit);
            figure(7)
            plot(lfit,t'.^2,shape(6,:)'.^2)
            xlabel('t^2 in \mus^2')
            ylabel('wx_t^2 in \mum^2')
            title(['Thermal Cloud. Slope=',num2str(k_t),'\pm',num2str(error(1))])
            saveas(gcf,fullfile(daPath,'thermal.fig'))
            saveas(gcf,fullfile(daPath,'thermal.png')) 
            
            figure(1)
            plot(t',shape(6,:)','.')
            xlabel('t in \mus')
            ylabel('wx_t in \mum')
            title('Thermal Cloud')
            
            % Atom number
            maxidx = size(shape,2);
            N_c = zeros(1,maxidx);
            N_t = zeros(1,maxidx);
            for ii = 1:maxidx
                N_c(ii) = 2*pi/5*shape(3,ii)*shape(5,ii)*shape(1,ii)/sigma;
                N_t(ii) = 3.78*shape(6,ii)*shape(7,ii)*shape(8,ii)/sigma;
            end
            
            figure(1)
            plot(t,N_c)
            figure(2)
            plot(t,N_t)
            
            %% Output parameters
            cn = sqrt(k_c/2)*1e3;
            cs_T = cn*gamma_T;
            cs_L = cn*gamma_L;
            mu = 1/2*k_c/hbaroverm/2/pi*1e3;
            n0 = k_c/hbaroverm^2/4/pi/(a11_T+a12_T)*1e12;
            T = 1/2*k_t/kboverm*1e9;
            xi_s_T = (8*pi*n0*1e-12*(a11_T-a12_T))^(-1/2);
            xi_s_L = (8*pi*n0*1e-12*deltaa_L)^(-1/2);
            disp(['Density sound wave velocity: ',num2str(cn),' mm/s'])
            disp(['Spin sound wave velocity (Tiemann): ',num2str(cs_T),' mm/s'])
            disp(['Spin sound wave velocity (Lett): ',num2str(cs_L),' mm/s'])
            disp(['Spin healing length (Tiemann): ',num2str(xi_s_T),' mum'])
            disp(['Spin healing length (Lett): ',num2str(xi_s_L),' mum'])
            disp(['Chemical potential: ',num2str(mu),' kHz'])
            disp(['Center density: ',num2str(n0,3),' cm^-3'])
            disp(['Temperature: ',num2str(T),' nK'])
            disp(['Condensate atom number: ',num2str(mean(N_c),3)])
            disp(['Thermal atom number: ',num2str(mean(N_t),3)])
            disp(['Total atom number: ',num2str(mean(N_t+N_t),3)])
            
        end
    end
end

