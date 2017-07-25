%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an pseduo RSA device. No RSA device needs
%to be connected to the PC as long as icdevice option File is used as shown
%below. Set a r3f file desired for playback. Script will produce a plot
%that shows both IQ data and spectrum of captured data.
%
%Obtain r3f File: Playback uses an r3f file to perform playback. To obtain
%an r3f file, their are two methods. Either use SignalVu-PC to create an
%r3f or run the IFStream_Example script to capture ADC data. If using
%IFStream, make sure to adjust the filename here to match the filename
%created. IFStream adds a timestamp to the filename.
%
%Adjustable Values in Script: userDefinedParameters, filePlayback
%Equipment: None required, including RSA device
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Connect to a pseudo RSA device which will be based on OpenDiskFile. Note:
%Some functions may not work in this state. All functions in this script
%will work with no RSA device
dev = icdevice('RSA_API_Driver', 'File');
connect(dev);

%Adjustable values for functions below
userDefinedParameters.setRecordLength = 5000;
userDefinedParameters.bw_req = 20e6;
userDefinedParameters.loopIterationsIQBlock = 100;

%Open and set properties of sample file for playback
filePlayback.filename = 'File_IQData.r3f';
filePlayback.start = 0;
filePlayback.stop = 100;
filePlayback.skip = 0.0; 
filePlayback.loop = true;
filePlayback.emulate = false;  

%Open file for playback
invoke(dev.Playback, 'OpenDiskFile', filePlayback.filename, filePlayback.start, filePlayback.stop, ...
    filePlayback.skip, filePlayback.loop, filePlayback.emulate);
fprintf('File being opened for disk playback: %s\n', filePlayback.filename);

%Call PrepareForRun to obtain internal state of device during data
%capture
invoke(dev.Device, 'PrepareForRun');

%Need to set record length. Adjusting bandwidth for better visual
%inspection
set(dev.Iqblock, 'IQRecordLength', userDefinedParameters.setRecordLength);
set(dev.Iqblock, 'IQBandwidth', userDefinedParameters.bw_req);

%Obtain the internal state of device during data capture
centerFrequency = get(dev.Configure, 'CenterFreq');
refLvl = get(dev.Configure, 'ReferenceLevel');
iqBandwidth = get(dev.Iqblock, 'IQBandwidth');
sampleRate = invoke(dev.Iqblock, 'GetIQSampleRate');
recordLength = get(dev.Iqblock, 'IQRecordLength');

%Print internal state of device
fprintf('Properties of %s For Playback:\n', filePlayback.filename);
fprintf('     Center frequency: %g\n', centerFrequency);
fprintf('     Reference Level: %d\n', refLvl);
fprintf('     Bandwidth: %d\n', iqBandwidth);
fprintf('     Sample Rate: %d\n', sampleRate);
fprintf('     Record Length: %d\n', recordLength);

fprintf('\n');

%Check GetReplayComplete returns false since data acquisition is not
%enabled 
complete = invoke(dev.Playback, 'GetReplayComplete');
fprintf('Replay Complete Status: %d\n', complete);

%Start data acquistion
invoke(dev.Device, 'Run');
invoke(dev.Device, 'StartFrameTransfer');

running = 0;

%Begin file playback, plotting IQ and spectrum using GetIQData
while(running < userDefinedParameters.loopIterationsIQBlock)
    %Obtain IQ data and split into own separate arrays
    IQ = invoke(dev.Iqblock, 'GetIQData', 0, recordLength);
    I = IQ(1:2:recordLength*2);
    Q = IQ(2:2:recordLength*2);

    %Plot IQ data in upper portion of figure
    subplot(2, 1, 1)
    x = 1:recordLength; 
    plot(x, I, x, Q) 
    title('IQBLOCK: File Playback')
    legend('I data', 'Q data')

    %Plot Spectrum in lower portion of figure
    subplot(2, 1, 2)
    plotTitle = 'IQBLOCK: Spectrum Plot Bounded By Sample Rate';
    RSA_API_IQ_to_Spectrum_dBm(dev, I, Q, plotTitle)
    drawnow

    %Obtain status of complete. If playback is set to loop forever,
    %complete should never return true. If playback is not set to loop
    %forever, break out of loop when complete returns true
    complete = invoke(dev.Playback, 'GetReplayComplete');
    if complete == 1
        if filePlayback.loop == 0
            fprintf('In GetReplayComplete, Replay Complete Status: True\n');
            break;
        end
    end

    %Increment loop counter
    running = running + 1;
end

fprintf('Replay Complete Status: %d\n', complete);

%Stop data acquisition
invoke(dev.Device, 'Stop');
close

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');