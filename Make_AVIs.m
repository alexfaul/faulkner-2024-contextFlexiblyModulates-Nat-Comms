% This script generates an .AVI file that can be called by MonkeyLogic.

clear;clc;
allAVIS=0:45:359;
avis=22.5:45:360;

%% user-defined parameters 

%(and change save name at end of file!!!)
path='Z:\MonkeyLogic\16Ori_videos\315deg_8s_square_full';
parameters.frameRate = 60;            % frame rate (Hz)
parameters.y = 500;                   % height of .AVI
parameters.x = 500;                   % width of .AVI
parameters.time = 8;                  % length of .AVI (seconds)
parameters.z = parameters.frameRate * parameters.time; % # of frames in .AVI
parameters.contrast = 1;              % contrast = (maxI - minI) / mean(I)
parameters.sf = 300;                   % spatial frequency (pixels)
parameters.v = 2;                     % cycles / second
parameters.rotation = 315;            % degrees of grating rotation     
parameters.innerCircleRadius = 130; % pixels
parameters.outerCircleRadius = 170; % pixels
parameters.backgroundI = 0.5;         % background intensity
parameters.style = 'square';          % 'square' or 'sine'
parameters.screenFill = 'full';     % 'circle' or 'full'
parameters.screenY = 1200;             % full screen Y resolution
parameters.screenX = 1920;             % full screen X resolution
parameters.stimCenterY = parameters.screenY/2;         % stimulus center on full screen (Y)
parameters.stimCenterX = parameters.screenX/2;         % stimulus center on full screen (X)

%% create, rotate, crop array

% this creates an array that will need to be cropped later if the 
% images are to be rotated by a degree other than 0 | 180

if strcmp(parameters.screenFill,'circle')

    if any(parameters.rotation == [0 180])
        y = parameters.y;
        x = parameters.x;
    else
        y = 2*parameters.y;
        x = 2*parameters.x;
    end

    frames = zeros(parameters.y,parameters.x,parameters.z); % preallocate

elseif strcmp(parameters.screenFill,'full')
    if any(parameters.rotation == [0 180])
        y = parameters.screenY;
        x = parameters.screenX;
    else
        y = 2*parameters.screenY;
        x = 2*parameters.screenX;
    end
    
    frames = zeros(parameters.screenY,parameters.screenX,parameters.z); % preallocate
    
end

for i = 1:parameters.z
    
    window = ([0 2*pi]) * (x / parameters.sf);
    window = window + ((i) * ((2*pi) / (parameters.frameRate / parameters.v)));
    
    line = zeros(1,x);
    line = sin(linspace(window(1), window(2), x));
    line = (line + 1) / 2;
    line = line * (parameters.contrast / 2);
    line = line + (parameters.backgroundI - (parameters.backgroundI * (parameters.contrast / 2)));

    frame = zeros(y,x);

    for j = 1:size(frame,1)
        frame(j,:) = line;
    end
    
    if strcmp(parameters.style,'square')
        frame(frame >= parameters.backgroundI) = parameters.backgroundI + (parameters.contrast / 4);
        frame(frame <  parameters.backgroundI) = parameters.backgroundI - (parameters.contrast / 4);
    end
    
    frame = imrotate(frame,parameters.rotation,'nearest','crop');
    
    if all(parameters.rotation ~= [0 180])
        frame_crop = frame((y/2 - y/4 + 1):(y/2 + y/4),(x/2 - x/4 + 1):(x/2 + x/4));
        frames(:,:,i) = frame_crop;
    else
        frames(:,:,i) = frame;
    end
    
end

clear frame i j line window x y

%% create circular stimulus with edge-smoothing effect

if strcmp(parameters.screenFill,'circle')

edgeFilt = zeros(parameters.x,1);
window = [pi/2 3*pi/2];
in = parameters.innerCircleRadius;
out = parameters.outerCircleRadius;

edgeFilt(1:in) = 1;
edgeFilt(out:end) = 0;

insert = sin(linspace(window(1),window(2),out - in + 1));
insert = (insert + 1)/2;
edgeFilt(in:out) = insert;

center = round([parameters.y parameters.x]/2);

frameFilt = ones(parameters.y,parameters.x);
for i = 1:parameters.y
    for j = 1:parameters.x
        currDist = round(sqrt((i - center(1))^2 + (j - center(2))^2));
        if currDist < 1
            currDist = 1;
        end
        frameFilt(i,j) = edgeFilt(currDist);
    end
end

for i = 1:parameters.z
    currFrame = frames(:,:,i);
    currFrame = parameters.backgroundI + ((currFrame - parameters.backgroundI).*frameFilt);
    frames(:,:,i) = currFrame;
end 

clear currFrame



%% embed circular stimulus in a rectangle, designate center

embedded = ones(parameters.screenY,parameters.screenX,parameters.z);
embedded = embedded * parameters.backgroundI;
for i = 1:parameters.z
    embedded((parameters.stimCenterY - parameters.y/2 + 1):(parameters.stimCenterY + parameters.y/2),...
        (parameters.stimCenterX - parameters.x/2 + 1):(parameters.stimCenterX + parameters.x/2),i) = frames(:,:,i);
end 

elseif strcmp(parameters.screenFill,'full')
    embedded = frames;
end

%% convert 'double' to 'uint8'

embedded = uint8(round(255*embedded));


%% write AVI

% myVideo = VideoWriter('C:\Analysis\users\johnson\myVideo', 'Uncompressed AVI');
myVideo = VideoWriter(path, 'Motion JPEG AVI');
myVideo.FrameRate = parameters.frameRate;
myVideo.Quality = 50;

open(myVideo);

for i = 1:parameters.z
    currFrame(:,:,1) = embedded(:,:,i);
    writeVideo(myVideo,currFrame);
end
close(myVideo);

