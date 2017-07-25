%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an RSA device that is connected to an
%external spectrum analyzer with RF input. Parameters are then set to
%output a signal to the external spectrum analyzer where every half second,
%the signal will adjust by a small fraction of a GHz. Addtionally, the
%height of the signal will change everytime the signal moves.
%
%Adjustable Values in Script: userDefinedParameters
%Required Equipment: Spectrum Analyzer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initiate setup to connect to an RSA device
dev = icdevice('RSA_API_Driver');
connect(dev); 

%Adjustable values for tracking generator
userDefinedParameters.centerFreq = 1e9;
userDefinedParameters.minCenterFreq = 0.99e9;
userDefinedParameters.maxCenterFreq = 1.01e9;
userDefinedParameters.stepSize = 10;
userDefinedParameters.refLevel = -0.0;
userDefinedParameters.bandwidth = 10.0e6;

%Adjustable values for looping tracking generator
userDefinedParameters.loopIterations = 100;
userDefinedParameters.loopPlaySeconds = .5;

%Set user desired parameters for tracking generator
set(dev.Configure, 'CenterFreq', userDefinedParameters.centerFreq);
set(dev.Configure, 'ReferenceLevel', userDefinedParameters.refLevel);
set(dev.Iqblock, 'IQBandwidth', userDefinedParameters.bandwidth);

%Get user desired parameters for tracking generator
centerFrequency = get(dev.Configure, 'CenterFreq');
refLvl = get(dev.Configure, 'ReferenceLevel');
iqBandwidth = get(dev.Iqblock, 'IQBandwidth');

%Verify user desired parameters for tracking generator by printing to screen
fprintf('Center frequency: %g\n', centerFrequency);
fprintf('Reference Level: %d\n', refLvl);
fprintf('IQ Bandwidth: %d\n', iqBandwidth);

%Determine the step size for center frequency
incrementSize = (userDefinedParameters.maxCenterFreq - userDefinedParameters.minCenterFreq)/(userDefinedParameters.stepSize - 1);

%Set center frequency in array based on number of steps in range and
%increment size
centerFreq(1) = (userDefinedParameters.minCenterFreq);
for i = 1:(userDefinedParameters.stepSize - 1)
   centerFreq(end+1) = userDefinedParameters.minCenterFreq + incrementSize * i;
end

fprintf('\n');

%Determine if RSA device has tracking generator hardware installed
installed = invoke(dev.Trkgen, 'GetHWInstalled');
if installed == true
    fprintf('Tracking generator hardware is installed\n');
    
    %Enable Tracking Generator
    setEnable = true;
    set(dev.Trkgen, 'Enable', setEnable);
    enabled = get(dev.Trkgen, 'Enable');
    fprintf('Tracking Generator Enable Status: %d\n', enabled);
    
    %Initialize loop
    running = 0;
    fprintf('Starting to output signal with tracking generator\n');
    fprintf('\n');
    
    while(running < userDefinedParameters.loopIterations) 
        %Output level ranges from -40 to 0. Loop through each possible
        %value
        loopLevel = mod(running, 41);
        set(dev.Trkgen, 'OutputLevel', (-loopLevel));
        level = get(dev.Trkgen, 'OutputLevel');

        %Set center frequency to a new frequency to adjust the output of
        %tracking generator
        loop = mod(running, userDefinedParameters.stepSize);
        userDefinedParameters.centerFreq = centerFreq(loop + 1);
        set(dev.Configure, 'CenterFreq', userDefinedParameters.centerFreq);
        centerFrequency = get(dev.Configure, 'CenterFreq');
                
        %Print current signal properties of output signal
        fprintf('Output Level: %d\n', level);
        fprintf('Center Frequency: %g\n', centerFrequency);
        
        %Pause loop for a moment to check tracking generator output then
        %increment loop
        pause(userDefinedParameters.loopPlaySeconds);
        running = running + 1;
    end
else
    fprintf('Tracking generator hardware is not installed. Ending Test\n');
end

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');