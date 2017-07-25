%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an RSA device and prints information
%about the device to the user. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initiate setup to connect to an RSA device
dev = icdevice('RSA_API_Driver');
connect(dev); 

%Search for connected RSA device
[numDevicesFound, deviceIDs, deviceSerial, deviceType] = invoke(dev.Device, 'Search');

%Print search results to user
fprintf('Number of Devices Found: %d\n', numDevicesFound);
fprintf('Device ID: %d\n', deviceIDs(1));
fprintf('Serial Number: %s\n', deviceSerial);
fprintf('Device Type: %s\n', deviceType);

fprintf('\n');

%Perform disconnect, reset and connect. Reset only works when device is
%disconnected.
fprintf('Disconnecting %s Device\n', deviceType);
invoke(dev.Device, 'Disconnect');
fprintf('Resetting %s Device\n', deviceType);
invoke(dev.Device, 'Reset', deviceIDs(1));
fprintf('Reconnecting %s Device\n', deviceType);
invoke(dev.Device, 'Connect', deviceIDs(1));

fprintf('\n');

%Obtain information about connected RSA device
apiVersion = invoke(dev.Device, 'GetAPIVersion');
nomenclature = invoke(dev.Device, 'GetDeviceNomenclature');
nomenclatureW = invoke(dev.Device, 'GetDeviceNomenclatureW');
serialNum = invoke(dev.Device, 'GetDeviceSerialNumber');
fwVersion = invoke(dev.Device, 'GetFWVersion');
fpgaVersion = invoke(dev.Device, 'GetFPGAVersion');
hwVersion = invoke(dev.Device, 'GetHWVersion');

%Print information about connected RSA device
fprintf('API Version: %s\n', apiVersion);
fprintf('Device Nomenclature: %s\n', nomenclature);
fprintf('Device Nomenclature Wide: %s\n', nomenclatureW);
fprintf('Serial Number: %s\n', serialNum);
fprintf('Firmware Version: %s\n', fwVersion);
fprintf('FPGA Version: %s\n', fpgaVersion);
fprintf('Hardware Version: %s\n', hwVersion);

fprintf('\n');
 
%Determine if alignment is needed. Note, when device is connected,
%alignment is always recommended
needed = invoke(dev.Alignment, 'GetAlignmentNeeded');
if needed == 1
    fprintf('Alignment is needed.  Starting alignment\n');
else
    fprintf('At start-up, alignment should be needed\n'); 
end

%Start alignment
invoke(dev.Alignment, 'RunAlignment');
fprintf('Alignment is complete\n');

%After an alignment is performed, alignment shouldn't be recommended again
needed = invoke(dev.Alignment, 'GetAlignmentNeeded');
if needed == 0
    fprintf('Alignment is no longer needed\n');
end

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');