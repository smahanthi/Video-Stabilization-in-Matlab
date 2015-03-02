function stabilizedvid = vstabilize(sourcevid,outputname,windowsize)
%Error Handling
if(~mod(windowsize,2))
    error('Window size is in improper format. Please enter odd integer value');
end
if(nargin<3)
    error('Insufficient number of Input parameters. Please enter (sourcevideo,outputname, windowsize)');
end
%---------------------VIDEO OBJECT INIT--------------%
%Initializing Video Reader object
videoFReader = vision.VideoFileReader(sourcevid,'ImageColorSpace','Intensity','VideoOutputDataType','uint8');
%Initializing Optical Flow object
% optical = vision.OpticalFlow('ReferenceFrameSource','Input port','Method','Lucas-Kanade','OutputValue','Horizontal and vertical components in complex form');
converter = vision.ImageDataTypeConverter; %Converts the data
%-----------------------------------------------------
%--------------initializing variables for stream processing----------
count = 1;
iFrame1 = step(videoFReader);
iFrame2 = step(videoFReader);
im1 =  step(converter, iFrame1);
im2 =  step(converter, iFrame2);
% %Padding to give space for stabilization in output
% im1 = padarray(im1,[50 50 0]);
% im2 = padarray(im2,[50 50 0]);
% %----------------Stream Processing Loop to derive affine transformation chain---------------------------------
tchain(:,:,1) = [0,0;0,0;0,0];
while ~isDone(videoFReader);
% mvects = step(optical,iFrame2,iFrame1);
count = count+1;
af = affine_flow('image1', double(im1), 'image2', double(im2), 'sigmaXY', 25, 'sampleStep', 10);
af = af.findFlow;
flow = af.flowStruct;
% aflow = calcaflow(flow.d,flow.s1,flow.s2,flow.r,flow.vx0,flow.vy0);
tchain(:,:,count) = [0, 0; 0, 0; tchain(3,1,count-1)+flow.vx0, tchain(3,2,count-1)+flow.vy0];
tchain2(:,:,count) = [0, 0; 0, 0; flow.vx0, flow.vy0];

% tchain(:,:,count) = aflow;
im1 = im2;
im2 = step(converter, step(videoFReader));
% %Padding to give space for stabilization in output
% im1 = padarray(im1,[50 50 0]);
% im2 = padarray(im2,[50 50 0]);
% %-------------------------------------------------
end
release(videoFReader);
release(converter);
%Smoothing transformation chain--------------------------------------
%Passing to mSmooth Function to smooth the transformation chain
structSmooth = mSmooth(tchain, windowsize);
%---------------------------------------------------------------------
p = weplot(structSmooth,tchain);
lt = length(tchain);
% tsmooth = calcaflow(structSmooth);
ct = 1;
tsmooth2 = zeros(size(tchain)); 
while(lt)
tsmooth2(:,:,ct) = tchain2(:,:,ct)+structSmooth(:,:,ct)-tchain2(:,:,ct);
ct = ct+1;
lt = lt-1;
end
tsmooth = calcaflow(tsmooth2);

%Sending the smoothed and original transf chains to plot graph
% if(~weplot(tsmooth,tchain))
%     throw(MException('Unable to plot graphs.'));
% end


%Video Completion and object initialization for video player and writer
converter2 = vision.ImageDataTypeConverter; 
converter3 = vision.ImageDataTypeConverter; 
videoF2Reader = vision.VideoFileReader(sourcevid,'ImageColorSpace','RGB');
videoFplayer = vision.VideoPlayer;
stabilizedvid = VideoWriter(outputname);
stabilizedvid.FrameRate = videoF2Reader.info.VideoFrameRate;
open(stabilizedvid);
count2 = 1;
% dummyframe = zeros(400, 400,3);
% dummyframe = im2frame(double(dummyframe));
% writeVideo(stabilizedvid, dummyframe);
oFrame1 = step(videoF2Reader);
oFrame1 = step(converter3,oFrame1);
release(converter3);
release(videoFplayer);
% oFrame1 = cell2mat(oFrame1);
% oFrame1 = imfuse(dummyframe,oFrame1);
% oFrame1 = im2frame(double(oFrame1));
writeVideo(stabilizedvid, oFrame1);
oFrame2 = step(videoF2Reader);
Rcb = imref2d(size(oFrame2));
Rout = Rcb;
Rout.XWorldLimits(2) = Rout.XWorldLimits(2)+20;
Rout.YWorldLimits(2) = Rout.YWorldLimits(2)+20;

%----Stream processing loop to apply the smoothed transformation
while ~isDone(videoF2Reader);
    count2 = count2+1;
    oImg = step(converter2,oFrame2);
    tform = affine2d( [tsmooth(1,1,count2),tsmooth(1,2,count2),0;tsmooth(2,1,count2),tsmooth(2,2,count2),0;tsmooth(3,1,count2),tsmooth(3,2,count2),1] );
%     invForm = invert(tform);
    %     tform = affine2d([1 0 0;0 1 0;-1*(tchain(3,1,count2)-tsmooth(3,1,count2)) -1*(tchain(3,2,count2)-tsmooth(3,2,count2)) 1]);
%     tform = affine2d([1 0 0;0 1 0;-1*(tchain(3,1,count2)-tsmooth(3,1,count2)) -1*(tchain(3,2,count2)-tsmooth(3,2,count2)) 1]);
    oImg = imwarp(oImg,tform,'OutputView',Rout);
%     oImg = imfuse(dummyframe,oImg);
%     oFrame = im2frame(double(oImg));
    writeVideo(stabilizedvid, oImg);
    step(videoFplayer,oImg);
    oFrame2 = step(videoF2Reader);
end
release(videoF2Reader);
close(stabilizedvid);
release(converter2);
release(videoFplayer);
