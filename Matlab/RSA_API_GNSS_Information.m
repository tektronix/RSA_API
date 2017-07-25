function GNSS_SignalVu = RSA_API_GNSS_Information(GNSS, GNSS_SignalVu, messageBoxGNSS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: Function updates MATLAB message box based on information obtained
%from deciphered NMEA message. In order to correctly update message box,
%need the sentence standard RMC to indicate that data is valid. When GNSS
%data is valid, need multiple NMEA sentence standards to accurately update
%message box, therefore function also needs previous data and only updates
%relevent fields when appropriate.
%
%Outputs:
%   GNSS_SignalVu: Struct that contains most recent GNSS data from NMEA
%       messages. Formatted to match structure found in SignalVu-PC
%
%Inputs: 
%   GNSS: Struct containing deciphered NMEA message
%   GNSS_SignalVu: Struct containing previous GNSS data. Formatted to match
%       structure found in SignalVu-PC 
%   messageBoxGNSS: msgBox object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Determine if antenna has received a valid GNSS message. GNSS is the struct
%obtained from GNSS_Conversion
if isfield(GNSS, 'Format')
    %Determine if Format is RMC
    if strcmp(GNSS.Format, 'RMC')
        %Need antenna to be locked to indicate that data is valid and can
        %start updating message box
        if strcmp(GNSS.status, 'Data Valid')
            GNSS_SignalVu.GNSS_Status = 'Locked';
        end
    end

    %Update date of message box
    if strcmp(GNSS.Format, 'RMC') && strcmp(GNSS_SignalVu.GNSS_Status, 'Locked')
        GNSS_SignalVu.Date = strcat('20', GNSS.year, '-', GNSS.month, '-', GNSS.day);
        GNSS_SignalVu.Time = strcat(GNSS.hours, ':', GNSS.minutes, ':', GNSS.seconds);
    end

    %Update latitude and longitude
    if (strcmp(GNSS.Format, 'GGA') || strcmp(GNSS.Format, 'RMC')) && strcmp(GNSS_SignalVu.GNSS_Status, 'Locked')
        %To indicate South, latitude becomes a negative value
        if strcmp(GNSS.northSouth, 'South')
            signLatitude = '-';
        else
            signLatitude = '';
        end
        %To indicate West, longitude becomes a negative value
        if strcmp(GNSS.eastWest, 'West')
            signLongitude = '-';
        else
            signLongitude = '';
        end
        
        %Combine N/S and E/W indicator to longitude and latitude
        GNSS_SignalVu.Longitude = strcat(signLongitude, GNSS.longitude, GNSS.degreeLongitude(2:end));
        GNSS_SignalVu.Latitude = strcat(signLatitude, GNSS.latitude, GNSS.degreeLatitude(2:end));
    end

    %Update number of satellites and altitude in meters
    if strcmp(GNSS.Format, 'GGA') && strcmp(GNSS_SignalVu.GNSS_Status, 'Locked')
        GNSS_SignalVu.Satellites = GNSS.numSatellites;
        GNSS_SignalVu.Altitude = strcat(GNSS.altitude, ' m');
    end

    %Update horizontal dilution 
    if (strcmp(GNSS.Format, 'GGA') || strcmp(GNSS.Format, 'GSA')) && strcmp(GNSS_SignalVu.GNSS_Status, 'Locked')
        GNSS_SignalVu.HDOP = GNSS.horizontalDilution;
    end

    %Update speed over ground and course
    if strcmp(GNSS.Format, 'VTG') && strcmp(GNSS_SignalVu.GNSS_Status, 'Locked')
        if isempty(GNSS.speedKilometers)
            GNSS_SignalVu.Speed = '0.000 km/h';
        else
            GNSS_SignalVu.Speed = strcat(GNSS.speedKilometers, ' km/h');
        end
        if isempty(GNSS.courseTrue)
            GNSS_SignalVu.Course = '0.000';
        else
            GNSS_SignalVu.Course = GNSS.courseTrue;
        end
    end

    %Update message box with relevent information
    updateGNSS = sprintf('GNSS Status  %s\nTime                %s %s\nLongitude         %s %c\nLatitude            %s %c\nAltitude             %s\nSatellites          %s\nHDOP              %s\nSpeed              %s\nCourse             %s %c\n', ...
        GNSS_SignalVu.GNSS_Status, GNSS_SignalVu.Date, GNSS_SignalVu.Time, GNSS_SignalVu.Longitude, char(176), ...
        GNSS_SignalVu.Latitude, char(176), GNSS_SignalVu.Altitude, GNSS_SignalVu.Satellites, GNSS_SignalVu.HDOP, ...
        GNSS_SignalVu.Speed, GNSS_SignalVu.Course, char(176));
    set(findobj(messageBoxGNSS, 'Tag', 'MessageBox'), 'String', updateGNSS);
    drawnow;
end
end