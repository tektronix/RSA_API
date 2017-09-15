@rem Demo_DPXcapture.bat
rem Demonstrates use of the DPXcapture.exe program to produce DPX traces and bitmaps
@goto run

** **********************************************************
** NOTE!! Everything below is a comment up to the executable line under ":run"
** **********************************************************
** To print the command line parameters, execute the program with "?" argument
**
** C:\SignalVu-PC Files>DPXcapture ?
** --- DPXcapture: v3.9.0 (Sep 12 2016 16:58:43) --- RSA-API: v3.9.0029.0 --- RunAt: 2016/09/14 11:04:07 ---
** Generate DPX Bitmaps and Spectrum traces and capture (for usage, put "?" on cmd line)
** CmdLine: DPXcapture ?
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
**   span=<reqspan>        Requested Span (Hz, def=40MHz)
**   rbw=<reqrbw>          RequestedRBW (Hz,  def=0(AUTO:Span/100))
**   vunits=<vertunits>    Vertical Units: 0=>dBm(def),1=>Wattk,2=Volt,3=Amp)
**   ltr=<tracelen>        Trace Length (def=801, must be ODD value)
**   nfr=<numframes>       Number of Frames (0=run until keypress(def), >0=stop after #frames)
**   ytop=<bitmaptop>      Bitmap Top Level (def=0.0)
**   ybot=<bitmapbot>      Bitmap Bottom Level (def=-100.0)
**   infpers               Enable infinite persistence
**   pers=<persisttime>    Persist Time (def=1.0)
**   fn=<outfilename>      Path\SATraceOutputFilename.ext (def=none)
**   bmap=<bmidx>          Index of frame to store Bitmap to File (def=0, disable))>
** Examples:
**   Search for all devices (no connect)
**     > DPXcapture
**   DEV=0,RL=0dBm,CF=1GHz,SPAN=40MHz,RBW=auto(Span/100),801 TracePts,Run until keypress
**     > DPXcapture dev=0
**   DEV=0,RL=-10dBm,CF=1.2GHz,SPAN=10MHz,RBW=10kHz,501 trace points, 100 traces
**     > DPXcapture dev=0 cf=1.2e9 span=10e6 rbw=10e3 ltr=501 nfr=100
**   Capture traces to text file: 'myfile.txt', Bitmap to: 'myfile.txt.bm'
**     > DPXcapture dev=0 <+other params> fn=myfile.txt bmap
**
**********************************************************
**
** Demo: Run DPX for 100 frames (50 msec/frame) and capture traces and bitmap to file
** - Connect to Device = 0 (dev=0)
** - Set Ref Level = -20 dBm (rl=-20), Ctr Freq = 2412 MHz (cf=2412e6)
** - Set Span = 40 MHz (span=40e6), rbw=50 kHz (rbw=50e3)
** - Number of trace pts = 1001 (ltr=1001), number of frames =100 (nfr=100)
** - Trace File output to "d:\data\mydpx.txt" (fn=d:\data\mydpx.txt)  (+Peak/-Peak/Avg det traces output for each frame)
**		NOTE: The Trace file written above can be read into Matlab and plotted using these commands:
**		> sa = load('d:\data\mydpx.txt');
**		> plot(sa(1:3:end,:)'),ylim([-100 0]),zoom on, grid on	% plots Max wfms
**		> plot(sa(2:3:end,:)'),ylim([-100 0]),zoom on, grid on	% plots Min wfms
**		> plot(sa(3:3:end,:)'),ylim([-100 0]),zoom on, grid on	% plots Avg wfms
** - Bitmap output of N=50th bitmap to file "d:\data\mydpx.txt.bm" (bmap=50)
**		NOTE: The Bitmap file written above can be read into Matlab and plotted using these commands:
**		> bm = flipud(load(bmfilename));
**		> a=3; b=0.1; pcolor(log(a*bm+b)), colormap hot
**
** **********************************************************
	
:run	
dpxcapture dev=0 rl=-20 cf=2412e6 span=40e6 rbw=50e3 ltr=1001 nfr=100 fn=d:\data\mydpx.txt bmap=50
