function checksum = RSA_API_GNSS_checksum(message)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary: Function converts a NMEA message into an equivalent checksum 
%value
%
%Outputs:
%   checksum: 2 character hexidecimal number that is the 8-bit exclusive OR
%       of all characters in the NMEA message excluding $ and *##
%
%Inputs: 
%   message: A complete NMEA type message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initialize checksum value
checksum = 0;

%Obtain part of NMEA message that checksum value is used to validate
checksumRange = message(2:end-3);

%Convert checksum value to a 8-bit value
numericNMEA = uint8(checksumRange);

%Exclusive OR each character in NMEA. NMEA does not include $ or *##
for i = 1:length(checksumRange)
    checksum = bitxor(checksum, numericNMEA(i));
end

%Convert checksum value to hexidecimal
checksum = dec2hex(checksum);

%If the calculated checksum value only contains a single digit, prepend 0
%to the fround of the checksum value. This is to ensure that the checksum
%value always contains two hexidecimal characters
if length(checksum) == 1
    checksum = strcat('0', checksum);
end
end