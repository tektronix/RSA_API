"""
Tektronix RSA_API Cython Unit Test for RSA306B
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

"""IMPORTANT: PLEASE READ"""
"""An external 10 MHz reference signal, a Trimble GPS+Beidou antenna
(P/N 100229-52 A), and a -5 dBm pulsed CW signal centered at 1 GHz
with a pulse width of 100 us and PRI of 1 ms is required for this test."""

import unittest
from time import sleep
from rsa_api import *
import numpy as np


class rsa_api_test(unittest.TestCase):
    """Test for rsa_api.pyd"""
    
    """DEVICE Command Testing"""
    
    # @unittest.skip('Debugging')
    def test_DEVICE_Connect(self):
        self.assertRaises(RSAError, DEVICE_Connect_py, num)
        self.assertRaises(RSAError, DEVICE_Connect_py, neg)
        self.assertRaises(TypeError, DEVICE_Connect_py, 'abc')
        self.assertRaises(TypeError, DEVICE_Connect_py, [num])
        
        for dev in range(1, DEVSRCH_MAX_NUM_DEVICES):
            self.assertRaises(RSAError, DEVICE_Connect_py, dev)
        
        self.assertIsNone(DEVICE_Connect_py(0))

    # @unittest.skip('Debugging')
    def test_DEVICE_GetEventStatus_overrange(self):
        DEVICE_Connect_py(0)
        CONFIG_Preset_py()
        CONFIG_SetCenterFreq_py(1e9)
        # self.assertFalse(True)
        CONFIG_SetReferenceLevel_py(-17)
        IQBLK_Acquire_py()
        overrange, overrangeTs = DEVICE_GetEventStatus_py(DEVEVENT_OVERRANGE)
        self.assertTrue(overrange)
        self.assertGreater(overrangeTs, 0)
        CONFIG_SetReferenceLevel_py(0)
        DEVICE_Stop_py()

    # @unittest.skip('Debugging')
    def test_DEVICE_GetEventStatus_trigger(self):
        DEVICE_Connect_py(0)
        CONFIG_Preset_py()
        CONFIG_SetCenterFreq_py(1e9)
        TRIG_SetTriggerMode_py(TriggerMode.triggered)
        TRIG_SetTriggerSource_py(TriggerSource.TriggerSourceIFPowerLevel)
        TRIG_SetIFPowerTriggerLevel_py(-15)
        IQBLK_Acquire_py()
        trig, trigTs = DEVICE_GetEventStatus_py(DEVEVENT_TRIGGER)
        self.assertTrue(trig)
        self.assertGreater(trigTs, 0)
        DEVICE_Stop_py()

    # @unittest.skip('Debugging')
    def test_DEVICE_GetEventStatus_1pps(self):
        DEVICE_Connect_py(0)
        CONFIG_Preset_py()
        
        DEVICE_Run_py()
        GNSS_SetEnable_py(True)
        GNSS_SetAntennaPower_py(True)
        GNSS_SetSatSystem_py(GNSS_SATSYS.GNSS_GPS_BEIDOU)

        while not GNSS_GetStatusRxLock_py():
            pass
        pps, ppsTs = DEVICE_GetEventStatus_py(DEVEVENT_1PPS)
        while not pps:
            pps, ppsTs = DEVICE_GetEventStatus_py(DEVEVENT_1PPS)
        self.assertTrue(pps)
        self.assertGreater(ppsTs, 0)
        
        DEVICE_Stop_py()
        
    
    """CONFIG Command Testing"""

    # @unittest.skip('Debugging')
    def test_CONFIG_FrequencyReferenceSource(self):
        DEVICE_Connect_py(0)
        src = [FREQREF_SOURCE.FRS_INTERNAL, FREQREF_SOURCE.FRS_EXTREF,
               FREQREF_SOURCE.FRS_GNSS]
        self.assertRaises(RSAError, CONFIG_SetFrequencyReferenceSource_py, neg)
        self.assertRaises(RSAError, CONFIG_SetFrequencyReferenceSource_py, num)
        self.assertRaises(TypeError, CONFIG_SetFrequencyReferenceSource_py, 'abc')
        self.assertRaises(TypeError, CONFIG_SetFrequencyReferenceSource_py, [num])
        
        for s in src:
            self.assertIsNone(CONFIG_SetFrequencyReferenceSource_py(s))
            self.assertEqual(CONFIG_GetFrequencyReferenceSource_py(), s)
            if s == FREQREF_SOURCE.FRS_EXTREF:
                self.assertEqual(CONFIG_GetExternalRefFrequency_py(), 10e6)

    """PLAYBACK Command Testing"""
    
    # @unittest.skip('Debugging')
    def test_PLAYBACK(self):
        fileName = 'C:\\SignalVu-PC Files\\unittest\\unittest.r3f'
        startPercentage = 0
        stopPercentage = 100
        skipTime = 0
        loopAtEndOfFile = False
        emulateRealTime = True
        
        self.assertRaises(RSAError, PLAYBACK_OpenDiskFile_py,
                          'C:\\notarealdirectory\\notarealfile.r3f',
                          startPercentage, stopPercentage, skipTime,
                          loopAtEndOfFile, emulateRealTime)
        self.assertRaises(RSAError, PLAYBACK_OpenDiskFile_py, fileName, neg,
                          stopPercentage, skipTime, loopAtEndOfFile,
                          emulateRealTime)
        self.assertRaises(RSAError, PLAYBACK_OpenDiskFile_py, fileName,
                          startPercentage, num, skipTime, loopAtEndOfFile,
                          emulateRealTime)
        self.assertRaises(RSAError, PLAYBACK_OpenDiskFile_py, fileName,
                          startPercentage, stopPercentage, neg,
                          loopAtEndOfFile, emulateRealTime)
        self.assertRaises(TypeError, PLAYBACK_OpenDiskFile_py, fileName,
                          startPercentage, stopPercentage, skipTime, 'abc',
                          emulateRealTime)
        self.assertRaises(TypeError, PLAYBACK_OpenDiskFile_py, fileName,
                          startPercentage, stopPercentage, skipTime,
                          loopAtEndOfFile, 'abc')
        
        DEVICE_Disconnect_py()
        self.assertIsNone(
            PLAYBACK_OpenDiskFile_py(fileName, startPercentage, stopPercentage,
                                     skipTime, loopAtEndOfFile, emulateRealTime))
        
        DEVICE_Run_py()
        
        self.assertIsInstance(PLAYBACK_GetReplayComplete_py(), bool)
        while not PLAYBACK_GetReplayComplete_py():
            pass
        self.assertTrue(PLAYBACK_GetReplayComplete_py())
        
        DEVICE_Stop_py()
        DEVICE_Disconnect_py()
    
    """GNSS Command Testing"""
    
    # @unittest.skip('Debugging')
    def test_GNSS_GetNavMessageData(self):
        DEVICE_Connect_py(0)
        
        GNSS_SetEnable_py(True)
        GNSS_SetAntennaPower_py(True)
        GNSS_SetSatSystem_py(GNSS_SATSYS.GNSS_GPS_BEIDOU)
        
        while not GNSS_GetStatusRxLock_py():
            pass
        message = b''
        while not message:
            message, msgLen = GNSS_GetNavMessageData_py()
            self.assertEqual(len(message), msgLen)

        isValid = False
        while not isValid:
            timestamp1PPS, isValid = GNSS_Get1PPSTimestamp_py()
        self.assertGreater(timestamp1PPS, 0)
        self.assertTrue(isValid)

    """AUDIO Command Testing"""

    # def test_AUDIO_Capture(self):
    #     """Commented out because of test length"""
    #     self.assertTrue(False)
    #     DEVICE_Run_py()
    #     AUDIO_SetMode_py(3)
    #     self.assertIsNone(AUDIO_Start_py())
    #     self.assertTrue(AUDIO_GetEnable_py())
    #     inSize = 1000
    #     data = AUDIO_GetData_py(inSize)
    #     self.assertIsInstance(data, np.ndarray)
    #     self.assertEqual(len(data), inSize)
    #     self.assertIsNone(AUDIO_Stop_py())
    #     # plt.plot(data)
    #     # plt.show()

    """ALIGN Command Testing"""

    # @unittest.skip('Debugging')
    def test_ALIGN_RunAlignment_py(self):
        DEVICE_Connect_py(0)
        self.assertIsNone(ALIGN_RunAlignment_py())

    """REFTIME Command Testing"""

    # @unittest.skip('Debugging')
    def test_REFTIME_GetIntervalSinceRefTimeSet_py(self):
        DEVICE_Connect_py(0)
        refTimeSec, refTimeNsec, refTimestamp = REFTIME_GetCurrentTime_py()
        REFTIME_SetReferenceTime_py(refTimeSec, refTimeNsec, refTimestamp)
        waitTime = 1
        sleep(waitTime)
        self.assertEqual(REFTIME_GetIntervalSinceRefTimeSet_py(), waitTime)

    """IFSTREAM Command Testing"""

    # @unittest.skip('Debugging')
    def test_IFSTREAM_Client(self):
        """Data verification"""
        DEVICE_Connect_py(0)
        CONFIG_SetCenterFreq_py(1e9)
        CONFIG_SetReferenceLevel_py(0)
        IQSTREAM_SetAcqBandwidth_py(2.5e6)
        TRIG_SetTriggerMode_py(TriggerMode.triggered)
        TRIG_SetTriggerSource_py(TriggerSource.TriggerSourceIFPowerLevel)
        TRIG_SetIFPowerTriggerLevel_py(-15)
    
        IFSTREAM_SetOutputConfiguration_py(IFSOUTDEST.IFSOD_CLIENT)
        bwHz_act, srSps, cfAtIfHz = IFSTREAM_GetAcqParameters_py()
        buffer, numSamples = IFSTREAM_GetIFDataBufferSize_py()
        scaleFactor, scaleFreq = IFSTREAM_GetScalingParameters_py()
    
        DEVICE_Run_py()
        IFSTREAM_SetEnable_py(True)
    
        data, dataLen, dataInfo = IFSTREAM_GetIFData_py()
    
        self.assertIsInstance(data, np.ndarray)
        self.assertIsInstance(dataInfo, dict)
        self.assertEqual(len(dataInfo), 4)
        self.assertEqual(len(data), numSamples)
        self.assertEqual(len(data), dataLen)
    
        self.assertAlmostEqual(dataInfo['triggerCount'], 12, delta=2)
        trigDelta = (dataInfo['triggerIndices'][1] - dataInfo['triggerIndices'][0]) / srSps
        self.assertAlmostEqual(trigDelta, 100e-6, delta=1e-6)
    
        IFSTREAM_SetEnable_py(False)
        DEVICE_Stop_py()
    
        # 10 samples in from the trigger
        ind = dataInfo['triggerIndices'][0] + 10
        measWidth = int(5e-6 * srSps)
        data = data * scaleFactor
    
        # power in dBm
        # 10log(Vrms^2/(R*1mW)
        power = 10 * np.log10((np.amax(data)*0.707)**2/(50 * 1e-3))
        # delta = combined amplitude accuracy specs for RSA and TSG
        self.assertAlmostEqual(power, -5, delta=1.2)
        
        
        if debug:
            print(power)
            plt.plot(data)
            plt.axvline(ind)
            plt.show()

    """IQSTREAM Command Testing"""
    
    @unittest.skip('Debugging')
    def test_IQSTREAM_Client(self):
        """Data verification"""
        DEVICE_Connect_py(0)
        CONFIG_SetCenterFreq_py(1e9)
        CONFIG_SetReferenceLevel_py(0)
        IQSTREAM_SetAcqBandwidth_py(40e6)
        TRIG_SetTriggerMode_py(TriggerMode.triggered)
        TRIG_SetTriggerSource_py(TriggerSource.TriggerSourceIFPowerLevel)
        TRIG_SetIFPowerTriggerLevel_py(-15)
        dType = [IQSOUTDTYPE.IQSODT_SINGLE, IQSOUTDTYPE.IQSODT_INT32,
                     IQSOUTDTYPE.IQSODT_INT16, IQSOUTDTYPE.IQSODT_SINGLE_SCALE_INT32]
        
        for d in dType:
            IQSTREAM_SetOutputConfiguration_py(IQSOUTDEST.IQSOD_CLIENT, d)
            bwHz_act, srSps = IQSTREAM_GetAcqParameters_py()
            buffer = IQSTREAM_GetIQDataBufferSize_py()
            
            DEVICE_Run_py()
            IQSTREAM_Start_py()
            
            while not IQSTREAM_WaitForIQDataReady_py():
                pass
            self.assertRaises(RSAError, IQSTREAM_GetIQData_py, buffer, num)
            self.assertRaises(RSAError, IQSTREAM_GetIQData_py, buffer, neg)
            self.assertRaises(RSAError, IQSTREAM_GetIQData_py, buffer, 'abc')
            self.assertRaises(RSAError, IQSTREAM_GetIQData_py, buffer, [num])
            
            iq, iqInfo = IQSTREAM_GetIQData_py(buffer, d)
            
            self.assertIsInstance(iq, np.ndarray)
            self.assertIsInstance(iqInfo, dict)
            self.assertEqual(len(iqInfo), 5)
            self.assertEqual(len(iq), buffer*2)
            
            trigDelta = (iqInfo['triggerIndices'][1]-iqInfo['triggerIndices'][0])/srSps
            self.assertEqual(trigDelta, 100e-6)
            
            IQSTREAM_Stop_py()
            DEVICE_Stop_py()
            
            # 10 samples in from the trigger
            ind = iqInfo['triggerIndices'][0] + 10
            iq = iq * iqInfo['scaleFactor']
            i = iq[0:-1:2]
            q = iq[1:-1:2]
            
            # power in dBm
            # 10log(Vpk^2/(2*R*1mW)
            power = 10*np.log10((i[ind]**2 + q[ind]**2)/(2*50*1e-3))
            # delta = combined amplitude accuracy specs for RSA and TSG
            self.assertAlmostEqual(power, -5, delta=2)
            
            if debug:
                plt.subplot(211)
                plt.plot(i)
                plt.axvline(ind)
                plt.subplot(212)
                plt.plot(q)
                plt.axvline(ind)
                plt.show()

if __name__ == '__main__':
    debug = True
    
    if debug:
        import matplotlib.pyplot as plt
    
    num = 400
    neg = -400
    unittest.main()
