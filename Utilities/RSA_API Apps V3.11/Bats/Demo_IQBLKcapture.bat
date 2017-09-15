@rem Demo_IQBLKcapture.bat
rem Demonstrates use of IQBLKcapture.exe program to produce IQ data blocks
@goto run

** **********************************************************
** NOTE!! Everything below is a comment up to the executable line under ":run"
** **********************************************************
** To print the command line parameters, execute the program with "?" argument
**
** C:\RSA_API_Apps>IQBLKcapture ?
** --- IQBLKcapture: v3.11.0 (Aug 10 2017 13:38:57) --- RSA-API: v3.11.0039.0 --- RunAt: 2017/08/10 13:40:52 ---
** Capture Live IQ sample blocks to CSV file (for usage, put "?" on cmd line)
** CmdLine: iqblkcapture ?
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
**   bw=<reqbw>            Requested IQ BW (Hz, def=40e6) 
**   np=<numpts>           Number of IQ points per Blk (def=1000)
**   na=<numacqs>          Number Of Blk Acqs (def=1, run until keypress=0) 
**   cpf                   Calculate Pavg and CWFreqOffset 
**   fn=<fname>            Path\OutputFilename.ext (def=none)> 
** Examples:
**   Search for all devices (no connect)
**     > IQBLKcapture
**   DEV=0,RL=0dBm,CF=1GHz,BW=40MHz,Niqpts=1000,Nacq=1
**     > IQBLKcapture dev=0
**   DEV=0,RL=-10dBm,CF=1.2GHz,BW=10MHz,Niqpts=5000,Nacq=10
**     > IQBLKcapture dev=0 cf=1.2e9 bw=10e6 np=5000 na=10
**   Write IQ Blocks to Text file 'd:\test\myfile.txt' (Interleaved I Q I Q..., 1 line per acq)
**     > IQBLKcapture dev=0 <+other params> fn=d:\test\myfile.txt   
**
** **********************************************************
** 
** Demo: Capture 10 IQ data blocks, 1 MHz BW, 1000 samples/blk, to file
** - Connect to Device = 0 (dev=0)
** - Set Ref Level = -20 dBm (rl=-20), Ctr Freq = 2412 MHz (cf=2412e6)
** - Set BW = 1 MHz (bw=1e6)
** - Number of IQ pts/blk = 1000 (np=100), number of acq blocks = 10 (na=10)
** - Output blocks to file, 1 block/line (fn=myiqdata.txt)
**
** **********************************************************
	
:run	
iqblkcapture dev=0 rl=-20 cf=2412e6 bw=1e6 np=1000 na=10 fn=myiqdata.txt
