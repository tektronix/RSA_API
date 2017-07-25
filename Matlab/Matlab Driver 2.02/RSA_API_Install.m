%Run Tektronix RSA API Installer
%--------------------------------
%This script must be run with administrator privileges
%If you are not running MATLAB with admin privleges, please run MATLAB as
%an admin, or run setup.exe directly with sufficient privileges
fprintf('Starting Tektronix RSA API Installer...\n');
system('.\\RSAAPI-64_3.9.0029\\setup.exe','-runAsAdmin');
fprintf('Finished.\n');