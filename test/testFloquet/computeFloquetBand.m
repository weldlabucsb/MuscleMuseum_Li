function output = computeFloquetBand(nput)
% Title  :computeFloquetBands.m
% Author : Cora Fujiwara
%
% This code calculates the Floquet band structure of a 1D optical lattice.
close all;

% Uncomment if you're actually going to use this as a fucntion
if nargin==1
    depth=nput.depth;
    freq=nput.freq;
    alpha=nput.alpha;
    hybrid=nput.hybrid;
else
    % Modulation Parameters default if you don't want to use this as a
    % function you naughty person :P
    % B=.4;              % modulation depth in Er
    depth=5.9637;         % static lattice depth in Er
    alpha=.3;      % relative modulation depth
    hybrid=[1:4];       % static bands to monitor
    freq=75.2639;            % modulation frequency in kHz

%       depth=14.8164;
%       freq=51.1905;
%       alpha=2.7094;
%       hybrid = [1 2 3];
end

disp([newline 'computeFloquetBands.m']);
output=struct;

% physical constants
fr=25.127; % recoil frequency in kHz
doSave=0;


% simulation paramaters
numStates=25;               % size of basis
kpoints=251;                % number of quasimomenta to analyze
klim=[-1 1];                % limits of quasimomenta
freqE=freq/fr;              % modulation frequency in Er
numSteps=21;                % number of time steps in a drive
T=2*pi/freqE;               % period in units of omega_R


K=linspace(klim(1),klim(2),kpoints)';   % quasimomentum vector                 
dK=K(2)-K(1);                           % quasimomentum spacing
dT=T/numSteps;                          % time spacing
numBands=max(hybrid);                   % number of staic bands to plot


%%%%%%%%%%%%%%%%% assign to output structure %%%%%%%%%%%%%%%%%
output.depth=depth;
output.alpha=alpha;
output.freq=freq;
output.hybrid=hybrid;
output.numStates=numStates;
output.numSteps=numSteps;
output.K=K;

%%%%%%%%%%%%%%%%%% display simulation parameters %%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ');
disp(['   static depth     : ' num2str(depth) ' Er']);
disp(['   mod frequency    : ' num2str(freq)  ...
    ' kHz (' num2str(round(freqE,2)) ' Er)']);
disp(['   mod depth        : ' num2str(alpha) ]);
disp(['   recoil frequency : ' num2str(fr) ' kHz']);
disp(' ')
disp(['   quasimomentum    : [' num2str(klim) ']']);
disp(['   num momentum     : ' num2str(kpoints) ]);
disp(['   basis size       : ' num2str(numStates)]);
disp(['   time steps       : ' num2str(numSteps)]);
disp(newline);

% titles for figures
titstr0=['$(U,\Omega) : (' ...
    num2str(round(depth,3)) 'E_R,'...
    num2str(round(freq,3)) '~\mathrm{kHz})$'];
titstr=['$(U,\alpha,\Omega) : (' ...
    num2str(round(depth,3)) 'E_R,'...
    num2str(round(alpha,3)) ',' ...
    num2str(round(freq,3)) '~\mathrm{kHz})$'];

% Lattice modulation info
nfo=struct;
nfo.theta=0;                % phase of modulation
nfo.depth=depth;            % lattice depth
nfo.alpha=alpha;            % depth of modulation
nfo.numStates=numStates;    % number of basis states
nfo.k=0;                    % quasimomentum

%% Static Lattice Calculations
bandsStatic=zeros(length(K),numStates);       % static bands
bandsFold=zeros(length(K),numStates);

vecStatic=zeros(numStates,numStates,length(K));
%%%%%%%%%%%% calculate static lattice bands %%%%%%%%%%%%
fprintf('computing static band structure...');
for ii=1:length(K)     
    static=nfo;
    static.alpha=0;
    static.k=K(ii); 
    H0=makeHmatrix(static);              % get Hamiltonian
    [vS,eng]=eig(full(H0));               % calculate eigenvalues
    bandsFold(ii,:)=mod(...
        diag(eng)-freqE/2,freqE)-freqE/2;
    bandsStatic(ii,:)=diag(eng)-depth/2;
    vecStatic(:,:,ii)=vS;
end
disp('done');

% Add the computed band structure to the output
output.bandsStatic=bandsStatic;
output.vecStatic=vecStatic;
output.bandsFold=bandsFold;

%%%%%%%%%%%% plot folded bands %%%%%%%%%%%%
% plot the folded bands the main issue comes from edge effects at band
% crossings which

bandDataFold={};
fprintf('folding the static bands in the first quasienergy zone...');
for nn=1:numBands
    Ef=bandsFold(:,nn);         % get the current bands

    % find zone crossings
    EfoldP=circshift(Ef,1);                  % Shift to find derivative
    delta=round((Ef-EfoldP)/freqE);          % Scale by the energy     
    barriers=find(delta);                    % Find discontinuities      
    numPs=length(barriers)+1;                % Number of plots
    
    if numPs==1
        % If no crossings then it's the simplest case.
        bandDataFold{nn}{1}(:,1)=K;
        bandDataFold{nn}{1}(:,2)=Ef;
    else   
        % First one
        % Linearly extrapolate to the edge
        y1=sign(Ef(barriers(1)-1))*...       	% Boundary energy
                freqE*0.5;        
        m1=(Ef(barriers(1)-1)-...                % Slope
            Ef(barriers(1)-2))/dK;     
        
        x1=(y1-Ef(barriers(1)-1))/m1+K(barriers(1)-1);

        % Add edges to the data list
        bandDataFold{nn}{1}(:,1)=...
            [K(1:barriers(1)-1); x1];
        bandDataFold{nn}{1}(:,2)=...
            [Ef(1:barriers(1)-1); y1];            
        
        % Iterate over the middle crossings which are different since they
        % have two edges
        for kk=2:(numPs-1)
            bStart=barriers(kk-1);
            bEnd=barriers(kk)-1;            
            
            kData=K(bStart:bEnd);
            eData=Ef(bStart:bEnd);
            
            y1=sign(Ef(bStart))*...              % Boundary energy
                freqE*0.5;        
            m1=(Ef(bStart+1)-...                 % Slope
                Ef(bStart))/dK;     
            x1=(y1-Ef(bStart))/m1+K(bStart);

            y2=sign(Ef(bEnd))*...                % Boundary energy
                freqE*0.5;        
            m2=(Ef(bEnd)-...                     % Slope
                Ef(bEnd-1))/dK;     
            x2=(y2-Ef(bEnd))/m2+K(bEnd);

            bandDataFold{nn}{kk}(:,1)=[x1; kData; x2];
            bandDataFold{nn}{kk}(:,2)=[y1; eData; y2];            
        end        
        
        % Last One
        y2=sign(Ef(barriers(end)))*...           % Boundary energy
            freqE*0.5;        
        m2=(Ef(barriers(end)+1)-...              % Slope
            Ef(barriers(end)))/dK;        
        x2=(y2-Ef(barriers(end)))/m2+K(barriers(end));

        bandDataFold{nn}{numPs}(:,1)=...
            [x2; K(barriers(end):end)];
        bandDataFold{nn}{numPs}(:,2)=...
            [y2; Ef(barriers(end):end)];        
    end
end

disp('done');
%% Find the transitions
% Find the transitions between the bands for the given modulation up to a
% higher number of photon couplings

fprintf('calculating transitions...');
transLst=struct('n1',{},'n2',{},'photons',{},...
    'energy1',{},'energy2',{},'k',{});


for ii=1:numBands
    for jj=(ii+1):numBands
        Ei=bandsStatic(:,ii);
        Ef=bandsStatic(:,jj);
        for nn=1:4           
            Ef_dress=Ef-freqE*nn; 
            ind=find(diff((sign(Ef_dress-Ei)+1)./2));    
            if ~isempty(ind)
                indp=ind(2);                
                a=struct;
                a.n1=ii;
                a.n2=jj;
                a.photons=nn;
                a.energy1=Ei(indp);
                a.energy2=Ef(indp);
                a.k=K(indp);
                transLst(end+1)=a;        
            end
        end
   end       
end

disp('done');

disp(' ');   
for nn=1:length(transLst)
   disp(['    ' num2str(transLst(nn).n1) ' to ' ...
       num2str(transLst(nn).n2)  ' @ k=' num2str(transLst(nn).k) ' ' num2str(transLst(nn).photons) ]);
end

output.transitions=transLst;

disp(' ');

%%
% % Compute and show Transition Matrix Elemnts
% fprintf('Computing transition matrix elements...');
% [hFOverlap,funcs]=computeTransitionOverlaps(depth,numBands);
% disp('done');
% 

%% Figure 1: Static Bands
% Plot the static band structure, harmonic oscillator energies, and the
% transitions
fprintf('Plotting static bands with transitions...');

hF1=figure('Name','static_bands','color','w',...
    'units','pixels','resize','off');
clf;
hF1.Position=[10 50 350 600];

ax1=axes;
cla
co=get(gca,'colororder');
set(ax1,'fontsize',14,'box','on','linewidth',1,'fontname','times');
xlabel('quasimomentum ($\hbar k_L$)','interpreter','latex');
ylabel('energy ($E_R$)','interpreter','latex');
xlim([min(K) max(K)]);
ylim([-depth ceil(max(max(bandsStatic(:,1:numBands))))]);
hold on

% Plot harmonic oscilator energies
engHO=-depth+2*sqrt(depth)*(0.5+(0:10));
for ii=1:length(engHO)
plot(klim,[1 1]*engHO(ii),'k:','linewidth',1); 
end

% Plot the bands
for kk=1:numBands
   plot(K,bandsStatic(:,kk),'-','linewidth',3,...
       'color',co(mod(kk-1,7)+1,:)); 
end

% Plot the transitions
for kk=1:length(transLst)
    pm=(mod(kk,2)-.5)*2;
    p1=plot(pm*[1 1]*transLst(kk).k,...
        [transLst(kk).energy1 transLst(kk).energy2],...
        'k-','linewidth',1);
    switch transLst(kk).photons
        case 1
            p1.LineStyle='-';
            p1.LineWidth=3;
        case 2
            p1.LineStyle='--';
            p1.LineWidth=2;
        case 3
            p1.LineStyle='-.';
            p1.LineWidth=1;
        otherwise
            p1.LineWidth=.2;
    end
end


% Add transitions
for kk=1:length(transLst)
   if transLst(kk).photons==1
        nI=transLst(kk).n1;
        nF=transLst(kk).n2;       
        k=transLst(kk).k;       
%         funcs.Add(nI,nF,k);
   end    
end

% draw band letters at the mean band position
letters={'s','p','d','f','g','h','i','j','k',...
    'l','m','n','o','p','q','r'};
for ll=1:numBands
    yy=mean(bandsStatic(:,ll));
    tL=text(klim(2),yy,['$' letters{mod(ll-1,7)+1} '$'],...
        'units','data','fontsize',24,...
        'horizontalalignment','left',...
        'color',co(mod(ll-1,7)+1,:),'interpreter','latex',...
        'verticalalignment','middle');    
    tL.Units='pixels';
    tL.Position(1)=tL.Position(1)+10;
    tL.Units='data';
end

title(titstr0,'fontweight','normal','interpreter','latex');


disp('done');
%% Figure 2: Folded Bands
% Plot the static bands but folded into the first quasienergy zone
fprintf('Plotting Folded Bands...');
hF2=figure('Name','folded_bands',...
      'color','w','units','pixels','resize','off');
clf
hF2.Position=[370 50 400 300];

% Make axis object
ax1=axes;
cla
set(ax1,'fontsize',14,'units','pixels','box','on','linewidth',1,...
    'fontname','times');
ylim([-1 1]*freqE*.5);
xlim([min(K) max(K)]);
hold on
xlabel('quasimomentum ($\hbar k_L$)','interpreter','latex');
ylabel('quasienergy ($E_R$)','interpreter','latex');

title(titstr0,'fontweight','normal','interpreter','latex');

% Iterate over every band
for ii=1:numBands        
    % Iterate over each fold of band
    for nn=1:length(bandDataFold{ii})     
        % Plot the folded spectrum
        plot(bandDataFold{ii}{nn}(:,1),...
            bandDataFold{ii}{nn}(:,2),...
            'k-','linewidth',2,...
            'color',co(mod(ii-1,7)+1,:));
    end
end

disp('done');
%% Figure 3 : Plot the Floquet Bands
disp('Computing floquet spectrum with live update...');


%%%%%%%%%%%%%%%%% initialize the live update figure %%%%%%%%%%%%%%%%%%%%%%%
hF3=figure('Name','floquet_live','color','w','units','pixels',...
      'resize','off');
clf
hF3.Position=hF2.Position;
hF3.Position(1)=hF3.Position(1)+hF3.Position(3)+10;

axes;
title(titstr,'fontweight','normal','interpreter','latex');
set(gca,'box','on','fontsize',14,'fontname','times','linewidth',1);
xlim([min(K) max(K)]);
ylim([-1 1]*freqE/2);
xlabel('quasimomentum ($\hbar k_L$)','interpreter','latex');
ylabel('quasienergy ($E_R$)','interpreter','latex');
hold on

% Plot folded bands
for ii=1:numBands            
    for nn=1:length(bandDataFold{ii})            
        plot(bandDataFold{ii}{nn}(:,1),...
            bandDataFold{ii}{nn}(:,2),...
            'k-','linewidth',2,...
            'color',co(mod(ii-1,7)+1,:));
    end
end

% Initialize graphics with some dummy data
pFloquet=scatter([],[],5,'ko','markerfacecolor','k');  

%%%%%%%%%%%%%%%%% initialize the live update figure %%%%%%%%%%%%%%%%%%%%%%%

   
% Initialize output data structures
Heffs=zeros(numStates,numStates,length(K));         % effective hamiltonian
vecFloquet=zeros(numStates,numStates,length(K));    % floquet eigenstates
bandsFloquet=zeros(kpoints,numStates);              % floquet bands

% compute floquet spectrum for all quasimomentum
for ii=1:length(K) 
    % assign new quasimomentum
    nfo.k=K(ii);               
    
    % initialize the time evolution operator
    U_T_all=zeros(numStates,numStates,numSteps);

    
    % the modulation phase vector
    thetavec=linspace(0,2*pi,numSteps);
    
    % Calculate all time evolutions operators over a cycle
    for kk=1:numSteps    
        % assign the modulation phase
        nfo.theta=thetavec(kk);    
        
        % calculate the hamiltonian
        thisHmatrix=makeHmatrix(nfo); 
        
        % make the time evolution operator for this time step
        U=expm(-1i*thisHmatrix*dT);        
        
        % assign the time evolution operator for this time step
        U_T_all(:,:,kk)=U;
    end

    % calculate the single period time evolution operator
    U_T=speye(numStates);
    for kk=1:size(U_T_all,3)
        U_T=U_T_all(:,:,kk)*U_T;    
    end

    % compute the effective hamiltonian
    Heff=1i*(freqE/(2*pi))*logm(U_T);

    % assign the hamiltonian to the output
    Heffs(:,:,ii)=Heff;
    
    % Caclulate eigenstates
    [vF,eng]=eig(full(Heff));
    Efloquet=real(diag(eng));
    
    % get eigenvector of static lattice
    vS=transpose(vecStatic(:,:,ii));
    
    % compute overlap of floquet and static eigenvector basis   
    C=vS*conj(vF);                  % overlap     C_ij=<i|j>
    P=C.*conj(C);                   % probability P_ij=|<i|j>|^2
      
    % Acquire the highest probability floquet states
    [~,inds]=max(P,[],2);           % order by probability overlap
    Efloquet=Efloquet(inds);        % order the eigenvalues
    vF=vF(:,inds);                  % order the eigenvalues
    bandsFloquet(ii,:)=Efloquet;    % append eigenvalues
       
    % Add these basis vectors to the total Floquet basis              
    vecFloquet(:,:,ii)=vF;

    % add quasienerngies to live plot
    nn=(numBands*(ii-1)+1):numBands*ii;
    pFloquet.XData(nn)=K(ii)*ones(numBands,1);
    pFloquet.YData(nn)=Efloquet(1:numBands);      
    
    % update plot
    drawnow;
end    

% Assign calculations to output structure
output.Heff=Heffs;
output.vecFloquet=vecFloquet;
output.bandsFloquet=bandsFloquet;
%% Figure 4 : Plot Floquet Bands of Desired Hybridization
% Plot the floquet bands by their wavefunction overlap

fprintf('plotting floquet bands ...');
hF4=figure('Name','floquet_bands',...
      'color','w','units','pixels',...
      'resize','off','Color','w','Position',hF2.Position);
clf
hF4.Position(2)=hF2.Position(2)+hF2.Position(4)+35;

% Initialize axis
ax1=axes;
set(ax1,'box','on','fontsize',14,'units','pixels',...
    'linewidth',1,'fontname','times');
xlim([min(K) max(K)]);
ylim([-1 1]*freqE/2);
xlabel('quasimomentum ($\hbar k_L$)','interpreter','latex');
ylabel('quasienergy ($E_R$)','interpreter','latex');
hold on
title(titstr,'interpreter','latex','fontweight','normal');

% Iterate over band hybrids
for ii=1:length(hybrid)
    c=co(mod(hybrid(ii)-1,7)+1,:);
    scatter(K,bandsFloquet(:,hybrid(ii)),5,'o',...
        'markerfacecolor',c,...
        'markeredgecolor',c);     
end
disp('done');

%% track Floquet band
% Separate the spectrum into quasienergy bands.  This is hard because the
% bands are composed of different static bands and also cross the
% quasienergy brillouin zone.
%
% The idea is to track each band by tracing the highest probability
% state of from the initial state in the subspace of desired hybrid bands.

fprintf('Sorting into separate floquet bands...');

% hybrid subspace eigenvalues wrapped (ie. quasienergies)
bandsSubspaceA=bandsFloquet(:,hybrid);                 

% hybrid subspace eigenvalues unwrapped (ie. dressed quasienergies)
bandsSubspaceB=bandsFloquet(:,hybrid);     

% hybrid subspace basis
vSubspace=vecFloquet(hybrid,hybrid,:);

% photon number - how many times each band has wrapped quasienergy
Nvec=zeros(1,length(hybrid));             

% sorting vector - tracker of subspace permutation [1 2 3 .. N] is initial
indVec=1:length(hybrid);                  

% Iterate over all quasimomentum
for kk=2:length(K)
    % Make all combinations
    perMat=flip(perms(indVec),1);

    % Compute probability overlap
    Cpre=vSubspace(:,indVec,kk-1);                   % Previous eigentstates
    Cnow=vSubspace(:,:,kk);                          % Current eigenstates   
    
    CpreRep=repmat(Cpre,1,size(perMat,1));      % Repeated
    CnowPerms=Cnow(:,perMat');                  % Permute current eigen
        
    A=sum(CpreRep.*conj(CnowPerms),1);          % Take the overlap
    A=sqrt(A.*conj(A));                         % Convert to probability
    
    B=reshape(A,...                             % Reshape
        [length(hybrid) size(perMat,1)]);    
    C=sum(B,1);                                 % Sum it
    [~,ind]=max(C);                             % Find maximum
    
    if ~isequal(perMat(ind,:),indVec)        
        indVec=perMat(ind,:);       
    end
    
    % Check for discontinuities accross FBZ
    Enow=bandsSubspaceA(kk,indVec);
    Eprev=bandsSubspaceA(kk-1,indVec);    
    deltaE=Enow-Eprev;
    nn=find((abs(deltaE)>.95*freqE));
    if ~isempty(nn)
        Nvec(nn)=Nvec(nn)-sign(deltaE(nn));
    end        
    
    % Add the quasienergy to the unwrapped band
    bandsSubspaceB(kk,:)=bandsSubspaceA(kk,indVec)+freqE*Nvec;
end

disp('done');

output.bandsHybrid=bandsSubspaceB;
%% Compute Derivatives
% With the Floquet bands now separated into different bands, now compute
% the first derivative which is useful for semiclassical calculations

fprintf('computing group velocity the band structure...');

E_func={};
dEdK_func={};

for kk=1:size(bandsSubspaceB,2)
    kp=[K(1)-dK;  K; K(end)+dK];
    
    % elongate the so that interp is fine
    Ek_data=bandsSubspaceB(:,kk); 
    E1=Ek_data(1)+(Ek_data(1)-Ek_data(2));
    E2=Ek_data(end)+(Ek_data(end)-Ek_data(end-1));   
    Ek_data=[E1; Ek_data; E2];

    % smooth the data    
    Ek_data=smooth(Ek_data,4);

    % create anoynymous functions
    Ek=@(k) interp1(kp,Ek_data,k);
    
    dEdK=@(k) (Ek(k+.5*dK)-Ek(k-.5*dK))/dK;    

    % assign functions to the cell output
    E_func{kk}=@(k) Ek(k-sign(k).*ceil((abs(k)-1)/2)*2);
    dEdK_func{kk}=@(k) dEdK(k-sign(k).*ceil((abs(k)-1)/2)*2);

end

output.bandsHybrid_E=E_func;
output.bandsHybrid_dEdK=dEdK_func;

disp('done');
%% Figure 5 : plot hybridized band analysis         
fprintf('Plotting the hybrized bands...');
for kk=1:size(bandsSubspaceB,2)
    str=['floquet_band_analysis_' num2str(kk)];
    hF5=figure('Name',str,...
        'color','w','units','pixels','resize','off');
    clf
    hF5.Position=[800 430 400 300];

    ax=axes;
    co=get(gca,'colororder');
    set(ax,'fontname','times','fontsize',12,'box','on',...
        'linewidth',1);
    xlabel('quasimomentum ($\hbar k_L$)','interpreter','latex');
    ylabel('quasienergy ($E_R$)','interpreter','latex');
    xlim(klim);
    hold on
   
    yyaxis right
    pEK=plot(K,dEdK_func{kk}(K),'-','linewidth',1,'color',co(2,:));
    ylabel('group velocity ($E_R/(\hbar k_L)$)','interpreter','latex');
    
    yyaxis left
    pE=plot(K,bandsSubspaceB(:,kk),'-','linewidth',1,'color',co(1,:));
    
    text(10,.10,['$\Delta E=' num2str(round(max(pE.YData)-min(pE.YData),2)) 'E_R$'],...
        'interpreter','latex','units','pixels',...
        'verticalalignment','bottom','fontsize',16);
end        
disp('done');



%% Figure 6 : raw output         
fprintf('plotting raw spectrum...');

hF6=figure('Name','floquet_raw_spectrum',...
    'color','w','units','pixels','resize','off');
clf
hF6.Position=[1200 430 400 300];



ax=axes;
co=get(gca,'colororder');
set(ax,'fontname','times','fontsize',12,'box','on',...
    'linewidth',1);
xlabel('quasimomentum ($\hbar k_L$)','interpreter','latex');
ylabel('quasienergy ($E_R$)','interpreter','latex');
xlim(klim);
ylim([-1 1]*freqE/2);
hold on
title(titstr,'fontweight','normal','interpreter','latex');

for kk=1:size(bandsFloquet,2)
    plot(K,bandsFloquet(:,kk),'.','color',[.2 .2 .2],'markersize',2);
end
disp('done');
%% Saving

if doSave
    dirname='floquet_figures';
    if ~exist(dirname,7)
        mkdir(dirname);
    end
    
    disp('saving figures');
    figs=get(groot,'Children');
    for n=1:length(figs)
        savepdf(figs(n),[dirname filesep figs(n).Name]);
    end

end

end

function savepdf(hF,fname)
fprint([fname '...']);

figure(hF)
set(hF,'Units','Inches');
pos = get(hF,'Position');
set(hF,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

print(hF,fname,'-dpdf','-r0')
print(hF,fname,'-dpng','-r150')
saveas(hF,fname);
set(hF,'units','pixels');

disp('saved');
end




