%                 load("commandNet.mat");
load('trainedNetwork1.mat');
% ports=serialportlist('all')
                available_ports=serialportlist('available');
%                 device=serialport(available_ports(1),9600);
                device=serialport('COM3',9600);
h=figure;
title('close if you want to finish','FontSize',12,'Fontweight','bold','FontName','Times');
[x,fs] = audioread("stop_command.flac");
auditorySpect = helperExtractAuditoryFeatures(x,fs);
classificationRate = 20;
adr = audioDeviceReader(SampleRate=fs,SamplesPerFrame=floor(fs/classificationRate));
app.TheRecogniziedOrdersayTextArea.Value=sprintf('audioDeviceReader finished ');
audioBuffer = dsp.AsyncBuffer(fs);
labels = trainedNet.Layers(end).Classes;
YBuffer(1:classificationRate/2) = categorical("background");
probBuffer = zeros([numel(labels),classificationRate/2]);

countThreshold = ceil(classificationRate*0.2);
probThreshold = 0.7;


% Initialize variables for plotting
currentTime = 0;
colorLimits = [-1,1];

timeLimit = inf;

tic
% while toc<timeLimit && isVisible(wavePlotter) && isVisible(specPlotter)
while ishandle(h)&& toc<timeLimit   
    % Extract audio samples from the audio device and add the samples to
    % the buffer.
    x = adr();
    
    write(audioBuffer,x);
    y = read(audioBuffer,fs,fs-adr.SamplesPerFrame);
    
    spec = helperExtractAuditoryFeatures(y,fs);
    
    % Classify the current spectrogram, save the label to the label buffer,
    % and save the predicted probabilities to the probability buffer.
    [YPredicted,probs] = classify(trainedNet,spec,ExecutionEnvironment="cpu");
    YBuffer = [YBuffer(2:end),YPredicted];
    probBuffer = [probBuffer(:,2:end),probs(:)];
    
    % Plot the current waveform and spectrogram.
%     wavePlotter(y(end-adr.SamplesPerFrame+1:end))
%     specPlotter(spec')
    
    % Now do the actual command detection by performing a thresholding operation.
    % Declare a detection and display it in the figure if the following hold: 
    %   1) The most common label is not background. 
    %   2) At last countThreshold of the latest frame labels agree. 
    %   3) The maximum probability of the predicted label is at least probThreshold.
    % Otherwise, do not declare a detection.
    [YMode,count] = mode(YBuffer);
    maxProb = max(probBuffer(labels == YMode,:));

    hjh=string(YMode)%fprintf(hjh);
    switch YMode % n='1'>>"right",n='2'>>"left",  3 go, 4 >> stop
                case  "right"
                    n='1';
                    write(device,n,"char")

             
                case "left"
                    n='2';
                    write(device,n,"char");

                case "up"

                case  "down"

                app.OffLamp.Color='w';
                case  "yes"

                case  "no"

                case "go"
                    n='3';
                    write(device,n,"char");

                case   "stop"
                    n='4';
                    write(device,n,"char");

                case   "on"

                      
                case         "off"                          

              end 


              drawnow
    
end

clear;