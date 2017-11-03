from rsa_api_h cimport *
import numpy as np
from os.path import exists
cimport numpy as np

class RSAError(Exception):
    pass

class OutOfRangeError(Exception):
    pass

def err_check(rs):
    errMessage = DEVICE_GetErrorString(rs).decode()
    # print(errMessage)
    if errMessage != 'No Error':
        raise RSAError(errMessage)


##########################################################
# Structs and Named Enums
##########################################################

cpdef enum FREQREF_SOURCE:
    FRS_INTERNAL = 0
    FRS_EXTREF = 1
    FRS_GNSS = 2
    FRS_USER = 3

cpdef enum GFR_MODE:
    GFRM_OFF = 0
    GFRM_FREQTRACK = 2
    GFRM_PHASETRACK = 3
    GFRM_HOLD = 4

cpdef enum GFR_STATE:
    GFRS_OFF = 0
    GFRS_ACQUIRING = 1
    GFRS_FREQTRACKING = 2
    GFRS_PHASETRACKING = 3
    GFRS_HOLDING = 4

cpdef enum GFR_QUALITY:
    GFRQ_INVALID = 0
    GFRQ_LOW = 1
    GFRQ_MEDIUM = 2
    GFRQ_HIGH = 3

cpdef enum TriggerMode:
    freeRun = 0
    triggered = 1

cpdef enum TriggerSource:
    TriggerSourceExternal = 0
    TriggerSourceIFPowerLevel = 1

cpdef enum TriggerTransition:
    TriggerTransitionLH = 1
    TriggerTransitionHL = 2
    TriggerTransitionEither = 3

cpdef enum REFTIME_SRC:
    RTSRC_NONE = 0
    RTSRC_SYSTEM = 1
    RTSRC_GNSS = 2
    RTSRC_USER = 3

cpdef enum SpectrumWindows:
    SpectrumWindow_Kaiser = 0
    SpectrumWindow_Mil6dB = 1
    SpectrumWindow_BlackmanHarris = 2
    SpectrumWindow_Rectangle = 3
    SpectrumWindow_FlatTop = 4
    SpectrumWindow_Hann = 5

cpdef enum SpectrumTraces:
    SpectrumTrace1 = 0
    SpectrumTrace2 = 1
    SpectrumTrace3 = 2

cpdef enum SpectrumDetectors:
    SpectrumDetector_PosPeak = 0
    SpectrumDetector_NegPeak = 1
    SpectrumDetector_AverageVRMS = 2
    SpectrumDetector_Sample = 3

cpdef enum SpectrumVerticalUnits:
    SpectrumVerticalUnit_dBm = 0
    SpectrumVerticalUnit_Watt = 1
    SpectrumVerticalUnit_Volt = 2
    SpectrumVerticalUnit_Amp = 3
    SpectrumVerticalUnit_dBmV = 4

cpdef enum TraceType:
    TraceTypeAverage = 0
    TraceTypeMax = 1
    TraceTypeMaxHold = 2
    TraceTypeMin = 3
    TraceTypeMinHold = 4

cpdef enum VerticalUnitType:
    VerticalUnit_dBm = 0
    VerticalUnit_Watt = 1
    VerticalUnit_Volt = 2
    VerticalUnit_Amp = 3

"""
NB: Due to the inability of Cython to convert C pointers to Python objects,
it was necessary to preallocate the spectrumBitmap, spectrumTraces, and
sogramBitmap struct members. Due also to some inability of Cython to pass
a struct containing preallocated multidimensional arrays correctly to
external functions, it is necessary to "reformat" certain complex struct
members and feed them to a Python class for the DPX_FrameBuffer IN THE
FUNCTION THAT CALLS DPX_GetFrameBuffer() ITSELF. Passing the
DPX_FrameBuffer object to another function DOES NOT result in correct passing
"""

class DPX_FrameBuffer_py():
    def __init__(self, fb, spectrumBitmap, spectrumTraces, sogramBitmap):
        self.fftPerFrame = fb['fftPerFrame']
        self.fftCount = fb['fftCount']
        self.frameCount = fb['frameCount']
        self.timestamp = fb['timestamp']
        self.acqDataStatus = fb['acqDataStatus']

        self.minSigDuration = fb['minSigDuration']
        self.minSigDurOutOfRange = fb['minSigDurOutOfRange']

        self.spectrumBitmapWidth = fb['spectrumBitmapWidth']
        self.spectrumBitmapHeight = fb['spectrumBitmapHeight']
        self.spectrumBitmapSize = fb['spectrumBitmapSize']
        self.spectrumTraceLength = fb['spectrumTraceLength']
        self.numSpectrumTraces = fb['numSpectrumTraces']

        self.spectrumEnabled = fb['spectrumEnabled']
        self.spectrogramEnabled = fb['spectrogramEnabled']

        self.spectrumBitmap = spectrumBitmap
        self.spectrumTraces = spectrumTraces

        self.sogramBitmapWidth = fb['sogramBitmapWidth']
        self.sogramBitmapHeight = fb['sogramBitmapHeight']
        self.sogramBitmapSize = fb['sogramBitmapSize']
        self.sogramBitmapNumValidLines = fb['sogramBitmapNumValidLines']

        self.sogramBitmap = sogramBitmap
        self.sogramBitmapTimestampArray = fb['sogramBitmapTimestampArray']
        self.sogramBitmapContainTriggerArray = fb['sogramBitmapContainTriggerArray']

cpdef enum AudioDemodMode:
    ADM_FM_8KHZ = 0
    ADM_FM_13KHZ = 1
    ADM_FM_75KHZ = 2
    ADM_FM_200KHZ = 3
    ADM_AM_8KHZ = 4

"""Legacy"""
# cpdef enum StreamingMode:
#     StreamingModeRaw = 0
#     StreamingModeFramed = 1

cpdef enum IFSOUTDEST:
    IFSOD_CLIENT = 0
    IFSOD_FILE_R3F = 1
    IFSOD_FILE_R3HA_DET = 3
    IFSOD_FILE_MIDAS = 11
    IFSOD_FILE_MIDAS_DET = 12

cpdef enum IQSOUTDEST:
    IQSOD_CLIENT = 0
    IQSOD_FILE_TIQ = 1
    IQSOD_FILE_SIQ = 2
    IQSOD_FILE_SIQ_SPLIT = 3
    IQSOD_FILE_MIDAS = 11
    IQSOD_FILE_MIDAS_DET = 12

cpdef enum IQSOUTDTYPE:
    IQSODT_SINGLE = 0
    IQSODT_INT32 = 1
    IQSODT_INT16 = 2
    IQSODT_SINGLE_SCALE_INT32 = 3

cpdef enum GNSS_SATSYS:
    GNSS_NOSYS = 0
    GNSS_GPS_GLONASS = 1
    GNSS_GPS_BEIDOU = 2
    GNSS_GPS = 3
    GNSS_GLONASS = 4
    GNSS_BEIDOU = 5


##########################################################
# Nameless Enums
##########################################################


AcqDataStatus_ADC_OVERRANGE = 0x1
AcqDataStatus_REF_OSC_UNLOCK = 0x2
AcqDataStatus_LOW_SUPPLY_VOLTAGE = 0x10
AcqDataStatus_ADC_DATA_LOST = 0x20
AcqDataStatus_VALID_BITS_MASK = (AcqDataStatus_ADC_OVERRANGE or AcqDataStatus_REF_OSC_UNLOCK or AcqDataStatus_LOW_SUPPLY_VOLTAGE or AcqDataStatus_ADC_DATA_LOST)

DEVSRCH_MAX_NUM_DEVICES = 20
DEVSRCH_SERIAL_MAX_STRLEN = 100
DEVSRCH_TYPE_MAX_STRLEN = 20

DEVINFO_MAX_STRLEN = 100

DEVEVENT_OVERRANGE = 0
DEVEVENT_TRIGGER = 1
DEVEVENT_1PPS = 2

IQBLK_STATUS_INPUT_OVERRANGE = (1 << 0)
IQBLK_STATUS_FREQREF_UNLOCKED = (1 << 1)
IQBLK_STATUS_ACQ_SYS_ERROR = (1 << 2)
IQBLK_STATUS_DATA_XFER_ERROR = (1 << 3)

DPX_TRACEIDX_1 = 0
DPX_TRACEIDX_2 = 1
DPX_TRACEIDX_3 = 2

IFSSDFN_SUFFIX_INCRINDEX_MIN = 0
IFSSDFN_SUFFIX_TIMESTAMP = -1
IFSSDFN_SUFFIX_NONE = -2

IQSSDFN_SUFFIX_INCRINDEX_MIN = 0
IQSSDFN_SUFFIX_TIMESTAMP = -1
IQSSDFN_SUFFIX_NONE = -2

IFSTRM_MAXTRIGGERS = 32

IFSTRM_STATUS_OVERRANGE = (1 << 0)
IFSTRM_STATUS_XFER_DISCONTINUITY = (1 << 1)

IQSTRM_STATUS_OVERRANGE = (1 << 0)
IQSTRM_STATUS_XFER_DISCONTINUITY = (1 << 1)
IQSTRM_STATUS_IBUFF75PCT = (1 << 2)
IQSTRM_STATUS_IBUFFOVFLOW = (1 << 3)
IQSTRM_STATUS_OBUFF75PCT = (1 << 4)
IQSTRM_STATUS_OBUFFOVFLOW = (1 << 5)
IQSTRM_STATUS_NONSTICKY_SHIFT = 0
IQSTRM_STATUS_STICKY_SHIFT = 16

IQSTRM_MAXTRIGGERS = 100

IQSTRM_FILENAME_DATA_IDX = 0
IQSTRM_FILENAME_HEADER_IDX = 1


##########################################################
# Device Connection and Info
##########################################################


def DEVICE_Search_py():
    cdef int numDevicesFound = 0
    cdef int deviceIDs[20]
    cdef char deviceSerial[20][100]
    cdef char deviceType[20][20]
    err_check(DEVICE_Search(&numDevicesFound, deviceIDs,
              deviceSerial, deviceType))
    devs = np.asarray(deviceIDs)
    return numDevicesFound, devs, deviceSerial, deviceType


def DEVICE_Connect_py(deviceID=0):
    cdef int _deviceID = deviceID
    err_check(DEVICE_Connect(_deviceID))


def DEVICE_Disconnect_py():
    err_check(DEVICE_Disconnect())


def DEVICE_Reset_py(deviceID):
    cdef int _deviceID = deviceID
    err_check(DEVICE_Reset(_deviceID))


def DEVICE_GetOverTemperatureStatus_py():
    cdef bint tempStatus
    err_check(DEVICE_GetOverTemperatureStatus(&tempStatus))
    return tempStatus


def DEVICE_GetNomenclature_py():
    cdef char nomenclature[100]
    err_check(DEVICE_GetNomenclature(nomenclature))
    return nomenclature.decode()


def DEVICE_GetSerialNumber_py():
    cdef char serialNum[100]
    err_check(DEVICE_GetSerialNumber(serialNum))
    return serialNum.decode()


def DEVICE_GetAPIVersion_py():
    cdef char apiVersion[100]
    err_check(DEVICE_GetAPIVersion(apiVersion))
    return apiVersion.decode()


def DEVICE_GetFWVersion_py():
    cdef char fwVersion[100]
    err_check(DEVICE_GetFWVersion(fwVersion))
    return fwVersion.decode()


def DEVICE_GetFPGAVersion_py():
    cdef char fpgaVersion[100]
    err_check(DEVICE_GetFPGAVersion(fpgaVersion))
    return fpgaVersion.decode()


def DEVICE_GetHWVersion_py():
    cdef char hwVersion[100]
    err_check(DEVICE_GetHWVersion(hwVersion))
    return hwVersion.decode()


def DEVICE_GetInfo_py():
    cdef DEVICE_INFO devInfo
    err_check(DEVICE_GetInfo(&devInfo))
    return devInfo


##########################################################
# Device Configuration (global)
##########################################################


def CONFIG_Preset_py():
    err_check(CONFIG_Preset())


def CONFIG_SetReferenceLevel_py(refLevel=0):
    if refLevel > 30 or refLevel < -130:
        raise RSAError('Parameter out of range.')
    cdef double _refLevel = refLevel
    err_check(CONFIG_SetReferenceLevel(_refLevel))


def CONFIG_GetReferenceLevel_py():
    cdef double refLevel
    err_check(CONFIG_GetReferenceLevel(&refLevel))
    return refLevel

def CONFIG_GetMaxCenterFreq_py():
    cdef double maxCF
    err_check(CONFIG_GetMaxCenterFreq(&maxCF))
    return maxCF


def CONFIG_GetMinCenterFreq_py():
    cdef double minCF
    err_check(CONFIG_GetMinCenterFreq(&minCF))
    return minCF


def CONFIG_SetCenterFreq_py(cf=2.4453e9):
    cdef double _cf = cf
    err_check(CONFIG_SetCenterFreq(_cf))


def CONFIG_GetCenterFreq_py():
    cdef double center
    err_check(CONFIG_GetCenterFreq(&center))
    return center


def CONFIG_SetExternalRefEnable_py(enable=True):
    if enable not in [False, True]:
        raise TypeError('"enable" must be of type "bool".')
    err_check(CONFIG_SetExternalRefEnable(enable))


def CONFIG_GetExternalRefEnable_py():
    cdef bint enable
    err_check(CONFIG_GetExternalRefEnable(&enable))
    return enable


def CONFIG_GetExternalRefFrequency_py():
    cdef double extFreq
    err_check(CONFIG_GetExternalRefFrequency(&extFreq))
    return extFreq


def CONFIG_SetAutoAttenuationEnable_py(enable=True):
    if enable not in [False, True]:
        raise TypeError('"enable" must be of type "bool".')
    err_check(CONFIG_SetAutoAttenuationEnable(enable))


def CONFIG_GetAutoAttenuationEnable_py():
    cdef bint enable
    err_check(CONFIG_GetAutoAttenuationEnable(&enable))
    return enable


def CONFIG_SetRFPreampEnable_py(enable=True):
    if enable not in [False, True]:
        raise TypeError('"enable" must be of type "bool".')
    err_check(CONFIG_SetRFPreampEnable(enable))


def CONFIG_GetRFPreampEnable_py():
    cdef bint enable
    err_check(CONFIG_GetRFPreampEnable(&enable))
    return enable


def CONFIG_SetRFAttenuator_py(atten=10):
    cdef double _atten = atten
    err_check(CONFIG_SetRFAttenuator(_atten))


def CONFIG_GetRFAttenuator_py():
    cdef double a
    err_check(CONFIG_GetRFAttenuator(&a))
    return a


def CONFIG_SetFrequencyReferenceSource_py(src):
    cdef int _src = src
    err_check(CONFIG_SetFrequencyReferenceSource(_src))
    

def CONFIG_GetFrequencyReferenceSource_py():
    cdef int src
    err_check(CONFIG_GetFrequencyReferenceSource(&src))
    return src


def CONFIG_SetModeGnssFreqRefCorrection_py(mode):
    cdef int _mode = mode
    err_check(CONFIG_SetModeGnssFreqRefCorrection(_mode))
    
    
def CONFIG_GetModeGnssFreqRefCorrection_py():
    cdef int mode
    err_check(CONFIG_GetModeGnssFreqRefCorrection(&mode))
    return mode


def CONFIG_GetStatusGnssFreqRefCorrection_py():
    cdef int state
    cdef int quality
    err_check(CONFIG_GetStatusGnssFreqRefCorrection(&state, &quality))
    return state, quality


def CONFIG_SetEnableGnssTimeRefAlign_py(enable):
    cdef bint _enable = enable
    err_check(CONFIG_SetEnableGnssTimeRefAlign(_enable))


def CONFIG_GetEnableGnssTimeRefAlign_py():
    cdef bint enable
    err_check(CONFIG_GetEnableGnssTimeRefAlign(&enable))
    return enable


def CONFIG_GetStatusGnssTimeRefAlign_py():
    cdef bint aligned
    err_check(CONFIG_GetStatusGnssTimeRefAlign(&aligned))
    return aligned


def CONFIG_SetFreqRefUserSetting_py(i_usstr):
    cdef char* _i_usstr = i_usstr
    err_check(CONFIG_SetFreqRefUserSetting(_i_usstr))
    

def CONFIG_GetFreqRefUserSetting_py():
    cdef char o_usstr[200]
    err_check(CONFIG_SetFreqRefUserSetting(o_usstr))
    return o_usstr
    

# def CONFIG_DecodeFreqRefUserSettingString_py(i_usstr):
#     cdef char* _i_usstr = i_usstr
#     cdef  FREQREF_USER_INFO o_fui
#     err_check(CONFIG_DecodeFreqRefUserSettingString(_i_usstr, &o_fui))
#     return o_fui


##########################################################
#  Trigger Configuration
##########################################################


def TRIG_SetTriggerMode_py(mode=TriggerMode.triggered):
    if mode not in [TriggerMode.freeRun, TriggerMode.triggered]:
        raise TypeError('"mode" must be of type "TriggerMode".')
    err_check(TRIG_SetTriggerMode(mode))


def TRIG_GetTriggerMode_py():
    # cdef TriggerMode mode
    cdef int mode
    err_check(TRIG_GetTriggerMode(&mode))
    return mode


def TRIG_SetTriggerSource_py(source=TriggerSource.TriggerSourceIFPowerLevel):
    err_check(TRIG_SetTriggerSource(source))


def TRIG_GetTriggerSource_py():
    # cdef TriggerSource source
    cdef int source
    err_check(TRIG_GetTriggerSource(&source))
    return source


def TRIG_SetTriggerTransition_py(transition=TriggerTransition.TriggerTransitionLH):
    err_check(TRIG_SetTriggerTransition(transition))


def TRIG_GetTriggerTransition_py():
    # cdef TriggerTransition transition
    cdef int transition
    err_check(TRIG_GetTriggerTransition(&transition))
    return transition


def TRIG_SetIFPowerTriggerLevel_py(trigLevel=-10):
    if trigLevel > 30 or trigLevel < -130:
        raise RSAError('Parameter out of range.')
    cdef double _trigLevel = trigLevel
    err_check(TRIG_SetIFPowerTriggerLevel(_trigLevel))


def TRIG_GetIFPowerTriggerLevel_py():
    cdef double trigLevel
    err_check(TRIG_GetIFPowerTriggerLevel(&trigLevel))
    return trigLevel


def TRIG_SetTriggerPositionPercent_py(trigPosPercent=10):
    if trigPosPercent < 1 or trigPosPercent > 99:
        raise RSAError('Parameter out of range.')
    cdef double _trigPosPercent = trigPosPercent
    err_check(TRIG_SetTriggerPositionPercent(_trigPosPercent))


def TRIG_GetTriggerPositionPercent_py():
    cdef double trigPosPercent
    err_check(TRIG_GetTriggerPositionPercent(&trigPosPercent))
    return trigPosPercent


def TRIG_ForceTrigger_py():
    err_check(TRIG_ForceTrigger())


##########################################################
# Device Alignment
##########################################################

def ALIGN_GetWarmupStatus_py():
    cdef bint warmedUp
    err_check(ALIGN_GetWarmupStatus(&warmedUp))
    return warmedUp


def ALIGN_GetAlignmentNeeded_py():
    cdef bint needed = False
    err_check(ALIGN_GetAlignmentNeeded(&needed))
    return needed


def ALIGN_RunAlignment_py():
    err_check(ALIGN_RunAlignment())


##########################################################
# Device Operation (global)
##########################################################


def DEVICE_PrepareForRun_py():
    err_check(DEVICE_PrepareForRun())


def DEVICE_Run_py():
    err_check(DEVICE_Run())


def DEVICE_GetEnable_py():
    cdef bint devEnable
    err_check(DEVICE_GetEnable(&devEnable))
    return devEnable


def DEVICE_StartFrameTransfer_py():
    err_check(DEVICE_StartFrameTransfer())


def DEVICE_Stop_py():
    err_check(DEVICE_Stop())


def DEVICE_GetEventStatus_py(eventID=DEVEVENT_OVERRANGE):
    cdef int _eventID = eventID
    cdef bint eventOccurred
    cdef uint64_t eventTimestamp
    err_check(DEVICE_GetEventStatus(_eventID, &eventOccurred, &eventTimestamp))
    return eventOccurred, eventTimestamp


    ##########################################################
    # System/Reference Time
    ##########################################################
def REFTIME_GetTimestampRate_py():
    cdef uint64_t o_refTimestampRate
    err_check(REFTIME_GetTimestampRate(&o_refTimestampRate))
    return o_refTimestampRate


def REFTIME_GetCurrentTime_py():
    cdef Py_ssize_t o_timeSec = 0
    cdef uint64_t o_timeNsec = 0
    cdef uint64_t o_timestamp = 0
    err_check(REFTIME_GetCurrentTime(&o_timeSec, &o_timeNsec, &o_timestamp))
    return o_timeSec, o_timeNsec, o_timestamp


def REFTIME_GetTimeFromTimestamp_py(i_timestamp):
    cdef uint64_t _i_timestamp = i_timestamp
    cdef Py_ssize_t o_timeSec
    cdef uint64_t o_timeNsec
    err_check(REFTIME_GetTimeFromTimestamp(_i_timestamp, &o_timeSec, &o_timeNsec))
    return o_timeSec, o_timeNsec


def REFTIME_GetTimestampFromTime_py(i_timeSec, i_timeNsec):
    cdef Py_ssize_t _i_timeSec = i_timeSec
    cdef uint64_t _i_timeNsec = i_timeNsec
    cdef uint64_t o_timestamp
    err_check(REFTIME_GetTimestampFromTime(_i_timeSec, _i_timeNsec, &o_timestamp))
    return o_timestamp


def REFTIME_GetIntervalSinceRefTimeSet_py():
    cdef double sec
    err_check(REFTIME_GetIntervalSinceRefTimeSet(&sec))
    return sec


def REFTIME_SetReferenceTime_py(refTimeSec, refTimeNsec, refTimestamp):
    cdef Py_ssize_t _refTimeSec = refTimeSec
    cdef uint64_t _refTimeNsec = refTimeNsec
    cdef uint64_t _refTimestamp = refTimestamp
    err_check(REFTIME_SetReferenceTime(_refTimeSec, _refTimeNsec, _refTimestamp))


def REFTIME_GetReferenceTime_py():
    cdef Py_ssize_t refTimeSec
    cdef uint64_t refTimeNsec
    cdef uint64_t refTimestamp
    err_check(REFTIME_GetReferenceTime(&refTimeSec, &refTimeNsec, &refTimestamp))
    return refTimeSec, refTimeNsec, refTimestamp


##########################################################
# IQ Block Data Acquisition
##########################################################


def IQBLK_GetMaxIQBandwidth_py():
    cdef double maxBandwidth
    err_check(IQBLK_GetMaxIQBandwidth(&maxBandwidth))
    return maxBandwidth


def IQBLK_GetMinIQBandwidth_py():
    cdef double minBandwidth
    err_check(IQBLK_GetMinIQBandwidth(&minBandwidth))
    return minBandwidth


def IQBLK_GetMaxIQRecordLength_py():
    cdef int maxSamples
    err_check(IQBLK_GetMaxIQRecordLength(&maxSamples))
    return maxSamples


def IQBLK_SetIQBandwidth_py(iqBandwidth=40e6):
    cdef double _iqBandwidth = iqBandwidth
    err_check(IQBLK_SetIQBandwidth(_iqBandwidth))


def IQBLK_GetIQBandwidth_py():
    cdef double iqBandwidth
    err_check(IQBLK_GetIQBandwidth(&iqBandwidth))
    return iqBandwidth


def IQBLK_GetIQSampleRate_py():
    cdef double iqSampleRate
    err_check(IQBLK_GetIQSampleRate(&iqSampleRate))
    return iqSampleRate


def IQBLK_SetIQRecordLength_py(recordLength=1000):
    if recordLength < 0 or recordLength > 112000000:
        raise RSAError('Parameter out of range.')
    cdef int _recordLength = recordLength
    err_check(IQBLK_SetIQRecordLength(_recordLength))


def IQBLK_GetIQRecordLength_py():
    cdef int recordLength
    err_check(IQBLK_GetIQRecordLength(&recordLength))
    return recordLength


def IQBLK_AcquireIQData_py():
    err_check(IQBLK_AcquireIQData())


def IQBLK_WaitForIQDataReady_py(timeoutMsec=10):
    cdef int _timeoutMsec = timeoutMsec
    cdef bint ready
    err_check(IQBLK_WaitForIQDataReady(_timeoutMsec, &ready))
    return ready


def IQBLK_GetIQData_py(reqLength=1000):
    if reqLength > 112000000:
        raise RSAError('Parameter out of range.')
    cdef int _reqLength = reqLength
    cdef int outLength
    cdef np.ndarray iqData = np.empty(shape=(reqLength*2), dtype=np.float32, order='c')
    err_check(IQBLK_GetIQData(<float*> iqData.data, &outLength, _reqLength))
    return np.asarray(iqData, dtype=np.float32)


def IQBLK_GetIQDataDeinterleaved_py(reqLength=1000):
    if reqLength > 112000000:
        raise RSAError('Parameter out of range.')
    cdef int _reqLength = reqLength
    cdef int outLength
    cdef np.ndarray iData = np.empty(shape=(reqLength), dtype=np.float32, order='c')
    cdef np.ndarray qData = np.empty(shape=(reqLength), dtype=np.float32, order='c')
    err_check(IQBLK_GetIQDataDeinterleaved(<float*> iData.data, <float*> qData.data, &outLength, _reqLength))
    return np.asarray(iData, dtype=np.float32), np.asarray(qData, dtype=np.float32)

# Not worth the trouble to convert the Cplx32 struct to a Pythonic data type
# The commented function below does not work
# def IQBLK_GetIQDataCplx_py(reqLength):
#     cdef int req = reqLength
#     cdef int outLength
#     cdef Cplx32 iqDataCplx[reqLength]
#     err_check(IQBLK_GetIQDataCplx(iqDataCplx, &outLength, reqLength))
#     return [(d['i'] + 1j * d['q']) for d in np.asarray(iqDataCplx)]

# Helper function
def IQBLK_Acquire_py(get_function=IQBLK_GetIQDataDeinterleaved_py,
                     recordLength=1000, timeoutMsec=10):
    DEVICE_Run_py()
    IQBLK_AcquireIQData_py()
    while not IQBLK_WaitForIQDataReady_py(timeoutMsec):
        pass
    return get_function(recordLength)


def IQBLK_GetIQAcqInfo_py():
    cdef IQBLK_ACQINFO acqInfo
    err_check(IQBLK_GetIQAcqInfo(&acqInfo))
    return acqInfo


##########################################################
# Spectrum Acquisition
##########################################################


def SPECTRUM_SetEnable_py(enable):
    cdef bint _enable = enable
    err_check(SPECTRUM_SetEnable(_enable))


def SPECTRUM_GetEnable_py():
    cdef bint enable
    err_check(SPECTRUM_GetEnable(&enable))
    return enable


def SPECTRUM_SetDefault_py():
    err_check(SPECTRUM_SetDefault())


def SPECTRUM_GetSettings_py():
    cdef Spectrum_Settings settings
    err_check(SPECTRUM_GetSettings(&settings))
    return settings


def SPECTRUM_SetSettings_py(span=40e6, rbw=300e3, enableVBW=False, vbw=300e3,
                            traceLength=801, window=SpectrumWindows.SpectrumWindow_Kaiser,
                            verticalUnit=SpectrumVerticalUnits.SpectrumVerticalUnit_dBm):
    # Grab fully-populated Spectrum_Settings struct for safety reasons
    settings = SPECTRUM_GetSettings_py()
    settings['span'] = span
    settings['rbw'] = rbw
    settings['enableVBW'] = enableVBW
    settings['vbw'] = vbw
    settings['window'] = window
    settings['traceLength'] = traceLength
    settings['verticalUnit'] = verticalUnit
    err_check(SPECTRUM_SetSettings(settings))


def SPECTRUM_SetTraceType_py(trace=SpectrumTraces.SpectrumTrace1, enable=True,
                          detector=SpectrumDetectors.SpectrumDetector_PosPeak):
    if not isinstance(trace, int) or not isinstance(detector, int):
        raise RSAError('"trace" argument must be SpectrumTraces type.')
    cdef SpectrumTraces _trace = trace
    cdef bint _enable = enable
    cdef SpectrumDetectors _detector = detector
    err_check(SPECTRUM_SetTraceType(_trace, _enable, _detector))


def SPECTRUM_GetTraceType_py(trace=SpectrumTraces.SpectrumTrace1):
    cdef bint enable
    cdef int detector
    err_check(SPECTRUM_GetTraceType(trace, &enable, &detector))
    return enable, detector


def SPECTRUM_GetLimits_py():
    cdef Spectrum_Limits limits
    err_check(SPECTRUM_GetLimits(&limits))
    return limits


def SPECTRUM_AcquireTrace_py():
    err_check(SPECTRUM_AcquireTrace())


def SPECTRUM_WaitForTraceReady_py(timeoutMsec=10):
    cdef int _timeoutMsec = timeoutMsec
    cdef bint ready
    err_check(SPECTRUM_WaitForTraceReady(_timeoutMsec, &ready))
    return ready


def SPECTRUM_GetTrace_py(trace=SpectrumTraces.SpectrumTrace1, tracePoints=801):
    cdef int _tracePoints = tracePoints
    cdef np.ndarray traceData = np.empty(shape=(tracePoints), dtype=np.float32,
                                     order='c')
    cdef int outTracePoints
    err_check(SPECTRUM_GetTrace(trace, _tracePoints, <float *> traceData.data, &outTracePoints))
    return np.asarray(traceData, dtype=np.float32)


def SPECTRUM_GetTraceInfo_py():
    cdef Spectrum_TraceInfo traceInfo
    err_check(SPECTRUM_GetTraceInfo(&traceInfo))
    return traceInfo


# Helper function
def SPECTRUM_Acquire_py(trace=SpectrumTraces.SpectrumTrace1, tracePoints=801,
                        timeoutMsec=10):
    DEVICE_Run_py()
    SPECTRUM_AcquireTrace_py()
    while not SPECTRUM_WaitForTraceReady_py(timeoutMsec):
        pass
    return SPECTRUM_GetTrace_py(trace, tracePoints)


##########################################################
# DPX Bitmap, Trace, and Spectrogram
##########################################################

"""
there is a problem when the spectrum or IQ examples are run before the
DPX example. This occurs right before grabbing the DPX_FrameBuffer
If the DPX example is run first, there is no problem.
"""
"""
DPX_Configure must be called after any DPX settings
have been changed and the device is in Stop state. This function
configures all the DPX settings.
DPX_SetParameters + DPX_Configure must be called before acquiring a DPX
FrameBuffer.
DPX_Configure has been automatically incorporated into DPX_SetParameters_py
DPX_SetParameters_py should be called before DPX_AcquireFB_py
See cython_example.py for usage
"""
# def DPX_Configure_py(_enableSpectrum, _enableSpectrogram):
#     cdef bint enableSpectrum = _enableSpectrum
#     cdef bint enableSpectrogram = _enableSpectrogram
#     err_check(DPX_Configure(enableSpectrum, enableSpectrogram))


def DPX_SetEnable_py(enable=True):
    cdef bint _enable = enable
    err_check(DPX_SetEnable(_enable))


def DPX_GetEnable_py():
    cdef bint enable
    err_check(DPX_GetEnable(&enable))
    return enable


def DPX_Reset_py():
    err_check(DPX_Reset())


def DPX_SetParameters_py(fspan=40e6, rbw=300e3, tracePtsPerPixel=1,
                        yUnit=VerticalUnitType.VerticalUnit_dBm,
                        yTop=0, yBottom=-100, infinitePersistence=False,
                        persistenceTimeSec=1, showOnlyTrigFrame=False):
    cdef double _fspan = fspan
    cdef double _rbw = rbw
    cdef int32_t _bitmapWidth = 801      # 0 <= 801
    cdef int32_t _tracePtsPerPixel = tracePtsPerPixel   # 1, 3, or 5.
    # tracePoints = bitmapWidth*tracePtsPerPixel
    cdef VerticalUnitType _yUnit = yUnit
    cdef double _yTop = yTop
    cdef double _yBottom = yBottom
    cdef bint _infinitePersistence = infinitePersistence
    cdef double _persistenceTimeSec = persistenceTimeSec
    cdef bint _showOnlyTrigFrame = showOnlyTrigFrame
    err_check(DPX_SetParameters(_fspan, _rbw, _bitmapWidth, _tracePtsPerPixel,
                           _yUnit, _yTop, _yBottom, _infinitePersistence,
                           _persistenceTimeSec, _showOnlyTrigFrame))

    cdef bint enableSpectrum = True
    cdef bint enableSpectrogram = True
    err_check(DPX_Configure(enableSpectrum, enableSpectrogram))


def DPX_SetSpectrumTraceType_py(traceIndex=DPX_TRACEIDX_1,
                              traceType=TraceType.TraceTypeMax):
    cdef int32_t _traceIndex = traceIndex
    cdef TraceType _traceType = traceType
    err_check(DPX_SetSpectrumTraceType(_traceIndex, _traceType))


def DPX_GetSettings_py():
    cdef DPX_SettingsStruct pSettings
    err_check(DPX_GetSettings(&pSettings))
    return pSettings


def DPX_GetRBWRange_py(fspan=40e6):
    cdef double minRBW
    cdef double maxRBW
    err_check(DPX_GetRBWRange(fspan, &minRBW, &maxRBW))
    return minRBW, maxRBW


def DPX_SetSogramParameters_py(timePerBitmapLine=0.1, timeResolution=0.01,
                               maxPower=0, minPower=-100):
    cdef double _timePerBitmapLine = timePerBitmapLine
    cdef double _timeResolution = timeResolution
    cdef double _maxPower = maxPower
    cdef double _minPower = minPower
    err_check(DPX_SetSogramParameters(_timePerBitmapLine, _timeResolution,
                                      _maxPower, _minPower))


def DPX_SetSogramTraceType_py(traceType=TraceType.TraceTypeMax):
    err_check(DPX_SetSogramTraceType(traceType))


def DPX_IsFrameBufferAvailable_py():
    cdef bint frameAvailable
    err_check(DPX_IsFrameBufferAvailable(&frameAvailable))
    return frameAvailable


def DPX_WaitForDataReady_py(timeoutMsec=50):
    cdef bint ready
    err_check(DPX_WaitForDataReady(timeoutMsec, &ready))
    return ready


def DPX_GetFrameBuffer_py():
    cpdef DPX_FrameBuffer fb
    err_check(DPX_GetFrameBuffer(&fb))
    err_check(DPX_FinishFrameBuffer())

    spectrumBitmap = np.asarray(fb.spectrumBitmap)
    spectrumBitmap = spectrumBitmap.reshape((fb.spectrumBitmapHeight,
                                        fb.spectrumBitmapWidth))

    spectrumTraces = []
    for i in range(3):
        spectrumTraces.append(10 * np.log10(1000 * np.asarray(
            fb.spectrumTraces[i])[:fb.spectrumTraceLength]) + 30)

    """
    The Cython typedef of uint8_t is an unsigned char. Because
    DPX_FrameBuffer.sogramBitmap is defined as a uint8_t*
    Python interprets, the returned value as a string. Fortunately
    Numpy has the .fromstring() method that interprets the string as
    numerical values.
    """
    sogramBitmap = np.fromstring(fb.sogramBitmap, dtype=np.uint8)
    sogramBitmap = sogramBitmap.reshape((
        fb.sogramBitmapHeight, fb.sogramBitmapWidth))[
               :fb.sogramBitmapNumValidLines]

    fb_py = DPX_FrameBuffer_py(fb, spectrumBitmap, spectrumTraces,
                               sogramBitmap)
    return fb_py


def DPX_AcquireFB_py():
    """Helper Function for DPX Acquisition"""
    DEVICE_Run_py()
    while not DPX_IsFrameBufferAvailable_py():
        pass
    while not DPX_WaitForDataReady_py():
        pass
    fb_py = DPX_GetFrameBuffer_py()
    return fb_py


def DPX_GetFrameInfo_py():
    cdef int64_t frameCount
    cdef int64_t fftCount
    err_check(DPX_GetFrameInfo(&frameCount, &fftCount))
    return frameCount, fftCount


def DPX_GetSogramSettings_py():
    cdef DPX_SogramSettingsStruct sSettings
    err_check(DPX_GetSogramSettings(&sSettings))
    return sSettings


def DPX_GetSogramHiResLineCountLatest_py():
    cdef int32_t lineCount
    err_check(DPX_GetSogramHiResLineCountLatest(&lineCount))
    return lineCount


def DPX_GetSogramHiResLineTriggered_py(lineIndex):
    cdef bint triggered
    cdef int32_t _lineIndex = lineIndex
    err_check(DPX_GetSogramHiResLineTriggered(&triggered, _lineIndex))
    return triggered


def DPX_GetSogramHiResLineTimestamp_py(lineIndex):
    cdef double timestamp
    cdef int32_t _lineIndex = lineIndex
    err_check(DPX_GetSogramHiResLineTimestamp(&timestamp, _lineIndex))
    return timestamp


def DPX_GetSogramHiResLine_py(lineIndex=0):
    # sogramBitmapWidth and sogramTracePoints are only ever 267
    cdef int16_t vData[267]
    cdef int32_t vDataSize
    cdef int32_t _lineIndex = lineIndex
    cdef double dataSF
    cdef int32_t tracePoints = 267
    cdef int32_t firstValidPoint = 0
    err_check(DPX_GetSogramHiResLine(vData, &vDataSize, _lineIndex, &dataSF, tracePoints, firstValidPoint))
    return np.array(vData)


##########################################################
# Audio Demod
##########################################################


def AUDIO_SetMode_py(mode):
    if mode < 0 or mode > 5:
        raise RSAError('Parameter out of range.')
    err_check(AUDIO_SetMode(mode))


def AUDIO_GetMode_py():
    cdef int mode
    err_check(AUDIO_GetMode(&mode))
    return mode


def AUDIO_SetVolume_py(volume):
    if volume < 0 or volume > 1.0:
        raise RSAError('Parameter out of range.')
    cdef float _volume = volume
    err_check(AUDIO_SetVolume(_volume))


def AUDIO_GetVolume_py():
    cdef float volume
    err_check(AUDIO_GetVolume(&volume))
    return volume


def AUDIO_SetMute_py(mute):
    if not isinstance(mute, bool):
        raise TypeError('Argument must be bool.')
    cdef bint _mute = mute
    err_check(AUDIO_SetMute(_mute))


def AUDIO_GetMute_py():
    cdef bint mute
    err_check(AUDIO_GetMute(&mute))
    return mute


def AUDIO_SetFrequencyOffset_py(freqOffsetHz):
    cdef double _freqOffsetHz = freqOffsetHz
    err_check(AUDIO_SetFrequencyOffset(_freqOffsetHz))


def AUDIO_GetFrequencyOffset_py():
    cdef double freqOffsetHz
    err_check(AUDIO_GetFrequencyOffset(&freqOffsetHz))
    return freqOffsetHz


def AUDIO_Start_py():
    err_check(AUDIO_Start())


def AUDIO_GetEnable_py():
    cdef bint enable
    err_check(AUDIO_GetEnable(&enable))
    return enable

# Error checking not working
def AUDIO_GetData_py(inSize):
    cdef uint16_t _inSize = inSize
    cdef uint16_t outSize
    cdef np.ndarray data = np.empty(shape=(inSize), dtype=np.int16, order='c')
    err_check(AUDIO_GetData(<int16_t *> data.data, _inSize, &outSize))
    # print(_inSize)
    # print(outSize)
    # if _inSize != outSize:
    #     raise RSAError('# samples requested != # samples returned')
    return data


def AUDIO_Stop_py():
    err_check(AUDIO_Stop())


##########################################################
# IF Streaming
##########################################################


def IFSTREAM_SetOutputConfiguration_py(dest):
    if not isinstance(dest, int):
        raise TypeError('"dest" must be int.')
    if dest not in [0, 1, 3, 11, 12]:
        raise RSAError('Parameter out of range.')
    cdef int _dest = dest
    err_check(IFSTREAM_SetOutputConfiguration(_dest))


# Legacy, use IFSTREAM_SetOutputConfiguration_py
# def IFSTREAM_SetDiskFileMode_py(mode):
#     cdef int _mode = mode
#     err_check(IFSTREAM_SetDiskFileMode(_mode))


def IFSTREAM_SetDiskFilePath_py(path):
    cdef char* _path = path
    err_check(IFSTREAM_SetDiskFilePath(_path))


def IFSTREAM_SetDiskFilenameBase_py(base):
    cdef char* _base = base
    err_check(IFSTREAM_SetDiskFilenameBase(_base))


def IFSTREAM_SetDiskFilenameSuffix_py(suffixCtl):
    if suffixCtl not in [0, -1, -2]:
        raise RSAError('Parameter out of range.')
    cdef int _suffixCtl = suffixCtl
    err_check(IFSTREAM_SetDiskFilenameSuffix(_suffixCtl))
    

def IFSTREAM_SetDiskFileLength_py(msec):
    cdef int _msec = msec
    err_check(IFSTREAM_SetDiskFileLength(_msec))


def IFSTREAM_SetDiskFileCount_py(count):
    cdef int _count = count
    err_check(IFSTREAM_SetDiskFileCount(_count))


def IFSTREAM_GetAcqParameters_py():
    cdef double bwHz_act
    cdef double srSps
    cdef double cfAtIfHz
    err_check(IFSTREAM_GetAcqParameters(&bwHz_act, &srSps, &cfAtIfHz))
    return bwHz_act, srSps, cfAtIfHz


def IFSTREAM_GetScalingParameters_py():
    cdef double scaleFactor
    cdef double scaleFreq
    err_check(IFSTREAM_GetScalingParameters(&scaleFactor, &scaleFreq))
    return scaleFactor, scaleFreq


# Return to this later, float** type conversion causing fits
# def IFSTREAM_GetEQParameters_py():
#     cdef int numPts
#     cdef float** freq
#     cdef float** ampl
#     cdef float** phase
#     err_check(IFSTREAM_GetEQParameters(numPts, freq, ampl, phase))
#     return numPts, freq, ampl, phase


def IFSTREAM_GetIFDataBufferSize_py():
    cdef int buffSize
    cdef int numSamples
    err_check(IFSTREAM_GetIFDataBufferSize(&buffSize, &numSamples))
    return buffSize, numSamples


def IFSTREAM_SetEnable_py(enable):
    cdef bint _enable = enable
    err_check(IFSTREAM_SetEnable(_enable))


def IFSTREAM_GetActiveStatus_py():
    cdef bint active
    err_check(IFSTREAM_GetActiveStatus(&active))
    return active


def IFSTREAM_GetIFData_py():
    cpdef np.ndarray data = np.empty(shape=(130848), dtype=np.int16, order='c')
    cdef int dataLen
    cdef IFSTRMDATAINFO dataInfo
    err_check(IFSTREAM_GetIFData(<int16_t *> data.data, &dataLen, &dataInfo))
    # err_check(IFSTREAM_GetIFData(&data, &dataLen, &dataInfo))
    return data, dataLen, dataInfo


# Return to this later, float** type conversion causing fits
# def IFSTREAM_GetIFFrames_py():
#     cdef uint8_t** data
#     cdef int numBytes
#     cdef int numFrames
#     err_check(IFSTREAM_GetIFFrames(&data, &numBytes, &numFrames))


###########################################################
# IQ Data Streaming to Client or Disk
###########################################################


def IQSTREAM_GetMinAcqBandwidth_py():
    cdef double minBandwidthHz
    err_check(IQSTREAM_GetMinAcqBandwidth(&minBandwidthHz))
    return minBandwidthHz


def IQSTREAM_GetMaxAcqBandwidth_py():
    cdef double maxBandwidthHz
    err_check(IQSTREAM_GetMaxAcqBandwidth(&maxBandwidthHz))
    return maxBandwidthHz


def IQSTREAM_SetAcqBandwidth_py(bwHz_req):
    cdef double _bwHz_req = bwHz_req
    err_check(IQSTREAM_SetAcqBandwidth(_bwHz_req))


# This MUST be sent before IQSTREAM_Start() or the resulting file will be empty
def IQSTREAM_GetAcqParameters_py():
    cdef double bwHz_act
    cdef double srSps
    err_check(IQSTREAM_GetAcqParameters(&bwHz_act, &srSps))
    return bwHz_act, srSps


def IQSTREAM_SetOutputConfiguration_py(dest=IQSOUTDEST.IQSOD_FILE_SIQ,
                                       dtype=IQSOUTDTYPE.IQSODT_INT16):
    cdef IQSOUTDEST _dest = dest
    cdef IQSOUTDTYPE _dtype = dtype
    err_check(IQSTREAM_SetOutputConfiguration(_dest, _dtype))


def IQSTREAM_SetIQDataBufferSize_py(reqSize):
    cdef int _reqSize = reqSize
    err_check(IQSTREAM_SetIQDataBufferSize(_reqSize))


def IQSTREAM_GetIQDataBufferSize_py():
    cdef int maxSize
    err_check(IQSTREAM_GetIQDataBufferSize(&maxSize))
    return maxSize


def IQSTREAM_SetDiskFilenameBase_py(filenameBase):
    cdef char* _filenameBase = filenameBase
    err_check(IQSTREAM_SetDiskFilenameBase(_filenameBase))


def IQSTREAM_SetDiskFilenameSuffix_py(suffixCtl=IQSSDFN_SUFFIX_NONE):
    if suffixCtl not in [IQSSDFN_SUFFIX_INCRINDEX_MIN, IQSSDFN_SUFFIX_TIMESTAMP,
                     IQSSDFN_SUFFIX_NONE]:
        raise RSAError('Parameter out of range.')
    cdef int _suffixCtl = suffixCtl
    err_check(IQSTREAM_SetDiskFilenameSuffix(_suffixCtl))


def IQSTREAM_SetDiskFileLength_py(msec):
    if msec < 0:
        raise RSAError('Parameter out of range.')
    cdef int _msec = msec
    err_check(IQSTREAM_SetDiskFileLength(_msec))


def IQSTREAM_Start_py():
    err_check(IQSTREAM_Start())


def IQSTREAM_GetEnable_py():
    cdef bint enable
    err_check(IQSTREAM_GetEnable(&enable))
    return enable


def IQSTREAM_GetDiskFileWriteStatus_py():
    cdef bint isComplete
    cdef bint isWriting
    err_check(IQSTREAM_GetDiskFileWriteStatus(&isComplete, &isWriting))
    return isComplete, isWriting


def IQSTREAM_Stop_py():
    err_check(IQSTREAM_Stop())


def IQSTREAM_WaitForIQDataReady_py(timeoutMsec=10):
    cdef int _timeoutMsec = timeoutMsec
    cdef bint ready
    err_check(IQSTREAM_WaitForIQDataReady(_timeoutMsec, &ready))
    return ready


def IQSTREAM_GetIQData_py(inputBuffer, dType):
    # cdef void* iqData
    if dType not in [IQSOUTDTYPE.IQSODT_SINGLE, IQSOUTDTYPE.IQSODT_INT32,
                     IQSOUTDTYPE.IQSODT_INT16,
                     IQSOUTDTYPE.IQSODT_SINGLE_SCALE_INT32]:
        raise RSAError('"dType" must be of type IQSOUTDTYPE')
    if dType == IQSOUTDTYPE.IQSODT_INT16:
        bufferDType = np.int16
    elif dType == IQSOUTDTYPE.IQSODT_INT32:
        bufferDType = np.int32
    elif dType == IQSOUTDTYPE.IQSODT_SINGLE or dType == IQSOUTDTYPE.IQSODT_SINGLE_SCALE_INT32:
        bufferDType = np.float32
    
    cdef np.ndarray iqData = np.empty(shape=(inputBuffer*2), dtype=bufferDType, order='c')
    cdef int iqlen
    cdef IQSTRMIQINFO iqinfo
    err_check(IQSTREAM_GetIQData(<void*> iqData.data, &iqlen, &iqinfo))
    return iqData, iqinfo


# def IQSTREAM_GetDiskFileInfo_py():
#     cdef IQSTRMFILEINFO fileinfo
#     err_check(IQSTREAM_GetFileInfo(&fileinfo))
#     return fileinfo


def IQSTREAM_ClearAcqStatus_py():
    IQSTREAM_ClearAcqStatus()


###########################################################
# Stored IF Data File Playback
###########################################################


def PLAYBACK_OpenDiskFile_py(fileName, startPercentage, stopPercentage,
                             skipTimeBetweenFullAcquisitions,
                             loopAtEndOfFile, emulateRealTime):
    if not exists(fileName):
        raise RSAError('errorStreamedFileOpenFailure')
    cdef Py_UNICODE* _fileName = fileName
    cdef int _startPercentage = startPercentage
    cdef int _stopPercentage = stopPercentage
    if skipTimeBetweenFullAcquisitions < 0:
        raise RSAError('Parameter out of range.')
    cdef double _skipTimeBetweenFullAcquisitions = skipTimeBetweenFullAcquisitions
    if not isinstance(loopAtEndOfFile, bool):
        raise TypeError('"loopAtEndOfFile" argument must be of type "bool".')
    if not isinstance(emulateRealTime, bool):
        raise TypeError('"emulateRealTime" argument must be of type "bool".')
    cdef bint _loopAtEndOfFile = loopAtEndOfFile
    cdef bint _emulateRealTime = emulateRealTime
    err_check(PLAYBACK_OpenDiskFile(_fileName, _startPercentage,
                                    _stopPercentage,
                                    _skipTimeBetweenFullAcquisitions,
                                    _loopAtEndOfFile, _emulateRealTime))


def PLAYBACK_GetReplayComplete_py():
    cdef bint complete
    err_check(PLAYBACK_GetReplayComplete(&complete))
    return complete


###########################################################
# GNSS Rx Control and Output
###########################################################


def GNSS_GetHwInstalled_py():
    cdef bint installed
    err_check(GNSS_GetHwInstalled(&installed))
    return installed

def GNSS_SetEnable_py(enable):
    cdef bint _enable = enable
    err_check(GNSS_SetEnable(_enable))


def GNSS_GetEnable_py():
    cdef bint enable
    err_check(GNSS_GetEnable(&enable))
    return enable


def GNSS_SetSatSystem_py(satSystem):
    if satSystem not in [GNSS_SATSYS.GNSS_NOSYS, GNSS_SATSYS.GNSS_GPS_GLONASS,
                     GNSS_SATSYS.GNSS_GPS_BEIDOU, GNSS_SATSYS.GNSS_GPS,
                     GNSS_SATSYS.GNSS_GLONASS, GNSS_SATSYS.GNSS_BEIDOU]:
        raise RSAError('Parameter out of range.')
    cdef int _satSystem = satSystem
    err_check(GNSS_SetSatSystem(_satSystem))


def GNSS_GetSatSystem_py():
    cdef int satSystem
    err_check(GNSS_GetSatSystem(&satSystem))
    return satSystem


def GNSS_SetAntennaPower_py(powered):
    cdef bint _powered = powered
    err_check(GNSS_SetAntennaPower(_powered))


def GNSS_GetAntennaPower_py():
    cdef bint powered
    err_check(GNSS_GetAntennaPower(&powered))
    return powered


def GNSS_GetNavMessageData_py():
    cdef int msgLen
    cdef char* message
    err_check(GNSS_GetNavMessageData(&msgLen, &message))
    return message, msgLen


def GNSS_ClearNavMessageData_py():
    err_check(GNSS_ClearNavMessageData())


def GNSS_Get1PPSTimestamp_py():
    cdef bint isValid
    cdef uint64_t timestamp1PPS
    err_check(GNSS_Get1PPSTimestamp(&isValid, &timestamp1PPS))
    return timestamp1PPS, isValid


def GNSS_GetStatusRxLock_py():
    cdef bint lock
    err_check(GNSS_GetStatusRxLock(&lock))
    return lock


###########################################################
# Power and Battery Status
###########################################################


def POWER_GetStatus_py():
    cdef POWER_INFO powerInfo
    err_check(POWER_GetStatus(&powerInfo))
    return powerInfo