%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: This script connects to an RSA device that has a GPS receiver
%connected. It will then receive NMEA messages until one indicates that
%GNSS data is valid. After GNSS is confirmed as valid, a message box will
%pop up that contains fields similiar to the one found in SignalVu-PC. This
%message box will be continuously updated until the user clicks ok or
%closes out of the message box.
%
%Required Equipment: GPS Receiver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initiate setup to connect to an RSA device
dev = icdevice('RSA_API_Driver');
connect(dev); 

%Determine if RSA device has GNSS hardware installed
installed = invoke(dev.Gnss, 'GetHWInstalled');
if installed
    fprintf('GNSS hardware is installed\n');

    %Initialize variable to store GNSS message in
    totalMessage = '';

    %Initialize GNSS message box based on format of SignalVu-PC. Need to set
    %one of these values with numerous characters so message box in MATLAB 
    %can display total message, otherwise message box will cut off information
    GNSS_SignalVu.GNSS_Status = 'Off';
    GNSS_SignalVu.Date = '                                               ';
    GNSS_SignalVu.Time = '';
    GNSS_SignalVu.Longitude = '';
    GNSS_SignalVu.Latitude = '';
    GNSS_SignalVu.Altitude = '';
    GNSS_SignalVu.Satellites = '';
    GNSS_SignalVu.HDOP = '';
    GNSS_SignalVu.Speed = '';
    GNSS_SignalVu.Course = '';

    %Print initialized GNSS message to user and update message box
    updateGNSS = sprintf('GNSS Status  %s\nTime         %s %s\nLongitude    %s %c\nLatitude     %s\nAltitude     %s\nSatellites   %s\nHDOP         %s\nSpeed        %s\nCourse       %s\n', ...
        GNSS_SignalVu.GNSS_Status, GNSS_SignalVu.Date, GNSS_SignalVu.Time, GNSS_SignalVu.Longitude, ...
        GNSS_SignalVu.Latitude, GNSS_SignalVu.Altitude, GNSS_SignalVu.Satellites, GNSS_SignalVu.HDOP, ...
        GNSS_SignalVu.Speed, GNSS_SignalVu.Course);
    messageBoxGNSS = msgbox(updateGNSS);
    
    %Enable GNSS
    setEnable = true;
    set(dev.Gnss, 'Enable', setEnable);
    enable = get(dev.Gnss, 'Enable');
    
    %Enable antenna power
    setAntennaPower = true;
    set(dev.Gnss, 'AntennaPower', setAntennaPower);
    powered = get(dev.Gnss, 'AntennaPower');

    fprintf('About to acquire GNSS message\n');
    
    fprintf('\n');
    infinite = 0;
    
    %Pause to lock GNSS signal
    pause(1);
    
    %loop until user clicks Ok on the message box or closes it
    while infinite > -2
        %Obtain NMEA message
        [msgLen, navMessage] = invoke(dev.Gnss, 'GetNavMessageData');
        
        if msgLen > 0
            %Add current Nav message to previous Nav message
            totalMessage = strcat(totalMessage, navMessage{1});
            
            %GNSS messages use NMEA standard. Messages start with $ and end
            %with *## where ## is a checksum value
            messageStart = findstr(totalMessage, '$');
            messageEnd = findstr(totalMessage, '*');

            %Messages received arrive in real time. Can intercept partway
            %through a NMEA message. If a message starts with * instead of
            %$, want to delete that section to obtain a full message
            if messageEnd(1) < messageStart(1)
                messageEnd = messageEnd(2:end);
            end
            
            %More then one $ indicates there should be at least one
            %complete NMEA to decipher
            if length(messageStart) > 1
                %Determine the total number of complete NMEA messages
                numMessages = length(messageStart) - 1;
                
                %Decipher each NMEA message
                for i = 1:numMessages
                    %Obtain a complete NMEA message to decipher
                    separateMessages = totalMessage(messageStart(i):(messageEnd(i) + 2));
                    
                    %Decipher the NMEA message
                    [GNSS, passed] = RSA_API_GNSS_Conversion(separateMessages);
                    
                    %Update the message box based on information from NMEA
                    %messgae. Return if user wants acess to it
                    [GNSS_SignalVu] = RSA_API_GNSS_Information(GNSS, GNSS_SignalVu, messageBoxGNSS);
                end
                
                %Remove all deciphered NMEA messages, keeping partial
                %message leftover. Next NMEA will complete this partial
                %message
                totalMessage = totalMessage(messageStart(numMessages + 1):end);
                
                %If user closes message box, exit loop
                if ~isvalid(messageBoxGNSS)
                    break;
                end
            end 
            
            infinite = infinite + 1;
        end
    end

    %Obtain 1PPS timestamp
    [isValid, timestamp1PPS, unixTime1PPS] = invoke(dev.Gnss, 'Get1PPSTimestamp');
    fprintf('1 PPS Timestamp Found Status: %d\n', isValid);
    fprintf('1 PPS Timestamp: %d\n', timestamp1PPS);
    unixTime = datestr(datetime(unixTime1PPS, 'ConvertFrom', 'posixtime'));
    fprintf('1 PPS Unix Time: %s\n', unixTime);
    
    %If called when NMEA messages are being retrieved, will clear out the
    %buffer, destorying the integrity of at least two messages.
    invoke(dev.Gnss, 'ClearNavMessageData');
    
    set(dev.Gnss, 'Enable', false);
    
else
    fprintf('GNSS hardware is not installed\n');
end

%Disconnect from device
fprintf('Disconnecting RSA device\n')
disconnect(dev);
delete(dev);
clear('dev');