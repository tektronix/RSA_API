@rem Demo_R3Fcapture.bat
rem Demonstrates use of the R3Fcapture.exe program to record IF (ADC) data samples to R3F file
rem NOTE: The file storage disk must be able to support 224 MB/sec continuous storage rate for this demo.
@goto run

** **********************************************************
** NOTE!! Everything below is a comment up to the executable line under ":run"
** **********************************************************
** To print the command line parameters, execute the program with "?" argument
** 
** C:\SignalVu-PC Files>R3Fcapture ?
** --- R3Fcapture: v3.9.0 (Sep 12 2016 16:55:48) --- RSA-API: v3.9.0029.0 --- RunAt: 2016/09/14 11:11:49 ---
** Record Live IF (ADC) samples to R3F file (for usage, put "?" on cmd line)
** CmdLine: R3Fcapture ?
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
**   msec=<time>           Output time length in msec (def=1000)
**   nf=<numFiles>         Number of Output Files (def=1)
**   fp=<filepath>         Output File Path (def='.')
**   fn=<fnbase>           Output Filename Base (def='ifstream')
**   fnsfx=<sfxctl>        Output Filename Suffix: -2=NoSuffix, -1=DateTime(def), (>=0)=5-DigitNumber
**   fm=<fmode>            Output File Mode: 0=Raw, 1=Fmtd(def)
** Examples:
**   Search for all devices (no connect)
**     > R3Fcapture
**   DEV=0,RL=0dBm,CF=1GHz,Trec=1000ms,FILE='.\ifstream'
**     > R3Fcapture dev=0
**   DEV=0,RL=10dBm,CF=133MHz,Trec=12.4s,FILE='c:\test\myfile'
**     > R3Fcapture dev=0 rl=10 cf=133e6 msec=12400 fp=c:\test fn=myfile
**   DEV=1,RL=0dBm,CF=2GHz,Trec=1000ms,FILE='.\ifstream',trigger=IF,-10dBm,L->H'
**     > R3Fcapture dev=1 cf=2e9 trig=-10 trigx=1
**   GNSS Timesync:  Enable GNSS + GNSS Antenna power, sync internal Ref Time to GNSS 1PPS
**     > R3Fcapture gsync gant <other ctls>
**
** ************************************************************
** 
** Demo: Record 10 second live signal IF samples to R3F file (~2.2 GB) at 112 MSa/sec
** - Connect to Device = 0 (dev=0)
** - Set Ref Level = -20 dBm (rl=-20), Ctr Freq = 2412 MHz (cf=2412e6)
** - Record 10 secs (msec=10000) of signal to file
** - Output File Path = "d:\data"
** - Output Filename Base = "R3Fcap" (date+time+.r3f is appended)
**
** NOTE: The file storage disk must be able to support 224 MB/sec continuous storage rate for this demo.
** 	
** **********************************************************

:run	
r3fcapture dev=0 rl=-20 cf=2412e6 msec=10000 fp=d:\data fn=R3Fcap
