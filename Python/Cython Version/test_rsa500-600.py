"""
Tektronix RSA_API Cython Unit Test for RSA500/600
Author: Morgan Allison
Date edited: 11/17
Windows 7 64-bit
RSA API version 3.11.0047
Python 3.6.1 64-bit (Anaconda 4.4.0)
NumPy 1.13.1, MatPlotLib 2.0.0
Download Anaconda: http://continuum.io/downloads
Anaconda includes NumPy and MatPlotLib
Download the RSA_API: http://www.tek.com/model/rsa306-software
Download the RSA_API Documentation:
http://www.tek.com/spectrum-analyzer/rsa306-manual-6
"""

import unittest
from time import sleep
from rsa_api import *
from os.path import isdir
from os import mkdir


class rsa_api_test(unittest.TestCase):
    """Test for rsa_api.pyd"""

    def test_err_check_no_error(self):
        """err_check() returns None if there are no errors."""
        self.assertIsNone(err_check(0))

    def test_err_check_err_not_connected(self):
        self.assertRaises(RSAError, err_check, 101)
        try:
            err_check(101)
        except RSAError as e:
            self.assertEqual(e.__str__(), 'Not Connected')

    def test_err_check_measurement_not_enabled(self):
        self.assertRaises(RSAError, err_check, 1102)
        try:
            err_check(1102)
        except RSAError as e:
            self.assertEqual(e.__str__(), 'Measurement not enabled')
    
    """DEVICE Command Testing"""
    
    def test_DEVICE_GetOverTemperatureStatus_py(self):
        self.assertIsInstance(DEVICE_GetOverTemperatureStatus_py(), bool)
    
    def test_DEVICE_GetNomenclature_py(self):
        self.assertEqual(DEVICE_GetNomenclature_py(), 'RSA507A')
    
    def test_DEVICE_GetSerialNumber_py(self):
        sn = DEVICE_GetSerialNumber_py()
        self.assertIsInstance(sn, str)
        self.assertEqual(len(sn), 7)
    
    def test_DEVICE_GetAPIVersion_py(self):
        self.assertEqual(DEVICE_GetAPIVersion_py(), '3.11.0047.0')
    
    def test_DEVICE_GetFWVersion_py(self):
        self.assertEqual(DEVICE_GetFWVersion_py(), 'V1.1')
    
    def test_DEVICE_GetFPGAVersion_py(self):
        self.assertEqual(DEVICE_GetFPGAVersion_py(), 'V3.30')
    
    def test_DEVICE_GetHWVersion_py(self):
        self.assertEqual(DEVICE_GetHWVersion_py(), 'V7')
    
    def test_DEVICE_GetInfo_py(self):
        info = DEVICE_GetInfo_py()
        self.assertIsInstance(info, dict)
        self.assertEqual(len(info), 6)
        self.assertEqual(len(info['serialNum']), 7)
        self.assertEqual(info['apiVersion'], b'3.11.0047.0')
        self.assertEqual(info['fwVersion'], b'V1.1')
        self.assertEqual(info['fpgaVersion'], b'V3.30')
        self.assertEqual(info['hwVersion'], b'V7')
    
    """CONFIG Command Testing"""
    
    def test_CONFIG_Preset_py(self):
        self.assertIsNone(CONFIG_Preset_py())
        self.assertEqual(CONFIG_GetCenterFreq_py(), 1.5e9)
        self.assertEqual(CONFIG_GetReferenceLevel_py(), 0)
        self.assertEqual(IQBLK_GetIQBandwidth_py(), 40e6)
    
    def test_CONFIG_ReferenceLevel(self):
        refLevel = 17
        self.assertIsNone(CONFIG_SetReferenceLevel_py(refLevel))
        self.assertEqual(CONFIG_GetReferenceLevel_py(), refLevel)
        self.assertRaises(TypeError, CONFIG_SetReferenceLevel_py, 'abc')
        self.assertRaises(RSAError, CONFIG_SetReferenceLevel_py, 31)
        self.assertRaises(RSAError, CONFIG_SetReferenceLevel_py, -131)
    
    def test_CONFIG_GetMaxCenterFreq_py_rsa507a(self):
        self.assertEqual(CONFIG_GetMaxCenterFreq_py(), 7.5e9)
    
    def test_CONFIG_GetMinCenterFreq_py(self):
        minCf = 9e3
        self.assertEqual(CONFIG_GetMinCenterFreq_py(), minCf)
    
    def test_CONFIG_CenterFreq(self):
        cf = 2.4453e9
        self.assertIsNone(CONFIG_SetCenterFreq_py(cf))
        self.assertEqual(CONFIG_GetCenterFreq_py(), cf)
        
        self.assertRaises(TypeError, CONFIG_SetCenterFreq_py, 'abc')
        # self.assertRaises(TypeError, CONFIG_SetCenterFreq_py, False)
        # RSA507A doesn't raise RSAError if cf is outside of allowable range
        # self.assertRaises(RSAError, CONFIG_SetCenterFreq_py, 400e9)
        # self.assertRaises(RSAError, CONFIG_SetCenterFreq_py, -40e6)
    
    def test_CONFIG_AutoAttenuation(self):
        atten = [False, True]
        for a in atten:
            self.assertIsNone(CONFIG_SetAutoAttenuationEnable_py(a))
            self.assertEqual(CONFIG_GetAutoAttenuationEnable_py(), a)
        self.assertRaises(TypeError, CONFIG_SetAutoAttenuationEnable_py, 'abc')
    
    def test_CONFIG_RFPreamp(self):
        preamp = [False, True]
        for p in preamp:
            self.assertIsNone(CONFIG_SetRFPreampEnable_py(p))
            self.assertEqual(CONFIG_GetRFPreampEnable_py(), p)
        self.assertRaises(TypeError, CONFIG_SetRFPreampEnable_py, 'abc')
    
    def test_CONFIG_RFAttenuator(self):
        atten = -20
        self.assertIsNone(CONFIG_SetRFAttenuator_py(atten))
        self.assertEqual(CONFIG_GetRFAttenuator_py(), atten)
        self.assertRaises(TypeError, CONFIG_SetRFAttenuator_py, 'abc')
    
    """TRIG Command Testing"""
    
    def test_TRIG_TriggerMode(self):
        mode = [TriggerMode.freeRun, TriggerMode.triggered]
        for m in mode:
            self.assertIsNone(TRIG_SetTriggerMode_py(m))
            self.assertEqual(TRIG_GetTriggerMode_py(), m)
    
    def test_TRIG_TriggerSource(self):
        source = [TriggerSource.TriggerSourceIFPowerLevel, TriggerSource.TriggerSourceExternal]
        for s in source:
            self.assertIsNone(TRIG_SetTriggerSource_py(s))
            self.assertEqual(TRIG_GetTriggerSource_py(), s)
    
    def test_TRIG_TriggerTransition(self):
        trans = [TriggerTransition.TriggerTransitionLH,
                 TriggerTransition.TriggerTransitionHL,
                 TriggerTransition.TriggerTransitionEither]
        for t in trans:
            self.assertIsNone(TRIG_SetTriggerTransition_py(t))
            self.assertEqual(TRIG_GetTriggerTransition_py(), t)
        
        self.assertRaises(TypeError, TRIG_SetTriggerTransition_py, 'abc')
    
    def test_TRIG_IFPowerTriggerLevel(self):
        trigLevel = -10
        self.assertIsNone(TRIG_SetIFPowerTriggerLevel_py(trigLevel))
        self.assertEqual(TRIG_GetIFPowerTriggerLevel_py(), trigLevel)
        self.assertRaises(TypeError, TRIG_SetIFPowerTriggerLevel_py, 'abc')
        self.assertRaises(RSAError, TRIG_SetIFPowerTriggerLevel_py, 31)
        self.assertRaises(RSAError, TRIG_SetIFPowerTriggerLevel_py, -131)
    
    def test_TRIG_TriggerPositionPercent(self):
        self.assertRaises(RSAError, TRIG_SetTriggerPositionPercent_py, 0.5)
        self.assertRaises(RSAError, TRIG_SetTriggerPositionPercent_py, 100)
        self.assertRaises(TypeError, TRIG_SetTriggerPositionPercent_py, 'abc')
        
        pos = 20
        self.assertIsNone(TRIG_SetTriggerPositionPercent_py(pos))
        self.assertEqual(TRIG_GetTriggerPositionPercent_py(), pos)
    
    def test_TRIG_ForceTrigger_py(self):
        self.assertIsNone(TRIG_ForceTrigger_py())
    
    """ALIGN Command Testing"""
    
    def test_ALIGN_GetWarmupStatus_py(self):
        self.assertIsInstance(ALIGN_GetWarmupStatus_py(), bool)
    
    def test_ALIGN_GetAlignmentNeeded_py(self):
        self.assertIsInstance(ALIGN_GetAlignmentNeeded_py(), bool)
    
    """DEVICE Global Command Testing"""
    
    def test_DEVICE_PrepareForRun_py(self):
        self.assertIsNone(DEVICE_PrepareForRun_py())
    
    def test_DEVICE_Run_py(self):
        self.assertIsNone(DEVICE_Run_py())
        self.assertTrue(DEVICE_GetEnable_py())
    
    def test_DEVICE_Stop_py(self):
        self.assertIsNone(DEVICE_Stop_py())
        self.assertFalse(DEVICE_GetEnable_py())
    
    def test_DEVICE_GetEventStatus_no_signal(self):
        eventType = [DEVEVENT_OVERRANGE, DEVEVENT_TRIGGER, DEVEVENT_1PPS]
        for e in eventType:
            event, timestamp = DEVICE_GetEventStatus_py(e)
            self.assertFalse(event)
            self.assertEqual(timestamp, 0)
    
    def test_DEVICE_GetEventStatus_trig_event(self):
        DEVICE_Run_py()
        TRIG_ForceTrigger_py()
        sleep(0.05)
        trig, trigTs = DEVICE_GetEventStatus_py(DEVEVENT_TRIGGER)
        self.assertTrue(trig)
        self.assertGreater(trigTs, 0)
    
    """REFTIME Command Testing"""
    
    def test_REFTIME_GetTimestampRate_py(self):
        self.assertEqual(REFTIME_GetTimestampRate_py(), 112000000)
    
    def test_REFTIME_TimeConversion(self):
        o_timeSec, o_timeNsec, o_timestamp = REFTIME_GetCurrentTime_py()
        test_timeSec, test_timeNsec = REFTIME_GetTimeFromTimestamp_py(
            o_timestamp)
        test_timestamp = REFTIME_GetTimestampFromTime_py(o_timeSec, o_timeNsec)
        REFTIME_SetReferenceTime_py(o_timeSec, o_timeNsec, o_timestamp)
        refTimeSec, refTimeNsec, refTimestamp = REFTIME_GetReferenceTime_py()
        
        self.assertEqual(o_timeSec, test_timeSec)
        self.assertEqual(o_timeNsec, test_timeNsec)
        self.assertEqual(o_timestamp, test_timestamp)
        self.assertEqual(o_timeSec, refTimeSec)
        self.assertEqual(o_timeNsec, refTimeNsec)
        self.assertEqual(o_timestamp, refTimestamp)
    
    """IQBLK Command Testing"""
    
    def test_IQBLK_MinMax(self):
        maxBw = IQBLK_GetMaxIQBandwidth_py()
        minBw = IQBLK_GetMinIQBandwidth_py()
        maxRl = IQBLK_GetMaxIQRecordLength_py()
        self.assertEqual(maxBw, 40e6)
        self.assertEqual(minBw, 100)
        self.assertEqual(maxRl, 112000000)
    
    def test_IQBLK_IQBandwidth(self):
        iqBw = 20e6
        self.assertIsNone(IQBLK_SetIQBandwidth_py(iqBw))
        self.assertEqual(iqBw, IQBLK_GetIQBandwidth_py())
        self.assertRaises(RSAError, IQBLK_SetIQBandwidth_py, neg)
        self.assertRaises(RSAError, IQBLK_SetIQBandwidth_py, 100e6)
        self.assertRaises(TypeError, IQBLK_SetIQBandwidth_py, 'abc')
    
    def test_IQBLK_IQRecordLength(self):
        iqRl = 8192
        self.assertIsNone(IQBLK_SetIQRecordLength_py(iqRl))
        self.assertEqual(iqRl, IQBLK_GetIQRecordLength_py())
        self.assertRaises(RSAError, IQBLK_SetIQRecordLength_py, neg)
        self.assertRaises(RSAError, IQBLK_SetIQRecordLength_py, 200e6)
        self.assertRaises(TypeError, IQBLK_SetIQRecordLength_py, 'abc')
    
    def test_IQBLK_GetIQData(self):
        rl = 1000
        i, q = IQBLK_Acquire_py(IQBLK_GetIQDataDeinterleaved_py,rl, 10)
        self.assertEqual(len(i), rl)
        self.assertEqual(len(q), rl)
        
        iq = IQBLK_Acquire_py(IQBLK_GetIQData_py, rl, 10)
        self.assertEqual(len(iq), rl * 2)
        
        self.assertRaises(ValueError, IQBLK_Acquire_py, recordLength=neg)
        self.assertRaises(RSAError, IQBLK_Acquire_py, recordLength=200000000)
        self.assertRaises(TypeError, IQBLK_Acquire_py, recordLength='abc')
    
    """SPECTRUM Command Testing"""
    
    def test_SPECTRUM_Enable(self):
        enable = [False, True]
        for e in enable:
            self.assertIsNone(SPECTRUM_SetEnable_py(e))
            self.assertEqual(SPECTRUM_GetEnable_py(), e)
    
    def test_SPECTRUM_Settings(self):
        self.assertIsNone(SPECTRUM_SetDefault_py())
        
        span = 20e6
        rbw = 100e3
        enableVBW = True
        vbw = 50e3
        traceLength = 1601
        window = SpectrumWindows.SpectrumWindow_Hann
        verticalUnit = SpectrumVerticalUnits.SpectrumVerticalUnit_dBm
        self.assertIsNone(SPECTRUM_SetSettings_py(span, rbw, enableVBW, vbw,
                                                  traceLength, window,
                                                  verticalUnit))
        settings = SPECTRUM_GetSettings_py()
        self.assertIsInstance(settings, dict)
        self.assertEqual(len(settings), 13)
        self.assertEqual(settings['span'], span)
        self.assertEqual(settings['rbw'], rbw)
        self.assertEqual(settings['enableVBW'], enableVBW)
        self.assertEqual(settings['vbw'], vbw)
        self.assertEqual(settings['window'], window)
        self.assertEqual(settings['traceLength'], traceLength)
        self.assertEqual(settings['verticalUnit'], verticalUnit)
        
        self.assertRaises(TypeError, SPECTRUM_SetSettings_py, 'span', 'rbw',
                          'enableVBW', 'vbw', 'traceLength',
                          'window', 'verticalUnit')
    
    def test_SPECTRUM_TraceType(self):
        trace = SpectrumTraces.SpectrumTrace2
        enable = True
        detector = SpectrumDetectors.SpectrumDetector_AverageVRMS
        self.assertIsNone(SPECTRUM_SetTraceType_py(trace, enable, detector))
        o_enable, o_detector = SPECTRUM_GetTraceType_py(trace)
        self.assertEqual(enable, o_enable)
        self.assertEqual(detector, o_detector)
        
        self.assertRaises(RSAError, SPECTRUM_SetTraceType_py, trace='abc')
        self.assertRaises(RSAError, SPECTRUM_SetTraceType_py, trace=40e5)
        self.assertRaises(RSAError, SPECTRUM_SetTraceType_py,
                          detector='abc')
        self.assertRaises(RSAError, SPECTRUM_SetTraceType_py, detector=40e5)
    
    def test_SPECTRUM_GetLimits_py(self):
        limits = SPECTRUM_GetLimits_py()
        self.assertIsInstance(limits, dict)
        self.assertEqual(len(limits), 8)
        self.assertEqual(limits['maxSpan'], 7.5e9)
        self.assertEqual(limits['minSpan'], 1e3)
        self.assertEqual(limits['maxRBW'], 10e6)
        self.assertEqual(limits['minRBW'], 10)
        self.assertEqual(limits['maxVBW'], 10e6)
        self.assertEqual(limits['minVBW'], 1)
        self.assertEqual(limits['maxTraceLength'], 64001)
        self.assertEqual(limits['minTraceLength'], 801)
    
    def test_SPECTRUM_Acquire_py(self):
        SPECTRUM_SetEnable_py(True)
        span = 20e6
        rbw = 100e3
        enableVBW = True
        vbw = 50e3
        traceLength = 1601
        window = SpectrumWindows.SpectrumWindow_Hann
        verticalUnit = SpectrumVerticalUnits.SpectrumVerticalUnit_dBm
        SPECTRUM_SetSettings_py(span, rbw, enableVBW, vbw, traceLength, window,
                                verticalUnit)
        spectrum = SPECTRUM_Acquire_py(trace=SpectrumTraces.SpectrumTrace1,
                                       tracePoints=traceLength)
        self.assertEqual(len(spectrum), traceLength)
        self.assertIsInstance(spectrum, np.ndarray)
        self.assertRaises(TypeError, SPECTRUM_Acquire_py, trace='abc')
        
        traceInfo = SPECTRUM_GetTraceInfo_py()
        self.assertIsInstance(traceInfo, dict)
        self.assertEqual(len(traceInfo), 2)
    
    """DPX Command Testing"""

    def test_DPX_Enable(self):
        self.assertIsNone(DPX_SetEnable_py(True))
        self.assertTrue(DPX_GetEnable_py())
        self.assertIsNone(DPX_SetEnable_py(False))
        self.assertFalse(DPX_GetEnable_py())

    def test_DPX_Reset_py(self):
        self.assertIsNone(DPX_Reset_py())
        frameCount, fftCount = DPX_GetFrameInfo_py()
        self.assertEqual(frameCount, 0)
        self.assertEqual(fftCount, 0)

    def test_DPX_Parameters(self):
        fspan = 20e6
        rbw = 100e3
        tracePtsPerPixel = 1
        yUnit = VerticalUnitType.VerticalUnit_dBm
        yTop = 10
        yBottom = -90
        infinitePersistence = False
        persistenceTimeSec = 2
        showOnlyTrigFrame = False
        self.assertIsNone(DPX_SetParameters_py(fspan, rbw, tracePtsPerPixel,
                                               yUnit, yTop, yBottom,
                                               infinitePersistence,
                                               persistenceTimeSec,
                                               showOnlyTrigFrame))
        

    def test_DPX_GetSettings_py(self):
        dpxSettings = DPX_GetSettings_py()
        self.assertIsInstance(dpxSettings, dict)
        self.assertEqual(len(dpxSettings), 7)

    def test_DPX_GetRBWRange_py(self):
        minRBW, maxRBW = DPX_GetRBWRange_py()
        self.assertAlmostEqual(minRBW, 1e3, delta=1)
        self.assertEqual(maxRBW, 5e6)

    def test_DPX_SogramParameters(self):
        timePerBitmapLine = 0.1
        timeResolution = 0.01
        maxPower = 0
        minPower = -100
        self.assertIsNone(DPX_SetSogramParameters_py(timePerBitmapLine,
                                                     timeResolution, maxPower,
                                                     minPower))
        traceType = TraceType.TraceTypeAverage
        self.assertIsNone(DPX_SetSogramTraceType_py(traceType))

    def test_DPX_AcquireFB(self):
        CONFIG_Preset_py()
        DPX_SetParameters_py()
        DPX_SetEnable_py(True)
        self.frameBuffer = DPX_AcquireFB_py()
        self.assertIsInstance(self.frameBuffer, DPX_FrameBuffer_py)

    def test_DPX_GetSogramSettings_py(self):
        sSettings = DPX_GetSogramSettings_py()
        self.assertIsInstance(sSettings, dict)
        self.assertEqual(len(sSettings), 4)
        self.assertEqual(sSettings['bitmapWidth'], 267)
        self.assertEqual(sSettings['bitmapHeight'], 500)

    def test_DPX_GetSogramHiResLineInfo(self):
        lineCount = DPX_GetSogramHiResLineCountLatest_py()
        self.assertIsInstance(lineCount, int)
        self.assertGreater(lineCount, 0)

        triggered = DPX_GetSogramHiResLineTriggered_py(0)
        self.assertFalse(triggered)

        timestamp = DPX_GetSogramHiResLineTimestamp_py(0)
        self.assertIsInstance(timestamp, float)

    def test_DPX_GetSogramHiResLine_py(self):
        vData = DPX_GetSogramHiResLine_py(0)
        self.assertIsInstance(vData, np.ndarray)
        self.assertEqual(len(vData), 267)

    """AUDIO Command Testing"""

    def test_AUDIO_Mode(self):
        for mode in range(6):
            self.assertIsNone(AUDIO_SetMode_py(mode))
            self.assertEqual(AUDIO_GetMode_py(), mode)

        self.assertRaises(TypeError, AUDIO_SetMode_py, 'abc')
        self.assertRaises(RSAError, AUDIO_SetMode_py, num)
        self.assertRaises(RSAError, AUDIO_SetMode_py, neg)

    def test_AUDIO_Volume(self):
        vol = 0.75
        self.assertIsNone(AUDIO_SetVolume_py(vol))
        self.assertEqual(AUDIO_GetVolume_py(), vol)
        self.assertRaises(TypeError, AUDIO_SetVolume_py, 'abc')
        self.assertRaises(RSAError, AUDIO_SetVolume_py, num)
        self.assertRaises(RSAError, AUDIO_SetVolume_py, neg)

    def test_AUDIO_Mute(self):
        mute = [False, True]
        for m in mute:
            self.assertIsNone(AUDIO_SetMute_py(m))
            self.assertEqual(AUDIO_GetMute_py(), m)
     
        self.assertRaises(TypeError, AUDIO_SetMute_py, 'abc')
        self.assertRaises(TypeError, AUDIO_SetMute_py, neg)
        self.assertRaises(TypeError, AUDIO_SetMute_py, num)
        self.assertRaises(TypeError, AUDIO_SetMute_py, 0)

    def test_AUDIO_FrequencyOffset(self):
        freq = 437e3
        self.assertIsNone(AUDIO_SetFrequencyOffset_py(freq))
        self.assertEqual(AUDIO_GetFrequencyOffset_py(), freq)

        self.assertRaises(RSAError, AUDIO_SetFrequencyOffset_py, 50e6)
        self.assertRaises(RSAError, AUDIO_SetFrequencyOffset_py, -50e6)
        self.assertRaises(TypeError, AUDIO_SetFrequencyOffset_py, 'abc')
        self.assertRaises(TypeError, AUDIO_SetFrequencyOffset_py, [num])

    """IFSTREAM Command Testing"""

    def test_IFSTREAM_SetOutputConfiguration_py(self):
        dest = [IFSOUTDEST.IFSOD_CLIENT, IFSOUTDEST.IFSOD_FILE_R3F,
                IFSOUTDEST.IFSOD_FILE_R3HA_DET, IFSOUTDEST.IFSOD_FILE_MIDAS,
                IFSOUTDEST.IFSOD_FILE_MIDAS_DET]
        for d in dest:
            self.assertIsNone(IFSTREAM_SetOutputConfiguration_py(d))
        
        self.assertRaises(TypeError, IFSTREAM_SetOutputConfiguration_py, 'abc')
        self.assertRaises(TypeError, IFSTREAM_SetOutputConfiguration_py, [num])
        self.assertRaises(RSAError, IFSTREAM_SetOutputConfiguration_py, num)

    def test_IFSTREAM_SetDiskFilePath_py(self):
        path = b'C:\\SignalVu-PC Files\\unittest\\'
        if not isdir(path):
            mkdir(path)

        self.assertRaises(TypeError, IFSTREAM_SetDiskFilePath_py, num)
        self.assertRaises(TypeError, IFSTREAM_SetDiskFilePath_py, [num])
        self.assertRaises(TypeError, IFSTREAM_SetDiskFilePath_py, 'abc')
        self.assertIsNone(IFSTREAM_SetDiskFilePath_py(path))

    def test_IFSTREAM_SetDiskFilenameBase_py(self):
        base = b'test'
        self.assertRaises(TypeError, IFSTREAM_SetDiskFilenameBase_py, num)
        self.assertRaises(TypeError, IFSTREAM_SetDiskFilenameBase_py, [num])
        self.assertRaises(TypeError, IFSTREAM_SetDiskFilenameBase_py, 'abc')
        self.assertIsNone(IFSTREAM_SetDiskFilenameBase_py(base))

    def test_IFSTREAM_SetDiskFilenameSuffix_py(self):
        suffix = [IFSSDFN_SUFFIX_INCRINDEX_MIN, IFSSDFN_SUFFIX_TIMESTAMP,
                  IFSSDFN_SUFFIX_NONE]
        for s in suffix:
            self.assertIsNone(IFSTREAM_SetDiskFilenameSuffix_py(s))
            
        self.assertRaises(RSAError, IFSTREAM_SetDiskFilenameSuffix_py, 'abc')
        self.assertRaises(RSAError, IFSTREAM_SetDiskFilenameSuffix_py, num)

    def test_IFSTREAM_SetDiskFileCount_py(self):
        count = 1
        self.assertRaises(TypeError, IFSTREAM_SetDiskFileCount_py, 'abc')
        self.assertRaises(TypeError, IFSTREAM_SetDiskFileCount_py, [num])
        self.assertIsNone(IFSTREAM_SetDiskFileCount_py(count))

    def test_IFSTREAM_GetAcqParameters_py(self):
        bwHz_act, srSps, cfAtIfHz = IFSTREAM_GetAcqParameters_py()
        self.assertEqual(bwHz_act, 40e6)
        self.assertEqual(srSps, 112e6)
        self.assertEqual(cfAtIfHz, 27995000.0)

    def test_IFSTREAM_GetScalingParameters_py(self):
        scaleFactor, scaleFreq = IFSTREAM_GetScalingParameters_py()
        self.assertAlmostEqual(scaleFactor, 2.9873573286159786e-05, delta=2e-6)
        self.assertEqual(scaleFreq, 28e6)

    def test_IFSTREAM_GetIFDataBufferSize_py(self):
        buffSize, numSamples = IFSTREAM_GetIFDataBufferSize_py()
        self.assertGreater(buffSize, 0)
        self.assertGreater(numSamples, 0)

    def test_IFSTREAM_Enable(self):
        IFSTREAM_SetOutputConfiguration_py(IFSOUTDEST.IFSOD_CLIENT)
        
        enable = [True, False]
        DEVICE_Run_py()
        for e in enable:
            self.assertIsNone(IFSTREAM_SetEnable_py(e))
            self.assertEqual(IFSTREAM_GetActiveStatus_py(), e)
        DEVICE_Stop_py()

    def test_IFSTREAM_GetIFData_py(self):
        # This needs more work
        DEVICE_Run_py()
        IFSTREAM_SetOutputConfiguration_py(IFSOUTDEST.IFSOD_CLIENT)
        IFSTREAM_SetEnable_py(True)
        data, dataLen, dataInfo = IFSTREAM_GetIFData_py()
        self.assertEqual(len(data), dataLen)
        self.assertIsInstance(dataInfo, dict)
        self.assertEqual(len(dataInfo), 4)
        IFSTREAM_SetEnable_py(False)
        DEVICE_Stop_py()

    """IQSTREAM Command Testing"""

    def test_IQSTREAM_MinMax(self):
        minBandwidthHz = IQSTREAM_GetMinAcqBandwidth_py()
        maxBandwidthHz = IQSTREAM_GetMaxAcqBandwidth_py()
        self.assertEqual(minBandwidthHz, 9765.625)
        self.assertEqual(maxBandwidthHz, 40e6)

    def test_IQSTREAM_AcqBandwidth(self):
        bwHz_req = [40e6, 20e6, 10e6, 5e6, 2.5e6, 1.25e6, 625e3, 312.5e3,
                    156.25e3, 78125, 39062.5, 19531.25, 9765.625]
        srSps_req = [56e6, 28e6, 14e6, 7e6, 3.5e6, 1.75e6, 875e3,
                     437.5e3, 218.75e3, 109.375e3, 54687.5, 27343.75,
                     13671.875]
        baseSize = [65536, 65536, 65536, 65536, 65536, 32768, 16384, 8192,
                    4096, 2048, 1024, 512, 256, 128]
        for b, s, r in zip(bwHz_req, srSps_req, baseSize):
            self.assertIsNone(IQSTREAM_SetAcqBandwidth_py(b))
            bwHz_act, srSps = IQSTREAM_GetAcqParameters_py()
            self.assertEqual(bwHz_act, b)
            self.assertEqual(srSps, s)
            self.assertIsNone(IQSTREAM_SetIQDataBufferSize_py(r))
            self.assertEqual(IQSTREAM_GetIQDataBufferSize_py(), r)

        self.assertRaises(TypeError, IQSTREAM_SetAcqBandwidth_py, 'abc')
        self.assertRaises(TypeError, IQSTREAM_SetAcqBandwidth_py, [num])
        self.assertRaises(RSAError, IQSTREAM_SetAcqBandwidth_py, 41e6)

    def test_IQSTREAM_SetOutputConfiguration_py(self):
        dest = [IQSOUTDEST.IQSOD_CLIENT, IQSOUTDEST.IQSOD_FILE_TIQ,
                IQSOUTDEST.IQSOD_FILE_SIQ, IQSOUTDEST.IQSOD_FILE_SIQ_SPLIT,
                IQSOUTDEST.IQSOD_FILE_MIDAS, IQSOUTDEST.IQSOD_FILE_MIDAS_DET]
        dtype = [IQSOUTDTYPE.IQSODT_SINGLE, IQSOUTDTYPE.IQSODT_INT32,
                 IQSOUTDTYPE.IQSODT_INT16,
                 IQSOUTDTYPE.IQSODT_SINGLE_SCALE_INT32]

        for d in dest:
            for t in dtype:
                if d is IQSOUTDEST.IQSOD_FILE_TIQ and t in [IQSOUTDTYPE.IQSODT_SINGLE,
                    IQSOUTDTYPE.IQSODT_SINGLE_SCALE_INT32]:
                    self.assertRaises(RSAError,
                                      IQSTREAM_SetOutputConfiguration_py, d, t)
                else:
                    self.assertIsNone(IQSTREAM_SetOutputConfiguration_py(d, t))

        self.assertRaises(TypeError, IQSTREAM_SetOutputConfiguration_py,
                          'abc', dtype[0])
        self.assertRaises(TypeError, IQSTREAM_SetOutputConfiguration_py,
                          dest[0], 'abc')

    def test_IQSTREAM_SetDiskFilenameBase_py(self):
        path = b'C:\\SignalVu-PC Files\\unittest\\'
        if not isdir(path):
            mkdir(path)
        filename = b'iqstream_test'
        filenameBase = path + filename
        self.assertIsNone(IQSTREAM_SetDiskFilenameBase_py(filenameBase))
        
        self.assertRaises(TypeError, IQSTREAM_SetDiskFilenameBase_py, num)
        self.assertRaises(TypeError, IQSTREAM_SetDiskFilenameBase_py, 'abc')
        self.assertRaises(TypeError, IQSTREAM_SetDiskFilenameBase_py, [num])
        
    def test_IQSTREAM_SetDiskFilenameSuffix_py(self):
        suffixCtl = [IQSSDFN_SUFFIX_INCRINDEX_MIN, IQSSDFN_SUFFIX_TIMESTAMP,
                     IQSSDFN_SUFFIX_NONE]
        for s in suffixCtl:
            self.assertIsNone(IQSTREAM_SetDiskFilenameSuffix_py(s))

        self.assertRaises(RSAError, IQSTREAM_SetDiskFilenameSuffix_py, 'abc')
        self.assertRaises(RSAError, IQSTREAM_SetDiskFilenameSuffix_py, num)
        self.assertRaises(RSAError, IQSTREAM_SetDiskFilenameSuffix_py, neg)

    def test_IQSTREAM_SetDiskFileLength_py(self):
        length = 100
        self.assertIsNone(IQSTREAM_SetDiskFileLength_py(length))
        self.assertRaises(TypeError, IQSTREAM_SetDiskFileLength_py, 'abc')
        self.assertRaises(RSAError, IQSTREAM_SetDiskFileLength_py, neg)

    def test_IQSTREAM_Operation(self):
        IQSTREAM_SetAcqBandwidth_py(5e6)
        IQSTREAM_SetOutputConfiguration_py(IQSOUTDEST.IQSOD_CLIENT,
                                           IQSOUTDTYPE.IQSODT_INT16)
        IQSTREAM_GetAcqParameters_py()
        DEVICE_Run_py()

        self.assertIsNone(IQSTREAM_Start_py())
        self.assertTrue(IQSTREAM_GetEnable_py())

        self.assertIsNone(IQSTREAM_Stop_py())
        self.assertFalse(IQSTREAM_GetEnable_py())

        DEVICE_Stop_py()

    def test_IQSTREAM_ClearAcqStatus_py(self):
        self.assertIsNone(IQSTREAM_ClearAcqStatus_py())

    """GNSS Command Testing"""

    def test_GNSS_GetHwInstalled_py(self):
        self.assertTrue(GNSS_GetHwInstalled_py())

    def test_GNSS_Enable(self):
        enable = [False, True]
        for e in enable:
            self.assertIsNone(GNSS_SetEnable_py(e))
            self.assertEqual(GNSS_GetEnable_py(), e)

    def test_GNSS_SatSystem(self):
        self.assertRaises(RSAError, GNSS_SetSatSystem_py, 'abc')
        self.assertRaises(RSAError, GNSS_SetSatSystem_py, num)
        self.assertRaises(RSAError, GNSS_SetSatSystem_py, [num])

        satSystem = [GNSS_SATSYS.GNSS_NOSYS, GNSS_SATSYS.GNSS_GPS_GLONASS,
                     GNSS_SATSYS.GNSS_GPS, GNSS_SATSYS.GNSS_GLONASS,
                     GNSS_SATSYS.GNSS_BEIDOU, GNSS_SATSYS.GNSS_GPS_BEIDOU]
        for s in satSystem:
            self.assertIsNone(GNSS_SetSatSystem_py(s))
            self.assertEqual(GNSS_GetSatSystem_py(), s)

    def test_GNSS_AntennaPower(self):
        powered = [False, True]
        for p in powered:
            self.assertIsNone(GNSS_SetAntennaPower_py(p))
            self.assertEqual(GNSS_GetAntennaPower_py(), p)

    def test_GNSS_GetStatusRxLock_py(self):
        self.assertIsInstance(GNSS_GetStatusRxLock_py(), bool)

    def test_GNSS_ClearNavMessageData_py(self):
        self.assertIsNone(GNSS_ClearNavMessageData_py())

    """POWER Command Testing"""

    def test_POWER_GetStatus_py(self):
        powerInfo = POWER_GetStatus_py()
        self.assertIsInstance(powerInfo, dict)
        self.assertEqual(len(powerInfo), 6)


if __name__ == '__main__':
    """There must be a connected RSA in order to correctly test these params"""
    DEVICE_Connect_py(0)
    
    nameList = ['RSA503A', 'RSA507A', 'RSA603A', 'RSA607A']
    if DEVICE_GetNomenclature_py() not in nameList:
        raise Exception('Incorrect RSA model, please connect RSA503A, RSA507A, RSA603A, or RSA607A')
    
    num = 400
    neg = -400
    unittest.main()
    
    DEVICE_Stop_py()
    DEVICE_Disconnect_py()

