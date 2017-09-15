@rem Demo_R3FtoIQ.bat
rem Demonstrates use of the R3FtoIQ.exe program to convert R3F file to IQ file at 5MHz BW
@goto run

** **********************************************************
** NOTE!! Everything below is a comment up to the executable line under ":run"
** **********************************************************
** To print the command line parameters, execute the program with "?" argument
**
** C:\SignalVu-PC Files>R3FtoIQ ?
** --- R3FtoIQ: v3.9.0 (Sep 12 2016 16:57:13) --- RSA-API: v3.9.0029.0 --- RunAt: 2016/09/14 11:13:04 ---
** Convert IF samples from R3F file to IQ samples in TIQ/SIQ file (for usage, put "?" on cmd line)
** CmdLine: R3FtoIQ ?
** Command Line Controls:
**   fnin=<infilename>     Input File Path\R3Ffilename.R3F (def=test.r3f)
**   start=<startPct>      Input File Start point (def=0)
**   stop=<stopPct>        Input File Stop point (def=100)
**   bw=<reqBW>            Requested IQBW (Hz, def=40e6)
**   msec=<outlen>         Msec Of Output (def=0=convert-all)
**   dest=<outdest>        Output Destination: 1=Client(def),2=File-TIQ,3=File-SIQ,4=File-SIQH/SIQD
**   dtyp=<datatype>       Output Data Type: 1=Single,2=Int32,3=Int16(def)
**   fn=<outfilnename>     Output File: Path\FilenameBase (def='iqstream')
**   fnsfx=<sfxctl>        Output Filename Suffix: -2=NoSuffix(def),-1=DateTime,(>=0)=5-DigitNumber
**   prtevt                Output Trigger and 1PPS event timestamps
** Examples:
**   Use all default settings
**     > R3FtoIQ
**   Fin='c:\data\myR3F.r3f',BW=40MHz,CLIENT-Int16
**     > R3FtoIQ fnin=c:\data\myIFfile.r3f
**   Fin='myR3F.r3f',BW=40MHz,TIQ-Int32,Fout='iqstream.tiq'
**     > R3FtoIQ fnin=myR3F.r3f dest=2 dtyp=2
**   Fin='myR3F.r3f',Range=25%->75%,BW=10MHz,SIQ-Int16,Fout='.\myIQ<+datetime>.siq'
**     > R3FtoIQ fnin=myR3F.r3f start=25 stop=75 bw=10e6 dest=3 fn=myIQ fnsfx=-1
**
** **********************************************************
** 
** Demo: Convert R3F file IF samples to IQ samples, BW=5MHz, stored in TIQ file
** - Connect to input R3F file "d:\data\R3Fcap.r3f"
** - Select R3F file content range 20%-80% (start=20 stop=80)
** - Set output IQBW = 5 MHz (bw=5e6)
** - Output file type: TIQ files (dest=2), Int32 data (dtyp=2)
** - File output: Path\Filename base = "d:\data\R3FtoIQ" (.tiq will be appended)
** - File suffix: None (fnsfx=-2)
** 
** **********************************************************

:run	
r3ftoiq fnin=d:\data\R3Fcap.r3f start=20 stop=80 bw=5e6 dest=2 dtyp=2 fn=d:\data\R3FtoIQ fnsfx=-2