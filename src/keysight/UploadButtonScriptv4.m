 
%Last edited 4/25/2022 by Eber Nolasco-Martinez

%This should build the waveform (repeat whatever I do
%for build button) and upload the current waveform into
%Keysight.

app.Lamp.Color='red';

%Input Sampling.


freForSampling=4e6;
disp('sampling reduced');
sampling=16;
stpSize=1/(sampling*freForSampling); %Leav Alone
sampleR=(1/stpSize); %Leave Alone
% sampleR=16e6;
% disp(stpSize)
% disp('stpSize')
disp(sampleR)

%Will create a script that assumes the code is either
%constant or

repeatsList1=[];
playmodes1={};
repeatsList2=[];
playmodes2={};

y=app.CurrentSequence1;
%Initial step unused, buffer step.
clear arbsList1 arbsList2;
arbsList1={};
arbsList2={};
arbsList1{1}=0.0.*sin(2*pi*5000*linspace(1,35,35));
arbsList2{1}=0.000.*sin(2*pi*5000*linspace(1,35,35));
fullsettings1=app.CurrentSequence1.settings;
fullsettings2=app.CurrentSequence2.settings;

for i=1:length(app.CurrentSequence1.step_type)
settings=app.CurrentSequence1.settings{i};
fullsettings1{i}=settings;
varsettings=app.CurrentSequence1.varsettings{i};
% disp(varsettings);

% Update Sequence for Current iteration if code is in list
% mode.
if ~strcmp(selectedButton, 'Single Run')
varsettingslogic=cellfun(@(c)strcmp('X',c), varsettings);
for j=1:length(varsettings)
    if varsettingslogic(j)
        settings(j)=varval; %%Varval was created in rfapp before script is called
%         disp('substituted index j');
%         disp(settings(j));
    end
end
end
%             disp(settings(j))

if strcmp(app.CurrentSequence1.step_type{i}, "Constant")

totaltime=settings(1);
amp=settings(2);

timemax=10e-6; %10us

if totaltime<timemax
    arbsList1{end+1}=amp*(0:stpSize:totaltime);
    repeatsList1(end+1)=1;
    playmodes1{end+1}='repeat';
else
    arbsList1{end+1}=amp*0:stpSize:timemax;
    repeatnum=floor(totaltime/timemax);
    repeatsList1(end+1)=repeatnum;
    playmodes1{end+1}='repeat';
%     arbsList1{end+1}=amp*((repeatnum*timemax):stpSize:totaltime);
%     repeatsList1(end+1)=repeatnum;
%     playmodes1{end+1}='repeat';
end
%Set a short time period as a default value for
%constant time. If less, just create the step
%once, if more, create repeat sequence and an
%extra step for leftover time
elseif strcmp(app.CurrentSequence1.step_type{i}, "Sinusoidal")
% settings=app.CurrentSequence1.settings{i};
totaltime=settings(1);
f=settings(2); %Cyclic??
amp=settings(3);
phase=settings(4);

%set a minimum number of cycles. If greater
%than, say 10, divide, repeats, 1 more for
%leftovers. If less, just make one run.Time
%will round up to nearest cycle down
cyclemax=10;
period=1/f;
if floor(totaltime/period)<=cyclemax
    totaltime=floor(totaltime/period)*period;
    repeatsList1(end+1)=1;
    playmodes1{end+1}='repeat';
    arbsList1{end+1}=amp*sin(2*pi*f*(0:stpSize:totaltime));
else %(This step is still buggy)
%                     cycles=floor(totaltime/period);
    newtime=period*cyclemax;
    cycles=floor(totaltime/newtime);
    repeatsList1(end+1)=cycles;
    arbsList1{end+1}=amp*sin(2*pi*f*(0:stpSize:newtime));
    playmodes1{end+1}='repeat';
    extratime=floor(totaltime/period)*period-newtime*cycles;%Messed up this calculation.
%                     repeatsList1(end+1)=1;
%                     playmodes1{end+1}='repeat';
%                     arbsList1{end+1}=amp*sin(2*pi*f*(0:stpSize:extratime));
end

elseif strcmp(app.CurrentSequence1.step_type{i}, "TwoFreq")
% settings=app.CurrentSequence1.settings{i};
totaltime=settings(1);
f1=settings(2); %Cyclic??
amp1=settings(3);
f2=settings(4);
amp2=settings(5);
freq2delay=settings(6);

%Fill out information, will not assume any periodicity
repeatsList1(end+1)=1;
playmodes1{end+1}='repeat';
arbsList1{end+1}=amp1*sin(2*pi*f1*(0:stpSize:totaltime))+amp2.*sin(2*pi*f2*((0:stpSize:totaltime)-freq2delay)).*heaviside((0:stpSize:totaltime)-freq2delay);

    elseif strcmp(app.CurrentSequence1.step_type{i}, "SineRampUp")
        % settings=app.CurrentSequence2.settings{i};
        %                 disp(settings);
        totaltime=settings(1);
        f=settings(2); %Cyclic??
        amp=settings(3);
        
        %Fill out information, will not assume any periodicity
        repeatsList1(end+1)=1;
        playmodes1{end+1}='once';
        period=1/f;
        cycles=floor(totaltime/period);
        actualtime=period*cycles;
        timelist=0:stpSize:actualtime;
        arbsList1{end+1}=amp.*timelist./actualtime.*sin(2.*pi.*f.*timelist);

    elseif strcmp(app.CurrentSequence1.step_type{i}, "SineRampDown")
        % settings=app.CurrentSequence2.settings{i};
        %                 disp(settings);
        totaltime=settings(1);
        f=settings(2); %Cyclic??
        amp=settings(3);
        
        %Fill out information, will not assume any periodicity
        repeatsList1(end+1)=1;
        playmodes1{end+1}='once';
        period=1/f;
        cycles=floor(totaltime/period);
        actualtime=period*cycles;
        timelist=0:stpSize:actualtime;
        arbsList1{end+1}=amp.*(1-timelist./actualtime).*sin(2.*pi.*f.*timelist);

elseif strcmp(app.CurrentSequence1.step_type{i}, "RFPulseWaveform")
        % settings=app.CurrentSequence2.settings{i};
        %                 disp(settings);
        totaltime=settings(1);
        f=settings(2); %Cyclic??
        amp=settings(3);
        phase=settings(4);
        rtime=settings(5);
        ftime=settings(6);
        
        %Fill out information, will not assume any periodicity
        period=1/f;
        timelist=0:stpSize:totaltime;
        timelist1=timelist(timelist<rtime);
        timelist2=timelist((timelist>=rtime)&(timelist<(totaltime-ftime)));
        timelist3=timelist(timelist>=(totaltime-ftime));

        %Rise time
        actualtime=timelist1(end);
        repeatsList1(end+1)=1;
        playmodes1{end+1}='repeat';
        arbsList1{end+1}=amp.*(timelist1./actualtime).*sin(2.*pi.*f.*timelist1+phase);

        %Repeat Fixed Amp Cycles
        cyclemax=10;
        period=1/f;
        fixedamptime=timelist2(end)-timelist2(1);
        if floor(fixedamptime/period)<=cyclemax
            repeatsList1(end+1)=1;
            playmodes1{end+1}='repeat';
            arbsList1{end+1}=amp*sin(2*pi*f*timelist2+phase);
        else
            cycles=floor(fixedamptime/(cyclemax*period));
            repeatsList1(end+1)=cycles;
            playmodes1{end+1}='repeat';
            timelistadjust2=timelist2(timelist2<=(cyclemax*period+timelist1(end)));
            arbsList1{end+1}=amp*sin(2*pi*f*timelistadjust2+phase);

            timelistadjust2leftover=timelist2(cycles*length(timelistadjust2)+1:end);
            if ~isempty(timelistadjust2leftover)
                repeatsList1(end+1)=1;
                playmodes1{end+1}='repeat';
                arbsList1{end+1}=amp*sin(2*pi*f*timelistadjust2leftover+phase);
            end
        end
        
        %Fall time
        actualtime=timelist3(end)-timelist3(1);
        repeatsList1(end+1)=1;
        playmodes1{end+1}='repeat';
        arbsList1{end+1}=amp.*(1-(timelist3-timelist3(1))./actualtime).*sin(2.*pi.*f.*timelist3+phase);


end
end

for i=1:length(app.CurrentSequence2.step_type)

settings2=app.CurrentSequence2.settings{i};
varsettings2=app.CurrentSequence2.varsettings{i};
fullsettings2{i}=settings2;
% Update Sequence for Current iteration if code is in list
% mode.
if ~strcmp(selectedButton, 'Single Run')
varsettingslogic=cellfun(@(c)strcmp('X',c), varsettings2);
for j=1:length(varsettings2)
    if varsettingslogic(j)
        settings2(j)=varval;
    end
end
end
if strcmp(app.CurrentSequence2.step_type{i}, "Constant")
% settings=app.CurrentSequence2.settings{i};
totaltime=settings2(1);
amp=settings2(2);

timemax=10e-6; %10us

if totaltime<timemax
    arbsList2{end+1}=amp*(0:stpSize:totaltime);
    repeatsList2(end+1)=1;
    playmodes2{end+1}='repeat';
else
    arbsList2{end+1}=amp*0:stpSize:timemax;
    repeatnum=floor(totaltime/timemax);
    repeatsList2(end+1)=repeatnum;
    playmodes2{end+1}='repeat';
    arbsList2{end+1}=amp*((repeatnum*timemax):stpSize:totaltime);
    repeatsList2(end+1)=repeatnum;
    playmodes2{end+1}='repeat';
end
%Set a short time period as a default value for
%constant time. If less, just create the step
%once, if more, create repeat sequence and an
%extra step for leftover time
elseif strcmp(app.CurrentSequence2.step_type{i}, "Sinusoidal")
% settings=app.CurrentSequence2.settings{i};
totaltime=settings2(1);
f=settings2(2); %Cyclic??
amp=settings2(3);
phase=settings2(4);

%set a minimum number of cycles. If greater
%than, say 10, divide, repeats, 1 more for
%leftovers. If less, just make one run.Time
%will round up to nearest cycle
cyclemax=10;
period=1/f;
if floor(totaltime/period)<=cyclemax
    totaltime=floor(totaltime/period)*period;
    repeatsList2(end+1)=1;
    playmodes2{end+1}='repeat';
    arbsList2{end+1}=amp*sin(2*pi*f*(0:stpSize:totaltime));
else %(This step is still buggy)
%                     cycles=floor(totaltime/period);
    newtime=period*cyclemax;
    cycles=floor(totaltime/newtime);
    repeatsList2(end+1)=cycles;
    arbsList2{end+1}=amp*sin(2*pi*f*(0:stpSize:newtime));
    playmodes2{end+1}='repeat';
    extratime=floor(totaltime/period)*period-newtime*cycles;%Messed up this calculation.
%                     repeatsList2(end+1)=1;
%                     playmodes2{end+1}='repeat';
%                     arbsList2{end+1}=amp*sin(2*pi*f*(0:stpSize:extratime));
end

    elseif strcmp(app.CurrentSequence2.step_type{i}, "TwoFreq")
    % settings=app.CurrentSequence2.settings{i};
    %                 disp(settings);
    totaltime=settings2(1);
    f1=settings2(2); %Cyclic??
    amp1=settings2(3);
    f2=settings2(4);
    amp2=settings2(5);
    freq2delay=settings2(6);
    
    %Fill out information, will not assume any periodicity
    repeatsList2(end+1)=1;
    playmodes2{end+1}='repeat';
    arbsList2{end+1}=amp1*sin(2*pi*f1*(0:stpSize:totaltime))+amp2.*sin(2*pi*f2*((0:stpSize:totaltime)-freq2delay)).*heaviside((0:stpSize:totaltime)-freq2delay);

    elseif strcmp(app.CurrentSequence2.step_type{i}, "SineRampUp")
    % settings=app.CurrentSequence2.settings{i};
    %                 disp(settings);
    totaltime=settings2(1);
    f=settings2(2); %Cyclic??
    amp=settings2(3);
    
    %Fill out information, will not assume any periodicity
    repeatsList2(end+1)=1;
    playmodes2{end+1}='repeat';
    period=1/f;
    cycles=floor(totaltime/period);
    actualtime=period*cycles;
    timelist=0:stpSize:actualtime;
    arbsList2{end+1}=amp.*timelist./actualtime.*sin(2.*pi.*f.*timelist);

    elseif strcmp(app.CurrentSequence2.step_type{i}, "SineRampDown")
        % settings=app.CurrentSequence2.settings{i};
        %                 disp(settings);
        totaltime=settings2(1);
        f=settings2(2); %Cyclic??
        amp=settings2(3);
        
        %Fill out information, will not assume any periodicity
        repeatsList2(end+1)=1;
        playmodes2{end+1}='repeat';
        period=1/f;
        cycles=floor(totaltime/period);
        actualtime=period*cycles;
        timelist=0:stpSize:actualtime;
        arbsList2{end+1}=amp.*(1-timelist./actualtime).*sin(2.*pi.*f.*timelist);

elseif strcmp(app.CurrentSequence2.step_type{i}, "RFPulseWaveform")
        % settings=app.CurrentSequence2.settings{i};
        %                 disp(settings);
        totaltime=settings2(1);
        f=settings2(2); %Cyclic??
        amp=settings2(3);
        phase=settings2(4);
        rtime=settings2(5);
        ftime=settings2(6);
        
        %Fill out information, will not assume any periodicity
        period=1/f;
        timelist=0:stpSize:totaltime;
        timelist1=timelist(timelist<rtime);
        timelist2=timelist((timelist>=rtime)&(timelist<(totaltime-ftime)));
        timelist3=timelist(timelist>=(totaltime-ftime));

        %Rise time
        actualtime=timelist1(end);
        repeatsList2(end+1)=1;
        playmodes2{end+1}='once';
        arbsList2{end+1}=amp.*(timelist1./actualtime).*sin(2.*pi.*f.*timelist1+phase);

        %Repeat Fixed Amp Cycles
        cyclemax=10;
        period=1/f;
        fixedamptime=timelist2(end)-timelist2(1);
        if floor(fixedamptime/period)<=cyclemax
            repeatsList2(end+1)=1;
            playmodes2{end+1}='repeat';
            arbsList2{end+1}=amp*sin(2*pi*f*timelist2+phase);
        else
            cycles=floor(fixedamptime/(cyclemax*period));
            repeatsList2(end+1)=cycles;
            playmodes2{end+1}='repeat';
            timelistadjust2=timelist2(timelist2<=(cyclemax*period+timelist1(end)));
            arbsList2{end+1}=amp*sin(2*pi*f*timelistadjust2+phase);

            timelistadjust2leftover=timelist2(cycles*length(timelistadjust2)+1:end);
            if ~isempty(timelistadjust2leftover)
                repeatsList2(end+1)=1;
                playmodes2{end+1}='repeat';
                arbsList2{end+1}=amp*sin(2*pi*f*timelistadjust2leftover+phase);
            end
        end
        
        %Fall time
        actualtime=timelist3(end)-timelist3(1);
        repeatsList2(end+1)=1;
        playmodes2{end+1}='repeat';
        arbsList2{end+1}=amp.*(1-(timelist3-timelist3(1))./actualtime).*sin(2.*pi.*f.*timelist3+phase);

    
    end

end



%Will be unused, buffer stage
arbsList1{end+1}=0.000.*sin(2*pi*5000*linspace(1,35,35));
arbsList2{end+1}=0.000.*sin(2*pi*5000*linspace(1,35,35));
% repeatsList1=[0,repeatsList1];
% repeatsList2=[0, repeatsList2];
% playmodes1={'onceWaitTrig',playmodes1{:}};
% playmodes2={'onceWaitTrig',playmodes2{:}};
repeatsList1=[0,repeatsList1,0];
repeatsList2=[0, repeatsList2, 0];
playmodes1={'onceWaitTrig',playmodes1{:},'repeat'};
playmodes2={'onceWaitTrig',playmodes2{:},'repeat'};
%Need to check whether ch1 and ch2 are the proper names (Should be
%SOURce1 and SOURce2, not ch1 and ch2;
% buildplotscript(app, '1', arbsList1, sampleR, repeatsList1, playmodes1, app.OutputButtonGroup.SelectedObject.Text);
% buildplotscript(app, '2', arbsList2, sampleR, repeatsList2, playmodes2, app.OutputButtonGroup.SelectedObject.Text);

a1=[];
a2=[];

if uploadState==1
    tic
    a1=loadSource_v1_gui('1', arbsList1, sampleR, repeatsList1, playmodes1, app.OutputButtonGroup.SelectedObject.Text);
    toc
    a2=loadSource_v1_gui("2", arbsList2, sampleR, repeatsList2, playmodes2, app.OutputButtonGroup.SelectedObject.Text);
    save_rf_log
end
clear arbsList1;
clear arbsList2;

app.Lamp.Color='green';
