
% This function records and returns a series of images using the immediate 
% triggering of the imaq adaptor.
%
%    [images] = pco_adaptor_example_immediateaquire(imcount, timeout_s)
%
% * Input parameters
%       imcount:        Number of images to acquire
%       timeout_s:      Number of seconds to wait before video input 
%                       timeout occurs
%
% * Output parameters
%       images:         Stack with acquired images
%
% - Set property values and trigger mode
% - Acquire images immediately after starting the videoinput device
% - Display images and reset the adaptor
%

imaqreset;
imcount = 1;
fileName = 'test\testCamera\run';
timeout_s = 30;

%% Set default values for paramters that haven't been set
if(~exist('imcount','var'))
    imco unt = 10;
end

if(~exist('timeout_s','var'))
    timeout_s = 120;
end

%% Get adaptor name
if verLessThan('matlab','8.2')%R2013a or older
    error('This adaptor is supported in Matlab 2013b and later versions'); 
elseif verLessThan('matlab','9.0') %R2015b - R2013b
    if(strcmp(computer('arch'),'win32'))
        adaptorName = ['pcocameraadaptor_r' version('-release') '_win32'];
    elseif(strcmp(computer('arch'),'win64'))
        adaptorName = ['pcocameraadaptor_r' version('-release') '_x64'];
    else
        error('This platform is not supported.');
    end
else %R2016a and newer
    if(strcmp(computer('arch'),'win64'))
        adaptorName = ['pcocameraadaptor_r' version('-release')];
    else
        error('This platform is not supported.');
    end
end

%% Configure camera and record images
%Create video input object
vid = videoinput(adaptorName,0);

%Create adaptor source
src = getselectedsource(vid);

%Set timestamp mode
src.TMTimestampMode = 'BinaryAndAscii';

%Set logging to memory
vid.LoggingMode = 'memory';

%Configure trigger type and mode
triggerconfig(vid, 'hardware', '', 'ExternExposureStart');

vid.TriggerRepeat = inf;

%Configure polarity of IO signal at trigger port
src.IO_1SignalPolarity = 'rising';
src.ExposureTime_s = 5*10^-6;

%Set frames per trigger
vid.FramesPerTrigger = 1;

%Set the Timeout property of video input object 'vid'
set(vid,'Timeout',timeout_s); 


%Read out all images and remove them from memory buffer
%Function blocks until the images have been aquired
% images = getdata(vid);
% 
vid.FramesAcquiredFcnCount = 3;
vid.FramesAcquiredFcn = {@saveImageData, fileName};

% vid.TimerFcn = @checkFuturesErrors;
% vid.TimerPeriod = 1;

start(vid);
wait(vid, 40)

% start(vid);
% wait(vid, 20)
% [img,~,metadata] = getdata(vid,3);
%% Show images
%Show images in Video Viewer app
% implay(images);

%Reset adaptor
imaqreset;
