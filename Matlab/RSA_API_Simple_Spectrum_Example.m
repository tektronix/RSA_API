%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an RSA device that is connected to an
%external antenna or signal generator. Parameters are then defined by the
%user to plot a spectrum trace. 
%
%Adjustable Values in Script: userDefinedParameters, userDefinedSettings,
%   userDefinedTrace 
%Recommended Equipment: Antenna or Signal Generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initiate setup to connect to an RSA device
dev = icdevice('RSA_API_Driver');
connect(dev); 

%Adjustable values for iqblock data acquisition
userDefinedParameters.centerFreq = 2.4453e9;
userDefinedParameters.refLevel = -15.0;
userDefinedParameters.loopIterations = 500;
userDefinedParameters.timeout = 5000;

%Adjustable values for spectrum settings
userDefinedSettings.span = 40e6;
userDefinedSettings.rbw = 300e3;
userDefinedSettings.enableVBW = false;
userDefinedSettings.vbw = 300e3;
userDefinedSettings.traceLength = 801;
userDefinedSettings.window = 'SpectrumWindow_Kaiser';
userDefinedSettings.verticalUnit = 'SpectrumVerticalUnit_dBm';

%Adjustable values for spectrum trace
userDefinedTrace.trace = 'SpectrumTrace1';
userDefinedTrace.enable = true;
userDefinedTrace.detector = 'SpectrumDetector_PosPeak';

%Set user desired parameters for graphing spectrum
set(dev.Configure, 'CenterFreq', userDefinedParameters.centerFreq);
set(dev.Configure, 'ReferenceLevel', userDefinedParameters.refLevel);

%Get user desired parameters for graphing spectrum
centerFrequency = get(dev.Configure, 'CenterFreq');
refLvl = get(dev.Configure, 'ReferenceLevel');

%Verify user desired parameters for graphing by printing to screen
fprintf('Center frequency: %g\n', centerFrequency);
fprintf('Reference Level: %d\n', refLvl);

fprintf('\n');

%Obtain limits of spectrum
limits = invoke(dev.Spectrum, 'GetLimits');
fprintf('Spectrum Limits: \n');
fprintf('     Minimum Span: %d\n', limits.minSpan);
fprintf('     Maximum Span: %d\n', limits.maxSpan);
fprintf('     Minimum RBW: %d\n', limits.minRBW);
fprintf('     Maximum RBW: %d\n', limits.maxRBW);
fprintf('     Minimum VBW: %d\n', limits.minVBW);
fprintf('     Maximum VBW: %d\n', limits.maxVBW);
fprintf('     Minimum Trace Length: %d\n', limits.minTraceLength);
fprintf('     Maximum Trace Length: %d\n', limits.maxTraceLength);

% %Uncomment this section and comment SetSettings to set default
% %parameters for Spectrum
% %Set default parameters for Spectrum
% fprintf('Setting default values for spectrum\n');
% invoke(dev.Spectrum, 'SetDefault');

fprintf('\n');

%Set user defined parameters for Spectrum
invoke(dev.Spectrum, 'SetSettings', userDefinedSettings);

%Obtain settings of spectrum
settings = invoke(dev.Spectrum, 'GetSettings');
fprintf('Settings for Spectrum:\n');
fprintf('     Span: %d\n', settings.span);
fprintf('     RBW: %d\n', settings.rbw);
fprintf('     VBW Status: %d\n', settings.enableVBW);
fprintf('     VBW: %d\n', settings.vbw);
fprintf('     Trace Length: %d\n', settings.traceLength);
fprintf('     Window: %s\n', settings.window);
fprintf('     Vertical Unit: %s\n', settings.verticalUnit);
fprintf('     Actual Start Frequency: %d\n', settings.actualStartFreq);
fprintf('     Actual Stop Frequency: %d\n', settings.actualStopFreq)
fprintf('     Actual Frequency Step Size: %d\n', settings.actualFreqStepSize);
fprintf('     Actual RBW: %g\n', settings.actualRBW);
fprintf('     Actual Start VBW: %d\n', settings.actualVBW);
fprintf('     Actual Number of IQ Samples: %d\n', settings.actualNumIQSamples);

fprintf('\n');

%Enable Spectrum
enabled = true;
set(dev.Spectrum, 'Enable', enabled);
enable = get(dev.Spectrum, 'Enable');
fprintf('Spectrum Enable Status: %d\n', enable);

fprintf('\n');

%Set trace type
invoke(dev.Spectrum, 'SetTraceType', userDefinedTrace.trace, userDefinedTrace.enable, userDefinedTrace.detector);

%Obtain trace properties
[enable, detector] = invoke(dev.Spectrum, 'GetTraceType', userDefinedTrace.trace);
fprintf('Spectrum Trace:\n     Detector: %s\n     Type: %s\n     Enable Status: %d\n', userDefinedTrace.trace, detector, enable);
    
fprintf('\n');

%Parameters used for Spectrum plot
maxTracePoints = settings.traceLength;
freqStepSize = settings.actualFreqStepSize;
startFreq = settings.actualStartFreq;
endFreq = startFreq + (maxTracePoints-1) * freqStepSize;
freqs = startFreq:freqStepSize:endFreq;

%Initialize loop
running = 0;

fprintf('Beginning to plot Spectrum\n');
while(running < userDefinedParameters.loopIterations)  
    %Start data acquisition, needed in loop
    invoke(dev.Spectrum, 'AcquireTrace');  

    %Wait for data 
    ready = invoke(dev.Spectrum, 'WaitForTraceReady', userDefinedParameters.timeout);

    %If there is data, proceed to plot spectrum
    if ready
        %Obtain trace data
        traceData = invoke(dev.Spectrum, 'GetTrace', userDefinedTrace.trace, maxTracePoints);

        %Obtain trace info
        traceInfo = invoke(dev.Spectrum, 'GetTraceInfo');
        if running == 0
            fprintf('Trace Info: \n');
            fprintf('     Timestamp: %g\n', traceInfo.timestamp);
            fprintf('     Unix Time: %s\n', traceInfo.unixTime);
            fprintf('     Acquisition Data Status: %d\n', traceInfo.acqDataStatus);
        end
        
        %Plot Spectrum
        axis1 = plot(freqs, traceData, 'y');
        set(axis1, 'Color', 'black');                
        axis([startFreq, endFreq, userDefinedParameters.refLevel-120, userDefinedParameters.refLevel]);
        ylabel('Power (dBm)')
        xlabel('Frequency (Hz)')
        title('GetTrace: Spectrum')
        drawnow

        %Increment loop
        running = running + 1;
    end
end

%Stop data acquisition
set(dev.Spectrum, 'Enable', false);
invoke(dev.Device, 'Stop');
close

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');