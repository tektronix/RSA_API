COMPATIBLE WITH RSA API V3.9.xxx and higher

The example C# solution requires a standard installation of the RSA API.

http://www.tek.com/model/rsa306-software-2

1. The solution assumes the RSA API is installed at the default location of C:\Tektronix.
2. Verify that the folder C:\Tektronix is present on your machine.
3. Instantiating the API:

	using Tektronix;
	APIWrapper api = new APIWrapper();

4. Connecting to a device:

            int[] idList = new int[20];
            string[] names = new string[20];
            string[] types = new string[20];

            ReturnStatus RS = api.DEVICE_Search(ref idList, ref names, ref types);
            if (RS == ReturnStatus.noError)
                RS = api.DEVICE_Connect(idList[0]);

5. Acquiring data:

            DPX_FrameBuffer buffer = new DPX_FrameBuffer();
            DPX_SettingsStruct settings = new DPX_SettingsStruct();

            api.DPX_Reset();
            api.DPX_SetParameters(40000000, 5000000, 200, 1, VerticalUnitType.VerticalUnit_dBm, 0, -100, false, 1, false);
            api.DPX_Configure(true, false);
            api.DPX_SetSpectrumTraceType(0, TraceType.TraceTypeMax);
            api.DPX_SetSpectrumTraceType(1, TraceType.TraceTypeMin);
            api.DPX_SetSpectrumTraceType(2, TraceType.TraceTypeAverage);
            api.DPX_GetSettings(ref settings);
            api.DPX_SetEnable(true);
	    api.DEVICE_Run();

            bool ready = false;
            bool available = false;
            string rs1 = null;
            api.DPX_WaitForDataReady(2000, ref ready);
            if (ready)
            {
                api.DPX_IsFrameBufferAvailable(ref available);
            }
            if (available)
            {
                api.DPX_GetFrameBuffer(ref buffer);
            }

6. API Example Project Descriptions

APILibrary

Managed C++ wrapper for the c-based RSA API makes .Net development against the RSA API much easier. 

DPXFrameAcquisition 
 
A console example of how to acquire DPX spectrum frames and write a frame to a file. 
The program searches for a device and connects to the first device discovered. The DPX frame 
settings are configured and the acquisition begins. The data from each frame acquired is written 
to a text file. 

IFDataToR3F 
 
The file streaming example saves a waveform to the hard drive using a variety of file types. 
These files can contain formatted, raw or only header information depending on streaming settings. For 
IF streaming, raw (.r3a and .r3h) or formatted (.r3f) file types are used which have both ADC data and 
header information. For IQ streaming, the .tiq or .sig file format is used and contains the processed I
and Q data and can be opened directly in signal-vu for playback. This example uses the 
StreamingModeFramed mode for saving data from and IF stream 

IQBlockAcquisition 
 
A console example on how to acquire sections of IQ data. The program searches for a spectrum analyzer and 
connects to the first device found. The IQ block acquisition settings are configured for the device. The 
device is set to triggered mode so that an IQ block is captured when a trigger is activated or forced. 

IQStreaming
 
This program is an example of how to stream and save IQ data. The program searches for 
a device and connects to the first device discovered. The IQ streaming settings are configured 
and IQ data is streamed to a file until the defined time limit is reached. 

SpectrumTraceAcquisition 
 
A console example of how to stream live spectrum data. The program searches for a device and connects to
the first device discovered. The spectrum streaming settings are configured and spectrum data is streamed 
until the set time has elapsed. 

