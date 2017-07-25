%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an RSA device that is connected to an
%external antenna or signal generator. It then stores this data into three
%different file types: tiq, siq, and siqd. Each file uses a different data
%type and suffix. At the end of each file creation, the header function is
%called to obtain infomration of the file.
%
%Adjustable Values in Script: userDefinedParameters
%Required Equipment: Antenna or Signal Generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initiate setup to connect to an RSA device
dev = icdevice('RSA_API_Driver');
connect(dev); 

%Adjustable values for IQ Stream data acquisition
userDefinedParameters.centerFreq = 101.9e6;
userDefinedParameters.refLevel = -5.0;
userDefinedParameters.bw_req = 40.0e6;
userDefinedParameters.recordFileLengthMilliseconds = 10;

%Set parameters to create three different files. Each with a different file
%type, data type and suffix
files.destination = {'IQSOD_FILE_TIQ', 'IQSOD_FILE_SIQ', 'IQSOD_FILE_SIQ_SPLIT'};
files.datatype = {'IQSODT_INT16', 'IQSODT_INT32', 'IQSODT_SINGLE'};
files.suffix = {'IQSSDFN_SUFFIX_INCRINDEX_MIN', 'IQSSDFN_SUFFIX_TIMESTAMP', 'IQSSDFN_SUFFIX_NONE'};

%Set user desired parameters for IQ Stream
set(dev.Configure, 'CenterFreq', userDefinedParameters.centerFreq);
set(dev.Configure, 'ReferenceLevel', userDefinedParameters.refLevel);

%Set and obtain user defined acquisition bandwidth and sample rate
invoke(dev.IQStream, 'SetAcqBandwidth', userDefinedParameters.bw_req);
[bwHz_act, srSps] = invoke(dev.IQStream, 'GetAcqParameters');
fprintf('IQ Stream Acquisition Bandwidth: %d\n', bwHz_act);
fprintf('IQ Stream Sample Rate: %d\n', srSps);

fprintf('\n');

fprintf('Setting output configuration parameters\n');

outputSize = numel(files.destination);
for i = 1:outputSize
    %Set output data destination and data type
    invoke(dev.IQStream, 'SetOutputConfiguration', files.destination{i}, files.datatype{i});
    filename = 'IQStream_Example_File';

    %Set base filename
    if i == 1
        fprintf('Base Filename: %s\n', filename);
        invoke(dev.IQStream, 'SetDiskFilenameBaseW', filename);
    else
        fprintf('Base Filename: %s\n', filename);
        invoke(dev.IQStream, 'SetDiskFilenameBase', filename);
    end
    
    %Set type of suffix attached to end of filename
    fprintf('Suffix: %s\n', files.suffix{i});
    invoke(dev.IQStream, 'SetDiskFilenameSuffix', files.suffix{i});
    
    %Set how long to record data to stream to disk
    fprintf('Recording Length in Milliseconds: %d\n', userDefinedParameters.recordFileLengthMilliseconds);
    invoke(dev.IQStream, 'SetDiskFileLength', userDefinedParameters.recordFileLengthMilliseconds);
    
    %Start data acquisition
    invoke(dev.Device, 'Run');
    invoke(dev.IQStream, 'Start');

    %Obtain status of IQ Stream writing to disk
    [isComplete, isWriting] = invoke(dev.IQStream, 'GetDiskFileWriteStatus');
    fprintf('Writing to Disk Status: %d\n', isWriting);
    fprintf('Writing Complete Status: %d\n', isComplete);
        
    %Continuously check status of IQ stream to disk
    while(isComplete == false)
        [isComplete, isWriting] = invoke(dev.IQStream, 'GetDiskFileWriteStatus');
    end
        
    %Stop data acquisition
    invoke(dev.IQStream, 'Stop');
    invoke(dev.Device, 'Stop');
    fprintf('\n');
    
    %Obtain information about completed file
    fileinfo = invoke(dev.IQStream, 'GetDiskFileInfo');
    fprintf('Properties of IQ Stream Disk File Info:\n');
    fprintf('     Number of Samples: %d\n', fileinfo.numberSamples);
    fprintf('     Timestamp of Sample: %d\n', fileinfo.sample0Timestamp);
    fprintf('     Unix Time of Sample: %s\n', fileinfo.unixTime);
    fprintf('     Trigger Index: %d\n', fileinfo.triggerSampleIndex);
    fprintf('     Timestamp of Triggered: %d\n', fileinfo.triggerTimestamp);
    fprintf('     Unix Time of Triggered: %s\n', fileinfo.triggerUnixTime);
    fprintf('     Acquisition Status: %d\n', fileinfo.acqStatus);
    fprintf('     Filename Data: %s\n', fileinfo.filenames(1,:));
    fprintf('     Filename Header: %s\n', fileinfo.filenames(2,:));
    
    %In GetDiskFileInfo, clear sticky bits
    fprintf('Clearing sticky bits of acquisition status\n');
    invoke(dev.IQStream, 'ClearAcqStatus');
    fprintf('\n');
end

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');