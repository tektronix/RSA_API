@rem Demo_IQcapture.bat
rem Demonstrates use of the IQcapture.exe program to record IQ data samples to file
rem NOTE: The file storage disk must be able to support 224 MB/sec continuous storage rate for this demo.
@goto run

** **********************************************************
** NOTE!! Everything below is a comment up to the executable line under ":run"
** **********************************************************
** To print the command line parameters, execute the program with "?" argument
**
** C:\RSA_API_Apps>IQcapture ?
** --- IQcapture: v3.11.0 (Aug 10 2017 13:00:00) --- RSA-API: v3.11.0039.0 --- RunAt: 2017/08/10 13:02:01 ---
** Record IQ samples to file (for usage, put "?" on cmd line)
** CmdLine: iqcapture ?
** Command Line Controls:
**   dev=<devid>           Device ID of device to connect (required: 0, 1, ...)
**   rst                   Apply device reset before connecting
**   align                 Run Alignment, no prompt
**   alignp                Run Alignment, with prompts
**   genb                  Enable GNSS Rx
**   gant                  Enable GNSS Rx antenna power. Antenna power disabled if not present
**   gsel=<gsatsel>        Select GNSS sat system(s): 1=GPS+Glonass(default),2=GPS+Beiduo,3=GPS,4=Glonass,5=Beidou
**   fref=<freqrefsrc>     Select Freq Ref Source: 0=Internal(default),1=External,2=GNSS-Rx,3=User
**   extref                Lock to External Ref input (OBSOLETE, use 'fref' instead!)
**   trig=<trigsel>        Select Trigger Src: 100=ExtTrig, (<=30)=IFtrigger(LevelIndBm)
**   trigx=<trigxn>        Trigger transition: 1=L->H(def), -1=H->L, 0=L<->H>
**   trigpct=<trigPct>     Trigger position in IQ record: 0..100, def=50
**   rl=<refLeveldBm>      RF Input Reference Level, def=0.0
**   cf=<ctrFreqHz>        RF Center Frequency, def=1e9
**   gwait=<gwaitctl>      Wait for GNSS state: 1=>GNSS Rx Lock, 2=>GNSS Timing Align
**   wait=<wait-msec>      Wait before running, in msec (0:wait until keypress, >=1:wait fixed time)
**   bw=<reqBW>            Requested IQBW (Hz, def=40e6)
**   msec=<outlen>         Msec Of Output (def=1000, 0=no limit)
**   dest=<outdest>        Output Destination: 1=Client(def),2=File-TIQ,3=File-SIQ,4=File-SIQH/SIQD,
**                                             11=File-MidasBlue(CDIF),12=File-MidasBlue(CDIF+DET)
**   dtyp=<datatype>       Output Data Type: 1=Single,2=Int32,3=Int16(def),4=Single-Int32
**   fn=<outfilnename>     Output File: Path\FilenameBase (def='iqstream')
**   fnsfx=<sfxctl>        Output Filename Suffix: -2=NoSuffix(def),-1=DateTime,(>=0)=5-DigitNumber
**   nf=<numFiles>         Number of Output Files (def=1)
**   prtevt                Output Trigger and 1PPS event timestamps
**   eqOff                 Disable channel correction equalizer
** Examples:
**   Search for all devices (no connect)
**     > IQcapture
**   DEV=0,RL=0dBm,CF=1GHz,BW=40MHz,Trec=1000ms,CLIENT'
**     > IQcapture dev=0 dest=1
**   DEV=0,RL=10dBm,CF=133MHz,BW=10MHz,Trec=12.4s,TIQ-Int16,FILE='d:\test\myfile'
**     > IQcapture dev=0 rl=10 cf=133e6 bw=10e6 msec=12400 dest=2 fn=d:\test\myfile
**   DEV=1,RL=0dBm,CF=2GHz,BW=5MHz,Trec=1000ms,TIQ-Int32,FILE='.\iqstream',trigger=IF,-10dBm,L->H'
**     > IQcapture dev=1 cf=2e9 bw=5e6 dest=2 dtyp=2 trig=-10 trigx=1
**
** **********************************************************
** 
** Demo: Record 10 seconds of live signal IQ samples to TIQ file at 40 MHz BW
** - Connect to Device = 0 (dev=0)
** - Set Ref Level = -20 dBm (rl=-20), Ctr Freq = 2412 MHz (cf=2412e6), IQBW = 40 MHz (bw=40e6)
** - Record 10 secs (msec=10000) of signal to file
** - Output: TIQ file (dest=2), Int16 data (dtype=3)
** - File output: Path\Filename base = "d:\data\IQcap" (fn=d:\data\IQcap)
** - File suffix: Append date+time (fnsfx=-1)
** 
** NOTE: The file storage disk must be able to support 224 MB/sec continuous storage rate for this demo.
** 
** **********************************************************
	
:run	
iqcapture dev=0 rl=-20 cf=2412e6 bw=40e6 msec=10000 dest=2 dtyp=3 fn=d:\data\IQcap fnsfx=-1
