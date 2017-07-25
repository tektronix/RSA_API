%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an RSA device that is connected to an
%external device that pulses to trigger on. User sets up the parameters to
%plot a signal that contains a pulse. Their are four situations that can
%apply to this situation. Continuously plot data, trigger on certain level,
%try to trigger but trigger level is too high, and forcing RSA device to
%force trigger. Each scenario is plotted below.
%
%Adjustable Values in Script: userDefinedParameters
%Required Equipment: Antenna, Signal Generator, Device that Produces a
%   Signal 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initiate setup to connect to an RSA device
dev = icdevice('RSA_API_Driver');
connect(dev); 

%Adjustable values for Trigger
userDefinedParameters.triggerLevel = 0;
userDefinedParameters.incrementTriggerLevel = -5;
userDefinedParameters.setPosition = 50;
userDefinedParameters.source = 'TriggerSourceIFPowerLevel';
userDefinedParameters.transition = 'TriggerTransitionHL';

%Adjustable values for iqblock data acquisition
userDefinedParameters.centerFreq = 101.9e6;
userDefinedParameters.refLevel = -30.0;
userDefinedParameters.bandwidth = 40e6;
userDefinedParameters.recordLength = 500;

%Adjustable values for plotting
userDefinedParameters.timeoutMsec = 2000;
userDefinedParameters.loopIterations = 100;     %If below 30, will get set to 30 in this script

%Set user desired parameters for trigger
set(dev.Trigger, 'Source', userDefinedParameters.source);
set(dev.Trigger, 'Transition', userDefinedParameters.transition);
set(dev.Trigger, 'IFPowerLevel', userDefinedParameters.triggerLevel);
set(dev.Trigger, 'PositionPercentage', userDefinedParameters.setPosition);

%Get user desired parameters for trigger
source = get(dev.Trigger, 'Source');
transition = get(dev.Trigger, 'Transition');
level = get(dev.Trigger, 'IFPowerLevel');
position = get(dev.Trigger, 'PositionPercentage');

%Verify user desired parameters for trigger by printing to screen
fprintf('Trigger Source: %s\n', source);
fprintf('Trigger Transition: %s\n', transition);
fprintf('IF Power Trigger Level: %d\n', level);
fprintf('Trigger Position Percentage: %d\n', position);

fprintf('\n');

%Set user desired parameters for graphing trigger
set(dev.Configure, 'CenterFreq', userDefinedParameters.centerFreq);
set(dev.Configure, 'ReferenceLevel', userDefinedParameters.refLevel);
set(dev.Iqblock, 'IQBandwidth', userDefinedParameters.bandwidth);
set(dev.Iqblock, 'IQRecordLength', userDefinedParameters.recordLength);

%Get user desired parameters for graphing trigger
centerFrequency = get(dev.Configure, 'CenterFreq');
refLvl = get(dev.Configure, 'ReferenceLevel');
iqBandwidth = get(dev.Iqblock, 'IQBandwidth');
recordLength = get(dev.Iqblock, 'IQRecordLength');

%Verify user desired parameters for graphing by printing to screen
fprintf('Center frequency: %g\n', centerFrequency);
fprintf('Reference Level: %d\n', refLvl);
fprintf('IQ Bandwidth: %d\n', iqBandwidth);
fprintf('IQ Record Length: %d\n', recordLength);

fprintf('\n');

%Start data acquisition. Set up loop for graphing trigger
invoke(dev.Iqblock, 'AcquireIQData');
running = 0;

%Ensure their is enough loops to see trigger events
if userDefinedParameters.loopIterations < 30
    userDefinedParameters.loopIterations = 30;
end

%Checking four different trigger scenarios
increments = int64(userDefinedParameters.loopIterations / 3);

%Validates trigger properties and functions with visual inspection
while(running < userDefinedParameters.loopIterations)  
    if(running == 0)
        %Allow continuous data acquisition in freerun mode
        mode = 'freeRun';
        set(dev.Trigger, 'Mode', mode);
        mode = get(dev.Trigger, 'Mode');
        fprintf('Trigger Mode: %s\n', mode);
    elseif(running == increments)
        %Need to stop data acquisition to correctly switch trigger modes
        invoke(dev.Device, 'Stop');

        %Capture data on trigger
        mode = 'triggered';
        set(dev.Trigger, 'Mode', mode);
        mode = get(dev.Trigger, 'Mode');
        fprintf('Trigger Mode: %s\n', mode);

        %Restart data acquisition
        invoke(dev.Iqblock, 'AcquireIQData');   
    end

    invoke(dev.Iqblock, 'AcquireIQData');   
    %Wait for data acquisition to occur
    ready = invoke(dev.Iqblock, 'WaitForIQDataReady', userDefinedParameters.timeoutMsec);

    if ready
        %Get IQ data from demo board
        iqData = invoke(dev.Iqblock, 'GetIQData', 0, recordLength);
        I = iqData(1:2:recordLength*2);
        Q = iqData(2:2:recordLength*2);

        %Plot IQ data on top half of figure
        subplot(2, 1, 1)
        x = 1:recordLength; 
        plot(x, I, x, Q) 
        
        %Update title of figure to indicate current trigger event
        if (running >= 0) && (running < increments)
            title('GetIQData: IQ Data Freerun')
            plotTitle = 'GetIQData Freerun: Spectrum Plot Bounded By Sample Rate';
        elseif running >= (increments)
            title('GetIQData: IQ Data Triggered')
            plotTitle = 'GetIQData Triggered: Spectrum Plot Bounded By Sample Rate';
        end
        legend('I data', 'Q data')

        %Plot spectrum on bottom half of figure
        subplot(2, 1, 2)
        RSA_API_IQ_to_Spectrum_dBm(dev, I, Q, plotTitle)  
        
        %Increment loop
        running = running + 1;
    else
        userDefinedParameters.triggerLevel = userDefinedParameters.triggerLevel + userDefinedParameters.incrementTriggerLevel;
        
        if userDefinedParameters.triggerLevel < -170 || userDefinedParameters.triggerLevel > 50
            fprintf('Limit reached for trigger level, no triggering signals were found.\n');
            fprintf('Proceeding to force trigger until end of loop.\n');
            invoke(dev.Trigger, 'ForceTrigger');
        else
            %Need to stop data acquisition to correctly adjust IF power level
            invoke(dev.Device, 'Stop');

            level = get(dev.Trigger, 'IFPowerLevel');
            fprintf('Expected signal power level is likely too low for given trigger level\n')
            fprintf('Current Trigger Level: %d\n', level);

            set(dev.Trigger, 'IFPowerLevel', userDefinedParameters.triggerLevel);
            level = get(dev.Trigger, 'IFPowerLevel');
            fprintf('New Trigger Level: %d\n', level);
            
            %Restart data acquisition
            fprintf('Forcing Trigger\n');
            invoke(dev.Iqblock, 'AcquireIQData'); 
            invoke(dev.Trigger, 'ForceTrigger');
        end
        
        %Wait for data acquisition to occur. Will occur due to forced
        %trigger.
        ready = invoke(dev.Iqblock, 'WaitForIQDataReady', userDefinedParameters.timeoutMsec);

        if ready
            %Get IQ data from demo board
            iqData = invoke(dev.Iqblock, 'GetIQData', 0, recordLength);
            I = iqData(1:2:recordLength*2);
            Q = iqData(2:2:recordLength*2);

            %Plot IQ data on top half of figure
            subplot(2, 1, 1)
            x = 1:recordLength; 
            plot(x, I, x, Q) 
            %Update title of figure to indicate forced trigger event
            title('GetIQData: IQ Data Forced Trigger')
            legend('I data', 'Q data')

            %Plot spectrum on bottom half of figure
            subplot(2, 1, 2)
            %Update title of figure to indicate forced trigger event
            plotTitle = 'GetIQData Forced Trigger: Spectrum Plot Bounded By Sample Rate';
            RSA_API_IQ_to_Spectrum_dBm(dev, I, Q, plotTitle)  
        end   
        
        %Increment loop
        running = running + 1;
    end   
end

%Stop and close data acquisiton
invoke(dev.Device, 'Stop');
close

%Set trigger mode back to freeRun in case trying to collect additional IQ
%data
mode = 'freeRun';
set(dev.Trigger, 'Mode', mode);

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');