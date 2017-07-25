function [GNSS, passed] = RSA_API_GNSS_Conversion(message)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: Function deciphers the received NMEA message based on the
%standard sentences defined by NMEA.  After determining if the NMEA is a
%valid message, the fields of the NMEA message are dissected to obtain the
%appropriate GNSS information. 
%
%   NMEA Format
%   $-----,----,----,----,----,----,----,-----*--
%   $<address>,[<data field>]...[<data field>]*<checksum>
%   
%   Note:   Address Field: 5 characters long, last 3 determine format
%           Data Field: Variable lengths and numbers, dependent on format
%           Checksum Field: two characters after *, hexidecimal value
%
%Outputs:
%   GNSS: Struct that contains deciphered information from NMEA message
%   passed: Indicate whether checksum value matches or not
%
%Inputs: 
%   message: A complete NMEA type message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initialize value to indicate if checksum value matches
passed = false;

%Separate Address, Data, and Checksum fields
NMEA = strsplit(message, ',');

%Obtain checksum field from original NMEA message and computed checksum
%value using NMEA message.  Used to validate if obtained NMEA message is
%accurate.
checksum = NMEA{end}(end-1:end);
checksumValidate = RSA_API_GNSS_checksum(message);

%Compare checksum field in original NMEA message against computed value. If
%false, don't update GNSS message to user, otherwise determine which NMEA
%address type received. Only GGA, GSA, GSV, RMC, and VTG supported 
if strcmp(checksum, checksumValidate) == 0
    GNSS.Null = '';
elseif findstr(NMEA{1}, 'GGA') == 4
    %Checksum value matched
    passed = true;
    
    %Adress: Global Positioning System Fix Data
    %Sentence Format: $--GGA,hhmmss.sss,ddmm.mmm,a,dddmm.mmm,a,x,uu,v.v,w.w,M,x.x,M,,*hh
    GNSS.Format = 'GGA';
    
    %UTC Time Format: hhmmss
    %   hh = hours
    %   mm = minutes
    %   ss.sss = seconds
    lengthTimeUTC = numel(NMEA{2});
    if lengthTimeUTC == 10
        timeUTC = NMEA{2};
        GNSS.hours = timeUTC(1:2);
        GNSS.minutes = timeUTC(3:4);
        GNSS.seconds = timeUTC(5:end);
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Latitude Format: ddmm.mmm
    %   dd = degrees
    %   mmm = minutes
    lengthLatitude = numel(NMEA{3});
    if lengthLatitude == 9
        GNSS.latitude = NMEA{3}(1:2);
        convertLatitude = str2num(NMEA{3}(3:end))/60;
        GNSS.degreeLatitude = num2str(convertLatitude);
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %North or South Orientation Format: a
    lengthNorthSouth = numel(NMEA{4});
    if lengthNorthSouth == 1
        northSouth = NMEA{4};
        if strcmp(northSouth, 'N')
            GNSS.northSouth = 'North';
        elseif strcmp(northSouth, 'S')
            GNSS.northSouth = 'South';
        end
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Longitude Format: dddmm.mmm
    %   ddd = degrees
    %   mmm = minutes
    lengthLongitude = numel(NMEA{5});
    if lengthLongitude == 10
        GNSS.longitude = NMEA{5}(1:3);
        convertLongitude = str2num(NMEA{5}(4:end))/60;
        GNSS.degreeLongitude = num2str(convertLongitude);
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %East or West Orientation Format: a
    lengthEastWest = numel(NMEA{6});
    if lengthEastWest == 1
        eastWest = NMEA{6};
        if strcmp(eastWest, 'E')
            GNSS.eastWest = 'East';
        elseif strcmp(eastWest, 'W')
            GNSS.eastWest = 'West';
        end
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %GPS Quality Indicator Format: x
    %Used to determine connection status
    lengthFixStatus = numel(NMEA{7});
    if lengthFixStatus == 1
        fixStatus = str2num(NMEA{7});
        if fixStatus == 0
            GNSS.fixStatus = 'Unlocked';
        elseif fixStatus == 1
            GNSS.fixStatus = 'Fixed';
        elseif fixStatus == 2
            GNSS.fixStatus = 'Fixed';
        end
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Satellites Used Format: uu
    %   00 - 24
    lengthNumSatellites = numel(NMEA{8});
    if lengthNumSatellites <= 2
        GNSS.numSatellites = NMEA{8};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Horizontal dilution of precision Format: v.v
    %   00.00 - 99.99
    lengthHorizontalDilution = numel(NMEA{9});
    if lengthHorizontalDilution <= 5
        GNSS.horizontalDilution = NMEA{9};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Altitude Format: w.w 
    %   -9999.9 - 17999.9
    %   based off sea level in meters
    lengthAltitude = numel(NMEA{10});
    if lengthAltitude <= 7
        GNSS.altitude = NMEA{10};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    %Altitude Metres Based on Mean Sea Level: Always M
    lengthAltitudeMeters = numel(NMEA{11});
    if lengthAltitudeMeters == 1
        GNSS.altitudeMeters = NMEA{11};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Geoidal Separation: x.x
    lengthGeoidalSeparation = numel(NMEA{12});
    if lengthGeoidalSeparation <= 5
        GNSS.geoidalSeparation = NMEA{12};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    %Geoidal Separation Metres Based on Mean Sea Level: Always M
    lengthGeoidalMeters = numel(NMEA{13});
    if lengthGeoidalMeters == 1
        GNSS.geoidalMeters = NMEA{13};   
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
elseif findstr(NMEA{1}, 'GSA') == 4
    %Checksum value matched
    passed = true;
    
    %Adress: GPS DOP and Active Satellites
    %Sentence Format: $--GSA,a,x,xx,xx,xx,xx,xx,xx,xx,xx,xx,xx,xx,xx,u.u,v.v,z.z*hh 
    GNSS.Format = 'GSA';
    
    %Mode Format: a
    %   Mode Types
    %   M = Manual
    %   A = Automatic
    lengthMode = numel(NMEA{2});
    if lengthMode == 1
        mode = NMEA{2};
        if strcmp(mode, 'A')
            GNSS.mode = 'Auto';
        elseif strcmp(mode, 'M')
            GNSS.mode = 'Manual';
        end
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Mode Format: x
    %   Fix Types
    %   1 = Fix not available
    %   2 = 2D
    %   3 = 3D
    lengthFixType = numel(NMEA{3});
    if lengthFixType == 1
        fixType = str2num(NMEA{3});
        if fixType == 1
            GNSS.fixType = 'Fix not available';
        elseif fixType == 2
            GNSS.fixType = '2D';
        elseif fixType == 3
            GNSS.fixType = '3D';
        end
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Satellite ID Format: xx
    %   xx = Can occur 12 times in one GSA type message
    numSatellites = numel(NMEA) - 6;
    for i = 1:numSatellites
        lengthSatelliteIDs = numel(NMEA{i+3});
        if lengthSatelliteIDs == 2
            GNSS.satelliteIDs = NMEA{i+3};
        else
            clear GNSS;
            GNSS.Null = '';
            return;
        end
    end
    
    %Position Dilution of Precision Format: u.u
    %   u.u = 00.0 - 99.9
    lengthGeoidalMeters = numel(NMEA{end-2});
    if lengthGeoidalMeters <= 4
        GNSS.positionDilution = NMEA{end-2};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Horizaontal Dilution of Precision Format: v.v
    %   v.v = 00.0 - 99.9
    lengthGeoidalMeters = numel(NMEA{end-1});
    if lengthGeoidalMeters <= 4
        GNSS.horizontalDilution = NMEA{end-1};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Vertical Dilution of Precision Format: z.z
    %   z.z = 00.0 - 99.9
    %   exclude checksum value
    lengthGeoidalMeters = numel(NMEA{end});
    if lengthGeoidalMeters <= 7
        GNSS.verticalDilution = NMEA{end}(1:end-3);
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
elseif findstr(NMEA{1}, 'GSV') == 4
    %Checksum value matched
    passed = true;
    
    %Adress: GNSS Satellites in View
    %Sentence Format: $--GSV,x,u,xx,uu,vv,zzz,ss,uu,vv,zzz,ss,…,uu,vv,zzz,ss*hh 
    GNSS.Format = 'GSV';
    
    %Number of Messages Format: x
    %   x = Total number of GSV that will be received
    lengthNumMessages = numel(NMEA{2});
    if lengthNumMessages == 1
        GNSS.numMessages = NMEA{2};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    %Sequence Number Format: u
    %   u = Current GSV message
    lengthSequenceNumber = numel(NMEA{3});
    if lengthSequenceNumber == 1
        GNSS.sequenceNumber = NMEA{3};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Satellites in View Format: xx
    %   xx = 00 - 12
    lengthNumSatellitesView = numel(NMEA{4});
    if lengthNumSatellitesView == 2
        GNSS.numSatellitesView = NMEA{4};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Satellite ID can only appear 4 times in one GSV type message.
    %Determine number of satellites in current GSV message. 
    %   - 4 is to exclude Address, Checksum, Number of Messages, and
    %       Sequence Number fields
    %   / 4 each satellite ID includes Elevation, Azimuth, and Signal
    %       Strength 
    numSatellites = (numel(NMEA) - 4)/4;

    %Obtain information about each satellite
    for i = 1:numSatellites
        %Satellite ID Format: uu
        lengthSatelliteID = numel(NMEA{1 + 4*i});
        if lengthSatelliteID == 2
            GNSS.satelliteID = NMEA{1 + 4*i};
        else
            clear GNSS;
            GNSS.Null = '';
            return;
        end
        %Elevation Format: vv
        %   vv = 00 - 99 degrees
        lengtheElevation = numel(NMEA{2 + 4*i});
        if lengtheElevation == 2
            GNSS.elevation = NMEA{2 + 4*i};
        else
            clear GNSS;
            GNSS.Null = '';
            return;
        end
        %Azimuth Format: zzz
        %   zzz = 000 - 360 degrees
        lengthAzimuth = numel(NMEA{3 + 4*i});
        if lengthAzimuth == 3
            GNSS.azimuth = NMEA{3 + 4*i};
        else
            clear GNSS;
            GNSS.Null = '';
            return;
        end
        %Signal Strength Format: ss
        %   ss = 00 - 99 dB
        %If this is the last satellite ID, exclude checksum value 
        if i == numSatellites
            lengthSignalStrength = numel(NMEA{4 + 4*i});
            if lengthSignalStrength == 5
                GNSS.signalStrength = NMEA{4 + 4*i}(1:end-3);
            elseif lengthSignalStrength ~= 3
                clear GNSS;
                GNSS.Null = '';
                return;
            end
        else
            lengthSignalStrength = numel(NMEA{4 + 4*i});
            if lengthSignalStrength == 2
                GNSS.signalStrength = NMEA{4 + 4*i};
            else
                clear GNSS;
                GNSS.Null = '';
                return;
            end
        end
    end
    
elseif findstr(NMEA{1}, 'RMC') == 4
    %Checksum value matched
    passed = true;
    
    %Adress: Recommended Minimum Specific GNSS Data
    %Sentence Format: $--RMC,hhmmss.sss,x,dddmm.mmm,a,dddmm.mmm,a,x.x,u.u,xxxxxx,,,v*hh
    GNSS.Format = 'RMC';
    
    %UTC Time Format: hhmmss
    %   hh = hours
    %   mm = minutes
    %   ss.sss = seconds
    lengthTimeUTC = numel(NMEA{2});
    if lengthTimeUTC == 10
        timeUTC = NMEA{2};
        GNSS.hours = timeUTC(1:2);
        GNSS.minutes = timeUTC(3:4);
        GNSS.seconds = timeUTC(5:end);
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Status Format: x
    lengthStatus = numel(NMEA{3});
    if lengthStatus == 1
        status = NMEA{3};
        if strcmp(status, 'V')
            GNSS.status = 'Navigation receiver warning';
        elseif strcmp(status, 'A')
            GNSS.status = 'Data Valid';
        end
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Latitude Format: ddmm.mmm
    %   dd = degrees
    %   mmm = minutes
    lengthLatitude = numel(NMEA{4});
    if lengthLatitude == 9
        GNSS.latitude = NMEA{4}(1:2);
        convertLatitude = str2num(NMEA{4}(3:end))/60;
        GNSS.degreeLatitude = num2str(convertLatitude);
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %North or South Orientation Format: A
    lengthNorthSouth = numel(NMEA{5});
    if lengthNorthSouth == 1
        northSouth = NMEA{5};
        if strcmp(northSouth, 'N')
            GNSS.northSouth = 'North';
        elseif strcmp(northSouth, 'S')
            GNSS.northSouth = 'South';
        end
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Longitude Format: dddmm.mmm
    %   ddd = degrees
    %   mmm = minutes
    lengthLongitude = numel(NMEA{6});
    if lengthLongitude == 10
        GNSS.longitude = NMEA{6}(1:3);
        convertLongitude = str2num(NMEA{6}(4:end))/60;
        GNSS.degreeLongitude = num2str(convertLongitude);
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %East or West Orientation Format: A
    lengthEastWest = numel(NMEA{7});
    if lengthEastWest == 1
        eastWest = NMEA{7};
        if strcmp(eastWest, 'E')
            GNSS.eastWest = 'East';
        elseif strcmp(eastWest, 'W')
            GNSS.eastWest = 'West';
        end
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Speed Over Ground Format: x.x
    %   x.x = 000.00 - 999.99 in knots
    lengthSpeed = numel(NMEA{8});
    if lengthSpeed <= 6
        GNSS.speed = NMEA{8};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Course Over Ground Format: u.u
    %   u.u = 000.00 - 359.99 in degrees
    lengthCourse = numel(NMEA{9});
    if lengthCourse <= 6
        GNSS.course = NMEA{9};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %UTC Date Format: ddmmyy
    %   dd = date
    %   mm = month
    %   yy = year
    lengthDate = numel(NMEA{10});
    if lengthDate == 6
        date = NMEA{10};
        GNSS.day = date(1:2);
        GNSS.month = date(3:4);
        GNSS.year = date(5:6);
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Mode Indicator Format: v
    %   exclude checksum value
    lengthMode = numel(NMEA{end});
    if lengthMode == 4
        mode = NMEA{end}(1:1);
        if strcmp(mode, 'N')
            GNSS.mode = 'Data Not Valid';
        elseif strcmp(mode, 'A')
            GNSS.mode = ' Autonomous mode';
        elseif strcmp(mode, 'D')
            GNSS.mode = 'Differential mode';
        elseif strcmp(mode, 'E')
            GNSS.mode = 'Estimated mode';
        end
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
elseif findstr(NMEA{1}, 'VTG') == 4
    %Checksum value matched
    passed = true;
    
    %Adress: Course Over Ground and Ground Speed
    %Sentence Format: $--VTG,x.x,T,y.y,M,u.u,N,v.v,K,m*hh
    GNSS.Format = 'VTG';

    %Course y.y never appears. Correction used to skip this field.
    correction = 0;
    
    %Course Over Ground Format: x.x, T
    %   x.x = 000.00 - 359.99 degrees true
    %   T = True
    lengthCourseTrue = numel(NMEA{2});
    if lengthCourseTrue <= 6
        GNSS.courseTrue = NMEA{2};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end

    lengthT = numel(NMEA{3});
    if lengthT == 1
        GNSS.T = NMEA{3};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    
    %Course Over Ground Format: y.y, M
    %   y.y = 000.0 - 359.9 degrees magnetic
    %   M = Magnetic
    if strcmp(NMEA{5 + correction}, 'M') == 1
        lengthCourceMagnetic = numel(NMEA{4 + correction});
        if lengthCourceMagnetic == 5
            GNSS.courceMagnetic = NMEA{4 + correction};
        else
            clear GNSS;
            GNSS.Null = '';
            return;
        end  
        lengthM = numel(NMEA{5 + correction});
        if lengthM == 1
            GNSS.M = NMEA{5 + correction};
        else
            clear GNSS;
            GNSS.Null = '';
            return;
        end
    else
        lengthM = numel(NMEA{4 + correction});
        if lengthM == 1
            GNSS.M = NMEA{4 + correction};
            correction = correction - 1;
        else
            clear GNSS;
            GNSS.Null = '';
            return;
        end
    end
   
    %Speed Over Ground Format: u.u, N
    %   u.u = 000.00 - 999.99 in knots
    %   N = Knots
    lengthSpeedKnots = numel(NMEA{6 + correction});
    if lengthSpeedKnots <= 6
        GNSS.speedKnots = NMEA{6 + correction};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    lengthN = numel(NMEA{7 + correction});
    if lengthN == 1
        GNSS.N = NMEA{7 + correction};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Speed Over Ground Format: v.v, K
    %   v.v = 000.00 - 1800.00 in kilometers per hour
    %   K = Kilometers per hour
    lengthSpeedKilometers = numel(NMEA{8 + correction});
    if lengthSpeedKilometers <= 7
       GNSS.speedKilometers = NMEA{8 + correction};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    lengthK = numel(NMEA{4});
    if lengthK == 1
       GNSS.K = NMEA{9 + correction};
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
    
    %Mode Format: m
    %   Exclude checksum value
    lengthNumSatellitesView = numel(NMEA{end});
    if lengthNumSatellitesView == 4
        mode = NMEA{end}(1:1);
        if strcmp(mode, 'N')
            GNSS.mode = 'Not Valid';
        elseif strcmp(mode, 'A')
            GNSS.mode = ' Autonomous mode';
        elseif strcmp(mode, 'D')
            GNSS.mode = 'Differential mode';
        elseif strcmp(mode, 'E')
            GNSS.mode = 'Estimated mode';
        end
    else
        clear GNSS;
        GNSS.Null = '';
        return;
    end
else
    passed = false;
    GNSS.Null = '';
end 
end