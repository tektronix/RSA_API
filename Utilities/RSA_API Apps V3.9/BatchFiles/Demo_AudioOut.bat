@rem Demo_AudioOut.bat
rem Demonstrates use of the AudioOut.exe program to generate and record Audio samples to file
@goto run

** **********************************************************
** NOTE!! Everything below is a comment up to the executable line under ":run"
** **********************************************************
** To print the command line parameters, execute the program with "?" argument
**
** C:\SignalVu-PC Files>AudioOut ?
** --- AudioOut: v3.9.0 (Sep 12 2016 16:57:34) --- RSA-API: v3.9.0029.0 --- RunAt: 2016/09/14 11:01:52 ---
** Play Audio to speaker and optionally store audio samples to file (for usage, put "?" on cmd line)
** CmdLine: AudioOut ?
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
**   foff=<offsetFreq>     Audio Frequency Offset From CF (def=0)
**   msec=<msecOut>        Msec of Output (def=1000), 0=play until keypress
**   dmode=<dmdMode>       Audio Demod Mode:0=AM_8KHz,1=FM_200kHz(def),2=>FM_75kHz,3=>FM_13kHz,4=>FM_8kHz
**   vol=<audvol>          Audio Volume (range:0.0..1.0,def=0.5)
**   mute                  Mute audio system output, sample data stream still available
**   fn=<aud-fname>        Filename to Store Audio Samples
**                         (ext='.wav' stores as 16b .wav file, '.bin' stores as 16b raw binary, other stores samples as ASCII numeric strings)
** Examples:
**   Search for all devices (no connect) --
**     > AudioOut
**   DEV=0,RL=0dBm,CF=1GHz,Tplay=1sec,FM_200KHz,vol=0.5 --
**     > AudioOut dev=0
**   DEV=0,RL=-40dBm,CF=91.5MHz,Tplay=10sec,FM_200KHz,vol=0.1,File(wav)=d:\data\audio.wav --
**     > AudioOut dev=0 rl=-40 cf=91.5e6 msec=10000 dmode=1 vol=0.1 fn=d:\data\audio.wav
**   DEV=0,RL=-40dBm,CF=91.5MHz,Tplay=10sec,FM_75KHz,vol=0.1,File(txt)=d:\data\audio.txt --
**     > AudioOut dev=0 rl=-40 cf=91.5e6 msec=10000 dmode=2 vol=0.1 fn=d:\data\audio.txt
**   DEV=0,RL=-20dBm,CF=550kHz,Tplay=(until-keypress),AM_8KHz,vol=0.5,File(bin)=d:\data\audio.bin --
**     > AudioOut dev=0 rl=-20 cf=550e3 msec=0 dmode=0 fn=d:\data\audio.bin
**
**********************************************************
**
** Demo: Play and record 10 seconds of live signal Audio samples to ASCII file from an FM signal at 200 kHz BW
** - Connect to Device = 0 (dev=0)
** - Set Ref Level = -40 dBm (rl=-40), Ctr Freq = 91.5 MHz (cf=91.5e6)
** - Play 10 secs (msec=10000), FM 200kHz BW (dmode=1)
** - Output: Audio Volume = 0.1 (vol=0.1)
** - Output: .WAV samples to d:\data\audio.wav (fn=d:\data\audio.wav)
**           Note: To save samples as 16bit signed binary integers, change the file extension to ".bin"
**           Note: To save samples as 16bit signed decimal ASCII values, change the file extension to ".txt"
** 
** **********************************************************
	
:run	
audioout dev=0 rl=-40 cf=91.5e6 msec=10000 dmode=1 vol=0.1 fn=d:\data\audio.wav
