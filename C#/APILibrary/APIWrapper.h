using namespace System;
using namespace System::Threading;
using namespace System::Runtime::InteropServices;

namespace Tektronix
{
	public enum class EventType
	{
		DEVEVENT_OVERRANGE = RSA_API::DEVEVENT_OVERRANGE,
		DEVEVENT_TRIGGER = RSA_API::DEVEVENT_TRIGGER,
		DEVEVENT_1PPS = RSA_API::DEVEVENT_1PPS,
		//DEVEVENT_LOUNLOCK = RSA_API::DEVEVENT_LOUNLOCK,
	};

	public enum class TraceType
	{
		TraceTypeAverage = 0,
		TraceTypeMax = 1,
		TraceTypeMaxHold = 2,
		TraceTypeMin = 3,
		TraceTypeMinHold = 4
	};

	public enum class VerticalUnitType
	{
		VerticalUnit_dBm = 0,
		VerticalUnit_Watt = 1,
		VerticalUnit_Volt = 2,
		VerticalUnit_Amp = 3
	};

	public ref struct DPX_FrameBuffer
	{
		Int32 fftPerFrame;
		Int64 fftCount;
		Int64 frameCount;
		double timestamp;
		Int32 acqDataStatus;

		double minSigDuration;
		bool minSigDurOutOfRange;

		Int32 spectrumBitmapWidth;
		Int32 spectrumBitmapHeight;
		Int32 spectrumBitmapSize;
		Int32 spectrumTraceLength;
		Int32 numSpectrumTraces;

		bool spectrumEnabled;
		bool spectrogramEnabled;

		cli::array<float>^ spectrumBitmap;
		cli::array<cli::array<float>^>^ spectrumTraces;

		Int32 sogramBitmapWidth;
		Int32 sogramBitmapHeight;
		Int32 sogramBitmapSize;
		Int32 sogramBitmapNumValidLines;
		cli::array<System::Byte>^ sogramBitmap;
		cli::array<double>^ sogramBitmapTimestampArray;
		cli::array<Int16>^ sogramBitmapContainTriggerArray;
	};

	public ref struct DPX_SettingsStruct
	{
		bool enableSpectrum;
		bool enableSpectrogram;
		Int32 bitmapWidth;
		Int32 bitmapHeight;
		Int32 traceLength;
		float decayFactor;
		double actualRBW;
	};

	public ref struct DPX_SogramSettingsStruct
	{
		Int32 bitmapWidth;
		Int32 bitmapHeight;
		double sogramTraceLineTime;
		double sogramBitmapLineTime;
	};

	public ref struct DEVICE_INFO
	{
		String^ nomenclature;
		String^ serialNum;
		String^ apiVersion;
		String^ fwVersion;
		String^ fpgaVersion;
		String^ hwVersion;
	};

	public enum class AudioDemodMode
	{
		ADM_FM_8KHZ = 0,
		ADM_FM_13KHZ = 1,
		ADM_FM_75KHZ = 2,
		ADM_FM_200KHZ = 3,
		ADM_AM_8KHZ = 4,
		ADM_NONE	// internal use only
	};

	public enum class GNSS_SATSYS
	{ 
		GNSS_NOSYS = 0, 
		GNSS_GPS_GLONASS = 1, 
		GNSS_GPS_BEIDOU = 2, 
		GNSS_GPS = 3, 
		GNSS_GLONASS = 4, 
		GNSS_BEIDOU = 5,
	};

	public enum class StreamingMode
	{
		StreamingModeRaw = 0,
		StreamingModeFramed = 1
	};

	public ref struct IQBLK_ACQINFO
	{
		UInt64  sample0Timestamp; 
		UInt64  triggerSampleIndex;
		UInt64  triggerTimestamp;
		UInt32  acqStatus;
	};

	public enum class IQSOUTDEST 
	{ 
		IQSOD_CLIENT = 0, 
		IQSOD_FILE_TIQ = 1, 
		IQSOD_FILE_SIQ = 2, 
		IQSOD_FILE_SIQ_SPLIT = 3 
	};

	public enum class IQSOUTDTYPE 
	{ 
		IQSODT_SINGLE = 0, 
		IQSODT_INT32 = 1, 
		IQSODT_INT16 = 2 
	};

	public enum class IQSSDFN_SUFFIX 
	{ 
		IQSSDFN_SUFFIX_INCRINDEX_MIN = 0,
		IQSSDFN_SUFFIX_TIMESTAMP = -1,
		IQSSDFN_SUFFIX_NONE = -2
	};

	public ref struct POWER_INFO
	{
		bool externalPowerPresent;
		bool batteryPresent;
		double batteryChargeLevel;
		bool batteryCharging;
		bool batteryOverTemperature;
		bool batteryHardwareError;
	};

	public ref struct Cplx32
	{
		float i;
		float q;
	};

	public ref struct CplxInt32
	{
		Int32 i;
		Int32 q;
	};

	public ref struct CplxInt16
	{
		Int16 i;
		Int16 q;
	};

	public ref struct IQSTRMFILEINFO
	{
		UInt64  numberSamples;
		UInt64  sample0Timestamp;
		UInt64  triggerSampleIndex;
		UInt64  triggerTimestamp;
		UInt32  acqStatus;
		cli::array<String^>^ filenames;
	};

	public ref struct IQSTRMIQINFO
	{
		UInt64  timestamp;
		int     triggerCount;
		cli::array<int>^ triggerIndices;
		double    scaleFactor;  
		UInt32  acqStatus;
	};

	public enum class SpectrumWindows
	{
		SpectrumWindow_Kaiser = 0,
		SpectrumWindow_Mil6dB = 1,
		SpectrumWindow_BlackmanHarris = 2,
		SpectrumWindow_Rectangle = 3,
		SpectrumWindow_FlatTop = 4,
		SpectrumWindow_Hann = 5
	};

	public enum class SpectrumTraces
	{
		SpectrumTrace1 = 0,
		SpectrumTrace2 = 1,
		SpectrumTrace3 = 2
	};

	public enum class SpectrumDetectors
	{
		SpectrumDetector_PosPeak = 0,
		SpectrumDetector_NegPeak = 1,
		SpectrumDetector_AverageVRMS = 2,
		SpectrumDetector_Sample = 3
	};

	public enum class SpectrumVerticalUnits
	{
		SpectrumVerticalUnit_dBm = 0,
		SpectrumVerticalUnit_Watt = 1,
		SpectrumVerticalUnit_Volt = 2,
		SpectrumVerticalUnit_Amp = 3,
		SpectrumVerticalUnit_dBmV = 4
	};

	public ref struct Spectrum_Limits
	{
		double maxSpan;
		double minSpan;
		double maxRBW;
		double minRBW;
		double maxVBW;
		double minVBW;
		int maxTraceLength;
		int minTraceLength;
	};

	public ref struct Spectrum_Settings
	{
		double span;
		double rbw;
		bool enableVBW;
		double vbw;
		int traceLength;
		SpectrumWindows window;
		SpectrumVerticalUnits verticalUnit;

		double actualStartFreq;
		double actualStopFreq;
		double actualFreqStepSize;
		double actualRBW;
		double actualVBW;
		int actualNumIQSamples;
	};

	public ref struct Spectrum_TraceInfo
	{
		UInt64 timestamp;	
		UInt16 acqDataStatus;	
	};

	public enum class TriggerMode
	{
		freeRun = 0,
		triggered = 1
	};

	public enum class TriggerSource
	{
		TriggerSourceExternal = 0,
		TriggerSourceIFPowerLevel = 1
	};

	public enum class TriggerTransition
	{
		TriggerTransitionLH = 1,	
		TriggerTransitionHL = 2,
		TriggerTransitionEither = 3	
	};

	public ref struct FREQREF_USER_INFO
	{
		bool    isvalid;
		unsigned int dacValue;
		String ^ datetime;  // storage d/t as yyyy-mm-ddThh:mm:ss
		double  temperature;    // storage temperature degC
	};

	public enum class REFTIME_SRC 
	{ 
		RTSRC_NONE = 0, 
		RTSRC_SYSTEM = 1, 
		RTSRC_GNSS = 2, 
		RTSRC_USER = 3 
	};

	public enum class FREQREF_SOURCE { FRS_INTERNAL = 0, FRS_EXTREF = 1, FRS_GNSS = 2, FRS_USER = 3 };
	public enum class GFR_MODE { GFRM_OFF = 0, GFRM_FREQTRACK = 2, GFRM_PHASETRACK = 3, GFRM_HOLD = 4 };
	public enum class GFR_STATE { GFRS_OFF = 0, GFRS_ACQUIRING = 1, GFRS_FREQTRACKING = 2, GFRS_PHASETRACKING = 3, GFRS_HOLDING = 4 };
	public enum class GFR_QUALITY { GFRQ_INVALID = 0, GFRQ_LOW = 1, GFRQ_MEDIUM = 2, GFRQ_HIGH = 3 };

	public enum class ReturnStatus
	{
		//-----------------
		// User errors - must not change the location of these error codes
		//-----------------
		noError = 0,

		// Connection
		errorNotConnected = 101,
		errorIncompatibleFirmware,
		errorBootLoaderNotRunning,
		errorTooManyBootLoadersConnected,
		errorRebootFailure,
		errorGNSSNotInstalled,
		errorGNSSNotEnabled,

		// POST
		errorPOSTFailureFPGALoad = 201,
		errorPOSTFailureHiPower,
		errorPOSTFailureI2C,
		errorPOSTFailureGPIF,
		errorPOSTFailureUsbSpeed,
		errorPOSTDiagFailure,
		errorPOSTFailure3P3VSense,

		// General Msmt
		errorBufferAllocFailed = 301,
		errorParameter,
		errorDataNotReady,

		// Spectrum
		errorParameterTraceLength = 1101,
		errorMeasurementNotEnabled,
		errorSpanIsLessThanRBW,
		errorFrequencyOutOfRange,

		// IF streaming
		errorStreamADCToDiskFileOpen = 1201,
		errorStreamADCToDiskAlreadyStreaming,
		errorStreamADCToDiskBadPath,
		errorStreamADCToDiskThreadFailure,
		errorStreamedFileInvalidHeader,
		errorStreamedFileOpenFailure,
		errorStreamingOperationNotSupported,
		errorStreamingFastForwardTimeInvalid,
		errorStreamingInvalidParameters,
		errorStreamingEOF,

		// IQ streaming
		errorIQStreamInvalidFileDataType = 1301,
		errorIQStreamFileOpenFailed,
		errorIQStreamBandwidthOutOfRange,

		//-----------------
		// Internal errors
		//-----------------
		errorTimeout = 3001,
		errorTransfer,
		errorFileOpen,
		errorFailed,
		errorCRC,
		errorChangeToFlashMode,
		errorChangeToRunMode,
		errorDSPLError,
		errorLOLockFailure,
		errorExternalReferenceNotEnabled,
		errorLogFailure,
		errorRegisterIO,
		errorFileRead,
		errorConsumerNotActive,

		errorDisconnectedDeviceRemoved = 3101,
		errorDisconnectedDeviceNodeChangedAndRemoved,
		errorDisconnectedTimeoutWaitingForADcData,
		errorDisconnectedIOBeginTransfer,
		errorOperationNotSupportedInSimMode,

		errorFPGAConfigureFailure = 3201,
		errorCalCWNormFailure,
		errorSystemAppDataDirectory,
		errorFileCreateMRU,
		errorDeleteUnsuitableCachePath,
		errorUnableToSetFilePermissions,
		errorCreateCachePath,
		errorCreateCachePathBoost,
		errorCreateCachePathStd,
		errorCreateCachePathGen,
		errorBufferLengthTooSmall,
		errorRemoveCachePath,
		errorGetCachingDirectoryBoost,
		errorGetCachingDirectoryStd,
		errorGetCachingDirectoryGen,
		errorInconsistentFileSystem,

		errorWriteCalConfigHeader = 3301,
		errorWriteCalConfigData,
		errorReadCalConfigHeader,
		errorReadCalConfigData,
		errorEraseCalConfig,
		errorCalConfigFileSize,
		errorInvalidCalibConstantFileFormat,
		errorMismatchCalibConstantsSize,
		errorCalConfigInvalid,

		// Flash
		errorFlashFileSystemUnexpectedSize = 3401,
		errorFlashFileSystemNotMounted,
		errorFlashFileSystemOutOfRange,
		errorFlashFileSystemIndexNotFound,
		errorFlashFileSystemReadErrorCRC,
		errorFlashFileSystemReadFileMissing,
		errorFlashFileSystemCreateCacheIndex,
		errorFlashFileSystemCreateCachedDataFile,
		errorFlashFileSystemUnsupportedFileSize,
		errorFlashFileSystemInsufficentSpace,
		errorFlashFileSystemInconsistentState,
		errorFlashFileSystemTooManyFiles,
		errorFlashFileSystemImportFileNotFound,
		errorFlashFileSystemImportFileReadError,
		errorFlashFileSystemImportFileError,
		errorFlashFileSystemFileNotFoundError,
		errorFlashFileSystemReadBufferTooSmall,
		errorFlashWriteFailure,
		errorFlashReadFailure,
		errorFlashFileSystemBadArgument,
		errorFlashFileSystemCreateFile,

		// Aux Monitoring
		errorMonitoringNotSupported = 3501,
		errorAuxDataNotAvailable,

		// Battery
		errorBatteryCommFailure = 3601,
		errorBatteryChargerCommFailure = 3602,
		errorBatteryNotPresent = 3603,

		// EST
		errorESTOutputPathFile = 3701,
		errorESTPathNotDirectory,
		errorESTPathDoesntExist,
		errorESTUnableToOpenLog,
		errorESTUnableToOpenLimits,

		// Revision information
		errorRevisionDataNotFound = 3801,

		// Alignment
		error112MHzAlignmentSignalLevelTooLow = 3901,
		error10MHzAlignmentSignalLevelTooLow,
		errorInvalidCalConstant,
		errorNormalizationCacheInvalid,
		errorInvalidAlignmentCache,
		errorLockExtRefAfterAlignment,

		// Triggering
		errorTriggerSystem = 4000,

		// VNA
		errorVNAUnsupportedConfiguration = 4100,

		// Acquisition Status
		errorADCOverrange = 9000,
		errorOscUnlock = 9001,

		errorNotSupported = 9901,

		errorPlaceholder = 9999,
		notImplemented = -1
	};

	public ref class APIWrapper
	{
	public:
		APIWrapper();
		~APIWrapper(void);
		!APIWrapper(void);

		// Alignment Functions
		ReturnStatus ALIGN_GetAlignmentNeeded(bool% needed);
		ReturnStatus ALIGN_GetWarmupStatus(bool% warmedUp);
		ReturnStatus ALIGN_RunAlignment();

		// Audio functions
		ReturnStatus AUDIO_SetFrequencyOffset(double freqOffsetHz);
		ReturnStatus AUDIO_GetFrequencyOffset(double% freqOffsetHz);
		ReturnStatus AUDIO_GetEnable(bool% enable);
		ReturnStatus AUDIO_GetData(Int16% data, Int16 inSize, UInt16% outSize);
		ReturnStatus AUDIO_GetMode(AudioDemodMode % _mode);
		ReturnStatus AUDIO_GetMute(bool% _mute);
		ReturnStatus AUDIO_GetVolume(float% _volume);
		ReturnStatus AUDIO_SetMode(AudioDemodMode mode);
		ReturnStatus AUDIO_SetMute(bool mute);
		ReturnStatus AUDIO_SetVolume(float volume);
		ReturnStatus AUDIO_Start();
		ReturnStatus AUDIO_Stop();

		// Configure functions
		ReturnStatus CONFIG_GetCenterFreq(double% cf);
		ReturnStatus CONFIG_GetExternalRefEnable(bool% exRefEn);
		ReturnStatus CONFIG_GetExternalRefFrequency(double% extFreq);
		ReturnStatus CONFIG_GetMaxCenterFreq(double% maxCF);
		ReturnStatus CONFIG_GetMinCenterFreq(double% minCF);
		ReturnStatus CONFIG_GetReferenceLevel(double% refLevel);
		ReturnStatus CONFIG_Preset();
		ReturnStatus CONFIG_SetCenterFreq(double cf);
		ReturnStatus CONFIG_SetExternalRefEnable(bool exRefEn);
		ReturnStatus CONFIG_SetReferenceLevel(double refLevel);
		ReturnStatus CONFIG_GetAutoAttenuationEnable(bool% enable);
		ReturnStatus CONFIG_SetAutoAttenuationEnable(bool enable);
		ReturnStatus CONFIG_GetRFPreampEnable(bool% enable);
		ReturnStatus CONFIG_SetRFPreampEnable(bool enable);
		ReturnStatus CONFIG_GetRFAttenuator(double% value);
		ReturnStatus CONFIG_SetRFAttenuator(double value);

		// Device functions
		String^ DEVICE_GetErrorString(ReturnStatus status);
		ReturnStatus DEVICE_SearchIntW(array<int>^% idList, cli::array<String^>^% serialList, cli::array<String^>^% typeList);
		ReturnStatus DEVICE_Search(array<int>^% idList, cli::array<String^>^% serialList, cli::array<String^>^% typeList);
		ReturnStatus DEVICE_Connect(int deviceID);
		ReturnStatus DEVICE_Disconnect();
		ReturnStatus DEVICE_GetEnable(bool% enabled);
		ReturnStatus DEVICE_GetFPGAVersion(String^ % fpgaVersion);
		ReturnStatus DEVICE_GetFWVersion(String^ % fwVersion);
		ReturnStatus DEVICE_GetHWVersion(String^ % hwVersion);
		ReturnStatus DEVICE_GetNomenclature(String^ % nomenclature);
		ReturnStatus DEVICE_GetSerialNumber(String^ % serialNum);
		ReturnStatus DEVICE_GetAPIVersion(String^ % apiVersion);
		ReturnStatus DEVICE_PrepareForRun();
		ReturnStatus DEVICE_GetInfo(DEVICE_INFO^% devInfo);
		ReturnStatus DEVICE_GetOverTemperatureStatus(bool% overTemperature);
		ReturnStatus DEVICE_Reset(int deviceID);
		ReturnStatus DEVICE_Run();
		ReturnStatus DEVICE_StartFrameTransfer();
		ReturnStatus DEVICE_Stop();
		ReturnStatus DEVICE_GetEventStatus(EventType eventID, bool% eventOccured, Int64% eventTimestamp);

		// DPX Functions
		ReturnStatus DPX_FinishFrameBuffer();
		ReturnStatus DPX_WaitForDataReady(int timeoutMsec, bool% ready);
		ReturnStatus DPX_Configure(bool enableSpectrum, bool enableSpectrogram);
		ReturnStatus DPX_GetEnable(bool % enabled);
		ReturnStatus DPX_GetRBWRange(double fspan, double% minRBW, double% maxRBW);
		ReturnStatus DPX_GetFrameInfo(Int64% frameCount, Int64% fftCount);
		ReturnStatus DPX_GetFrameBuffer(DPX_FrameBuffer^ % buffer);
		ReturnStatus DPX_SetEnable(bool enabled);
		ReturnStatus DPX_GetSettings(DPX_SettingsStruct^ % dpxSettings);
		ReturnStatus DPX_Reset();
		ReturnStatus DPX_SetParameters(double fspan, double rbw, Int32
			bitmapWidth, Int32 tracePtsPerPixel, VerticalUnitType yUnit, double yTop,
			double yBottom, bool infinitePersistence, double persistenceTimeSec, bool
			showOnlyTrigFrame);
		ReturnStatus DPX_SetSpectrumTraceType(Int32 traceIndex, TraceType type);
		ReturnStatus DPX_IsFrameBufferAvailable(bool% frameAvailable);
		ReturnStatus DPX_GetSogramHiResLine(Int16% vData, Int32% vDataSize,
			Int32 lineIndex, double% dataSF, Int32 tracePoints, Int32 firstValidPoint);
		ReturnStatus DPX_GetSogramHiResLineCountLatest(Int32% lineCount);
		ReturnStatus DPX_GetSogramHiResLineTimeStamp(double% timestamp, Int32 lineIndex);
		ReturnStatus DPX_GetSogramHiResLineTriggered(bool% triggered, Int32 lineIndex);
		ReturnStatus DPX_GetSogramSettings(DPX_SogramSettingsStruct^ % sogramSettings);
		ReturnStatus DPX_SetSogramParameters(double timePerBitmapLine, double timeResolution, double maxPower, double minPower);
		ReturnStatus DPX_SetSogramTraceType(TraceType traceType);

		// GNSS Functions
		ReturnStatus GNSS_ClearNavMessageData();
		ReturnStatus GNSS_Get1PPSTimestamp(bool% isValid, UInt64%
			timestamp1PPS);
		ReturnStatus GNSS_GetAntennaPower(bool% powered);
		ReturnStatus GNSS_GetEnable(bool% enable);
		ReturnStatus GNSS_GetHwInstalled(bool% installed);
		ReturnStatus GNSS_GetNavMessageData(int% msgLen, String^% message);
		ReturnStatus GNSS_GetSatSystem(GNSS_SATSYS^% satSystem);
		ReturnStatus GNSS_SetAntennaPower(bool powered);
		ReturnStatus GNSS_SetEnable(bool enable);
		ReturnStatus GNSS_SetSatSystem(GNSS_SATSYS satSystem);

		// IF Streaming functions
		ReturnStatus IFSTREAM_SetDiskFilenameSuffix(int suffixCtl);
		ReturnStatus IFSTREAM_GetActiveStatus(bool % enabled);
		ReturnStatus IFSTREAM_SetDiskFileCount(int maximum);
		ReturnStatus IFSTREAM_SetDiskFileLength(int msec);
		ReturnStatus IFSTREAM_SetDiskFileMode(StreamingMode mode);
		ReturnStatus IFSTREAM_SetDiskFilenameBase(String^  base);
		ReturnStatus IFSTREAM_SetDiskFilePath(String^ path);
		ReturnStatus IFSTREAM_SetEnable(bool enabled);

		// IQ Block Functions
		ReturnStatus IQBLK_GetIQAcqInfo(IQBLK_ACQINFO^ % acqInfo);
		ReturnStatus IQBLK_AcquireIQData();
		ReturnStatus IQBLK_GetIQBandwidth(double% iqBandwidth);
		ReturnStatus IQBLK_GetIQData(cli::array<float>^% iqData, int% outLength, int reqLength);
		ReturnStatus IQBLK_GetIQDataCplx(cli::array<Cplx32^>^% iqData, int% outLength, int reqLength);
		ReturnStatus IQBLK_GetIQDataDeinterleaved(cli::array<float>^ % iData, cli::array<float>^ % qData, int%outLength, int reqLength);
		ReturnStatus IQBLK_GetIQRecordLength(int% recordLength);
		ReturnStatus IQBLK_GetIQSampleRate(double% iqSampleRate);
		ReturnStatus IQBLK_GetMaxIQBandwidth(double% maxBandwidth);
		ReturnStatus IQBLK_GetMaxIQRecordLength(int% maxSamples);
		ReturnStatus IQBLK_GetMinIQBandwidth(double% minBandwidth);
		ReturnStatus IQBLK_SetIQBandwidth(double iqBandwidth);
		ReturnStatus IQBLK_SetIQRecordLength(int recordLength);
		ReturnStatus IQBLK_WaitForIQDataReady(int timeoutMsec, bool% ready);
		
		// IQ streaming functions
		ReturnStatus IQSTREAM_GetMaxAcqBandwidth(double% maxBandwidthHz);
		ReturnStatus IQSTREAM_GetMinAcqBandwidth(double% minBandwidthHz);
		void IQSTREAM_ClearAcqStatus();
		ReturnStatus IQSTREAM_GetAcqParameters(double% bwHz_act, double% srSps);
		ReturnStatus IQSTREAM_GetDiskFileInfo(IQSTRMFILEINFO^% fileinfo);
		ReturnStatus IQSTREAM_GetDiskFileWriteStatus(bool% isComplete, bool% isWriting);
		ReturnStatus IQSTREAM_GetEnable(bool% enabled);
		ReturnStatus IQSTREAM_GetIQData(Object^ % iqdata, int% iqlen, IQSTRMIQINFO^% iqinfo);
		ReturnStatus IQSTREAM_GetIQDataBufferSize(int% maxSize);
		ReturnStatus IQSTREAM_SetAcqBandwidth(double bwHz_req);
		ReturnStatus IQSTREAM_SetDiskFileLength(int msec);
		ReturnStatus IQSTREAM_SetDiskFilenameBase(String^ filenameBase);
		ReturnStatus IQSTREAM_SetDiskFilenameBaseW(String^ filenameBaseW);
		ReturnStatus IQSTREAM_SetDiskFilenameSuffix(IQSSDFN_SUFFIX suffixCtl);
		ReturnStatus IQSTREAM_SetIQDataBufferSize(int reqSize);
		ReturnStatus IQSTREAM_SetOutputConfiguration(IQSOUTDEST dest, IQSOUTDTYPE dtype);
		ReturnStatus IQSTREAM_Start();
		ReturnStatus IQSTREAM_Stop();

		// Playback functions
		ReturnStatus PLAYBACK_OpenDiskFile(String^ fileName, int
			startPercentage, int stopPercentage, double skipTimeBetweenFullAcquisitions,
			bool loopAtEndOfFile, bool emulateRealTime);
		ReturnStatus PLAYBACK_GetReplayComplete(bool% complete);

		// Power functions
		ReturnStatus POWER_GetStatus(POWER_INFO^% powerInfo);
		
		// Spectrum functions
		ReturnStatus SPECTRUM_AcquireTrace();
		ReturnStatus SPECTRUM_GetEnable(bool% enable);
		ReturnStatus SPECTRUM_GetLimits(Spectrum_Limits^% limits);
		ReturnStatus SPECTRUM_GetSettings(Spectrum_Settings^% settings);
		ReturnStatus SPECTRUM_GetTrace(SpectrumTraces trace, int maxTracePoints, cli::array<float>^% traceData, int% outTracePoints);
		ReturnStatus SPECTRUM_GetTraceInfo(Spectrum_TraceInfo^% traceInfo);
		ReturnStatus SPECTRUM_GetTraceType(SpectrumTraces trace, bool%enable, SpectrumDetectors% detector);
		ReturnStatus SPECTRUM_SetDefault();
		ReturnStatus SPECTRUM_SetEnable(bool enable);
		ReturnStatus SPECTRUM_SetSettings(Spectrum_Settings^ settings);
		ReturnStatus SPECTRUM_SetTraceType(SpectrumTraces trace, bool enable, SpectrumDetectors detector);
		ReturnStatus SPECTRUM_WaitForTraceReady(int timeoutMsec, bool% ready);
		
		// Time functions
		ReturnStatus REFTIME_SetReferenceTime(time_t refTimeSec, UInt64 refTimeNsec, UInt64 refTimestamp);
		ReturnStatus REFTIME_GetReferenceTime(time_t% refTimeSec, UInt64% refTimeNsec, UInt64% refTimestamp);
		ReturnStatus REFTIME_GetCurrentTime(time_t% o_timeSec, UInt64% o_timeNsec, UInt64% o_timestamp);
		ReturnStatus REFTIME_GetIntervalSinceRefTimeSet(double% sec);
		ReturnStatus REFTIME_GetTimeFromTimestamp(UInt64 i_timestamp, time_t% o_timeSec, UInt64% o_timeNsec);
		ReturnStatus REFTIME_GetTimestampFromTime(time_t i_timeSec, UInt64 i_timeNsec, UInt64% o_timestamp);
		ReturnStatus REFTIME_GetTimestampRate(UInt64% refTimestampRate);
		
		// Tracking generator functions
		ReturnStatus TRKGEN_GetEnable(bool% enable);
		ReturnStatus TRKGEN_GetHwInstalled(bool% installed);
		ReturnStatus TRKGEN_GetOutputLevel(double% levelDbm);
		ReturnStatus TRKGEN_SetEnable(bool enable);
		ReturnStatus TRKGEN_SetOutputLevel(double levelDbm);
		
		// Trigger functions
		ReturnStatus TRIG_ForceTrigger();
		ReturnStatus TRIG_GetIFPowerTriggerLevel(double% level);
		ReturnStatus TRIG_GetTriggerMode(TriggerMode% mode);
		ReturnStatus TRIG_GetTriggerPositionPercent(double% trigPosPercent);
		ReturnStatus TRIG_GetTriggerSource(TriggerSource% source);
		ReturnStatus TRIG_GetTriggerTransition(TriggerTransition% transition);
		ReturnStatus TRIG_SetIFPowerTriggerLevel(double level);
		ReturnStatus TRIG_SetTriggerMode(TriggerMode mode);
		ReturnStatus TRIG_SetTriggerPositionPercent(double trigPosPercent);
		ReturnStatus TRIG_SetTriggerSource(TriggerSource source);
		ReturnStatus TRIG_SetTriggerTransition(TriggerTransition transition);

		ReturnStatus CONFIG_DecodeFreqRefUserSettingString(String^ i_usstr, FREQREF_USER_INFO^% o_fui);

		// GNSS Functions
		ReturnStatus GNSS_GetStatusRxLock(bool% lock);

		// Time functions
		ReturnStatus REFTIME_GetReferenceTimeSource(REFTIME_SRC% source);

		// Frequency Reference Source selection control/status (access to GNSS and USER sources)
		ReturnStatus CONFIG_SetFrequencyReferenceSource(FREQREF_SOURCE src);
		ReturnStatus CONFIG_GetFrequencyReferenceSource(FREQREF_SOURCE% src);

		// GNSS-based Frequency Reference controls and status
		ReturnStatus CONFIG_SetModeGnssFreqRefCorrection(GFR_MODE mode);
		ReturnStatus CONFIG_GetModeGnssFreqRefCorrection(GFR_MODE% mode);
		ReturnStatus CONFIG_GetStatusGnssFreqRefCorrection(GFR_STATE% state, GFR_QUALITY% quality);

		// GNSS Timing Ref alignment controls
		ReturnStatus CONFIG_SetEnableGnssTimeRefAlign(bool enable);
		ReturnStatus CONFIG_GetEnableGnssTimeRefAlign(bool% enable);
		ReturnStatus CONFIG_GetStatusGnssTimeRefAlign(bool% aligned);

		// Manage USER Frequency Reference setting set/get
		ReturnStatus CONFIG_SetFreqRefUserSetting(String^ i_usstr);
		ReturnStatus CONFIG_GetFreqRefUserSetting(String^% o_usstr);

	private:
		cli::array<float>^ _iqDataResultArray;
		cli::array<float>^ _spectrumTraceArray;
		cli::array<Cplx32^>^ _cplx32IqDataResultArray;
		float* _iqStreamReadArrayFlt32;

		ReturnStatus ErrorCheck(RSA_API::ReturnStatus status);
	};
		

}
