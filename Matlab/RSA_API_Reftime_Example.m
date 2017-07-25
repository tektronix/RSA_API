%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an RSA device. Reftime API is designed to
%obtain and manipulate the time of the connected RSA device. Such as
%obtaining the current Unix time or the internal timestamp. Other functions
%can convert these values to obtain one or the other. Additionally, the
%internal time of the unit can be adjusted and retrieved.
%
%Adjustable Values in Script: userDefinedParameters
%Required Equipment: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initiate setup to connect to an RSA device
dev = icdevice('RSA_API_Driver');
connect(dev); 

%Adjustable values for Reftime
userDefinedParameters.pauseDuration = 3.1;
userDefinedParameters.refTimeSec = 1;
userDefinedParameters.refTimeNsec = 1;
userDefinedParameters.refTimestamp = 1;

%Check if GetTimestampRate is empty
rate = invoke(dev.Reftime, 'GetTimestampRate');
fprintf('Internal Clock Rate: %d \n', rate)

%Obtain current time based in Unix time and timestamp since device start up
[unixTimeBase, nsecBase, timestampBase] = invoke(dev.Reftime, 'GetCurrentTime');
fprintf('Current Unix Time: %d\n', unixTimeBase)
fprintf('Current Nanoseconds in Current Second: %d\n', nsecBase)
fprintf('Current Internal Timestamp: %d\n', timestampBase)

fprintf('\n');

%Internal timestamp keeps track of time based on internal clock rate. If
%two timestamps are retreived immediately before and after pausing MATLAB
%for a known duration, the length of the pause can be determined with these
%two timestamps and internal clock rate. Since GetCurrentTime cannot be
%called instantaneously, expect a tenth of a second wiggle room for the
%pause duration.
%pause RSA device for known duration
fprintf('Pausing RSA device for %d seconds\n', userDefinedParameters.pauseDuration);
pause(userDefinedParameters.pauseDuration);

%Obtain timestamp after pause
[notUsed, notUsed, timestampSecDelay] = invoke(dev.Reftime, 'GetCurrentTime');


%convert values to double to obtain a fractional second value
timestampBase = double(timestampBase);
timestampSecDelay = double(timestampSecDelay);
rate = double(rate);

%Obtain delay based on internal timestamp and clock rate
second = (timestampSecDelay-timestampBase)/rate;
fprintf('Internal timestamp and clock rate obtained %d second(s) delay\n', second);

fprintf('\n');
        
%Obtain a Unix time and number of nanoseconds in that current second from
%previous timestamp
[unixTimeConverted, nsecConverted] = invoke(dev.Reftime, 'GetTimeFromTimestamp', timestampBase);

%Currently have two Unix Time values. Have both Unix time and timestamp
%obtained earlier from GetCurrentTime. The other was obtained by converting
%timestamp into Unix time. Both Unix time values should be equivalent.
%Convert Unix time into a date time format
base = datestr(datetime(unixTimeBase, 'ConvertFrom', 'posixtime'));
converted = datestr(datetime(unixTimeConverted, 'ConvertFrom', 'posixtime'));

%View values obtained from GetCurrentTime against values obtained from
%timestamp
fprintf('Compare previous Unix time and nanoseconds against converted Unix time and nanoseconds obtained from timestamp\n');
fprintf('       Previous  Time: %s\n       Converted Time: %s\n', base, converted);
fprintf('       Previous  Unix Time: %d\n       Converted Unix Time: %d\n', unixTimeBase, unixTimeConverted);
fprintf('       Previous  Nanoseconds: %d\n       Converted Nanoseconds: %d\n', nsecBase, nsecConverted);

fprintf('\n');

%Obtain timestamp from previous Unix time and number of nanoseconds in
%that current second from GetCurrentTime 
timestampConverted = invoke(dev.Reftime, 'GetTimestampFromTime', unixTimeBase, nsecBase);

%Currently have two timestamp values.  One obtained from GetCurrentTime and
%another by converting Unix time and nanoseconds into a timestamp. 
fprintf('Compare previous timestamp against converted timestamp obtained from Unix time and nanoseconds\n');
fprintf('       Previous  Timestamp: %g\n       Converted Timestamp: %g\n', timestampBase, timestampConverted);

fprintf('\n');

%Set and obtain user defined reference time. 
%Note: invoke(dev.Reftime, 'SetReferenceTime', 0, 0, 0) will give current
%time
fprintf('Setting user defined reference time\n');
invoke(dev.Reftime, 'SetReferenceTime', userDefinedParameters.refTimeSec, userDefinedParameters.refTimeNsec, userDefinedParameters.refTimestamp);
[refTimeSec, refTimeNsec, refTimestamp] = invoke(dev.Reftime, 'GetReferenceTime');

%Convert reference time to Unix Time and print results
userDefined = datestr(datetime(refTimeSec, 'ConvertFrom', 'posixtime'));
fprintf('User Defined Posix Time: %s\n', userDefined);

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');