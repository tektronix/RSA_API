#include <msclr\marshal.h>

#include <iostream>
#include <fstream>
#include <time.h>

#include "RSA_API.h"
#include "APIWrapper.h"

namespace Tektronix
{
	APIWrapper::APIWrapper():_iqStreamReadArrayFlt32(0)
	{

	}

	APIWrapper::~APIWrapper(void)
	{
		this->!APIWrapper();
	}

	APIWrapper::!APIWrapper(void)
	{
		if (_iqStreamReadArrayFlt32 != 0)
			delete[] _iqStreamReadArrayFlt32;
	}

	ReturnStatus APIWrapper::ErrorCheck(RSA_API::ReturnStatus status)
	{
		return (ReturnStatus)status;
	}

	///////Alignment Functions///////
	ReturnStatus APIWrapper::ALIGN_GetAlignmentNeeded(bool% needed)
	{
		bool _needed;
		ReturnStatus rs = ErrorCheck(RSA_API::ALIGN_GetAlignmentNeeded(&_needed));
		needed = _needed;
		return rs;
	}

	ReturnStatus APIWrapper::ALIGN_GetWarmupStatus(bool% warmedUp)
	{
		bool _warmedup;
		ReturnStatus rs = ErrorCheck(RSA_API::ALIGN_GetWarmupStatus(&_warmedup));
		warmedUp = _warmedup;
		return rs;
	}

	ReturnStatus APIWrapper::ALIGN_RunAlignment()
	{
		return ErrorCheck(RSA_API::ALIGN_RunAlignment());
	}


	////////Audio functions/////////

	ReturnStatus APIWrapper::AUDIO_SetFrequencyOffset(double freqOffsetHz)
	{
		return ErrorCheck(RSA_API::AUDIO_SetFrequencyOffset(freqOffsetHz));
	}

	ReturnStatus APIWrapper::AUDIO_GetFrequencyOffset(double% freqOffsetHz)
	{
		double _double;
		ReturnStatus rs = ErrorCheck(RSA_API::AUDIO_GetFrequencyOffset(&_double));
		freqOffsetHz = _double;
		return rs;
	}

	ReturnStatus APIWrapper::AUDIO_GetEnable(bool% enable)
	{
		bool _enable;
		ReturnStatus rs = ErrorCheck(RSA_API::AUDIO_GetEnable(&_enable));
		enable = _enable;
		return rs;
	}

	ReturnStatus APIWrapper::AUDIO_GetData(Int16% data, Int16 inSize, UInt16% outSize)
	{
		Int16 _data;
		UInt16 _outSize;
		ReturnStatus rs = ErrorCheck(RSA_API::AUDIO_GetData(&_data, inSize, &_outSize));
		data = _data;
		outSize = _outSize;
		return rs;
	}

	ReturnStatus APIWrapper::AUDIO_GetMode(AudioDemodMode % _mode)
	{
		RSA_API::AudioDemodMode mode;
		ReturnStatus rs = ErrorCheck(RSA_API::AUDIO_GetMode(&mode));
		_mode = (AudioDemodMode)mode;
		return rs;
	}

	ReturnStatus APIWrapper::AUDIO_GetMute(bool% _mute)
	{
		bool mute;
		ReturnStatus rs = ErrorCheck(RSA_API::AUDIO_GetMute(&mute));
		_mute = mute;
		return rs;
	}

	ReturnStatus APIWrapper::AUDIO_GetVolume(float% _volume)
	{
		float volume;
		ReturnStatus rs = ErrorCheck(RSA_API::AUDIO_GetVolume(&volume));
		_volume = volume;
		return rs;
	}

	ReturnStatus APIWrapper::AUDIO_SetMode(AudioDemodMode mode)
	{
		RSA_API::AudioDemodMode _mode = (RSA_API::AudioDemodMode)mode;
		return ErrorCheck(RSA_API::AUDIO_SetMode(_mode));
	}

	ReturnStatus APIWrapper::AUDIO_SetMute(bool mute)
	{
		return ErrorCheck(RSA_API::AUDIO_SetMute(mute));
	}

	ReturnStatus APIWrapper::AUDIO_SetVolume(float volume)
	{
		return ErrorCheck(RSA_API::AUDIO_SetVolume(volume));
	}

	ReturnStatus APIWrapper::AUDIO_Start()
	{
		return ErrorCheck(RSA_API::AUDIO_Start());
	}

	ReturnStatus APIWrapper::AUDIO_Stop()
	{
		return ErrorCheck(RSA_API::AUDIO_Stop());
	}

	///////Device Functions///////

	String^ APIWrapper::DEVICE_GetErrorString(ReturnStatus status)
	{
		RSA_API::ReturnStatus _status = (RSA_API::ReturnStatus)status;
		return gcnew  System::String(RSA_API::DEVICE_GetErrorString(_status));
	}


	ReturnStatus APIWrapper::DEVICE_SearchIntW(cli::array<int>^% idList, cli::array<String^>^% serialList, cli::array<String^>^% typeList)
	{

		const uint8_t MAX_CONNECTIONS = RSA_API::DEVSRCH_MAX_NUM_DEVICES;
		int numDevices = 0;
		int* ids;
		const wchar_t** serialNumber;
		const wchar_t** deviceType;
		ReturnStatus RS = ErrorCheck(RSA_API::DEVICE_SearchIntW(&numDevices, &ids, &serialNumber, &deviceType));

		if (numDevices == 0) return RS;

		idList = gcnew cli::array<int>(numDevices);
		serialList = gcnew cli::array<String^>(numDevices);
		typeList = gcnew cli::array<String^>(numDevices);
		for (int i = 0; i < numDevices; i++)
		{
			idList[i] = ids[i];
			serialList[i] = gcnew System::String(serialNumber[i]);
			typeList[i] = gcnew System::String(deviceType[i]);
		}
		return RS;
	}

	ReturnStatus APIWrapper::DEVICE_Search(cli::array<int>^% idList, cli::array<String^>^% serialList, cli::array<String^>^% typeList)
	{

		const uint8_t MAX_CONNECTIONS = RSA_API::DEVSRCH_MAX_NUM_DEVICES;
		int numDevices = 0;
		int ids[MAX_CONNECTIONS];
		wchar_t serialNumber[MAX_CONNECTIONS][RSA_API::DEVSRCH_SERIAL_MAX_STRLEN];
		wchar_t deviceType[MAX_CONNECTIONS][RSA_API::DEVSRCH_TYPE_MAX_STRLEN];
		ReturnStatus RS = ErrorCheck(RSA_API::DEVICE_SearchW(&numDevices, ids, serialNumber, deviceType));

		if (numDevices == 0) return RS;

		idList = gcnew cli::array<int>(numDevices);
		serialList = gcnew cli::array<String^>(numDevices);
		typeList = gcnew cli::array<String^>(numDevices);
		for (int i = 0; i < numDevices; i++)
		{
			idList[i] = ids[i];
			serialList[i] = gcnew System::String(serialNumber[i]);
			typeList[i] = gcnew System::String(deviceType[i]);
		}
		return RS;
	}

	ReturnStatus APIWrapper::DEVICE_Connect(int deviceID)
	{
		return ErrorCheck(RSA_API::DEVICE_Connect(deviceID));
	}

	ReturnStatus APIWrapper::DEVICE_Disconnect()
	{
		return ErrorCheck(RSA_API::DEVICE_Disconnect());
	}

	ReturnStatus APIWrapper::DEVICE_GetEnable(bool% enabled)
	{
		bool _enabled;
		ReturnStatus rs = ErrorCheck(RSA_API::DEVICE_GetEnable(&_enabled));
		enabled = _enabled;
		return rs;
	}

	ReturnStatus APIWrapper::DEVICE_GetFPGAVersion(String^ % fpgaVersion)
	{
		char _fpgaVersion[RSA_API::DEVINFO_MAX_STRLEN] = "";
		ReturnStatus rs = ErrorCheck(RSA_API::DEVICE_GetFPGAVersion(_fpgaVersion));
		fpgaVersion = gcnew String(_fpgaVersion);
		return rs;
	}

	ReturnStatus APIWrapper::DEVICE_GetFWVersion(String^ % fwVersion)
	{
		char _Version[RSA_API::DEVINFO_MAX_STRLEN] = "";
		ReturnStatus rs = ErrorCheck(RSA_API::DEVICE_GetFWVersion(_Version));
		fwVersion = gcnew String(_Version);
		return rs;
	}

	ReturnStatus APIWrapper::DEVICE_GetHWVersion(String^ % hwVersion)
	{
		char _Version[RSA_API::DEVINFO_MAX_STRLEN] = "";
		ReturnStatus rs = ErrorCheck(RSA_API::DEVICE_GetHWVersion(_Version));
		hwVersion = gcnew String(_Version);
		return rs;
	}

	ReturnStatus APIWrapper::DEVICE_GetNomenclature(String^ % nomenclature)
	{
		char _Version[RSA_API::DEVINFO_MAX_STRLEN] = "";
		ReturnStatus rs = ErrorCheck(RSA_API::DEVICE_GetNomenclature(_Version));
		nomenclature = gcnew String(_Version);
		return rs;
	}

	ReturnStatus APIWrapper::DEVICE_GetSerialNumber(String^ % serialNum)
	{
		char _Version[RSA_API::DEVINFO_MAX_STRLEN] = "";
		ReturnStatus rs = ErrorCheck(RSA_API::DEVICE_GetSerialNumber(_Version));
		serialNum = gcnew String(_Version);
		return rs;
	}

	ReturnStatus APIWrapper::DEVICE_GetAPIVersion(String^ % apiVersion)
	{
		char _Version[RSA_API::DEVINFO_MAX_STRLEN] = "";
		ReturnStatus rs = ErrorCheck(RSA_API::DEVICE_GetAPIVersion(_Version));
		apiVersion = gcnew String(_Version);
		return rs;
	}

	ReturnStatus APIWrapper::DEVICE_PrepareForRun()
	{
		return ErrorCheck(RSA_API::DEVICE_PrepareForRun());
	}

	ReturnStatus APIWrapper::DEVICE_GetInfo(DEVICE_INFO^% devInfo)
	{
		RSA_API::DEVICE_INFO info;
		memset(&info, 0, sizeof(RSA_API::DEVICE_INFO));
		ReturnStatus rs = ErrorCheck(RSA_API::DEVICE_GetInfo(&info));
		if (devInfo == nullptr) return (ReturnStatus)301;
		devInfo->apiVersion = gcnew String(info.apiVersion);
		devInfo->fpgaVersion = gcnew String(info.fpgaVersion);
		devInfo->fwVersion = gcnew String(info.fwVersion);
		devInfo->serialNum = gcnew String(info.serialNum);
		devInfo->apiVersion = gcnew String(info.hwVersion);
		devInfo->nomenclature = gcnew String(info.nomenclature);
		return rs;
	}

	ReturnStatus APIWrapper::DEVICE_GetOverTemperatureStatus(bool% overTemperature)
	{
		bool _status;
		ReturnStatus rs = ErrorCheck(RSA_API::DEVICE_GetOverTemperatureStatus(&_status));
		overTemperature = _status;
		return rs;
	}

	ReturnStatus APIWrapper::DEVICE_Reset(int deviceID)
	{
		return ErrorCheck(RSA_API::DEVICE_Reset(deviceID));
	}

	ReturnStatus APIWrapper::DEVICE_Run()
	{
		return ErrorCheck(RSA_API::DEVICE_Run());
	}

	ReturnStatus APIWrapper::DEVICE_StartFrameTransfer()
	{
		return ErrorCheck(RSA_API::DEVICE_StartFrameTransfer());
	}

	ReturnStatus APIWrapper::DEVICE_Stop()
	{
		return ErrorCheck(RSA_API::DEVICE_Stop());
	}

	ReturnStatus APIWrapper::DEVICE_GetEventStatus(EventType eventID, bool% eventOccured, Int64% eventTimestamp)
	{
		bool _eventOccurred;
		uint64_t _eventTimestamp;
		ReturnStatus rs = ErrorCheck(RSA_API::DEVICE_GetEventStatus((int)eventID, &_eventOccurred, &_eventTimestamp));
		eventTimestamp = _eventTimestamp;
		eventOccured = _eventOccurred;
		return rs;
	}

	///////DPX Functions///////

	ReturnStatus APIWrapper::DPX_WaitForDataReady(int timeoutMsec, bool % ready)
	{
		bool _ready;
		ReturnStatus rs = ErrorCheck(RSA_API::DPX_WaitForDataReady(timeoutMsec, &_ready));
		ready = _ready;
		return rs;
	}

	ReturnStatus APIWrapper::DPX_GetRBWRange(double fspan, double% minRBW, double% maxRBW)
	{
		double _minRBW, _maxRBW;
		ReturnStatus rs = ErrorCheck(RSA_API::DPX_GetRBWRange(fspan, &_minRBW, &_maxRBW));
		minRBW = _minRBW;
		maxRBW = _maxRBW;
		return rs;
	}

	ReturnStatus APIWrapper::DPX_GetFrameInfo(Int64% frameCount, Int64% fftCount)
	{
		Int64 _frameCount, _fftCount;
		ReturnStatus rs = ErrorCheck(RSA_API::DPX_GetFrameInfo(&_frameCount, &_fftCount));
		frameCount = _frameCount;
		fftCount = _fftCount;
		return rs;
	}

	ReturnStatus APIWrapper::DPX_GetEnable(bool % enabled)
	{
		bool _enabled;
		ReturnStatus rs = ErrorCheck(RSA_API::DPX_GetEnable(&_enabled));
		enabled = _enabled;
		return rs;
	}

	ReturnStatus APIWrapper::DPX_GetFrameBuffer(DPX_FrameBuffer^% buffer)
	{
		RSA_API::DPX_FrameBuffer _buffer;
		memset(&_buffer, 0, sizeof(RSA_API::DPX_FrameBuffer));
		ReturnStatus rs = ErrorCheck(RSA_API::DPX_GetFrameBuffer(&_buffer));
		if (buffer == nullptr) return (ReturnStatus)301;
		buffer->fftPerFrame = _buffer.fftPerFrame;
		buffer->fftCount = _buffer.fftCount;
		buffer->frameCount = _buffer.frameCount;
		buffer->timestamp = _buffer.timestamp;
		buffer->acqDataStatus = _buffer.acqDataStatus;

		buffer->minSigDuration = _buffer.minSigDuration;
		buffer->minSigDurOutOfRange = _buffer.minSigDurOutOfRange;

		buffer->spectrumBitmapWidth = _buffer.spectrumBitmapWidth;
		buffer->spectrumBitmapHeight = _buffer.spectrumBitmapHeight;
		buffer->spectrumBitmapSize = _buffer.spectrumBitmapSize;
		buffer->spectrumTraceLength = _buffer.spectrumTraceLength;
		buffer->numSpectrumTraces = _buffer.numSpectrumTraces;

		buffer->spectrumEnabled = _buffer.spectrogramEnabled;
		buffer->spectrogramEnabled = _buffer.spectrogramEnabled;

		buffer->spectrumBitmap = gcnew cli::array<float>(_buffer.spectrumBitmapSize);
		Marshal::Copy(IntPtr(_buffer.spectrumBitmap), buffer->spectrumBitmap, 0, buffer->spectrumBitmapSize);

		buffer->spectrumTraces = gcnew cli::array<cli::array<float>^>(_buffer.numSpectrumTraces);

		for (int i = 0; i < _buffer.numSpectrumTraces; i++)
		{
			buffer->spectrumTraces[i] = gcnew cli::array<float>(_buffer.spectrumTraceLength);
			pin_ptr<float> pinPtrArray = &buffer->spectrumTraces[i][buffer->spectrumTraces[i]->GetLowerBound(0)];
			memcpy_s(pinPtrArray, _buffer.spectrumTraceLength * sizeof(float), _buffer.spectrumTraces[i], _buffer.spectrumTraceLength * sizeof(float));

		}
		if (_buffer.spectrogramEnabled)
		{
			buffer->sogramBitmapWidth = _buffer.sogramBitmapWidth;
			buffer->sogramBitmapHeight = _buffer.sogramBitmapHeight;
			buffer->sogramBitmapSize = _buffer.sogramBitmapSize;
			buffer->sogramBitmapNumValidLines = _buffer.sogramBitmapNumValidLines;

			buffer->sogramBitmap = gcnew cli::array<System::Byte>(_buffer.sogramBitmapSize);
			Marshal::Copy(IntPtr(_buffer.sogramBitmap), buffer->sogramBitmap, 0, _buffer.sogramBitmapSize);

			buffer->sogramBitmapTimestampArray = gcnew cli::array<double>(_buffer.sogramBitmapHeight);
			Marshal::Copy(IntPtr(_buffer.sogramBitmapTimestampArray), buffer->sogramBitmapTimestampArray, 0, _buffer.sogramBitmapHeight);

			buffer->sogramBitmapContainTriggerArray = gcnew cli::array<Int16>(_buffer.sogramBitmapHeight);
			Marshal::Copy(IntPtr(_buffer.sogramBitmapContainTriggerArray), buffer->sogramBitmapContainTriggerArray, 0, _buffer.sogramBitmapHeight);
		}

		return rs;
	}

	ReturnStatus APIWrapper::DPX_SetEnable(bool enabled)
	{
		return ErrorCheck(RSA_API::DPX_SetEnable(enabled));
	}

	ReturnStatus APIWrapper::DPX_GetSettings(DPX_SettingsStruct^ % dpxSettings)
	{
		RSA_API::DPX_SettingsStruct settings;
		memset(&settings, 0, sizeof(RSA_API::DPX_SettingsStruct));
		ReturnStatus rs = ErrorCheck(RSA_API::DPX_GetSettings(&settings));
		if (dpxSettings == nullptr) return (ReturnStatus)301;
		dpxSettings->actualRBW = settings.actualRBW;
		dpxSettings->bitmapHeight = settings.bitmapHeight;
		dpxSettings->bitmapWidth = settings.bitmapWidth;
		dpxSettings->traceLength = settings.traceLength;
		dpxSettings->enableSpectrogram = settings.enableSpectrogram;
		dpxSettings->enableSpectrum = settings.enableSpectrum;
		dpxSettings->decayFactor = settings.decayFactor;
		return rs;
	}

	ReturnStatus APIWrapper::DPX_Configure(bool enableSpectrum, bool enableSpectrogram)
	{
		return ErrorCheck(RSA_API::DPX_Configure(enableSpectrum, enableSpectrogram));
	}

	ReturnStatus APIWrapper::DPX_Reset()
	{
		return ErrorCheck(RSA_API::DPX_Reset());
	}

	ReturnStatus APIWrapper::DPX_SetParameters(double fspan, double rbw, Int32
		bitmapWidth, Int32 tracePtsPerPixel, VerticalUnitType yUnit, double yTop,
		double yBottom, bool infinitePersistence, double persistenceTimeSec, bool
		showOnlyTrigFrame)
	{
		RSA_API::VerticalUnitType _yUnit = (RSA_API::VerticalUnitType)yUnit;
		return ErrorCheck(RSA_API::DPX_SetParameters(fspan, rbw, bitmapWidth, tracePtsPerPixel, _yUnit, yTop, yBottom,
			infinitePersistence, persistenceTimeSec, showOnlyTrigFrame));
	}

	ReturnStatus APIWrapper::DPX_SetSpectrumTraceType(Int32 traceIndex, TraceType type)
	{
		RSA_API::TraceType _type = (RSA_API::TraceType)type;
		return ErrorCheck(RSA_API::DPX_SetSpectrumTraceType(traceIndex, _type));
	}

	ReturnStatus APIWrapper::DPX_IsFrameBufferAvailable(bool% frameAvailable)
	{
		bool _ready;
		ReturnStatus rs = ErrorCheck(RSA_API::DPX_IsFrameBufferAvailable(&_ready));
		frameAvailable = _ready;
		return rs;
	}

	ReturnStatus APIWrapper::DPX_FinishFrameBuffer()
	{
		return ErrorCheck(RSA_API::DPX_FinishFrameBuffer());
	}

	ReturnStatus APIWrapper::DPX_GetSogramHiResLine(Int16% vData, Int32% vDataSize,
		Int32 lineIndex, double% dataSF, Int32 tracePoints, Int32 firstValidPoint)
	{
		Int16 _vData;
		Int32 _vDataSize;
		double _dataSF;
		ReturnStatus rs = ErrorCheck(RSA_API::DPX_GetSogramHiResLine(&_vData, &_vDataSize, lineIndex,
			&_dataSF, tracePoints, firstValidPoint));
		vData = _vData;
		vDataSize = _vDataSize;
		dataSF = _dataSF;
		return rs;
	}

	ReturnStatus APIWrapper::DPX_GetSogramHiResLineCountLatest(Int32% lineCount)
	{
		Int32 _lineCount;
		ReturnStatus rs = ErrorCheck(RSA_API::DPX_GetSogramHiResLineCountLatest(&_lineCount));
		lineCount = _lineCount;
		return rs;
	}

	ReturnStatus APIWrapper::DPX_GetSogramHiResLineTimeStamp(double% timestamp, Int32 lineIndex)
	{
		double _timestamp;
		ReturnStatus rs = ErrorCheck(RSA_API::DPX_GetSogramHiResLineTimestamp(&_timestamp, lineIndex));
		timestamp = _timestamp;
		return rs;
	}

	ReturnStatus APIWrapper::DPX_GetSogramHiResLineTriggered(bool% triggered, Int32 lineIndex)
	{
		bool _triggered;
		ReturnStatus rs = ErrorCheck(RSA_API::DPX_GetSogramHiResLineTriggered(&_triggered, lineIndex));
		triggered = _triggered;
		return rs;
	}

	ReturnStatus APIWrapper::DPX_GetSogramSettings(DPX_SogramSettingsStruct^ % sogramSettings)
	{
		RSA_API::DPX_SogramSettingsStruct settings;
		memset(&settings, 0, sizeof(RSA_API::DPX_SogramSettingsStruct));
		ReturnStatus rs = ErrorCheck(RSA_API::DPX_GetSogramSettings(&settings));
		if (sogramSettings == nullptr) return (ReturnStatus)301;
		sogramSettings->bitmapHeight = settings.bitmapHeight;
		sogramSettings->bitmapWidth = settings.bitmapWidth;
		sogramSettings->sogramBitmapLineTime = settings.sogramBitmapLineTime;
		sogramSettings->sogramTraceLineTime = settings.sogramTraceLineTime;
		return rs;
	}

	ReturnStatus APIWrapper::DPX_SetSogramParameters(double timePerBitmapLine, double timeResolution, double maxPower, double minPower)
	{
		return ErrorCheck(RSA_API::DPX_SetSogramParameters(timePerBitmapLine, timeResolution, maxPower, minPower));
	}

	ReturnStatus APIWrapper::DPX_SetSogramTraceType(TraceType traceType)
	{
		RSA_API::TraceType _type = (RSA_API::TraceType)traceType;
		return ErrorCheck(RSA_API::DPX_SetSogramTraceType(_type));
	}

	//////Configure Functions//////

	ReturnStatus APIWrapper::CONFIG_GetCenterFreq(double% cf)
	{
		double _cf;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetCenterFreq(&_cf));
		cf = _cf;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_GetExternalRefEnable(bool% exRefEn)
	{
		bool _exRefEn;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetExternalRefEnable(&_exRefEn));
		exRefEn = _exRefEn;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_GetExternalRefFrequency(double% extFreq)
	{
		double _extFreq;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetExternalRefFrequency(&_extFreq));
		extFreq = _extFreq;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_GetMaxCenterFreq(double% maxCF)
	{
		double _maxCF;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetMaxCenterFreq(&_maxCF));
		maxCF = _maxCF;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_GetMinCenterFreq(double% minCF)
	{
		double _minCF;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetMinCenterFreq(&_minCF));
		minCF = _minCF;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_GetReferenceLevel(double% refLevel)
	{
		double _refLevel;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetReferenceLevel(&_refLevel));
		refLevel = _refLevel;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_Preset()
	{
		return ErrorCheck(RSA_API::CONFIG_Preset());
	}

	ReturnStatus APIWrapper::CONFIG_SetCenterFreq(double cf)
	{
		return ErrorCheck(RSA_API::CONFIG_SetCenterFreq(cf));
	}

	ReturnStatus APIWrapper::CONFIG_SetExternalRefEnable(bool exRefEn)
	{
		return ErrorCheck(RSA_API::CONFIG_SetExternalRefEnable(exRefEn));
	}

	ReturnStatus APIWrapper::CONFIG_SetReferenceLevel(double refLevel)
	{
		return ErrorCheck(RSA_API::CONFIG_SetReferenceLevel(refLevel));
	}

	ReturnStatus APIWrapper::CONFIG_GetAutoAttenuationEnable(bool% enable)
	{
		bool _enable;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetAutoAttenuationEnable(&_enable));
		enable = _enable;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_SetAutoAttenuationEnable(bool enable)
	{
		return ErrorCheck(RSA_API::CONFIG_SetAutoAttenuationEnable(enable));
	}

	ReturnStatus APIWrapper::CONFIG_GetRFPreampEnable(bool% enable)
	{
		bool _enable;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetRFPreampEnable(&_enable));
		enable = _enable;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_SetRFPreampEnable(bool enable)
	{
		return ErrorCheck(RSA_API::CONFIG_SetRFPreampEnable(enable));
	}

	ReturnStatus APIWrapper::CONFIG_GetRFAttenuator(double% value)
	{
		double _value;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetRFAttenuator(&_value));
		value = _value;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_SetRFAttenuator(double value)
	{
		return ErrorCheck(RSA_API::CONFIG_SetRFAttenuator(value));
	}

	///////GNSS Functions//////////

	ReturnStatus APIWrapper::GNSS_ClearNavMessageData()
	{
		return ErrorCheck(RSA_API::GNSS_ClearNavMessageData());
	}

	ReturnStatus APIWrapper::GNSS_Get1PPSTimestamp(bool% isValid, UInt64%
		timestamp1PPS)
	{
		bool _isValid;
		UInt64 _timestamp1PPS;
		ReturnStatus rs = ErrorCheck(RSA_API::GNSS_Get1PPSTimestamp(&_isValid, &_timestamp1PPS));
		timestamp1PPS = _timestamp1PPS;
		isValid = _isValid;
		return rs;
	}

	ReturnStatus APIWrapper::GNSS_GetAntennaPower(bool% powered)
	{
		bool _powered;
		ReturnStatus rs = ErrorCheck(RSA_API::GNSS_GetAntennaPower(&_powered));
		powered = _powered;
		return rs;
	}

	ReturnStatus APIWrapper::GNSS_GetEnable(bool% enable)
	{
		bool _enable;
		ReturnStatus rs = ErrorCheck(RSA_API::GNSS_GetEnable(&_enable));
		enable = _enable;
		return rs;
	}

	ReturnStatus APIWrapper::GNSS_GetHwInstalled(bool% installed)
	{
		bool _installed;
		ReturnStatus rs = ErrorCheck(RSA_API::GNSS_GetHwInstalled(&_installed));
		installed = _installed;
		return rs;
	}

	ReturnStatus APIWrapper::GNSS_GetNavMessageData(int% msgLen, String^% message)
	{
		int _msglen = 0;
		const char* _message;
		ReturnStatus rs = ErrorCheck(RSA_API::GNSS_GetNavMessageData(&_msglen, &_message));
		message = msclr::interop::marshal_as<String^>(_message);
		msgLen = _msglen;
		return rs;
	}

	ReturnStatus APIWrapper::GNSS_GetSatSystem(GNSS_SATSYS^% satSystem)
	{
		RSA_API::GNSS_SATSYS _satSystem;
		ReturnStatus rs = ErrorCheck(RSA_API::GNSS_GetSatSystem(&_satSystem));
		satSystem = (GNSS_SATSYS)_satSystem;
		return rs;
	}

	ReturnStatus APIWrapper::GNSS_SetAntennaPower(bool powered)
	{
		return ErrorCheck(RSA_API::GNSS_SetAntennaPower(powered));
	}

	ReturnStatus APIWrapper::GNSS_SetEnable(bool enable)
	{
		return ErrorCheck(RSA_API::GNSS_SetEnable(enable));
	}

	ReturnStatus APIWrapper::GNSS_SetSatSystem(GNSS_SATSYS satSystem)
	{
		RSA_API::GNSS_SATSYS _satSystem = (RSA_API::GNSS_SATSYS)satSystem;
		return ErrorCheck(RSA_API::GNSS_SetSatSystem(_satSystem));
	}

	///////IF Streaming Functions/////

	ReturnStatus APIWrapper::IFSTREAM_SetDiskFilenameSuffix(int suffixCtl)
	{
		return ErrorCheck(RSA_API::IFSTREAM_SetDiskFilenameSuffix(suffixCtl));
	}

	ReturnStatus APIWrapper::IFSTREAM_GetActiveStatus(bool % enabled)
	{
		bool _enabled;
		ReturnStatus rs = ErrorCheck(RSA_API::IFSTREAM_GetActiveStatus(&_enabled));
		enabled = _enabled;
		return rs;
	}

	ReturnStatus APIWrapper::IFSTREAM_SetDiskFileCount(int maximum)
	{
		return ErrorCheck(RSA_API::IFSTREAM_SetDiskFileCount(maximum));
	}

	ReturnStatus APIWrapper::IFSTREAM_SetDiskFileLength(int msec)
	{
		return ErrorCheck(RSA_API::IFSTREAM_SetDiskFileLength(msec));
	}

	ReturnStatus APIWrapper::IFSTREAM_SetDiskFileMode(StreamingMode mode)
	{
		RSA_API::StreamingMode _mode = (RSA_API::StreamingMode)mode;
		return ErrorCheck(RSA_API::IFSTREAM_SetDiskFileMode(_mode));
	}

	ReturnStatus APIWrapper::IFSTREAM_SetDiskFilenameBase(String^ base)
	{
		char * p = (char *)Marshal::StringToHGlobalAnsi(base).ToPointer();
		ReturnStatus rs = ErrorCheck(RSA_API::IFSTREAM_SetDiskFilenameBase(p));
		Marshal::FreeHGlobal(IntPtr(p));
		return rs;
	}

	ReturnStatus APIWrapper::IFSTREAM_SetDiskFilePath(String^  path)
	{
		char * p = (char *)Marshal::StringToHGlobalAnsi(path).ToPointer();
		ReturnStatus rs = ErrorCheck(RSA_API::IFSTREAM_SetDiskFilePath(p));
		Marshal::FreeHGlobal(IntPtr(p));
		return rs;
	}

	ReturnStatus APIWrapper::IFSTREAM_SetEnable(bool enabled)
	{
		return ErrorCheck(RSA_API::IFSTREAM_SetEnable(enabled));
	}

	///////IQ Block Functions///////

	ReturnStatus APIWrapper::IQBLK_GetIQAcqInfo(IQBLK_ACQINFO^ % acqInfo)
	{
		RSA_API::IQBLK_ACQINFO iqAcqInfo;
		memset(&iqAcqInfo, 0, sizeof(RSA_API::IQBLK_ACQINFO));
		ReturnStatus rs = ErrorCheck(RSA_API::IQBLK_GetIQAcqInfo(&iqAcqInfo));
		if (acqInfo == nullptr) return (ReturnStatus)301;
		acqInfo->acqStatus = iqAcqInfo.acqStatus;
		acqInfo->sample0Timestamp = iqAcqInfo.sample0Timestamp;
		acqInfo->triggerSampleIndex = iqAcqInfo.triggerSampleIndex;
		acqInfo->triggerTimestamp = iqAcqInfo.triggerTimestamp;
		return rs;
	}

	ReturnStatus APIWrapper::IQBLK_AcquireIQData()
	{
		return ErrorCheck(RSA_API::IQBLK_AcquireIQData());
	}

	ReturnStatus APIWrapper::IQBLK_GetIQBandwidth(double% iqBandwidth)
	{
		double _iqBandwidth;
		ReturnStatus rs = ErrorCheck(RSA_API::IQBLK_GetIQBandwidth(&_iqBandwidth));
		iqBandwidth = _iqBandwidth;
		return rs;
	}

	ReturnStatus APIWrapper::IQBLK_GetIQData(cli::array<float>^ % iqData, int% outLength, int reqLength)
	{
		_iqDataResultArray = gcnew cli::array<float>(reqLength);

		if ((_iqDataResultArray == nullptr) || (2 * reqLength != _iqDataResultArray->Length))
		{
			_iqDataResultArray = gcnew cli::array<float>(2 * reqLength);
		}
		pin_ptr<float> p = &_iqDataResultArray[0];
		int length;
		ReturnStatus rs = ErrorCheck(RSA_API::IQBLK_GetIQData(p, &length, reqLength));
		outLength = length;
		iqData = _iqDataResultArray;
		return rs;
	}

	ReturnStatus APIWrapper::IQBLK_GetIQDataCplx(cli::array<Cplx32^>^% iqData, int% outLength, int reqLength)
	{
		_cplx32IqDataResultArray = gcnew cli::array<Cplx32^>(reqLength);

		if ((_cplx32IqDataResultArray == nullptr) || (2 * reqLength != _cplx32IqDataResultArray->Length))
		{
			_cplx32IqDataResultArray = gcnew cli::array<Cplx32^>(2 * reqLength);
		}

		RSA_API::Cplx32 * _p = new RSA_API::Cplx32[reqLength];
		if ((_p == nullptr))
		{
			_p = new RSA_API::Cplx32[2*reqLength];
		}

		int _outLength;
		ReturnStatus rs = ErrorCheck(RSA_API::IQBLK_GetIQDataCplx(_p, &_outLength, reqLength));

		if (_p)
		{
			for (int i = 0; i < reqLength; i++)
			{
				_cplx32IqDataResultArray[i] = gcnew Cplx32();
				_cplx32IqDataResultArray[i]->i = _p[i].i;
				_cplx32IqDataResultArray[i]->q = _p[i].q;
			}
		}
		else
			goto end;

	end:
		iqData = _cplx32IqDataResultArray;
		outLength = _outLength;
		delete _p;
		return rs;
	}

	ReturnStatus APIWrapper::IQBLK_GetIQDataDeinterleaved(cli::array<float>^ % iData, cli::array<float>^ % qData, int%outLength, int reqLength)
	{
		cli::array<float>^ _iData = gcnew cli::array<float>(reqLength);
		cli::array<float>^ _qData = gcnew cli::array<float>(reqLength);
		int _outLength;

		if ((_iData == nullptr) || (2 * reqLength != _iData->Length))
		{
			_iData = gcnew cli::array<float>(2 * reqLength);
		}
		if ((_qData == nullptr) || (2 * reqLength != _qData->Length))
		{
			_qData = gcnew cli::array<float>(2 * reqLength);
		}

		pin_ptr<float> iDataP = &_iData[0];
		pin_ptr<float> qDataP = &_qData[0];

		ReturnStatus rs = ErrorCheck(RSA_API::IQBLK_GetIQDataDeinterleaved(iDataP, qDataP, &_outLength, reqLength));

		outLength = _outLength;
		iData = _iData;
		qData = _qData;
		return rs;
	}

	ReturnStatus APIWrapper::IQBLK_GetIQRecordLength(int% recordLength)
	{
		int _recordLength;
		ReturnStatus rs = ErrorCheck(RSA_API::IQBLK_GetIQRecordLength(&_recordLength));
		recordLength = _recordLength;
		return rs;
	}

	ReturnStatus APIWrapper::IQBLK_GetIQSampleRate(double% iqSampleRate)
	{
		double _iqSampleRate;
		ReturnStatus rs = ErrorCheck(RSA_API::IQBLK_GetIQSampleRate(&_iqSampleRate));
		iqSampleRate = _iqSampleRate;
		return rs;
	}

	ReturnStatus APIWrapper::IQBLK_GetMaxIQBandwidth(double% maxBandwidth)
	{
		double _maxBandwidth;
		ReturnStatus rs = ErrorCheck(RSA_API::IQBLK_GetMaxIQBandwidth(&_maxBandwidth));
		maxBandwidth = _maxBandwidth;
		return rs;
	}

	ReturnStatus APIWrapper::IQBLK_GetMaxIQRecordLength(int% maxSamples)
	{
		int _maxSamples;
		ReturnStatus rs = ErrorCheck(RSA_API::IQBLK_GetMaxIQRecordLength(&_maxSamples));
		maxSamples = _maxSamples;
		return rs;
	}

	ReturnStatus APIWrapper::IQBLK_GetMinIQBandwidth(double% minBandwidth)
	{
		double _minBandwidth;
		ReturnStatus rs = ErrorCheck(RSA_API::IQBLK_GetMinIQBandwidth(&_minBandwidth));
		minBandwidth = _minBandwidth;
		return rs;
	}

	ReturnStatus APIWrapper::IQBLK_SetIQBandwidth(double iqBandwidth)
	{
		return ErrorCheck(RSA_API::IQBLK_SetIQBandwidth(iqBandwidth));
	}

	ReturnStatus APIWrapper::IQBLK_SetIQRecordLength(int recordLength)
	{
		return ErrorCheck(RSA_API::IQBLK_SetIQRecordLength(recordLength));
	}

	ReturnStatus APIWrapper::IQBLK_WaitForIQDataReady(int timeoutMsec, bool% ready)
	{
		bool _ready;
		ReturnStatus rs = ErrorCheck(RSA_API::IQBLK_WaitForIQDataReady(timeoutMsec, &_ready));
		ready = _ready;
		return rs;
	}

	///////IQ Streaming Functions//////

	ReturnStatus APIWrapper::IQSTREAM_GetMaxAcqBandwidth(double% maxBandwidthHz)
	{
		double _maxBandwidthHz;
		ReturnStatus rs = ErrorCheck(RSA_API::IQSTREAM_GetMaxAcqBandwidth(&_maxBandwidthHz));
		maxBandwidthHz = _maxBandwidthHz;
		return rs;
	}

	ReturnStatus APIWrapper::IQSTREAM_GetMinAcqBandwidth(double% minBandwidthHz)
	{
		double _minBandwidthHz;
		ReturnStatus rs = ErrorCheck(RSA_API::IQSTREAM_GetMaxAcqBandwidth(&_minBandwidthHz));
		minBandwidthHz = _minBandwidthHz;
		return rs;
	}

	void APIWrapper::IQSTREAM_ClearAcqStatus()
	{
		RSA_API::IQSTREAM_ClearAcqStatus();
	}

	ReturnStatus APIWrapper::IQSTREAM_GetAcqParameters(double% bwHz_act, double% srSps)
	{
		double _bwHz_act, _srSps;
		ReturnStatus rs = ErrorCheck(RSA_API::IQSTREAM_GetAcqParameters(&_bwHz_act, &_srSps));
		bwHz_act = _bwHz_act;
		srSps = _srSps;
		return rs;
	}

	ReturnStatus APIWrapper::IQSTREAM_GetDiskFileInfo(IQSTRMFILEINFO^% fileinfo)
	{
		RSA_API::IQSTRMFILEINFO info;
		ReturnStatus rs = ErrorCheck(RSA_API::IQSTREAM_GetDiskFileInfo(&info));
		if (fileinfo == nullptr) return (ReturnStatus)301;
		fileinfo->numberSamples = info.numberSamples;
		fileinfo->sample0Timestamp = info.sample0Timestamp;
		fileinfo->triggerSampleIndex = info.triggerSampleIndex;
		fileinfo->triggerTimestamp = info.triggerTimestamp;
		fileinfo->acqStatus = info.acqStatus;
		fileinfo->filenames = gcnew array< String^ >(2);
		fileinfo->filenames[0] = gcnew String(info.filenames[0]);
		fileinfo->filenames[1] = gcnew String(info.filenames[1]);
		return rs;
	}

	ReturnStatus APIWrapper::IQSTREAM_GetDiskFileWriteStatus(bool% isComplete, bool% isWriting)
	{
		bool _isComplete, _isWriting;
		ReturnStatus rs = ErrorCheck(RSA_API::IQSTREAM_GetDiskFileWriteStatus(&_isComplete,&_isWriting));
		isComplete = _isComplete;
		isWriting = _isWriting;
		return rs;
	}
	
	ReturnStatus APIWrapper::IQSTREAM_GetEnable(bool% enabled)
	{
		bool _enabled;
		ReturnStatus rs = ErrorCheck(RSA_API::IQSTREAM_GetEnable(&_enabled));
		enabled = _enabled;
		return rs;
	}

	ReturnStatus APIWrapper::IQSTREAM_GetIQData(Object^ % iqdata, int% iqlen, IQSTRMIQINFO^% iqinfo)
	{
		if (iqinfo == nullptr) return (ReturnStatus)301;
		int _maxSize;
		RSA_API::IQSTREAM_GetIQDataBufferSize(&_maxSize);
		int _bufferSize = 2 * _maxSize;
		int _iqlen;
		RSA_API::IQSTRMIQINFO _iqinfo;
		cli::array<float>^ _iqStreamResultArrayFlt32;
		if (!_iqStreamReadArrayFlt32 || (_iqStreamResultArrayFlt32 == nullptr) || (_bufferSize != _iqStreamResultArrayFlt32->Length))
		{
			if (_iqStreamReadArrayFlt32) delete[] _iqStreamReadArrayFlt32;
			_iqStreamReadArrayFlt32 = new float[_bufferSize];
			_iqStreamResultArrayFlt32 = gcnew cli::array<float>(_bufferSize);
		}
		ReturnStatus rs = ErrorCheck(RSA_API::IQSTREAM_GetIQData((RSA_API::Cplx32*)_iqStreamReadArrayFlt32, &_iqlen, &_iqinfo));
		for (int i = 0; i < _iqlen * 2; i++)
		{
			_iqStreamResultArrayFlt32[i] = _iqStreamReadArrayFlt32[i];
		}
		iqlen = _iqlen;
		iqinfo->scaleFactor = _iqinfo.scaleFactor;
		iqinfo->timestamp = _iqinfo.timestamp;
		iqinfo->triggerCount = _iqinfo.triggerCount;
		iqinfo->triggerIndices = gcnew cli::array<int>(RSA_API::IQSTRM_MAXTRIGGERS);
		for (int n = 0; n < RSA_API::IQSTRM_MAXTRIGGERS; n++)
			iqinfo->triggerIndices[n] = _iqinfo.triggerIndices[n];
		iqinfo->acqStatus = _iqinfo.acqStatus;
		return rs;
	}

	ReturnStatus APIWrapper::IQSTREAM_GetIQDataBufferSize(int% maxSize)
	{
		int _maxSize;
		ReturnStatus rs = ErrorCheck(RSA_API::IQSTREAM_GetIQDataBufferSize(&_maxSize));
		maxSize = _maxSize;
		return rs;
	}

	ReturnStatus APIWrapper::IQSTREAM_SetAcqBandwidth(double bwHz_req)
	{
		return ErrorCheck(RSA_API::IQSTREAM_SetAcqBandwidth(bwHz_req));
	}

	ReturnStatus APIWrapper::IQSTREAM_SetDiskFileLength(int msec)
	{
		return ErrorCheck(RSA_API::IQSTREAM_SetDiskFileLength(msec));
	}

	ReturnStatus APIWrapper::IQSTREAM_SetDiskFilenameBase(String^ filenameBase)
	{
		char * p = (char *)Marshal::StringToHGlobalAnsi(filenameBase).ToPointer();
		ReturnStatus rs = ErrorCheck(RSA_API::IQSTREAM_SetDiskFilenameBase(p));
		Marshal::FreeHGlobal(IntPtr(p));
		return rs;
	}

	ReturnStatus APIWrapper::IQSTREAM_SetDiskFilenameBaseW(String^ filenameBaseW)
	{
		wchar_t * p = (wchar_t *)Marshal::StringToHGlobalAnsi(filenameBaseW).ToPointer();
		ReturnStatus rs = ErrorCheck(RSA_API::IQSTREAM_SetDiskFilenameBaseW(p));
		Marshal::FreeHGlobal(IntPtr(p));
		return rs;
	}

	ReturnStatus APIWrapper::IQSTREAM_SetDiskFilenameSuffix(IQSSDFN_SUFFIX suffixCtl)
	{
		int i = (int)suffixCtl;
		return ErrorCheck(RSA_API::IQSTREAM_SetDiskFilenameSuffix(i));
	}

	ReturnStatus APIWrapper::IQSTREAM_SetIQDataBufferSize(int reqSize)
	{
		return ErrorCheck(RSA_API::IQSTREAM_SetIQDataBufferSize(reqSize));
	}

	ReturnStatus APIWrapper::IQSTREAM_SetOutputConfiguration(IQSOUTDEST dest, IQSOUTDTYPE dtype)
	{
		RSA_API::IQSOUTDEST _dest = (RSA_API::IQSOUTDEST)dest;
		RSA_API::IQSOUTDTYPE _dtype = (RSA_API::IQSOUTDTYPE)dtype;
		return ErrorCheck(RSA_API::IQSTREAM_SetOutputConfiguration(_dest, _dtype));
	}

	ReturnStatus APIWrapper::IQSTREAM_Start()
	{
		return ErrorCheck(RSA_API::IQSTREAM_Start());
	}

	ReturnStatus APIWrapper::IQSTREAM_Stop()
	{
		return ErrorCheck(RSA_API::IQSTREAM_Stop());
	}

	///////Playback Functions//////

	ReturnStatus APIWrapper::PLAYBACK_OpenDiskFile(String^ fileName, int
		startPercentage, int stopPercentage, double skipTimeBetweenFullAcquisitions,
		bool loopAtEndOfFile, bool emulateRealTime)
	{
		wchar_t * p = (wchar_t *)Marshal::StringToHGlobalAnsi(fileName).ToPointer();
		ReturnStatus rs = ErrorCheck(RSA_API::PLAYBACK_OpenDiskFile(p,startPercentage,stopPercentage,skipTimeBetweenFullAcquisitions,
			loopAtEndOfFile,emulateRealTime));
		Marshal::FreeHGlobal(IntPtr(p));
		return rs;
	}

	ReturnStatus APIWrapper::PLAYBACK_GetReplayComplete(bool% complete)
	{
		bool _complete;
		ReturnStatus rs = ErrorCheck(RSA_API::PLAYBACK_GetReplayComplete(&_complete));
		complete = _complete;
		return rs;
	}

	////Power Functions/////

	ReturnStatus APIWrapper::POWER_GetStatus(POWER_INFO^% powerInfo)
	{
		RSA_API::POWER_INFO info;
		memset(&info, 0, sizeof(RSA_API::POWER_INFO));
		ReturnStatus rs = ErrorCheck(RSA_API::POWER_GetStatus(&info));
		if (powerInfo == nullptr) return (ReturnStatus)301;
		powerInfo->batteryChargeLevel = info.batteryChargeLevel;
		powerInfo->batteryCharging = info.batteryCharging;
		powerInfo->batteryHardwareError = info.batteryHardwareError;
		powerInfo->batteryOverTemperature = info.batteryOverTemperature;
		powerInfo->batteryPresent = info.batteryPresent;
		powerInfo->externalPowerPresent = info.externalPowerPresent;
		return rs;
	}

	///Spectrum Functions///

	ReturnStatus APIWrapper::SPECTRUM_AcquireTrace()
	{
		return ErrorCheck(RSA_API::SPECTRUM_AcquireTrace());
	}

	ReturnStatus APIWrapper::SPECTRUM_GetEnable(bool% enable)
	{
		bool _enable;
		ReturnStatus rs = ErrorCheck(RSA_API::SPECTRUM_GetEnable(&_enable));
		enable = _enable;
		return rs;
	}

	ReturnStatus APIWrapper::SPECTRUM_GetLimits(Spectrum_Limits^% limits)
	{
		RSA_API::Spectrum_Limits _limits;
		ReturnStatus rs = ErrorCheck(RSA_API::SPECTRUM_GetLimits(&_limits));
		if (limits == nullptr) return (ReturnStatus)301;
		limits->maxRBW = _limits.maxRBW;
		limits->maxSpan = _limits.maxSpan;
		limits->maxTraceLength = _limits.maxTraceLength;
		limits->maxVBW = _limits.maxVBW;
		limits->minRBW = _limits.minRBW;
		limits->minSpan = _limits.minSpan;
		limits->minTraceLength = _limits.minTraceLength;
		limits->minVBW = _limits.minVBW;
		return rs;
	}

	ReturnStatus APIWrapper::SPECTRUM_GetSettings(Spectrum_Settings^% settings)
	{
		RSA_API::Spectrum_Settings _settings;
		ReturnStatus rs = ErrorCheck(RSA_API::SPECTRUM_GetSettings(&_settings));
		if (settings == nullptr) return (ReturnStatus)301;
		settings->actualFreqStepSize = _settings.actualFreqStepSize;
		settings->actualNumIQSamples = _settings.actualNumIQSamples;
		settings->actualRBW = _settings.actualRBW;
		settings->actualStartFreq = _settings.actualStartFreq;
		settings->actualStopFreq = _settings.actualStopFreq;
		settings->actualVBW = _settings.actualVBW;
		settings->enableVBW = _settings.enableVBW;
		settings->rbw = _settings.rbw;
		settings->span = _settings.span;
		settings->traceLength = _settings.traceLength;
		settings->vbw = _settings.vbw;
		SpectrumVerticalUnits _units = (SpectrumVerticalUnits)(_settings.verticalUnit);
		settings->verticalUnit = _units;
		SpectrumWindows _window = (SpectrumWindows)(_settings.window);
		settings->window = _window;
		return rs;
	}

	ReturnStatus APIWrapper::SPECTRUM_GetTrace(SpectrumTraces trace, int maxTracePoints, cli::array<float>^% traceData, int% outTracePoints)
	{
		traceData = gcnew cli::array<float>(maxTracePoints);

		_spectrumTraceArray = gcnew cli::array<float>(maxTracePoints);
		pin_ptr<float> p = &_spectrumTraceArray[0];
		int _outTracePoints;
		RSA_API::SpectrumTraces _trace = (RSA_API::SpectrumTraces)trace;
		ReturnStatus rs = ErrorCheck(RSA_API::SPECTRUM_GetTrace(_trace, maxTracePoints, p, &_outTracePoints));
		traceData = _spectrumTraceArray;
		outTracePoints = _outTracePoints;
		return rs;
	}

	ReturnStatus APIWrapper::APIWrapper::SPECTRUM_GetTraceInfo(Spectrum_TraceInfo^% traceInfo)
	{
		RSA_API::Spectrum_TraceInfo _info;
		ReturnStatus rs = ErrorCheck(RSA_API::SPECTRUM_GetTraceInfo(&_info));
		if (traceInfo == nullptr) return (ReturnStatus)301;
		traceInfo->acqDataStatus = _info.acqDataStatus;
		traceInfo->timestamp = _info.timestamp;
		return rs;
	}

	ReturnStatus APIWrapper::SPECTRUM_GetTraceType(SpectrumTraces trace, bool%enable, SpectrumDetectors% detector)
	{
		bool _enable;
		RSA_API::SpectrumDetectors _detector = (RSA_API::SpectrumDetectors)detector;
		RSA_API::SpectrumTraces _trace = (RSA_API::SpectrumTraces)trace;
		ReturnStatus rs = ErrorCheck(RSA_API::SPECTRUM_GetTraceType(_trace, &_enable, &_detector));
		enable = _enable;
		detector = (SpectrumDetectors)_detector;
		return rs;
	}

	ReturnStatus APIWrapper::SPECTRUM_SetDefault()
	{
		return ErrorCheck(RSA_API::SPECTRUM_SetDefault());
	}

	ReturnStatus APIWrapper::SPECTRUM_SetEnable(bool enable)
	{
		return ErrorCheck(RSA_API::SPECTRUM_SetEnable(enable));
	}

	ReturnStatus APIWrapper::SPECTRUM_SetSettings(Spectrum_Settings^ settings)
	{
		if (settings == nullptr)
			return (ReturnStatus)301;
		RSA_API::Spectrum_Settings _settings;
		_settings.actualFreqStepSize = settings->actualFreqStepSize;
		_settings.actualNumIQSamples = settings->actualNumIQSamples;
		_settings.actualRBW = settings->actualRBW;
		_settings.actualStartFreq = settings->actualStartFreq;
		_settings.actualStopFreq = settings->actualStopFreq;
		_settings.actualVBW = settings->actualVBW;
		_settings.enableVBW = settings->enableVBW;
		_settings.rbw = settings->rbw;
		_settings.span = settings->span;
		_settings.traceLength = settings->traceLength;
		_settings.vbw = settings->vbw;
		RSA_API::SpectrumVerticalUnits _units = (RSA_API::SpectrumVerticalUnits)(settings->verticalUnit);
		_settings.verticalUnit = _units;
		RSA_API::SpectrumWindows _window = (RSA_API::SpectrumWindows)(settings->window);
		_settings.window = _window;
		return ErrorCheck(RSA_API::SPECTRUM_SetSettings(_settings));
	}

	ReturnStatus APIWrapper::SPECTRUM_SetTraceType(SpectrumTraces trace, bool enable, SpectrumDetectors detector)
	{
		RSA_API::SpectrumTraces _trace = (RSA_API::SpectrumTraces)trace;
		RSA_API::SpectrumDetectors _detector = (RSA_API::SpectrumDetectors)detector;
		return ErrorCheck(RSA_API::SPECTRUM_SetTraceType(_trace, enable, _detector));
	}

	ReturnStatus APIWrapper::SPECTRUM_WaitForTraceReady(int timeoutMsec, bool% ready)
	{
		bool _ready;
		ReturnStatus rs = ErrorCheck(RSA_API::SPECTRUM_WaitForTraceReady(timeoutMsec, &_ready));
		ready = _ready;
		return rs;
	}

	/////Time Functions///////

	ReturnStatus APIWrapper::REFTIME_SetReferenceTime(time_t refTimeSec, UInt64 refTimeNsec, UInt64 refTimestamp)
	{
		return ErrorCheck(RSA_API::REFTIME_SetReferenceTime(refTimeSec, refTimeNsec, refTimeNsec));
	}

	ReturnStatus APIWrapper::REFTIME_GetReferenceTime(time_t% refTimeSec, UInt64% refTimeNsec, UInt64% refTimestamp)
	{
		time_t refTimeTimet;
		uint64_t _refTimeNsec;
		uint64_t _refTimestamp;
		ReturnStatus rs = ErrorCheck(RSA_API::REFTIME_GetReferenceTime(&refTimeTimet, &_refTimeNsec, &_refTimestamp));
		refTimeSec = (uint64_t)refTimeTimet;
		refTimeNsec = _refTimeNsec;
		refTimestamp = _refTimestamp;
		return rs;
	}

	ReturnStatus APIWrapper::REFTIME_GetCurrentTime(time_t% o_timeSec, UInt64% o_timeNsec, UInt64% o_timestamp)
	{
		time_t _o_timeSec;
		UInt64 _o_timeNsec;
		UInt64 _o_timeStamp;
		ReturnStatus rs = ErrorCheck(RSA_API::REFTIME_GetCurrentTime(&_o_timeSec,&_o_timeNsec,&_o_timeStamp));
		o_timeSec = (uint64_t)_o_timeSec;
		o_timeNsec = _o_timeNsec;
		o_timestamp = _o_timeStamp;
		return rs;
	}

	ReturnStatus APIWrapper::REFTIME_GetIntervalSinceRefTimeSet(double% sec)
	{
		double _sec;
		ReturnStatus rs = ErrorCheck(RSA_API::REFTIME_GetIntervalSinceRefTimeSet(&_sec));
		sec = _sec;
		return rs;
	}

	ReturnStatus APIWrapper::REFTIME_GetTimeFromTimestamp(UInt64 i_timestamp, time_t% o_timeSec, UInt64% o_timeNsec)
	{
		time_t _o_timeSec;
		UInt64 _o_timeNsec;
		ReturnStatus rs = ErrorCheck(RSA_API::REFTIME_GetTimeFromTimestamp(i_timestamp, &_o_timeSec, &_o_timeNsec));
		o_timeSec = (uint64_t)_o_timeSec;
		o_timeNsec = (uint64_t)_o_timeNsec;
		return rs;
	}

	ReturnStatus APIWrapper::REFTIME_GetTimestampFromTime(time_t i_timeSec, UInt64 i_timeNsec, UInt64% o_timestamp)
	{
		UInt64 _o_timestamp;
		ReturnStatus rs = ErrorCheck(RSA_API::REFTIME_GetTimestampFromTime(i_timeSec, i_timeNsec,&_o_timestamp));
		o_timestamp = _o_timestamp;
		return rs;

	}

	ReturnStatus APIWrapper::REFTIME_GetTimestampRate(UInt64% refTimestampRate)
	{
		UInt64 _refTimestampRate;
		ReturnStatus rs = ErrorCheck(RSA_API::REFTIME_GetTimestampRate(&_refTimestampRate));
		refTimestampRate = _refTimestampRate;
		return rs;
	}

	///////Tracking generator functions//////

	ReturnStatus  APIWrapper::TRKGEN_GetEnable(bool% enable)
	{
		bool _enable;
		ReturnStatus rs = ErrorCheck(RSA_API::TRKGEN_GetEnable(&_enable));
		enable = _enable;
		return rs;
	}

	ReturnStatus  APIWrapper::TRKGEN_GetHwInstalled(bool% installed)
	{
		bool _installed;
		ReturnStatus rs = ErrorCheck(RSA_API::TRKGEN_GetHwInstalled(&_installed));
		installed = _installed;
		return rs;
	}

	ReturnStatus  APIWrapper::TRKGEN_GetOutputLevel(double% levelDbm)
	{
		double _levelDbm;
		ReturnStatus rs = ErrorCheck(RSA_API::TRKGEN_GetOutputLevel(&_levelDbm));
		levelDbm = _levelDbm;
		return rs;
	}

	ReturnStatus  APIWrapper::TRKGEN_SetEnable(bool enable)
	{
		return ErrorCheck(RSA_API::TRKGEN_SetEnable(enable));
	}

	ReturnStatus  APIWrapper::TRKGEN_SetOutputLevel(double levelDbm)
	{
		return ErrorCheck(RSA_API::TRKGEN_SetOutputLevel(levelDbm));
	}

	/////Trigger Functions//////

	ReturnStatus APIWrapper::TRIG_ForceTrigger()
	{
		return ErrorCheck(RSA_API::TRIG_ForceTrigger());
	}

	ReturnStatus APIWrapper::TRIG_GetIFPowerTriggerLevel(double% level)
	{
		double _level;
		ReturnStatus rs = ErrorCheck(RSA_API::TRIG_GetIFPowerTriggerLevel(&_level));
		level = _level;
		return rs;
	}

	ReturnStatus APIWrapper::TRIG_GetTriggerMode(TriggerMode% mode)
	{
		RSA_API::TriggerMode _mode;
		ReturnStatus rs = ErrorCheck(RSA_API::TRIG_GetTriggerMode(&_mode));
		mode = (TriggerMode)_mode;
		return rs;
	}

	ReturnStatus APIWrapper::TRIG_GetTriggerPositionPercent(double% trigPosPercent)
	{
		double _trigPosPercent;
		ReturnStatus rs = ErrorCheck(RSA_API::TRIG_GetTriggerPositionPercent(&_trigPosPercent));
		trigPosPercent = _trigPosPercent;
		return rs;
	}

	ReturnStatus APIWrapper::TRIG_GetTriggerSource(TriggerSource% source)
	{
		RSA_API::TriggerSource _source;
		ReturnStatus rs = ErrorCheck(RSA_API::TRIG_GetTriggerSource(&_source));
		source = (TriggerSource)_source;
		return rs;
	}

	ReturnStatus APIWrapper::TRIG_GetTriggerTransition(TriggerTransition% transition)
	{
		RSA_API::TriggerTransition _transition;
		ReturnStatus rs = ErrorCheck(RSA_API::TRIG_GetTriggerTransition(&_transition));
		transition = (TriggerTransition)_transition;
		return rs;
	}

	ReturnStatus APIWrapper::TRIG_SetIFPowerTriggerLevel(double level)
	{
		return ErrorCheck(RSA_API::TRIG_SetIFPowerTriggerLevel(level));
	}

	ReturnStatus APIWrapper::TRIG_SetTriggerMode(TriggerMode mode)
	{
		RSA_API::TriggerMode _mode = (RSA_API::TriggerMode)mode;
		return ErrorCheck(RSA_API::TRIG_SetTriggerMode(_mode));
	}

	ReturnStatus APIWrapper::TRIG_SetTriggerPositionPercent(double trigPosPercent)
	{
		return ErrorCheck(RSA_API::TRIG_SetTriggerPositionPercent(trigPosPercent));
	}

	ReturnStatus APIWrapper::TRIG_SetTriggerSource(TriggerSource source)
	{
		RSA_API::TriggerSource _source = (RSA_API::TriggerSource)source;
		return ErrorCheck(RSA_API::TRIG_SetTriggerSource(_source));
	}

	ReturnStatus APIWrapper::TRIG_SetTriggerTransition(TriggerTransition transition)
	{
		RSA_API::TriggerTransition _transition = (RSA_API::TriggerTransition)transition;
		return ErrorCheck(RSA_API::TRIG_SetTriggerTransition(_transition));
	}

	ReturnStatus  APIWrapper::CONFIG_DecodeFreqRefUserSettingString(String^ i_usstr, FREQREF_USER_INFO^% o_fui)
	{
		char * _i_usstr = (char *)Marshal::StringToHGlobalAnsi(i_usstr).ToPointer();
		RSA_API::FREQREF_USER_INFO _o_fui;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_DecodeFreqRefUserSettingString(_i_usstr, &_o_fui));
		Marshal::FreeHGlobal(IntPtr(_i_usstr));
		if (o_fui == nullptr)
			return rs;
		o_fui->dacValue = _o_fui.dacValue;
		o_fui->datetime = gcnew String(_o_fui.datetime);
		o_fui->isvalid = _o_fui.isvalid;
		o_fui->temperature = _o_fui.temperature;
		return rs;
	}

	ReturnStatus  APIWrapper::GNSS_GetStatusRxLock(bool% lock)
	{
		bool _lock;
		ReturnStatus rs = ErrorCheck(RSA_API::GNSS_GetStatusRxLock(&_lock));
		lock = _lock;
		return rs;
	}

	ReturnStatus APIWrapper::REFTIME_GetReferenceTimeSource(REFTIME_SRC% source)
	{
		RSA_API::REFTIME_SRC _source;
		ReturnStatus rs = ErrorCheck(RSA_API::REFTIME_GetReferenceTimeSource(&_source));
		source = (REFTIME_SRC)_source;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_SetFrequencyReferenceSource(FREQREF_SOURCE src)
	{
		RSA_API::FREQREF_SOURCE _src = (RSA_API::FREQREF_SOURCE)src;
		return ErrorCheck(RSA_API::CONFIG_SetFrequencyReferenceSource(_src));
	}

	ReturnStatus APIWrapper::CONFIG_GetFrequencyReferenceSource(FREQREF_SOURCE% src)
	{
		RSA_API::FREQREF_SOURCE _src;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetFrequencyReferenceSource(&_src));
		src = (FREQREF_SOURCE)_src;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_SetModeGnssFreqRefCorrection(GFR_MODE mode)
	{
		RSA_API::GFR_MODE _mode = (RSA_API::GFR_MODE)mode;
		return ErrorCheck(RSA_API::CONFIG_SetModeGnssFreqRefCorrection(_mode));
	}

	ReturnStatus APIWrapper::CONFIG_GetModeGnssFreqRefCorrection(GFR_MODE% mode)
	{
		RSA_API::GFR_MODE _mode;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetModeGnssFreqRefCorrection(&_mode));
		mode = (GFR_MODE)_mode;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_GetStatusGnssFreqRefCorrection(GFR_STATE% state, GFR_QUALITY% quality)
	{
		RSA_API::GFR_STATE _state;
		RSA_API::GFR_QUALITY _quality;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetStatusGnssFreqRefCorrection(&_state, &_quality));
		state = (GFR_STATE)_state;
		quality = (GFR_QUALITY)_quality;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_SetEnableGnssTimeRefAlign(bool enable)
	{
		return ErrorCheck(RSA_API::CONFIG_SetEnableGnssTimeRefAlign(enable));
	}

	ReturnStatus APIWrapper::CONFIG_GetEnableGnssTimeRefAlign(bool% enable)
	{
		bool _enable;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetEnableGnssTimeRefAlign(&_enable));
		enable = _enable;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_GetStatusGnssTimeRefAlign(bool% aligned)
	{
		bool _aligned;
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetStatusGnssTimeRefAlign(&_aligned));
		aligned = _aligned;
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_SetFreqRefUserSetting(String^ i_usstr)
	{
		char * _i_usstr = (char *)Marshal::StringToHGlobalAnsi(i_usstr).ToPointer();
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_SetFreqRefUserSetting(_i_usstr));
		Marshal::FreeHGlobal(IntPtr(_i_usstr));
		return rs;
	}

	ReturnStatus APIWrapper::CONFIG_GetFreqRefUserSetting(String^% o_usstr)
	{
		char _o_usstr[RSA_API::DEVINFO_MAX_STRLEN] = "";
		ReturnStatus rs = ErrorCheck(RSA_API::CONFIG_GetFreqRefUserSetting(_o_usstr));
		o_usstr = gcnew String(_o_usstr);
		return rs;
	}

}
