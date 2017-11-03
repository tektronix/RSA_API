cdef extern from 'RSA_API.h':

    ##########################################################
    # Status and Error Reporting
    ##########################################################

    ctypedef   signed char  int8_t
    ctypedef   signed short int16_t
    ctypedef   signed int   int32_t
    ctypedef   signed long  int64_t
    ctypedef unsigned char  uint8_t
    ctypedef unsigned short uint16_t
    ctypedef unsigned int   uint32_t
    ctypedef unsigned long long uint64_t

    ctypedef enum ReturnStatus:
        noError = 0

        # Connection
        errorNotConnected = 101
        errorIncompatibleFirmware = 102
        errorBootLoaderNotRunning = 103
        errorTooManyBootLoadersConnected = 104
        errorRebootFailure = 105

        # POST
        errorPOSTFailureFPGALoad = 201
        errorPOSTFailureHiPower = 202
        errorPOSTFailureI2C = 203
        errorPOSTFailureGPIF = 204
        errorPOSTFailureUsbSpeed = 205
        errorPOSTDiagFailure = 206

        # General Msmt
        errorBufferAllocFailed = 301
        errorParameter = 302
        errorDataNotReady = 304

        # Spectrum
        errorParameterTraceLength = 1101
        errorMeasurementNotEnabled = 1102
        errorSpanIsLessThanRBW = 1103
        errorFrequencyOutOfRange = 1104

        # IF streaming
        errorStreamADCToDiskFileOpen = 1201
        errorStreamADCToDiskAlreadyStreaming = 1202
        errorStreamADCToDiskBadPath = 1203
        errorStreamADCToDiskThreadFailure = 1204
        errorStreamedFileInvalidHeader = 1205
        errorStreamedFileOpenFailure = 1206
        errorStreamingOperationNotSupported = 1207
        errorStreamingFastForwardTimeInvalid = 1208
        errorStreamingInvalidParameters = 1209
        errorStreamingEOF = 1210

        # IQ streaming
        errorIQStreamInvalidFileDataType = 1301
        errorIQStreamFileOpenFailed = 1302
        errorIQStreamBandwidthOutOfRange = 1303

        # -----------------
        # Internal errors
        # -----------------
        errorTimeout = 3001
        errorTransfer = 3002
        errorFileOpen = 3003
        errorFailed = 3004
        errorCRC = 3005
        errorChangeToFlashMode = 3006
        errorChangeToRunMode = 3007
        errorDSPLError = 3008
        errorLOLockFailure = 3009
        errorExternalReferenceNotEnabled = 3010
        errorLogFailure = 3011
        errorRegisterIO = 3012
        errorFileRead = 3013

        errorDisconnectedDeviceRemoved = 3101
        errorDisconnectedDeviceNodeChangedAndRemoved = 3102
        errorDisconnectedTimeoutWaitingForADcData = 3103
        errorDisconnectedIOBeginTransfer = 3104
        errorOperationNotSupportedInSimMode = 3015

        errorFPGAConfigureFailure = 3201
        errorCalCWNormFailure = 3202
        errorSystemAppDataDirectory = 3203
        errorFileCreateMRU = 3204
        errorDeleteUnsuitableCachePath = 3205
        errorUnableToSetFilePermissions = 3206
        errorCreateCachePath = 3207
        errorCreateCachePathBoost = 3208
        errorCreateCachePathStd = 3209
        errorCreateCachePathGen = 3210
        errorBufferLengthTooSmall = 3211
        errorRemoveCachePath = 3212
        errorGetCachingDirectoryBoost = 3213
        errorGetCachingDirectoryStd = 3214
        errorGetCachingDirectoryGen = 3215
        errorInconsistentFileSystem = 3216

        errorWriteCalConfigHeader = 3301
        errorWriteCalConfigData = 3302
        errorReadCalConfigHeader = 3303
        errorReadCalConfigData = 3304
        errorEraseCalConfig = 3305
        errorCalConfigFileSize = 3306
        errorInvalidCalibConstantFileFormat = 3307
        errorMismatchCalibConstantsSize = 3308
        errorCalConfigInvalid = 3309

        # flash
        errorFlashFileSystemUnexpectedSize = 3401
        errorFlashFileSystemNotMounted = 3402
        errorFlashFileSystemOutOfRange = 3403
        errorFlashFileSystemIndexNotFound = 3404
        errorFlashFileSystemReadErrorCRC = 3405
        errorFlashFileSystemReadFileMissing = 3406
        errorFlashFileSystemCreateCacheIndex = 3407
        errorFlashFileSystemCreateCachedDataFile = 3408
        errorFlashFileSystemUnsupportedFileSize = 3409
        errorFlashFileSystemInsufficentSpace = 3410
        errorFlashFileSystemInconsistentState = 3411
        errorFlashFileSystemTooManyFiles = 3412
        errorFlashFileSystemImportFileNotFound = 3413
        errorFlashFileSystemImportFileReadError = 3414
        errorFlashFileSystemImportFileError = 3415
        errorFlashFileSystemFileNotFoundError = 3416
        errorFlashFileSystemReadBufferTooSmall = 3417
        errorFlashWriteFailure = 3418
        errorFlashReadFailure = 3419
        errorFlashFileSystemBadArgument = 3420
        errorFlashFileSystemCreateFile = 3421

        # Aux monitoring
        errorMonitoringNotSupported = 3501
        errorAuxDataNotAvailable = 3502

        # battery
        errorBatteryCommFailure = 3601
        errorBatteryChargerCommFailure = 3602
        errorBatteryNotPresent = 3603

        # EST
        errorESTOutputPathFile = 3701
        errorESTPathNotDirectory = 3702
        errorESTPathDoesntExist = 3703
        errorESTUnableToOpenLog = 3704
        errorESTUnableToOpenLimits = 3705

        # Revision information
        errorRevisionDataNotFound = 3801

        # alignment
        error112MHzAlignmentSignalLevelTooLow = 3901
        error10MHzAlignmentSignalLevelTooLow = 3902
        errorInvalidCalConstant = 3903
        errorNormalizationCacheInvalid = 3904
        errorInvalidAlignmentCache = 3905

        # acq status
        errorADCOverrange = 9000
        errorOscUnlock = 9001

        errorNotSupported = 9901

        errorPlaceholder = 9999
        notImplemented = -1

    ##########################################################
    # Global Type Definitions
    ##########################################################

    ctypedef struct Cplx32:
        float i
        float q

    ctypedef struct CplxInt32:
        int i
        int q

    ctypedef struct CplxInt16:
        int i
        int q

    # AcqDataStatus enum defined in rsa_api.pyx

    ##########################################################
    # Device Connection and Info
    ##########################################################

    const char* DEVICE_GetErrorString(ReturnStatus status)

    # DEVSRCH enum defined in rsa_api.pyx

    ReturnStatus DEVICE_Search(int* numDevicesFound, int deviceIDs[], const char deviceSerial[20][100], const char deviceType[20][20])
    # DEVICE_SearchW not imported

    # DEVICE_Search() usage
    # cdef int numDevicesFound = 0
    # cdef int* deviceIDs
    # cdef char deviceSerial[DEVSRCH_MAX_NUM_DEVICES][DEVSRCH_SERIAL_MAX_STRLEN]
    # cdef char deviceType[20][20]
    #
    # rs = DEVICE_Search(&numDevicesFound, deviceIDs, deviceSerial, deviceType)
    # print('Number of devices: {}'.format(numDevicesFound))
    # print('Device serial numbers: {}'.format(deviceSerial[0].decode()))
    # print('Device type: {}'.format(deviceType[0].decode()))
    #
    # THERE IS A PROBLEM WITH CONVERTING POINTERS TO PYTHON OBJECTS/VICE VERSA
    # ReturnStatus DEVICE_SearchInt(int* numDevicesFound, int* deviceIDs[], const char** deviceSerial[], const char** deviceType[])
    # DEVICE_SearchIntW not imported
    # cdef int numDevicesFound = 0
    # cdef int* deviceIDs
    # cdef char** deviceSerial
    # cdef char** deviceType
    #
    # rs = DEVICE_SearchInt(&numDevicesFound, &deviceIDs, &deviceSerial, &deviceType)
    # print('Number devices: {}'.format(numDevicesFound))
    # print('Device serial numbers: {}'.format(deviceSerial[0].decode()))
    # print('Device type: {}'.format(deviceType[0].decode()))

    ReturnStatus DEVICE_Connect(int deviceID)
    ReturnStatus DEVICE_Reset(int deviceID)
    ReturnStatus DEVICE_Disconnect()

    # DEVINFO_MAX_STRLEN defined in rsa_api.pyx

    ReturnStatus DEVICE_GetNomenclature(char* nomenclature)
    ReturnStatus DEVICE_GetNomenclatureW(Py_UNICODE* nomenclature)
    ReturnStatus DEVICE_GetSerialNumber(char* serialNum)
    ReturnStatus DEVICE_GetAPIVersion(char* apiVersion)
    ReturnStatus DEVICE_GetFWVersion(char* fwVersion)
    ReturnStatus DEVICE_GetFPGAVersion(char* fpgaVersion)
    ReturnStatus DEVICE_GetHWVersion(char* hwVersion)

    ctypedef struct DEVICE_INFO:
        char nomenclature[100]
        char serialNum[100]
        char apiVersion[100]
        char fwVersion[100]
        char fpgaVersion[100]
        char hwVersion[100]

    ReturnStatus DEVICE_GetInfo(DEVICE_INFO* devInfo)

    ReturnStatus DEVICE_GetOverTemperatureStatus(bint* overTemperature)


    ##########################################################
    # Device Configuration (global)
    ##########################################################

    ReturnStatus CONFIG_Preset()

    ReturnStatus CONFIG_SetReferenceLevel(double refLevel)
    ReturnStatus CONFIG_GetReferenceLevel(double* refLevel)
    ReturnStatus CONFIG_GetMaxCenterFreq(double* maxCF)
    ReturnStatus CONFIG_GetMinCenterFreq(double* minCF)
    ReturnStatus CONFIG_SetCenterFreq(double cf)
    ReturnStatus CONFIG_GetCenterFreq(double* cf)

    ReturnStatus CONFIG_GetAutoAttenuationEnable(bint* enable)
    ReturnStatus CONFIG_SetAutoAttenuationEnable(bint enable)
    ReturnStatus CONFIG_GetRFPreampEnable(bint* enable)
    ReturnStatus CONFIG_SetRFPreampEnable(bint enable)
    ReturnStatus CONFIG_GetRFAttenuator(double* value)
    ReturnStatus CONFIG_SetRFAttenuator(double value)

    ReturnStatus CONFIG_SetExternalRefEnable(bint exRefEn)
    ReturnStatus CONFIG_GetExternalRefEnable(bint* exRefEn)
    ReturnStatus CONFIG_GetExternalRefFrequency(double* extFreq)

    # FREQREF_SOURCE enum defined in rsa_api.pyx

    # ReturnStatus CONFIG_SetFrequencyReferenceSource(FREQREF_SOURCE src)
    # ReturnStatus CONFIG_GetFrequencyReferenceSource(FREQREF_SOURCE* src)
    ReturnStatus CONFIG_SetFrequencyReferenceSource(int src)
    ReturnStatus CONFIG_GetFrequencyReferenceSource(int* src)

    # GFR_MODE enum defined in rsa_api.pyx

    # ReturnStatus CONFIG_SetModeGnssFreqRefCorrection(GFR_MODE mode)
    # ReturnStatus CONFIG_GetModeGnssFreqRefCorrection(GFR_MODE* mode)
    ReturnStatus CONFIG_SetModeGnssFreqRefCorrection(int mode)
    ReturnStatus CONFIG_GetModeGnssFreqRefCorrection(int* mode)

    # GFR_STATE enum defined in rsa_api.pyx
    # GFR_QUALITY enum defined in rsa_api.pyx

    # ReturnStatus CONFIG_GetStatusGnssFreqRefCorrection(GFR_STATE* state, GFR_QUALITY* quality)
    ReturnStatus CONFIG_GetStatusGnssFreqRefCorrection(int* state, int* quality)
    
    ReturnStatus CONFIG_SetEnableGnssTimeRefAlign(bint enable)
    ReturnStatus CONFIG_GetEnableGnssTimeRefAlign(bint* enable)
    ReturnStatus CONFIG_GetStatusGnssTimeRefAlign(bint* aligned);

    ReturnStatus CONFIG_SetFreqRefUserSetting(const char* i_usstr);
    ReturnStatus CONFIG_GetFreqRefUserSetting(char* o_usstr);

    # ctypedef struct FREQREF_USER_INFO:
    #     bint isValid
    #     uint32_t dacValue
    #     char datetime[200]
    #     double temperature
    #
    # ReturnStatus CONFIG_DecodeFreqRefUserSettingString(const char* i_usstr, FREQREF_USER_INFO* o_fui)


    ##########################################################
    # Trigger Configuration
    ##########################################################
    #
    # Defined in rsa_api.pyx
    # ctypedef enum TriggerMode:
    #     freeRun = 0
    #     triggered = 1
    #
    # ctypedef enum TriggerSource:
    #     TriggerSourceExternal = 0
    #     TriggerSourceIFPowerLevel = 1
    #
    # ctypedef enum TriggerTransition:
    #     TriggerTransitionLH = 1
    #     TriggerTransitionHL = 2
    #     TriggerTransitionEither = 3

    # ReturnStatus TRIG_SetTriggerMode(TriggerMode mode)
    # ReturnStatus TRIG_GetTriggerMode(TriggerMode mode)
    ReturnStatus TRIG_SetTriggerMode(int mode)
    ReturnStatus TRIG_GetTriggerMode(int* mode)
    # ReturnStatus TRIG_SetTriggerSource(TriggerSource source)
    # ReturnStatus TRIG_GetTriggerSource(TriggerSource* source)
    ReturnStatus TRIG_SetTriggerSource(int source)
    ReturnStatus TRIG_GetTriggerSource(int* source)
    # ReturnStatus TRIG_SetTriggerTransition(TriggerTransition transition)
    # ReturnStatus TRIG_GetTriggerTransition(TriggerTransition* transition)
    ReturnStatus TRIG_SetTriggerTransition(int transition)
    ReturnStatus TRIG_GetTriggerTransition(int* transition)
    ReturnStatus TRIG_SetIFPowerTriggerLevel(double level)
    ReturnStatus TRIG_GetIFPowerTriggerLevel(double* level)
    ReturnStatus TRIG_SetTriggerPositionPercent(double trigPosPercent)
    ReturnStatus TRIG_GetTriggerPositionPercent(double* trigPosPercent)
    ReturnStatus TRIG_ForceTrigger()


    ##########################################################
    # Device Alignment
    ##########################################################

    ReturnStatus ALIGN_GetWarmupStatus(bint* warmedUp)
    ReturnStatus ALIGN_GetAlignmentNeeded(bint* needed)
    ReturnStatus ALIGN_RunAlignment()


    ##########################################################
    # Device Operation (global)
    ##########################################################

    ReturnStatus DEVICE_GetEnable(bint* enable)
    ReturnStatus DEVICE_Run()
    ReturnStatus DEVICE_Stop()
    ReturnStatus DEVICE_PrepareForRun()
    ReturnStatus DEVICE_StartFrameTransfer()

    # DEVEVENT enum defined in rsa_api.pyx

    ReturnStatus DEVICE_GetEventStatus(int eventID, bint* eventOccurred, uint64_t* eventTimestamp)


    ##########################################################
    # System/Reference Time
    ##########################################################

    ReturnStatus REFTIME_GetTimestampRate(uint64_t* o_refTimestampRate)
    ReturnStatus REFTIME_GetCurrentTime(Py_ssize_t* o_timeSec, uint64_t* o_timeNsec, uint64_t* o_timestamp)
    ReturnStatus REFTIME_GetTimeFromTimestamp(uint64_t i_timestamp, Py_ssize_t* o_timeSec, uint64_t* o_timeNsec)
    ReturnStatus REFTIME_GetTimestampFromTime(Py_ssize_t i_timeSec, uint64_t i_timeNsec, uint64_t* o_timestamp)
    ReturnStatus REFTIME_GetIntervalSinceRefTimeSet(double* sec)

    ReturnStatus REFTIME_SetReferenceTime(Py_ssize_t refTimeSec, uint64_t refTimeNsec, uint64_t refTimestamp)
    ReturnStatus REFTIME_GetReferenceTime(Py_ssize_t* refTimeSec, uint64_t* refTimeNsec, uint64_t* refTimestamp)
    
    # REFTIME_SRC enum defined in rsa_api.pyx
    
    # ReturnStatus REFTIME_GetReferenceTimeSource(REFTIME_SRC* source)
    ReturnStatus REFTIME_GetReferenceTimeSource(int* source)


    ##########################################################
    # IQ Block Data Acquisition
    ##########################################################

    ReturnStatus IQBLK_GetMaxIQBandwidth(double* maxBandwidth)
    ReturnStatus IQBLK_GetMinIQBandwidth(double* minBandwidth)
    ReturnStatus IQBLK_SetIQBandwidth(double iqBandwidth)
    ReturnStatus IQBLK_GetIQBandwidth(double* iqBandwidth)
    
    ReturnStatus IQBLK_GetMaxIQRecordLength(int* maxSamples)
    ReturnStatus IQBLK_GetIQSampleRate(double* iqSampleRate)

    ReturnStatus IQBLK_SetIQRecordLength(int recordLength)
    ReturnStatus IQBLK_GetIQRecordLength(int* recordLength)

    ReturnStatus IQBLK_AcquireIQData()
    ReturnStatus IQBLK_WaitForIQDataReady(int timeoutMsec, bint* ready)

    ReturnStatus IQBLK_GetIQData(float* iqData, int* outLength, int reqLength)
    ReturnStatus IQBLK_GetIQDataDeinterleaved(float* iData, float* qData, int* outLength, int reqLength)
    ReturnStatus IQBLK_GetIQDataCplx(Cplx32* iqData, int* outLength, int reqLength)

    ReturnStatus IQBLK_FinishedIQData()
    
    # IQBLK_STATUS enum defined in rsa_api.pyx

    ctypedef struct IQBLK_ACQINFO:
        uint64_t sample0Timestamp
        uint64_t triggerSampleIndex
        uint64_t triggerTimestamp
        int acqStatus

    ReturnStatus IQBLK_GetIQAcqInfo(IQBLK_ACQINFO* acqInfo)

    ##########################################################
    # Spectrum Trace Acquisition
    ##########################################################

    # Defined in rsa_api.pyx
    # ctypedef enum SpectrumWindows:
    #     SpectrumWindow_Kaiser = 0
    #     SpectrumWindow_Mil6dB = 1
    #     SpectrumWindow_BlackmanHarris = 2
    #     SpectrumWindow_Rectangle = 3
    #     SpectrumWindow_FlatTop = 4
    #     SpectrumWindow_Hann = 5
    #
    # ctypedef enum SpectrumTraces:
    #     SpectrumTrace1 = 0
    #     SpectrumTrace2 = 1
    #     SpectrumTrace3 = 2
    #
    # ctypedef enum SpectrumDetectors:
    #     SpectrumDetector_PosPeak = 0
    #     SpectrumDetector_NegPeak = 1
    #     SpectrumDetector_AverageVRMS = 2
    #     SpectrumDetector_Sample = 3
    #
    # ctypedef enum SpectrumVerticalUnits:
    #     SpectrumVerticalUnit_dBm = 0
    #     SpectrumVerticalUnit_Watt = 1
    #     SpectrumVerticalUnit_Volt = 2
    #     SpectrumVerticalUnit_Amp = 3
    #     SpectrumVerticalUnit_dBmV = 4

    # Spectrum settings structure
    # The actual values are returned from SPECTRUM_GetSettings() function
    # Use SPECTRUM_GetLimits() to get the limits of the settings
    ctypedef struct Spectrum_Settings:
        double span
        double rbw
        bint enableVBW
        double vbw
        int traceLength     # MUST be odd number
        # SpectrumWindows window
        # SpectrumVerticalUnits verticalUnit
        int window
        int verticalUnit

        # additional settings return from SPECTRUM_GetSettings()
        double actualStartFreq
        double actualStopFreq
        double actualFreqStepSize
        double actualRBW
        double actualVBW
        int actualNumIQSamples

    ctypedef struct Spectrum_Limits:
        double maxSpan
        double minSpan
        double maxRBW
        double minRBW
        double maxVBW
        double minVBW
        int maxTraceLength
        int minTraceLength

    ctypedef struct Spectrum_TraceInfo:
        uint64_t timestamp       # timestamp of the first acquisition sample
        int acqDataStatus	# See AcqDataStatus enumeration for bit definitions

    ReturnStatus SPECTRUM_SetEnable(bint enable)
    ReturnStatus SPECTRUM_GetEnable(bint* enable)
    ReturnStatus SPECTRUM_SetDefault()
    ReturnStatus SPECTRUM_SetSettings(Spectrum_Settings settings)
    ReturnStatus SPECTRUM_GetSettings(Spectrum_Settings* settings)
    # ReturnStatus SPECTRUM_SetTraceType(SpectrumTraces trace, bint enable, SpectrumDetectors detector)
    # ReturnStatus SPECTRUM_GetTraceType(SpectrumTraces trace, bint* enable, SpectrumDetectors* detector)
    ReturnStatus SPECTRUM_SetTraceType(int trace, bint enable, int detector)
    ReturnStatus SPECTRUM_GetTraceType(int trace, bint* enable, int* detector)
    ReturnStatus SPECTRUM_GetLimits(Spectrum_Limits* limits)

    ReturnStatus SPECTRUM_AcquireTrace()
    ReturnStatus SPECTRUM_WaitForTraceReady(int timeoutMsec, bint* ready)

    # ReturnStatus SPECTRUM_GetTrace(SpectrumTraces trace, int maxTracePoints, float* traceData, int* outTracePoints)
    ReturnStatus SPECTRUM_GetTrace(int trace, int maxTracePoints, float* traceData, int* outTracePoints)
    ReturnStatus SPECTRUM_GetTraceInfo(Spectrum_TraceInfo* traceInfo)

    ##########################################################
    # DPX Bitmap, Trace, and Spectrogram
    ##########################################################

    ctypedef struct DPX_FrameBuffer:
        int32_t fftPerFrame
        int64_t fftCount
        int64_t frameCount
        double timestamp
        uint32_t acqDataStatus

        double minSigDuration
        bint minSigDurOutOfRange

        int32_t spectrumBitmapWidth
        int32_t spectrumBitmapHeight
        int32_t spectrumBitmapSize
        int32_t spectrumTraceLength
        int32_t numSpectrumTraces

        bint spectrumEnabled
        bint spectrogramEnabled

        float spectrumBitmap[161001]
        float spectrumTraces[3][4005]

        int32_t sogramBitmapWidth
        int32_t sogramBitmapHeight
        int32_t sogramBitmapSize
        int32_t sogramBitmapNumValidLines
        uint8_t sogramBitmap[133500]
        double sogramBitmapTimestampArray[500]
        int16_t sogramBitmapContainTriggerArray[500]


    ctypedef struct DPX_SogramSettingsStruct:
        int32_t bitmapWidth
        int32_t bitmapHeight
        double sogramTraceLineTime
        double sogramBitmapLineTime

    ctypedef struct DPX_SettingsStruct:
        bint enableSpectrum
        bint enableSpectrogram
        int32_t bitmapWidth
        int32_t bitmapHeight
        int32_t traceLength
        float decayFactor
        double actualRBW

    # ctypedef enum TraceType:
    #     TraceTypeAverage = 0
    #     TraceTypeMax = 1
    #     TraceTypeMaxHold = 2
    #     TraceTypeMin = 3
    #     TraceTypeMinHold = 4
    #
    # ctypedef enum VerticalUnitType:
    #     VerticalUnit_dBm = 0
    #     VerticalUnit_Watt = 1
    #     VerticalUnit_Volt = 2
    #     VerticalUnit_Amp = 3

    ReturnStatus DPX_GetEnable(bint* enable)
    ReturnStatus DPX_SetEnable(bint enable)
    # ReturnStatus DPX_SetParameters(double fspan, double rbw, int32_t bitmapWidth, int32_t tracePtsPerPixel,
    #                                            VerticalUnitType yUnit, double yTop, double yBottom,
    #                                            bint infinitePersistence, double persistenceTimeSec, bint showOnlyTrigFrame)
    ReturnStatus DPX_SetParameters(double fspan, double rbw, int32_t bitmapWidth, int32_t tracePtsPerPixel,
                                               int yUnit, double yTop, double yBottom,
                                               bint infinitePersistence, double persistenceTimeSec, bint showOnlyTrigFrame)
    ReturnStatus DPX_Configure(bint enableSpectrum, bint enableSpectrogram)
    ReturnStatus DPX_GetSettings(DPX_SettingsStruct* pSettings)

    # ReturnStatus DPX_SetSpectrumTraceType(int32_t traceIndex, TraceType type)
    ReturnStatus DPX_SetSpectrumTraceType(int32_t traceIndex, int type)
    ReturnStatus DPX_GetRBWRange(double fspan, double* minRBW, double* maxRBW)
    ReturnStatus DPX_Reset()
    ReturnStatus DPX_WaitForDataReady(int timeoutMsec, bint* ready)

    ReturnStatus DPX_GetFrameInfo(int64_t* frameCount, int64_t* fftCount)

    ReturnStatus DPX_SetSogramParameters(double timePerBitmapLine, double timeResolution, double maxPower, double minPower)
    # ReturnStatus DPX_SetSogramTraceType(TraceType traceType)
    ReturnStatus DPX_SetSogramTraceType(int traceType)
    ReturnStatus DPX_GetSogramSettings(DPX_SogramSettingsStruct *pSettings)

    ReturnStatus DPX_GetSogramHiResLineCountLatest(int32_t* lineCount)
    ReturnStatus DPX_GetSogramHiResLineTriggered(bint* triggered, int32_t lineIndex)
    ReturnStatus DPX_GetSogramHiResLineTimestamp(double* timestamp, int32_t lineIndex)
    ReturnStatus DPX_GetSogramHiResLine(int16_t* vData, int32_t* vDataSize, int32_t lineIndex, double* dataSF, int32_t tracePoints, int32_t firstValidPoint)

    ReturnStatus DPX_GetFrameBuffer(DPX_FrameBuffer* frameBuffer)

    # The client is required to call FinishFrameBuffer() before the next frame can be available.
    ReturnStatus DPX_FinishFrameBuffer()
    ReturnStatus DPX_IsFrameBufferAvailable(bint* frameAvailable)


    ##########################################################
    # Audio Demod
    ##########################################################

    # ctypedef enum AudioDemodMode:
    #     ADM_FM_8KHZ = 0
    #     ADM_FM_13KHZ = 1
    #     ADM_FM_75KHZ = 2
    #     ADM_FM_200KHZ = 3
    #     ADM_AM_8KHZ = 4
    #     # ADM_NONE	// internal use only

    # ReturnStatus AUDIO_SetMode(AudioDemodMode mode)
    # ReturnStatus AUDIO_GetMode(AudioDemodMode* mode)
    ReturnStatus AUDIO_SetMode(int mode)
    ReturnStatus AUDIO_GetMode(int* mode)

    ReturnStatus AUDIO_SetVolume(float volume)
    ReturnStatus AUDIO_GetVolume(float* _volume)

    ReturnStatus AUDIO_SetMute(bint mute)
    ReturnStatus AUDIO_GetMute(bint* _mute)

    ReturnStatus AUDIO_SetFrequencyOffset(double freqOffsetHz)
    ReturnStatus AUDIO_GetFrequencyOffset(double* freqOffsetHz)

    ReturnStatus AUDIO_Start()
    ReturnStatus AUDIO_Stop()
    ReturnStatus AUDIO_GetEnable(bint *enable)

    # Get data from audio output
    # User must allocate data to inSize before calling
    # Actual data returned is in outSize and will not exceed inSize
    ReturnStatus AUDIO_GetData(int16_t* data, uint16_t inSize, uint16_t* outSize)


    ###########################################################
    # IF(ADC) Data Streaming to disk
    ###########################################################
    
    # ctypedef enum IFSOUTDEST:
    #     IFSOD_CLIENT = 0
    #     IFSOD_FILE_R3F = 1
    #     IFSOD_FILE_R3HA_DET = 3
    #     IFSOD_FILE_MIDAS = 11
    #     IFSOD_FILE_MIDAS_DET = 12
    
    # ctypedef enum StreamingMode:
    #     StreamingModeRaw = 0
    #     StreamingModeFramed = 1

    # ReturnStatus IFSTREAM_SetOutputConfiguration(IFSOUTDEST dest)
    ReturnStatus IFSTREAM_SetOutputConfiguration(int dest)

    # Legacy, use IFSTREAM_SetOutputConfiguration
    # ReturnStatus IFSTREAM_SetDiskFileMode(StreamingMode mode)
    # ReturnStatus IFSTREAM_SetDiskFileMode(int mode)
    ReturnStatus IFSTREAM_SetDiskFilePath(const char* path)
    ReturnStatus IFSTREAM_SetDiskFilenameBase(const char* base)

    # IFSSDFN enum type defined in rsa_api.pyx

    ReturnStatus IFSTREAM_SetDiskFilenameSuffix(int suffixCtl)
    ReturnStatus IFSTREAM_SetDiskFileLength(int msec)
    ReturnStatus IFSTREAM_SetDiskFileCount(int count)

    ReturnStatus IFSTREAM_GetAcqParameters(double* bwHz_act, double* srSps, double* cfAtIfHz)
    ReturnStatus IFSTREAM_GetScalingParameters(double* scaleFactor, double* scaleFreq)
    # Return to this later, float** type conversion causing fits
    # ReturnStatus IFSTREAM_GetEQParameters(int* numPts, float** freq, float** ampl, float** phase)
    ReturnStatus IFSTREAM_GetIFDataBufferSize(int* buffSize, int* numSamples)

    ReturnStatus IFSTREAM_SetEnable(bint enable)
    ReturnStatus IFSTREAM_GetActiveStatus(bint* active)

    # IFSTRM_MAXTRIGGERS enum type defined in rsa_api.pyx
    # IFSTRM_STATUS enum type defined in rsa_api.pyx
    
    ctypedef struct IFSTRMDATAINFO:
        uint64_t timestamp
        int triggerCount
        int triggerIndices[32]
        uint32_t acqStatus

    ReturnStatus IFSTREAM_GetIFData(int16_t* data, int* datalen, IFSTRMDATAINFO* datainfo)
    # Return to this later, float** type conversion causing fits
    # ReturnStatus IFSTREAM_GetIFFrames(uint8_t** data, int* numBytes, int* numFrames)

    ###########################################################
    # IQ Data Streaming to Client or Disk
    ###########################################################

    ReturnStatus IQSTREAM_GetMaxAcqBandwidth(double* maxBandwidthHz)
    ReturnStatus IQSTREAM_GetMinAcqBandwidth(double* minBandwidthHz)
    ReturnStatus IQSTREAM_SetAcqBandwidth(double bwHz_req)
    ReturnStatus IQSTREAM_GetAcqParameters(double* bwHz_act, double* srSps)

    # ctypedef enum IQSOUTDEST:
    #     IQSOD_CLIENT = 0
    #     IQSOD_FILE_TIQ = 1
    #     IQSOD_FILE_SIQ = 2
    #     IQSOD_FILE_SIQ_SPLIT = 3
    #     IQSOD_FILE_MIDAS = 11
    #     IQSOD_FILE_MIDAS_DET = 12
    #
    # ctypedef enum IQSOUTDTYPE:
    #     IQSODT_SINGLE = 0
    #     IQSODT_INT32 = 1
    #     IQSODT_INT16 = 2
    #     IQSODT_SINGLE_SCALE_INT32 = 3

    # ReturnStatus IQSTREAM_SetOutputConfiguration(IQSOUTDEST dest, IQSOUTDTYPE dtype)
    ReturnStatus IQSTREAM_SetOutputConfiguration(int dest, int dtype)
    ReturnStatus IQSTREAM_SetIQDataBufferSize(int reqSize)
    ReturnStatus IQSTREAM_GetIQDataBufferSize(int* maxSize)

    # ReturnStatus IQSTREAM_SetDiskFilenameBaseW(const wchar_t* filenameBaseW)
    ReturnStatus IQSTREAM_SetDiskFilenameBase(const char* filenameBase)
    # ReturnStatus IQSTREAM_SetDiskFilenameBase(const Pu_UNICODE* filenameBase)

    # IQSSDFN enum type defined in rsa_api.pyx

    ReturnStatus IQSTREAM_SetDiskFilenameSuffix(int suffixCtl)
    ReturnStatus IQSTREAM_SetDiskFileLength(int msec)

    ReturnStatus IQSTREAM_Start()
    ReturnStatus IQSTREAM_Stop()
    ReturnStatus IQSTREAM_GetEnable(bint* enable)

    # IQSTRM_STATUS enum type defined in rsa_api.pyx
    # IQSTRM_MAXTRIGGERS enum type defined in rsa_api.pyx

    ctypedef struct IQSTRMIQINFO:
        uint64_t timestamp
        int triggerCount
        int triggerIndices[100]
        double scaleFactor
        uint32_t acqStatus

    ReturnStatus IQSTREAM_WaitForIQDataReady(int timeoutMsec, bint* ready)
    ReturnStatus IQSTREAM_GetIQData(void* iqdata, int* iqlen, IQSTRMIQINFO* iqinfo)

    ReturnStatus IQSTREAM_GetDiskFileWriteStatus(bint* isComplete, bint* isWriting)

    # IQSTRM_FILENAME enum type defined in rsa_api.pyx

    ctypedef struct IQSTRMFILEINFO:
        uint64_t numberSamples
        uint64_t sample0Timestamp
        uint64_t triggerSampleIndex
        uint64_t triggerTimestamp
        uint32_t acqStatus
        Py_UNICODE** filenames

    ReturnStatus IQSTREAM_GetDiskFileInfo(IQSTRMFILEINFO* fileinfo)

    void IQSTREAM_ClearAcqStatus()


    ###########################################################
    # Stored IF Data File Playback
    ###########################################################

    # THIS IS NOT WORKING IN ANY PROGRAMMING LANGUAGE
    ReturnStatus PLAYBACK_OpenDiskFile(
        Py_UNICODE* fileName,
        int startPercentage,
        int stopPercentage,
        double skipTimeBetweenFullAcquisitions,
        bint loopAtEndOfFile,
        bint emulateRealTime)

    ReturnStatus PLAYBACK_GetReplayComplete(bint* complete)


    ###########################################################
    # Tracking Generator Control
    ###########################################################

    ReturnStatus TRKGEN_GetHwInstalled(bint* installed)
    ReturnStatus TRKGEN_SetEnable(bint enable)
    ReturnStatus TRKGEN_GetEnable(bint* enable)
    ReturnStatus TRKGEN_SetOutputLevel(double leveldBm)
    ReturnStatus TRKGEN_GetOutputLevel(double* leveldBm)


    ###########################################################
    # GNSS Rx Control and Output
    ###########################################################

    # ctypedef enum GNSS_SATSYS:
    #     GNSS_NOSYS = 0
    #     GNSS_GPS_GLONASS = 1
    #     GNSS_GPS_BEIDOU = 2
    #     GNSS_GPS = 3
    #     GNSS_GLONASS = 4
    #     GNSS_BEIDOU = 5

    ReturnStatus GNSS_GetHwInstalled(bint* installed)
    ReturnStatus GNSS_SetEnable(bint enable)
    ReturnStatus GNSS_GetEnable(bint* enable)
    # ReturnStatus GNSS_SetSatSystem(GNSS_SATSYS satSystem)
    # ReturnStatus GNSS_GetSatSystem(GNSS_SATSYS* satSystem)
    ReturnStatus GNSS_SetSatSystem(int satSystem)
    ReturnStatus GNSS_GetSatSystem(int* satSystem)
    ReturnStatus GNSS_SetAntennaPower(bint powered)
    ReturnStatus GNSS_GetAntennaPower(bint* powered)
    ReturnStatus GNSS_GetNavMessageData(int* msgLen, const char** message)
    ReturnStatus GNSS_ClearNavMessageData()
    ReturnStatus GNSS_Get1PPSTimestamp(bint* isValid, uint64_t* timestamp1PPS)
    ReturnStatus GNSS_GetStatusRxLock(bint* lock)


    ###########################################################
    # Power and Battery Status
    ###########################################################

    ctypedef struct POWER_INFO:
        bint externalPowerPresent
        bint batteryPresent
        double batteryChargeLevel
        bint batteryCharging
        bint batteryOverTemperature
        bint batteryHardwareError

    ReturnStatus POWER_GetStatus(POWER_INFO* powerInfo)
