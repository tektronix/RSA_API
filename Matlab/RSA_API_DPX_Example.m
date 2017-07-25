%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an RSA device that is connected to an
%external antenna or signal generator. The parameters are then set to
%obtain a spectrum, sogram, and spectrum trace based on the parameters
%defined. The spectrum, sogram, and spectrum trace are all plotted on one
%figure. After the loop completes, another figure will show up showing data
%from the sogram line.
%
%Adjustable Values in Script: userDefinedParameters, userDefinedParameter,
%   userDefinedSpectrum, userDefinedSogram, userDefinedSogramTrace
%Recommended Equipment: Antenna or Signal Generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initiate setup to connect to an RSA device
dev = icdevice('RSA_API_Driver');
connect(dev); 

%Adjustable values for dpx data acquisition
userDefinedParameters.centerFreq = 2.4453e9;
userDefinedParameters.refLevel = -25.0;
userDefinedParameters.timeout = 1000;
userDefinedParameters.frames = 500;

%Adjustable values for dpx parameter. This struct contains all inputs for
%SetParameters
userDefinedParameter.fspan = 40e6;
userDefinedParameter.resBandwidth = 30e3;
userDefinedParameter.bitmapWidth = 801;
userDefinedParameter.tracePtsPerPixel = 1;
userDefinedParameter.yUnit = 'VerticalUnit_dBm';
userDefinedParameter.yTop = 0;
userDefinedParameter.yBottom = -100;
userDefinedParameter.infinitePersistance = false;
userDefinedParameter.persistanceTimeSec = 1;
userDefinedParameter.showOnlyTriggerFrames = false;

%Adjustable values for spectrum trace
userDefinedSpectrum.traceType = 'TraceTypeAverage';
userDefinedSpectrum.traceIndex = 1;

%Adjustable values for sogram
userDefinedSogram.timePerBitmapLine = 0.0001;
userDefinedSogram.timeResolution = 0.0001;
userDefinedSogram.maxPower = -30;
userDefinedSogram.minPower = -150;

%Adjustable values for sogram
userDefinedSogramTrace.traceType = 'TraceTypeAverage';

%Set user desired parameters for graphing dpx
set(dev.Configure, 'CenterFreq', userDefinedParameters.centerFreq);
set(dev.Configure, 'ReferenceLevel', userDefinedParameters.refLevel);

%Get user desired parameters for graphing dpx
centerFrequency = get(dev.Configure, 'CenterFreq');
refLvl = get(dev.Configure, 'ReferenceLevel');

%Verify user desired parameters for graphing by printing to screen
fprintf('Center frequency: %g\n', centerFrequency);
fprintf('Reference Level: %d\n', refLvl);

fprintf('\n');

%Obtain minimum and maximum RBW values
[minRBW, maxRBW] = invoke(dev.DPX, 'GetRBWRange', userDefinedParameter.fspan);
fprintf('Minimum RBW: %g\n', minRBW);
fprintf('Maximum RBW: %d\n', maxRBW);

fprintf('\n');

fprintf('Resetting DPX Settings\n');
invoke(dev.DPX, 'Reset');

fprintf('\n');

%Set user defined trace for dpx
fprintf('User Defined Trace Index: %d Trace Type: %s\n', userDefinedSpectrum.traceIndex, userDefinedSpectrum.traceType);
invoke(dev.DPX, 'SetSpectrumTraceType', userDefinedSpectrum.traceIndex, userDefinedSpectrum.traceType);

fprintf('\n');

%Print all user defined parameters to command window
fprintf('User Defined DPX Parameters,\n');
fprintf('     Span: %d\n', userDefinedParameter.fspan);
fprintf('     RBW: %d\n', userDefinedParameter.resBandwidth);
fprintf('     Bitmap Width: %d\n', userDefinedParameter.bitmapWidth);
fprintf('     Trace Points Per Pixel: %d\n', userDefinedParameter.tracePtsPerPixel);
fprintf('     Units of Y-Axis: %s\n', userDefinedParameter.yUnit);
fprintf('     Maximum Y-Axis: %d\n', userDefinedParameter.yTop);
fprintf('     Minimum Y-Axis: %d\n', userDefinedParameter.yBottom);
fprintf('     Infinite Persistence: %d\n', userDefinedParameter.infinitePersistance);
fprintf('     Persistence Time in Seconds: %d\n', userDefinedParameter.persistanceTimeSec);
fprintf('     Show Only Trigger Frames: %d\n', userDefinedParameter.showOnlyTriggerFrames);

%Set DPX parameters
invoke(dev.DPX, 'SetParameters', userDefinedParameter.fspan, userDefinedParameter.resBandwidth, ...
    userDefinedParameter.bitmapWidth, userDefinedParameter.tracePtsPerPixel, userDefinedParameter.yUnit, ...
    userDefinedParameter.yTop, userDefinedParameter.yBottom, userDefinedParameter.infinitePersistance, ...
    userDefinedParameter.persistanceTimeSec, userDefinedParameter.showOnlyTriggerFrames);

fprintf('\n');

%Predefine boolean values for function Configure
enableSpectrum = true;
enableSpectrogram = true;
fprintf('Enabling Spectrum and Spectrogram to obtain settings\n');

%Need to enable spectrum and spectrogram to obtain settings.
invoke(dev.DPX, 'Configure', enableSpectrum, enableSpectrogram);

fprintf('\n');

%Obtain some settings of DPX parameters
settings = invoke(dev.DPX, 'GetSettings');

%Print settings of DPX
fprintf('Returned DPX Settings:\n');
fprintf('     Enable Spectrum: %d\n', settings.enableSpectrum);
fprintf('     Enable Spectrogram: %d\n', settings.enableSpectrogram);
fprintf('     Bitmap Width: %d\n', settings.bitmapWidth);
fprintf('     Bitmap Height: %d\n', settings.bitmapHeight);
fprintf('     Trace Length: %d\n', settings.traceLength);
fprintf('     Decay Factor: %g\n', settings.decayFactor);
fprintf('     Actual RBW value: %g\n', settings.actualRBW);

fprintf('\n');

%Set DPX sogram parameters
invoke(dev.DPX, 'SetSogramParameters', userDefinedSogram.timePerBitmapLine, userDefinedSogram.timeResolution, userDefinedSogram.maxPower, userDefinedSogram.minPower);

%Need to enable spectrum and spectrogram to obtain sogram settings
invoke(dev.DPX, 'Configure', enableSpectrum, enableSpectrogram);

%Obtain sogram settings
sogramSettings = invoke(dev.DPX, 'GetSogramSettings');
fprintf('Returned DPX Sogram Parameters:\n');
fprintf('     Bitmap Width: %d\n', sogramSettings.bitmapWidth);
fprintf('     Bitmap Height: %d\n', sogramSettings.bitmapHeight);
fprintf('     Sogram Trace Line Time: %g\n', sogramSettings.sogramTraceLineTime);
fprintf('     Sogram Bitmap Line Time: %g\n', sogramSettings.sogramBitmapLineTime);

fprintf('\n');

%Set user defined sogram trace type
fprintf('Setting User Defined Trace Type: %s\n', userDefinedSogramTrace.traceType);
invoke(dev.DPX, 'SetSogramTraceType', userDefinedSogramTrace.traceType);

fprintf('\n');

%Enable DPX and start data acquisition
fprintf('Beginning to plot using DPX\n');
set(dev.DPX, 'Enable', false);
set(dev.DPX, 'Enable', true);

fprintf('\n');

%Start data acquisition
invoke(dev.Device, 'Run');

for i = 1:userDefinedParameters.frames
    %Wait for data 
    bufferReady = 0;
    dataReady = invoke(dev.DPX, 'WaitForDataReady', userDefinedParameters.timeout);
    
    if dataReady
        bufferReady = invoke(dev.DPX, 'IsFrameBufferAvailable');
    end
    
    if bufferReady
        %Obtain frame buffer
        frameBuffer =  invoke(dev.DPX, 'GetFrameBuffer');

        %Obtain frame info. Note this is a live update for count, unlike
        %frame buffer
        [frameCount, fftCount] = invoke(dev.DPX, 'GetFrameInfo');

        %Print info about frame on first loop only
        if i == 1
            fprintf('Properties of Frame Info:\n');
            fprintf('     FFT count: %d\n', fftCount);
            fprintf('     Frame Count: %d\n', frameCount);

            fprintf('\n');
            
            fprintf('Properties of Frames:\n');
            fprintf('     FFT Per Frame: %d\n', frameBuffer.fftPerFrame);
            fprintf('     FFT Count: %d\n', frameBuffer.fftCount);
            fprintf('     Frame Count: %d\n', frameBuffer.frameCount);
            fprintf('     Timestamp: %d\n', frameBuffer.timestamp);
            fprintf('     Acquisition Data Status: %d\n', frameBuffer.acqDataStatus);
            fprintf('     Minimum Signal Duration: %d\n', frameBuffer.minSigDuration);
            fprintf('     Minimum Signal Duration Out Of Range: %d\n', frameBuffer.minSigDurOutOfRange);
            fprintf('     Spectrum Bitmap Width: %d\n', frameBuffer.spectrumBitmapWidth);
            fprintf('     Spectrum Bitmap Height: %d\n', frameBuffer.spectrumBitmapHeight);
            fprintf('     Spectrum Bitmap Size: %d\n', frameBuffer.spectrumBitmapSize);
            fprintf('     Spectrum Trace Length: %d\n', frameBuffer.spectrumTraceLength);
            fprintf('     Number of Spectrum Traces: %d\n', frameBuffer.numSpectrumTraces);
            fprintf('     Spectrum Enable: %d\n', frameBuffer.spectrumEnabled);
            fprintf('     Spectrogram Enable: %d\n', frameBuffer.spectrogramEnabled);
 
            [numBitmaps, length] = size(frameBuffer.spectrumBitmap);
            spectrumBitmapType = class(frameBuffer.spectrumBitmap);
            fprintf('     Spectrum Bitmap: [%dx%d %s]\n', numBitmaps, length, spectrumBitmapType);
            [traceLength, numTraces] = size(frameBuffer.spectrumTraces);
            spectrumTracesType = class(frameBuffer.spectrumTraces);
            fprintf('     Spectrum Traces: [%dx%d %s]\n', traceLength, numTraces, spectrumTracesType);
            
            fprintf('     Sogram Bitmap Width: %d\n', frameBuffer.sogramBitmapWidth);
            fprintf('     Sogram Bitmap Height: %d\n', frameBuffer.sogramBitmapHeight);
            fprintf('     Sogram Bitmap Size: %d\n', frameBuffer.sogramBitmapSize);
            fprintf('     Number of Sogram Bitmap Valid Lines: %d\n', frameBuffer.sogramBitmapNumValidLines);
            
            [numSogramBitmaps, lengthSogramBitmap] = size(frameBuffer.sogramBitmap);
            sogramBitmapType = class(frameBuffer.sogramBitmap);
            fprintf('     Sogram Bitmap: [%dx%d %s]\n', numSogramBitmaps, lengthSogramBitmap, sogramBitmapType);
            [rowTimestamp, lengthTimestamp] = size(frameBuffer.sogramBitmapTimestampArray);
            sogramBitmapTimestampArrayType = class(frameBuffer.sogramBitmapTimestampArray);
            fprintf('     Sogram Bitmap Timestamp Array: [%dx%d %s]\n', rowTimestamp, lengthTimestamp, sogramBitmapTimestampArrayType);
            [rowTrigger, lengthTrigger] = size(frameBuffer.sogramBitmapContainTriggerArray);
            sogramBitmapContainTriggerArrayType = class(frameBuffer.sogramBitmapContainTriggerArray);
            fprintf('     Sogram Bitmap Trigger Array: [%dx%d %s]\n', rowTrigger, lengthTrigger, sogramBitmapContainTriggerArrayType);
        end
           
        %Plot spectrum bitmap
        brightBitpmap = vec2mat(frameBuffer.spectrumBitmap, frameBuffer.spectrumBitmapWidth);
        fadedBitpmap = 10*log10(brightBitpmap*1000);
        subplot(3,1,1);
        imagesc(fadedBitpmap)
%         ylabel('Bitmap Height')
%         xlabel('Bitmap Width')
        title('DPX Spectrum Bitmap');
        
        %Plot sogram bitmap
        sogram = vec2mat(frameBuffer.sogramBitmap, frameBuffer.sogramBitmapWidth);
        subplot(3,1,2)
        frameBuffer.sogramBitmap;
        imagesc(sogram);
%         ylabel('Bitmap Height')
%         xlabel('Bitmap Width')
        title('DPX Sogram Bitmap');
        
        %Plot Spectrum trace in dBm
        Watts = frameBuffer.spectrumTraces(:,1);
        spectrum = 10*log10(Watts*1000);
        subplot(3,1,3)
        plot(spectrum)
        axis([0, userDefinedParameter.bitmapWidth, userDefinedParameter.yBottom, userDefinedParameter.yTop]);
        ylabel('Power (dBm)')
%         xlabel('Bitmap Width')
        title('DPX Spectrum Trace (dBm)');
        drawnow;
    end
    
    %Need to finish frame buffer before can retrieve next frame buffer
    invoke(dev.DPX, 'FinishFrameBuffer', true);
end

%Stop data acquisition
invoke(dev.Device, 'Stop');

fprintf('\n');

%Obtain line count
linecount = invoke(dev.DPX, 'GetSogramHiResLineCountLatest');
fprintf('Line Count Found for High Resolution Sogram: %d\n', linecount); 

if linecount > 4000
    linecount = 4000;
end

fprintf('Obtaining data to product high resolution sogram figure. Long pause is expected.\n')
fprintf('Line Count Used to Generate High Resolution Sogram Bitmap: %d\n', linecount); 

%Create a high resolution sogram of data acquired
A= zeros(linecount,801);
for i = 1:linecount
    hires = invoke(dev.DPX, 'GetSogramHiResLine', i, 801, 0);
    timestamps(i) = invoke(dev.DPX, 'GetSogramHiResLineTimestamp', i);
    triggers(i) = invoke(dev.DPX, 'GetSogramHiResLineTriggered', i);
    A(i,:) = hires;
end

%Plot the high resolution sogram bitmap on a new figure
figure
imagesc(A);
title('DPX Sogram High Resolution Bitmap');

%Disable DPX
set(dev.DPX, 'Enable', false);
fprintf('DPX is disabled\n');
invoke(dev.Device, 'Stop');

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');