%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an RSA device that is connected to an
%external antenna. Then sets up the parameters needed to play a FM radio
%station, in this case 101.9, at half volume. It will play this station for
%six seconds before switching to another radio station to play for another
%five seconds. During most of the time the audio is playing, a graph will
%appear plotting current audio data.
%
%Adjustable Values in Script: userDefinedParameters
%Required Equipment: Antenna
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initiate setup to connect to an RSA device
dev = icdevice('RSA_API_Driver');
connect(dev); 

%Adjustable values for audio data acquisition
userDefinedParameters.centerFreq = 101.9e6;
userDefinedParameters.refLevel = -25.0;
userDefinedParameters.loopIterations = 200;

%Adjustable values for playing audio
userDefinedParameters.mode = 'ADM_FM_200KHZ';
userDefinedParameters.vol = 0.5;
userDefinedParameters.loopPlaySeconds = .1;
userDefinedParameters.setOffset = -800000;
userDefinedParameters.mute = false;

fprintf('Setting center frequency to FM radio station %g\n', userDefinedParameters.centerFreq/(1e6));

%Set user desired parameters for audio
set(dev.Configure, 'CenterFreq', userDefinedParameters.centerFreq);
set(dev.Configure, 'ReferenceLevel', userDefinedParameters.refLevel);
set(dev.Audio, 'Mode', userDefinedParameters.mode);
set(dev.Audio, 'Volume', userDefinedParameters.vol);
set(dev.Audio, 'Mute', userDefinedParameters.mute);

%Get user desired parameters for audio playback
centerFrequency = get(dev.Configure, 'CenterFreq');
refLvl = get(dev.Configure, 'ReferenceLevel');
mode = get(dev.Audio, 'Mode');
volume = get(dev.Audio, 'Volume');
mute = get(dev.Audio, 'Mute');

%Verify user desired parameters by printing to screen
fprintf('Center frequency: %g\n', centerFrequency);
fprintf('Reference Level: %d\n', refLvl);
fprintf('Audio Demodulation Mode: %s\n', mode);
fprintf('Audio Volume: %d\n', (volume*100));
fprintf('Mute Status: %d\n', mute);

fprintf('\n');

%Start audio playback
fprintf('Starting audio playback\n');
invoke(dev.Device, 'Run');
invoke(dev.Audio, 'Start');
fprintf('Playing radio station %g\n', (userDefinedParameters.centerFreq/(1e6)));

%Allow playback to play for a second. Ensures at least a second of audio is
%played
pause(1);

%Initialize loop values
running = 0;
halfwayPoint = userDefinedParameters.loopIterations / 2;

%Determine inSize parameter for GetData based on user input
bytesPerSecond = 32000;
inSize = bytesPerSecond * userDefinedParameters.loopPlaySeconds;

%Can only retrieve 16384 byes of data at a time, rate is 32000 bytes per
%seconds. At max, roughly half a second of audio data can be retrieved at a
%time
if inSize > 16384
    inSize = 16384;
end

while(running < userDefinedParameters.loopIterations)  
    %Obtain audio data
    [data, outSize] = invoke(dev.Audio, 'GetData', inSize);

    %Plot audio data
    plot(data)
    title('Audio Data');        %add radio station here
    axis([0, inSize, -3.5e4, 3.5e4])
    drawnow

    %Pause for length of user defined duration. Used to allow audio to play
    %for a certain length of time
    pause(userDefinedParameters.loopPlaySeconds);
    running = running + 1;
    
    %Halfway through audio playback, change audio station. running + 0.5 is
    %used to account for odd intergers
    if (mod(running,halfwayPoint) == 0 || mod(running + 0.5,halfwayPoint) == 0) && running ~= userDefinedParameters.loopIterations
        %Switch to another predetermined radio station using frequency
        %offset 
        set(dev.Audio, 'FrequencyOffset', userDefinedParameters.setOffset);
        offset = get(dev.Audio, 'FrequencyOffset');    
        fprintf('Audio Frequency Offset: %d\n', offset);
                
        %Inform user which new radio station is being played
        center = get(dev.Configure, 'CenterFreq');
        fprintf('Playing radio station %g\n', (center+offset)/(1e6));
        pause(1);
    end
end

%Stop audio playback
invoke(dev.Audio, 'Stop');
invoke(dev.Device, 'Stop');
close

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');