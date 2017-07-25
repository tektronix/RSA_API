%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an RSA device that is connected to an
%external antenna or signal generator. Then sets up the parameters needed
%to plot IQ data and a spectrum. 
%
%Adjustable Values in Script: userDefinedParameters
%Required Equipment: Antenna or Signal Generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initiate setup to connect to an RSA device
dev = icdevice('RSA_API_Driver');
connect(dev); 

%Adjustable values for IQ Stream data acquisition
userDefinedParameters.centerFreq = 101.9e6;
userDefinedParameters.refLevel = -15.0;
userDefinedParameters.bw_req = 10.0e6;
userDefinedParameters.setBuffer = 1;
userDefinedParameters.loopIterations = 100;

%Set user desired parameters for IQ Stream
set(dev.Configure, 'CenterFreq', userDefinedParameters.centerFreq);
set(dev.Configure, 'ReferenceLevel', userDefinedParameters.refLevel);

%Set and obtain user defined acquisition bandwidth and sample rate
invoke(dev.IQStream, 'SetAcqBandwidth', userDefinedParameters.bw_req);
[bwHz_act, srSps] = invoke(dev.IQStream, 'GetAcqParameters');

fprintf('IQ Stream Acquisition Bandwidth: %d\n', bwHz_act);
fprintf('IQ Stream Sample Rate: %d\n', srSps);

fprintf('\n');

%Set output data destination and data type
fprintf('Setting output configuration parameters\n');
destination = 'IQSOD_CLIENT';
datatype = 'IQSODT_SINGLE';
invoke(dev.IQStream, 'SetOutputConfiguration', destination, datatype);

%Set IQ stream buffer size
invoke(dev.IQStream, 'SetIQDataBufferSize', userDefinedParameters.setBuffer);
bufferLength = invoke(dev.IQStream, 'GetIQDataBufferSize');
fprintf('IQ Stream Buffer Size: %d\n', bufferLength);
 
%Initialize buffer size to store IQ data
buffer = zeros(2, bufferLength);

%Start IQ Stream data acquisition
invoke(dev.Device, 'Run');
invoke(dev.IQStream, 'Start');

%Obtain IQ Stream enable status. While return true since IQ Stream is
%enabled above
enable = invoke(dev.IQStream, 'GetEnable');
fprintf('IQ Stream Enable Status: %d\n', enable);

fprintf('\n');

fprintf('Starting IQ Stream data acquisition\n');
running = 0;

while(running < userDefinedParameters.loopIterations) 
    %Obtain IQ data and split into own separate arrays
    [iqdata, iqlen, iqinfo] = invoke(dev.IQStream, 'GetIQData', buffer);
    I = iqdata(1:2:iqlen*2);
    Q = iqdata(2:2:iqlen*2);

    %If there is data, proceed to plot data
    if iqlen > 0
        
        %Obtain header information for current IQ block
        if running == 0
            fprintf('Properties of IQ Stream Sample Info:\n');
            fprintf('     Timestamp: %d\n', iqinfo.timestamp);
            fprintf('     Unix Time: %s\n', iqinfo.unixTime);
            fprintf('     Trigger Count: %d\n', iqinfo.triggerCount);
            [rowIndices, colIndices] = size(iqinfo.triggerIndices);
            classtype = class(iqinfo.triggerIndices);
            fprintf('     Trigger Indices Array Size: [%dx%d %s]\n', rowIndices, colIndices, classtype);
            fprintf('     Scale Factor: %d\n', iqinfo.scaleFactor);
            fprintf('     Acquistion Status: %d\n', iqinfo.acqStatus);
        end

        %Plot IQ data in upper portion of figure
        subplot(2, 1, 1)
        x = 1:iqlen; 
        plot(x, I, x, Q) 
        title('I vs Q Data Plot')
        legend('I data', 'Q data')

        %Plot Spectrum in lower portion of figure
        subplot(2, 1, 2)
        plotTitle = 'Spectrum Plot Bounded By Sample Rate';
        RSA_API_IQ_to_Spectrum_dBm(dev, I, Q, plotTitle)
        drawnow

        %Increment loop
        running = running + 1;
    end
end

%Stop IQ stream data acquisition
invoke(dev.IQStream, 'Stop');
invoke(dev.Device, 'Stop');
close 

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');