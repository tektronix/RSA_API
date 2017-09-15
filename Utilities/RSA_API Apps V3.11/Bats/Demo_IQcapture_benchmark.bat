@rem Demo_IQcapture_benchmark.bat
rem Demonstrates use of the IQcapture.exe program for CPU thruput benchmark
rem NOTE: IQ Data is not stored to file, it is just discarded
@goto run

** **********************************************************
** 
** Demo: Run IQ Streaming processing, with Client app as destination (data is discarded)
** - Connect to Device = 0 (dev=0)
** - Accept default Ref Level and Ctr Freq, set IQBW = 40 MHz (bw=40e6)
** - Set reclen = 0 (msec=0) to allow "infinite" run (terminate with any keypress)
** - Output: Client (dest=1), Single data (dtype=1)
** - No File output
** 
** NOTE: IQ Data is not stored to file, it is just discarded
** 
** **********************************************************
	
:run	
iqcapture dev=0 bw=40e6 msec=0 dest=1 dtyp=1
