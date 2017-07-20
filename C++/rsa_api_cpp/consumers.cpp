#include "rsa_cpp.h"

void err_check(ReturnStatus rs)
{
	if (rs != noError)
	{
		cout << "Error: " << rs << endl;
		system("pause");
		exit(0);
	}
}

void print_device_info(int* deviceIDs, int numFound, const char** deviceSerial, const char** deviceType)
{
	cout << "Number of devices found: " << numFound << endl;
	for (int i = 0; i < numFound; i++)
	{
		cout << "Device ID: " << i;
		cout << ", Serial Number: " << deviceSerial[i];
		cout << ", Device Type: " << deviceType[i] << endl;
	}
}

int search_connect()
{
	int numFound = 0;
	int* deviceIDs;
	const char** deviceSerial;
	const char** deviceType;
	char apiVersion[200];
	ReturnStatus rs;

	rs = DEVICE_GetAPIVersion(apiVersion);
	cout << "API Version: " << apiVersion << endl;
	rs = DEVICE_SearchInt(&numFound, &deviceIDs, &deviceSerial, &deviceType);
	if (numFound < 1)
	{
		cout << "No devices found, exiting script." << endl;
		system("pause");
		exit(0);
	}
	else if (numFound == 1)
	{
		print_device_info(deviceIDs, numFound, deviceSerial, deviceType);
		rs = DEVICE_Connect(deviceIDs[0]);
		err_check(rs);
	}
	else
	{
		print_device_info(deviceIDs, numFound, deviceSerial, deviceType);
		int dev;
		cout << "Select device between 0 and " << (numFound - 1) << "\n> ";
		cin >> dev;
		rs = DEVICE_Connect(deviceIDs[dev]);
		err_check(rs);
		cout << "Connected to device " << dev;
		cout << ", Serial Number: " << deviceSerial[dev];
		cout << ", Device Type: " << deviceType[dev] << endl;
	}

	return 0;
}

Spectrum_Settings config_spectrum(double cf, double refLevel, double span, double rbw)
{
	SPECTRUM_SetEnable(true);
	CONFIG_SetCenterFreq(cf);
	CONFIG_SetReferenceLevel(refLevel);
	
	SPECTRUM_SetDefault();
	Spectrum_Settings specSet;
	SPECTRUM_GetSettings(&specSet);
	specSet.span = span;
	specSet.rbw = rbw;
	SPECTRUM_SetSettings(specSet);
	SPECTRUM_GetSettings(&specSet);
	
	return specSet;
}

double* create_frequency_array(Spectrum_Settings specSet)
{
	double* freq = NULL;
	int n = specSet.traceLength;
	freq = new double[n];
	for (int i=0; i < specSet.traceLength; i++)
	{
		freq[i] = specSet.actualStartFreq + specSet.actualFreqStepSize*i;
	}

	return freq;
}

float* acquire_spectrum(Spectrum_Settings specSet)
{
	bool ready = false;
	int timeoutMsec = 0;

	SpectrumTraces trace = SpectrumTrace1;
	int maxTracePoints = specSet.traceLength;
	int outTracePoints = 0;
	float* traceData = NULL;
	int n = maxTracePoints;
	traceData = new float[n];
	
	DEVICE_Run();
	SPECTRUM_AcquireTrace();
	while (ready == false)
	{
		SPECTRUM_WaitForTraceReady(timeoutMsec, &ready);
	}
	SPECTRUM_GetTrace(trace, maxTracePoints, traceData, &outTracePoints);
	Spectrum_TraceInfo traceInfo;
	SPECTRUM_GetTraceInfo(&traceInfo);
	DEVICE_Stop();

	cout << "Trace Data Status: " << traceInfo.acqDataStatus << endl;

	return traceData;
}

int peak_power_detector(float* traceData, double* freq, Spectrum_Settings specSet)
{
	int peakIndex = 0;
	for (int i = 0; i < specSet.traceLength; i++)
	{
		if (traceData[i] > traceData[peakIndex])
		{
			peakIndex = i;
		}
	}

	return peakIndex;
}


void spectrum_example()
{
	double cf = 1e9;
	double refLevel = -30;
	double span = 40e6;
	double rbw = 300e3;
	Spectrum_Settings specSet;
	double* freq = NULL;
	float* traceData = NULL;
	int peakIndex = 0;

	search_connect();
	CONFIG_Preset();
	CONFIG_SetCenterFreq(cf);
	CONFIG_SetReferenceLevel(refLevel);

	specSet = config_spectrum(cf, refLevel, span, rbw);
	traceData = acquire_spectrum(specSet);
	freq = create_frequency_array(specSet);
	peakIndex = peak_power_detector(traceData, freq, specSet);
	
	cout << "Start frequency: " << freq[0] << endl;
	cout << "Center frequency: " << freq[(specSet.traceLength - 1) / 2] << endl;
	cout << "Stop frequency: " << freq[specSet.traceLength - 1] << endl;
	cout << "Maximum value: " << traceData[peakIndex] << " dBm" << endl;
	cout << "Frequency of max amplitude: " << freq[peakIndex] << " Hz" << endl;

	cout << "Disconnecting." << endl;
	DEVICE_Disconnect();

	//Clean up arrays
	delete[] freq;
	delete[] traceData;
	freq = NULL;
	traceData = NULL;

	//Stop the program so we can see printouts
	system("pause");
}

double* config_block_iq(double cf, double refLevel, double iqBw, int recordLength)
{
	double iqSampleRate = 0;
	double* time = NULL;
	int n = recordLength;
	time = new double[n];
	ReturnStatus rs;

	CONFIG_SetCenterFreq(cf);
	CONFIG_SetReferenceLevel(refLevel);

	IQBLK_SetIQBandwidth(iqBw);
	IQBLK_SetIQRecordLength(recordLength);
	rs = IQBLK_GetIQSampleRate(&iqSampleRate);
	err_check(rs);

	//simple C++ implementation of numpy.linspace()
	double step = recordLength/iqSampleRate/(recordLength-1);
	for (int i = 0; i < recordLength; i++)
	{
		time[i] = i*step;
	}

	return time;
}

Cplx32* acquire_block_iq(int recordLength)
{
	Cplx32* iqData = NULL;
	int n = recordLength;
	iqData = new Cplx32[n];
	bool ready = false;
	int timeoutMsec = 100;
	int outLength = 0;

	DEVICE_Run();
	IQBLK_AcquireIQData();
	while (ready == false)
	{
		IQBLK_WaitForIQDataReady(timeoutMsec, &ready);
	}
	IQBLK_GetIQDataCplx(iqData, &outLength, recordLength);
	DEVICE_Stop();

	return iqData;
}

void block_iq_example()
{
	search_connect();
	double cf = 1e9;
	double refLevel = 0;
	double iqBw = 40e6;
	int recordLength = 1000;
	double* time = NULL;
	Cplx32* iqData = NULL;

	time = config_block_iq(cf, refLevel, iqBw, recordLength);
	iqData = acquire_block_iq(recordLength); 
	cout << "Disconnecting." << endl;
	cout << "Also this is boring because I can't plot anything." << endl;

	cout << "Disconnecting." << endl;
	DEVICE_Disconnect();

	//Clean up arrays
	delete[] time;
	delete[] iqData;
	time = NULL;
	iqData = NULL;

	//Stop the program so we can see printouts
	system("pause");
}


void config_dpx(double cf, double refLevel, double span, double rbw)
{
	double yTop = refLevel;
	double yBottom = yTop - 100;
	double timeResolution = 1e-3;
	CONFIG_SetCenterFreq(cf);
	CONFIG_SetReferenceLevel(refLevel);

	DPX_SetEnable(true);
	DPX_SetParameters(span, rbw, 801, 1, VerticalUnit_dBm, yTop, yBottom, false, 1.0, false);
	DPX_SetSogramParameters(timeResolution, timeResolution, yTop, yBottom);
	DPX_Configure(true, true);
	DPX_SetSpectrumTraceType(0, TraceTypeMaxHold);
	DPX_SetSpectrumTraceType(1, TraceTypeAverage);
	DPX_SetSpectrumTraceType(2, TraceTypeMinHold);
}

void acquire_dpx(DPX_FrameBuffer* fb)
{
	bool frameAvailable = false;
	bool ready = false;

	DEVICE_Run();
	while (frameAvailable == false)
	{
		DPX_IsFrameBufferAvailable(&frameAvailable);
	}
	while (ready == false)
	{
		DPX_WaitForDataReady(100, &ready);
	}
	DPX_GetFrameBuffer(fb);
	DPX_FinishFrameBuffer();
	DEVICE_Stop();
}


void dpx_example()
{
	search_connect();
	double cf = 2.4453e9;
	double refLevel = -30;
	double span = 40e6;
	double rbw = 300e3;
	DPX_FrameBuffer fb;

	config_dpx(cf, refLevel, span, rbw);
	acquire_dpx(&fb);
	cout << "\nFFTs in frame: " << fb.fftCount << endl;
	cout << "DPX FrameBuffers acquired: " << fb.frameCount << endl;
	cout << "DPX Bitmap is "<< fb.spectrumBitmapWidth << 
		" x " << fb.spectrumBitmapHeight << " pixels." << endl;
	cout << "DPX Spectrogram is " << fb.sogramBitmapWidth <<
		" x " << fb.sogramBitmapHeight << " pixels." << endl;
	cout << "Valid traces in spectrogram: " << fb.sogramBitmapNumValidLines << endl;
	
	cout << "Disconnecting." << endl;
	DEVICE_Disconnect();

	//Stop the program so we can see printouts
	system("pause");
}

void config_if_stream(double cf, double refLevel, char* fileDir, char* fileName, int durationMsec)
{
	CONFIG_SetCenterFreq(cf);
	CONFIG_SetReferenceLevel(refLevel);

	IFSTREAM_SetDiskFilePath(fileDir);
	IFSTREAM_SetDiskFilenameBase(fileName);
	IFSTREAM_SetDiskFilenameSuffix(-2);
	IFSTREAM_SetDiskFileLength(durationMsec);
	IFSTREAM_SetDiskFileMode(StreamingModeFramed);
	IFSTREAM_SetDiskFileCount(1);
}

void if_stream_example()
{
	search_connect();
	double cf = 2.4453e9;
	double refLevel = -30;
	char* fileDir = "C:\\SignalVu-PC Files\\";
	char* fileName = "if_stream_test";
	int durationMsec = 1000;
	int waitTime = 10;
	bool writing = true;

	config_if_stream(cf, refLevel, fileDir, fileName, durationMsec);

	DEVICE_Run();
	IFSTREAM_SetEnable(true);
	while (writing == true)
	{
		Sleep(waitTime);
		IFSTREAM_GetActiveStatus(&writing);
	}
	DEVICE_Stop();
	cout << "Streaming finished." << endl;
	
	cout << "Disconnecting." << endl;
	DEVICE_Disconnect();

	//Stop the program so we can see printouts
	system("pause");
}


void config_iq_stream(double cf, double refLevel, double bw, char* fileName, IQSOUTDEST dest, int suffixCtl, int durationMsec)
{
	double bwActual = 0;
	double sampleRate = 0;
	CONFIG_SetCenterFreq(cf);
	CONFIG_SetReferenceLevel(refLevel);

	IQSTREAM_SetAcqBandwidth(bw);
	IQSTREAM_SetOutputConfiguration(dest, IQSODT_INT16);
	IQSTREAM_SetDiskFilenameBase(fileName);
	IQSTREAM_SetDiskFilenameSuffix(suffixCtl);
	IQSTREAM_SetDiskFileLength(durationMsec);
	IQSTREAM_GetAcqParameters(&bwActual, &sampleRate);
}

void iqstream_status_parser(uint32_t acqStatus)
{
	if (acqStatus == 0)
		printf("No errors in IQ streaming detected.\n");
	else
	{
		if (acqStatus & IQSTRM_STATUS_OVERRANGE)
		{
			cout << "Input overrange." << endl;
		}
		if (acqStatus & IQSTRM_STATUS_XFER_DISCONTINUITY)
		{
			cout << "Streaming discontinuity, loss of data has occurred." << endl;
		}
		if (acqStatus & IQSTRM_STATUS_IBUFF75PCT)
		{
			cout << "Input buffer > 75% full." << endl;
		}
		if (acqStatus & IQSTRM_STATUS_IBUFF75PCT)
		{
			cout << "Input buffer overflow, IQStream processing too slow, data loss has occurred." << endl;
		}
		if (acqStatus & IQSTRM_STATUS_OBUFF75PCT)
		{
			cout << "Output buffer > 75% full." << endl;
		}
		if (acqStatus & IQSTRM_STATUS_OBUFFOVFLOW)
		{
			cout << "Output buffer overflow, file writing too slow, data loss has occurred." << endl;
		}
	}
}

void iq_stream_example()
{
	search_connect();
	double cf = 2.4453e9;
	double refLevel = -30;
	
	double bw = 40e6;
	IQSOUTDEST dest = IQSOD_FILE_SIQ;
	int suffixCtl = -2;
	int durationMsec = 2000;
	int waitTime = 10;
	char* fileName = "C:\\SignalVu-PC Files\\iq_stream_test";
	IQSTRMFILEINFO iqStreamInfo;

	bool complete = false;
	bool writing = false;

	config_iq_stream(cf, refLevel, bw, fileName, dest, suffixCtl, durationMsec);
	DEVICE_Run();
	IQSTREAM_Start();
	while (complete == false)
	{
		Sleep(waitTime);
		IQSTREAM_GetDiskFileWriteStatus(&complete, &writing);
	}
	IQSTREAM_Stop();
	cout << "Streaming finished." << endl;
	IQSTREAM_GetDiskFileInfo(&iqStreamInfo);
	iqstream_status_parser(iqStreamInfo.acqStatus);
	DEVICE_Stop();

	cout << "Disconnecting." << endl;
	DEVICE_Disconnect();

	//Stop the program so we can see printouts
	system("pause");
}


void config_trigger(TriggerMode trigMode, double trigLevel, TriggerSource trigSource)
{
	TRIG_SetTriggerMode(trigMode);
	TRIG_SetIFPowerTriggerLevel(trigLevel);
	TRIG_SetTriggerSource(trigSource);
	TRIG_SetTriggerPositionPercent(10);
}


void if_playback()
{
	search_connect();
	const char* fileName = "C:\\SignalVu-PC Files\\if_stream_test.r3f";
	wchar_t wFileName[300];
	swprintf(wFileName, 300, L"%S", fileName);   // %S is 1-byte-char type for sWprintf
	
	FILE* fp = _wfopen(wFileName, L"rb");
	if (fp == NULL)
	{
		printf("Error Opening File: \"%S\"\n", wFileName);
	}
	
	int start = 0;
	int stop = 100;
	double skip = 0;
	bool loop = false;
	bool rt = true;
	bool complete = false;

	PLAYBACK_OpenDiskFile(wFileName, start, stop, skip, loop, rt);
	DEVICE_Run();
	while (complete == false)
	{
		PLAYBACK_GetReplayComplete(&complete);
	}
	cout << "Playback Complete: " << complete << endl;
	system("pause");
}