%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an RSA device that is connected to an
%external antenna or signal generator. It then sets up the parameters to
%capture ADC data for wifi signals at 2.4453 GHz. It will then produce an
%r3f file at the path provided with the given filename.
%
%Adjustable Values in Script: userDefinedParameters
%Recommended Equipment: Antenna or Signal Generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initiate setup to connect to an RSA device
dev = icdevice('RSA_API_Driver');
connect(dev); 

%Adjustable values for IF stream
userDefinedParameters.centerFreq = 2.4453e9;
userDefinedParameters.centerFreq = 100e6;
userDefinedParameters.refLevel = -20.0;
userDefinedParameters.path = '.';
userDefinedParameters.filename = 'Example_File';
userDefinedParameters.mode = 'StreamingModeFramed';
userDefinedParameters.suffix = 'IFSSDFN_SUFFIX_NONE';
userDefinedParameters.msec = 1000;
userDefinedParameters.count = 1;

%Set user desired parameters for graphing
set(dev.Configure, 'CenterFreq', userDefinedParameters.centerFreq);
set(dev.Configure, 'ReferenceLevel', userDefinedParameters.refLevel);

%Get user desired parameters for graphing
centerFrequency = get(dev.Configure, 'CenterFreq');
refLvl = get(dev.Configure, 'ReferenceLevel');

%Print user desired parameters for graphing to verify
fprintf('Center frequency: %g\n', centerFrequency);
fprintf('Reference Level: %d\n', refLvl);

fprintf('\n');

%Set path to store file
fprintf('Setting Disk File Path: %s\n', userDefinedParameters.path);
invoke(dev.IFStream, 'SetDiskFilePath', userDefinedParameters.path);

%Set filename used
fprintf('Setting Disk Filename: %s\n', userDefinedParameters.filename);
invoke(dev.IFStream, 'SetDiskFilenameBase', userDefinedParameters.filename);

%Set disk file mode
fprintf('Setting Disk File Mode: %s\n', userDefinedParameters.mode);
invoke(dev.IFStream, 'SetDiskFileMode', userDefinedParameters.mode);

%Set disk file suffix
fprintf('Setting Disk File Suffix: %s\n', userDefinedParameters.suffix);
invoke(dev.IFStream, 'SetDiskFilenameSuffix', userDefinedParameters.suffix);

%Set disk file length
fprintf('Setting Disk File Length: %d\n', userDefinedParameters.msec);
invoke(dev.IFStream, 'SetDiskFileLength', userDefinedParameters.msec);

%Set number of files to generate
fprintf('Setting Disk File Count: %d\n', userDefinedParameters.count);
invoke(dev.IFStream, 'SetDiskFileCount', userDefinedParameters.count);

fprintf('\n');

%Enable IF stream
fprintf('Enabling IF Stream to disk\n');
invoke(dev.Device, 'Run');
enable = true;
invoke(dev.IFStream, 'SetEnable', enable);

%IF Stream should now be enabled
isActive = invoke(dev.IFStream, 'GetActiveStatus');
fprintf('IF Stream Active Status: %d\n', isActive);

%Continuously check status of IF stream to disk. When complete, will return
%false
while(isActive == true)
    isActive = invoke(dev.IFStream, 'GetActiveStatus');
end

%Disable IF stream
fprintf('IF Stream to disk is complete\n');
enable = false;
invoke(dev.IFStream, 'SetEnable', enable);

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');