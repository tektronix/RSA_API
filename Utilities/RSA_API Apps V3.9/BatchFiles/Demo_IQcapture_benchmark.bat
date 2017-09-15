@rem Demo_IQcapture_benchmark.bat
rem Demonstrates use of the IQcapture.exe program for CPU thruput benchmark
rem NOTE: IQ Data is not stored to file, it is just discarded
@goto run

** **********************************************************
** NOTE!! Everything below is a comment up to the executable line under ":run"
** **********************************************************
** To print the command line parameters, execute the program with "?" argument
**
** C:\SignalVu-PC Files>IQcapture ?
** --- IQcapture: v3.9.0 (Sep 12 2016 16:56:49) --- RSA-API: v3.9.0029.0 --- RunAt: 2016/09/14 11:08:33 ---
** Record Live IQ samples to TIQ, SIQ or SIQH/SIQD file (for usage, put "?" on cmd line)
** CmdLine: IQcapture ?
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
**   msec=<outlen>         Msec Of Output (def=1000)
**   dest=<outdest>        Output Destination: 1=Client(def),2=File-TIQ,3=File-SIQ,4=File-SIQH/SIQD
**   dtyp=<datatype>       Output Data Type: 1=Single,2=Int32,3=Int16(def)
**   fn=<outfilnename>     Output File: Path\FilenameBase (def='iqstream')
**   fnsfx=<sfxctl>        Output Filename Suffix: -2=NoSuffix(def),-1=DateTime,(>=0)=5-DigitNumber
**   prtevt                Output Trigger and 1PPS event timestamps
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
** Demo: Run IQ Streaming processing, with Client app as destination (data is discarded)
** - Connect to Device = 0 (dev=0)
** - Accept devault Ref Level and Ctr Freq, set IQBW = 40 MHz (bw=40e6)
** - Set reclen = 0 (msec=0) to allow "infinite" run (terminate with any keypress)
** - Output: Client (dest=1), Single data (dtype=1)
** - No File output
** 
** NOTE: IQ Data is not stored to file, it is just discarded
** 
** **********************************************************
	
:run	
iqcapture dev=0 bw=40e6 msec=0 dest=1 dtyp=1
