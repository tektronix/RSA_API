@rem Demo_SAcapture.bat
rem Demonstrates use of the SAcapture.exe program to produce Spectrum Trace data
@goto run

** **********************************************************
** NOTE!! Everything below is a comment up to the executable line under ":run"
** **********************************************************
** To print the command line parameters, execute the program with "?" argument
**
** C:\RSA_API_Apps>SAcapture ?
** --- SAcapture: v3.11.0 (Aug 10 2017 13:27:17) --- RSA-API: v3.11.0039.0 --- RunAt: 2017/08/10 13:27:54 ---
** Generate Spectrum traces and capture (for usage, put "?" on cmd line)
** CmdLine: sacapture ?
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
**   span=<reqspan>        Requested Span (Hz,def=40e6)
**   win=<wintype>         Window Type: 0=>Kaiser(def),1=>Mil-6dB,2=>BlkmanHarris,3=>Rect,4=>FlatTop,5=>Hann
**   det=<dettype>         Detector Type: 0=>+Pk(def),1=>-Pk,2=Avg,3=>Sample)
**   rbw=<reqrbw>          RequestedRBW (Hz, def=0(AUTO=Span/100))
**   vbw=<reqvbw>          RequestedVBW (Hz, (def=0(OFF))
**   vunit=<vertunit>      Vertical Units: 0=>dBm(def),1=>Watt,2=Volt,3=Amp,4=dBmV)
**   ltr=<tracelen>        Trace Length (def=801, must be ODD value)
**   ntr=<numtraces>       Number Of Traces (def=10, 0=run until keypress)
**   fn=<outfn>            OutputPath\OutputFilename.ext (def=none)
**   fhdr                  Add info header as first line of trace output file: RL CF Span RBW VBW Niqsamp Fstart Fstop Fstep Noutpts 0 0 0...)
**   hold                  Enable trace functions (MaxHold, MinHold, Avg)
** Examples:
**   Search for all devices (no connect)
**     > SAcapture
**   DEV=0,RL=0dBm,CF=1GHz,SPAN=40MHz,RBW=auto(Span/100),VBW=off,KaiserWin,+PeakDet,Run until keypress
**     > SAcapture dev=0 ntr=0
**   DEV=0,RL=-10dBm,CF=1.2GHz,SPAN=500MHz,RBW=200kHz,VBW=5kHz,KaiserWin,+PeakDet,2501 trace points, 100 traces
**     > SAcapture dev=0 cf=1.2e9 span=500e6 rbw=200e3 vbw=5e3 ltr=2501 ntr=100
**   CAPTURE TRACES TO TEXT FILE 'd:\test\myfile.txt'
**     > SAcapture dev=0 <+other params> fn=d:\test\myfile.txt
**
** **********************************************************
** 
** Demo: Spectrum Trace processing at 1.2GHz CF, 500 MHz Span, 200 kHz RBW, 5 kHz VBW, 1001 points/trace, 20 traces.
** - Connect to Device = 0 (dev=0)
** - Set Ctr Freq = 1.2GHz (cf=1.2e9), Span = 500 MHz (span=500e6), RBW = 200 kHz (rbw=200e3), VBW = 5kHz (vbw=5e3)
** - 1001 trace points (ltr=1001), 20 traces (ntr=20)
** 
**  2 optional CL input params can be added from the batch file cmd line to modify the default settings in this file.
**  Demo Example: Save to file:  >demo_sacapture "fn=d:\test\mydata.txt"
**  Captured traces are not saved unless an optional CL parameter specifying output file is added.
**  After running, the thruput statistics are printed to screen.
**  
**  To capture the spectrum traces to an ASCII text file, add the 'fn=<filename>' CL arg:
**  	> sacapture dev=0 cf=1.2e9 span=500e6 rbw=200e3 vbw=5e3 ltr=1001 ntr=20 fn=c:\mydata\mytraces.txt
**  
**  If the file path or filename has any spaces in it, put quotes around the entire entry, including 'fn=' tag:
**  	> sacapture dev=0 cf=1.2e9 span=500e6 rbw=200e3 vbw=5e3 ltr=1001 ntr=20 "fn=c:\My Data\My Traces.txt"
**  
**  To add a file header line with setting values, include the "fhdr" arg:
**  	> sacapture dev=0 cf=1.2e9 span=500e6 rbw=200e3 vbw=5e3 ltr=1001 ntr=20 fn=c:\mydata\mytraces.txt fhdr
** 
** **********************************************************
	
:run	
sacapture %1 %2 dev=0 cf=1.2e9 span=500e6 rbw=200e3 vbw=5e3 ltr=1001 ntr=20
