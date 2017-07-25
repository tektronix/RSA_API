%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an RSA device that is connected to an
%external antenna or signal generator. Then sets up the parameters needed
%obtain IQ data from the connected equipment. Their are three functions in
%total that behave the same way, GetIQData, GetIQDataCplx, and
%GetIQDataDeinterleaved. Each is called to obtain IQ data and plots both
%their respective IQ data and spectrum in a figure. The spectrum displays
%both the sample rate and bandwidth of the RSA unit.
%
%Adjustable Values in Script: userDefinedParameters
%Recommended Equipment: Antenna or Signal Generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initiate setup to connect to an RSA device
dev = icdevice('RSA_API_Driver');
connect(dev); 

%Adjustable values for IQ data
userDefinedParameters.centerFreq = 100e6;
userDefinedParameters.refLevel = -20.0;
userDefinedParameters.bandwidth = 10.0e6;
userDefinedParameters.recordLength = 5000;

%Adjustable values for looping
userDefinedParameters.timeoutMsec = 5000;
userDefinedParameters.iqDataLoopIterations = 100;
userDefinedParameters.iqCplxLoopIterations = 100;
userDefinedParameters.iqDeinterleavedLoopIterations = 100;

%Set user desired parameters for graphing
set(dev.Configure, 'CenterFreq', userDefinedParameters.centerFreq);
set(dev.Configure, 'ReferenceLevel', userDefinedParameters.refLevel);
set(dev.Iqblock, 'IQBandwidth', userDefinedParameters.bandwidth);
set(dev.Iqblock, 'IQRecordLength', userDefinedParameters.recordLength);

%Get user desired parameters for graphing
centerFrequency = get(dev.Configure, 'CenterFreq');
refLvl = get(dev.Configure, 'ReferenceLevel');
iqBandwidth = get(dev.Iqblock, 'IQBandwidth');
recordLength = get(dev.Iqblock, 'IQRecordLength');

%Print user desired parameters for graphing to verify
fprintf('Center frequency: %g\n', centerFrequency);
fprintf('Reference Level: %d\n', refLvl);
fprintf('IQ Bandwidth: %d\n', iqBandwidth);
fprintf('IQ Record Length: %d\n', recordLength);

%Obtain properties of RSA device
minBandwidth = invoke(dev.Iqblock, 'GetMinIQBandwidth');
maxBandwidth = invoke(dev.Iqblock, 'GetMaxIQBandwidth');
maxSamples = invoke(dev.Iqblock, 'GetMaxIQRecordLength');

fprintf('Minimum IQ Bandwidth: %d\n', minBandwidth);
fprintf('Maximum IQ Bandwidth: %d\n', maxBandwidth);
fprintf('Maximum IQ Record Length: %d\n', maxSamples);  

fprintf('\n');

fprintf('Beginning to plot IQ Data\n');
running = 0;

%Start data acquisition
% invoke(dev.Device, 'Run');

%Begin plotting using GetIQData
while(running < userDefinedParameters.iqDataLoopIterations)  
    
    %Start data acquisition
    invoke(dev.Device, 'Run');
    
    %Wait for data 
    ready = invoke(dev.Iqblock, 'WaitForIQDataReady', userDefinedParameters.timeoutMsec);

    %If there is data, proceed to plot data
    if ready
        %Obtain IQ data and split into own separate arrays
        iqData = invoke(dev.Iqblock, 'GetIQData', 0, recordLength);
        I = iqData(1:2:recordLength*2);
        Q = iqData(2:2:recordLength*2);

        %Obtain header information of current IQ data block
        if running == 0
            [header] = invoke(dev.Iqblock, 'GetIQAcqInfo');
            fprintf('Properties of IQ Acquisition Info:\n');
            fprintf('     Acquisition Data Status: %d\n', header.acqStatus);
            fprintf('     Acquisition Timestamp: %d\n', header.sample0Timestamp);
            fprintf('     Acquisition Unix Time: %s\n', header.sample0UnixTime);
        end

        %Plot IQ data in upper portion of figure
        subplot(2, 1, 1)
        x = 1:recordLength; 
        plot(x, I, x, Q) 
        title('GetIQData: IQ Data')
        legend('I data', 'Q data')

        %Plot Spectrum in lower portion of figure
        subplot(2, 1, 2)
        plotTitle = 'GetIQData: Spectrum Plot Bounded By Sample Rate';
        RSA_API_IQ_to_Spectrum_dBm(dev, I, Q, plotTitle)  
    end

    %Update loop counter
    running = running + 1;
end

% fprintf('\n');
% 
% fprintf('Beginning to plot IQ Data Complex\n');
% running = 0;
% 
% %Begin plotting using GetIQDataCplx
% while(running < userDefinedParameters.iqCplxLoopIterations)  
%     %Wait for data 
%     ready = invoke(dev.Iqblock, 'WaitForIQDataReady', userDefinedParameters.timeoutMsec);
% 
%     %If there is data, proceed to plot data
%     if ready
%         %Obtain IQ data and split into own separate arrays
%         iqData = invoke(dev.Iqblock, 'GetIQDataCplx', 0, recordLength);
%         I = iqData(1:2:recordLength*2);
%         Q = iqData(2:2:recordLength*2);
% 
%         %Obtain header information of current IQ data block
%         if running == 0
%             [header] = invoke(dev.Iqblock, 'GetIQAcqInfo');
%             fprintf('Properties of IQ Acquisition Info:\n');
%             fprintf('     Acquisition Data Status: %d\n', header.acqStatus);
%             fprintf('     Acquisition Timestamp: %d\n', header.sample0Timestamp);
%             fprintf('     Acquisition Unix Time: %s\n', header.sample0UnixTime);
%         end
% 
%         %Plot IQ data in upper portion of figure
%         subplot(2, 1, 1)
%         x = 1:recordLength; 
%         plot(x, I, x, Q) 
%         title('GetIQDataCplx: IQ Data')
%         legend('I data', 'Q data')
% 
%         %Plot Spectrum in lower portion of figure
%         subplot(2, 1, 2)
%         plotTitle = 'GetIQDataCplx: Spectrum Plot Bounded By Sample Rate';
%         RSA_API_IQ_to_Spectrum_dBm(dev, I, Q, plotTitle)     
%     end
% 
%     %Update loop counter
%     running = running + 1;
% end
% 
% fprintf('\n');
% 
% fprintf('Beginning to plot IQ Data Deinterleaved\n');
% running = 0;
% 
% while(running < userDefinedParameters.iqDeinterleavedLoopIterations)  
%     %Wait for data 
%     ready = invoke(dev.Iqblock, 'WaitForIQDataReady', userDefinedParameters.timeoutMsec);
% 
%     %If there is data, proceed to plot data
%     if ready
%         %Obtain IQ data
%         [I, Q] = invoke(dev.Iqblock, 'GetIQDataDeinterleaved', 0, recordLength);
% 
%         %Obtain header information of current IQ data block
%         if running == 0
%             [header] = invoke(dev.Iqblock, 'GetIQAcqInfo');
%             fprintf('Properties of IQ Acquisition Info:\n');
%             fprintf('     Acquisition Data Status: %d\n', header.acqStatus);
%             fprintf('     Acquisition Timestamp: %d\n', header.sample0Timestamp);
%             fprintf('     Acquisition Unix Time: %s\n', header.sample0UnixTime);
%         end
% 
%         %Plot IQ data in upper portion of figure
%         subplot(2, 1, 1)
%         x = 1:recordLength; 
%         plot(x, I, x, Q) 
%         title('GetIQDataDeinterleaved: IQ Data')
%         legend('I data', 'Q data')
% 
%         %Plot Spectrum in lower portion of figure
%         subplot(2, 1, 2)
%         plotTitle = 'GetIQDataDeinterleaved: Spectrum Plot Bounded By Sample Rate';
%         RSA_API_IQ_to_Spectrum_dBm(dev, I, Q, plotTitle) 
%     end
% 
%     %Update loop counter
%     running = running + 1;
% end

%Stop data acquisition and close all figures
invoke(dev.Device, 'Stop');
close
close

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');