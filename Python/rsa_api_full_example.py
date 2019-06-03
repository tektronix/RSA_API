"""
Tektronix RSA_API Example
Author: Morgan Allison
Date created: 6/15
Date edited: 9/17
Windows 7 64-bit
RSA API version 3.11.0047
Python 3.6.1 64-bit (Anaconda 4.4.0)
NumPy 1.13.1, MatPlotLib 2.0.2
Download Anaconda: http://continuum.io/downloads
Anaconda includes NumPy and MatPlotLib
Download the RSA_API: http://www.tek.com/model/rsa306-software
Download the RSA_API Documentation:
http://www.tek.com/spectrum-analyzer/rsa306-manual-6

YOU WILL NEED TO REFERENCE THE API DOCUMENTATION
"""

from ctypes import *
from os import chdir
from time import sleep
import numpy as np
import matplotlib.pyplot as plt
from RSA_API import *

from matplotlib import __version__ as __mversion__
print('Matplotlib Version:', __mversion__)
print('Numpy Version:', np.__version__)


# C:\Tektronix\RSA_API\lib\x64 needs to be added to the
# PATH system environment variable
chdir("C:\\Tektronix\\RSA_API\\lib\\x64")
rsa = cdll.LoadLibrary("RSA_API.dll")


"""################CLASSES AND FUNCTIONS################"""
def err_check(rs):
    if ReturnStatus(rs) != ReturnStatus.noError:
        raise RSAError(ReturnStatus(rs).name)

def search_connect():
    numFound = c_int(0)
    intArray = c_int * DEVSRCH_MAX_NUM_DEVICES
    deviceIDs = intArray()
    deviceSerial = create_string_buffer(DEVSRCH_SERIAL_MAX_STRLEN)
    deviceType = create_string_buffer(DEVSRCH_TYPE_MAX_STRLEN)
    apiVersion = create_string_buffer(DEVINFO_MAX_STRLEN)

    rsa.DEVICE_GetAPIVersion(apiVersion)
    print('API Version {}'.format(apiVersion.value.decode()))

    err_check(rsa.DEVICE_Search(byref(numFound), deviceIDs,
                                deviceSerial, deviceType))

    if numFound.value < 1:
        # rsa.DEVICE_Reset(c_int(0))
        print('No instruments found. Exiting script.')
        exit()
    elif numFound.value == 1:
        print('One device found.')
        print('Device type: {}'.format(deviceType.value.decode()))
        print('Device serial number: {}'.format(deviceSerial.value.decode()))
        err_check(rsa.DEVICE_Connect(deviceIDs[0]))
    else:
        # corner case
        print('2 or more instruments found. Enumerating instruments, please wait.')
        for inst in deviceIDs:
            rsa.DEVICE_Connect(inst)
            rsa.DEVICE_GetSerialNumber(deviceSerial)
            rsa.DEVICE_GetNomenclature(deviceType)
            print('Device {}'.format(inst))
            print('Device Type: {}'.format(deviceType.value))
            print('Device serial number: {}'.format(deviceSerial.value))
            rsa.DEVICE_Disconnect()
        # note: the API can only currently access one at a time
        selection = 1024
        while (selection > numFound.value - 1) or (selection < 0):
            selection = int(raw_input('Select device between 0 and {}\n> '.format(numFound.value - 1)))
        err_check(rsa.DEVICE_Connect(deviceIDs[selection]))
    rsa.CONFIG_Preset()


"""################SPECTRUM EXAMPLE################"""
def config_spectrum(cf=1e9, refLevel=0, span=40e6, rbw=300e3):
    rsa.SPECTRUM_SetEnable(c_bool(True))
    rsa.CONFIG_SetCenterFreq(c_double(cf))
    rsa.CONFIG_SetReferenceLevel(c_double(refLevel))

    rsa.SPECTRUM_SetDefault()
    specSet = Spectrum_Settings()
    rsa.SPECTRUM_GetSettings(byref(specSet))
    specSet.window = SpectrumWindows.SpectrumWindow_Kaiser
    specSet.verticalUnit = SpectrumVerticalUnits.SpectrumVerticalUnit_dBm
    specSet.span = span
    specSet.rbw = rbw
    rsa.SPECTRUM_SetSettings(specSet)
    rsa.SPECTRUM_GetSettings(byref(specSet))
    return specSet


def create_frequency_array(specSet):
    # Create array of frequency data for plotting the spectrum.
    freq = np.arange(specSet.actualStartFreq, specSet.actualStartFreq
                     + specSet.actualFreqStepSize * specSet.traceLength,
                     specSet.actualFreqStepSize)
    return freq


def acquire_spectrum(specSet):
    ready = c_bool(False)
    traceArray = c_float * specSet.traceLength
    traceData = traceArray()
    outTracePoints = c_int(0)
    traceSelector = SpectrumTraces.SpectrumTrace1

    rsa.DEVICE_Run()
    rsa.SPECTRUM_AcquireTrace()
    while not ready.value:
        rsa.SPECTRUM_WaitForDataReady(c_int(100), byref(ready))
    rsa.SPECTRUM_GetTrace(traceSelector, specSet.traceLength, byref(traceData),
                          byref(outTracePoints))
    rsa.DEVICE_Stop()
    return np.array(traceData)


def spectrum_example():
    print('\n\n########Spectrum Example########')
    search_connect()
    cf = 2.4453e9
    refLevel = -30
    span = 40e6
    rbw = 10e3
    specSet = config_spectrum(cf, refLevel, span, rbw)
    trace = acquire_spectrum(specSet)
    freq = create_frequency_array(specSet)
    peakPower, peakFreq = peak_power_detector(freq, trace)

    plt.figure(1, figsize=(15, 10))
    ax = plt.subplot(111, facecolor='k')
    ax.plot(freq, trace, color='y')
    ax.set_title('Spectrum Trace')
    ax.set_xlabel('Frequency (Hz)')
    ax.set_ylabel('Amplitude (dBm)')
    ax.axvline(peakFreq)
    ax.text((freq[0] + specSet.span / 20), peakPower,
            'Peak power in spectrum: {:.2f} dBm @ {} MHz'.format(
                peakPower, peakFreq / 1e6), color='white')
    ax.set_xlim([freq[0], freq[-1]])
    ax.set_ylim([refLevel - 100, refLevel])
    plt.tight_layout()
    plt.show()
    rsa.DEVICE_Disconnect()


"""################BLOCK IQ EXAMPLE################"""
def config_block_iq(cf=1e9, refLevel=0, iqBw=40e6, recordLength=10e3):
    recordLength = int(recordLength)
    rsa.CONFIG_SetCenterFreq(c_double(cf))
    rsa.CONFIG_SetReferenceLevel(c_double(refLevel))

    rsa.IQBLK_SetIQBandwidth(c_double(iqBw))
    rsa.IQBLK_SetIQRecordLength(c_int(recordLength))

    iqSampleRate = c_double(0)
    rsa.IQBLK_GetIQSampleRate(byref(iqSampleRate))
    # Create array of time data for plotting IQ vs time
    time = np.linspace(0, recordLength / iqSampleRate.value, recordLength)
    time1 = []
    step = recordLength / iqSampleRate.value / (recordLength - 1)
    for i in range(recordLength):
        time1.append(i * step)
    return time


def acquire_block_iq(recordLength=10e3):
    recordLength = int(recordLength)
    ready = c_bool(False)
    iqArray = c_float * recordLength
    iData = iqArray()
    qData = iqArray()
    outLength = 0
    rsa.DEVICE_Run()
    rsa.IQBLK_AcquireIQData()
    while not ready.value:
        rsa.IQBLK_WaitForIQDataReady(c_int(100), byref(ready))
    rsa.IQBLK_GetIQDataDeinterleaved(byref(iData), byref(qData),
                                     byref(c_int(outLength)), c_int(recordLength))
    rsa.DEVICE_Stop()

    return np.array(iData) + 1j * np.array(qData)


def block_iq_example():
    print('\n\n########Block IQ Example########')
    search_connect()
    cf = 1e9
    refLevel = 0
    iqBw = 40e6
    recordLength = 1e3

    time = config_block_iq(cf, refLevel, iqBw, recordLength)
    IQ = acquire_block_iq(recordLength)

    fig = plt.figure(1, figsize=(15, 10))
    fig.suptitle('I and Q vs Time', fontsize='20')
    ax1 = plt.subplot(211, facecolor='k')
    ax1.plot(time * 1000, np.real(IQ), color='y')
    ax1.set_ylabel('I (V)')
    ax1.set_xlim([time[0] * 1e3, time[-1] * 1e3])
    ax2 = plt.subplot(212, facecolor='k')
    ax2.plot(time * 1000, np.imag(IQ), color='c')
    ax2.set_ylabel('I (V)')
    ax2.set_xlabel('Time (msec)')
    ax2.set_xlim([time[0] * 1e3, time[-1] * 1e3])
    plt.tight_layout()
    plt.show()
    rsa.DEVICE_Disconnect()


"""################DPX EXAMPLE################"""
def config_DPX(cf=1e9, refLevel=0, span=40e6, rbw=300e3):
    yTop = refLevel
    yBottom = yTop - 100
    yUnit = VerticalUnitType.VerticalUnit_dBm

    dpxSet = DPX_SettingStruct()
    rsa.CONFIG_SetCenterFreq(c_double(cf))
    rsa.CONFIG_SetReferenceLevel(c_double(refLevel))

    rsa.DPX_SetEnable(c_bool(True))
    rsa.DPX_SetParameters(c_double(span), c_double(rbw), c_int(801), c_int(1),
                          yUnit, c_double(yTop), c_double(yBottom), c_bool(False),
                          c_double(1.0), c_bool(False))
    rsa.DPX_SetSogramParameters(c_double(1e-3), c_double(1e-3),
                                c_double(refLevel), c_double(refLevel - 100))
    rsa.DPX_Configure(c_bool(True), c_bool(True))

    rsa.DPX_SetSpectrumTraceType(c_int32(0), c_int(2))
    rsa.DPX_SetSpectrumTraceType(c_int32(1), c_int(4))
    rsa.DPX_SetSpectrumTraceType(c_int32(2), c_int(0))

    rsa.DPX_GetSettings(byref(dpxSet))
    dpxFreq = np.linspace((cf - span / 2), (cf + span / 2), dpxSet.bitmapWidth)
    dpxAmp = np.linspace(yBottom, yTop, dpxSet.bitmapHeight)
    return dpxFreq, dpxAmp


def acquire_dpx_frame():
    frameAvailable = c_bool(False)
    ready = c_bool(False)
    fb = DPX_FrameBuffer()

    rsa.DEVICE_Run()
    rsa.DPX_Reset()

    while not frameAvailable.value:
        rsa.DPX_IsFrameBufferAvailable(byref(frameAvailable))
        while not ready.value:
            rsa.DPX_WaitForDataReady(c_int(100), byref(ready))
    rsa.DPX_GetFrameBuffer(byref(fb))
    rsa.DPX_FinishFrameBuffer()
    rsa.DEVICE_Stop()
    return fb


def extract_dpx_spectrum(fb):
    # When converting a ctypes pointer to a numpy array, we need to
    # explicitly specify its length to dereference it correctly
    dpxBitmap = np.array(fb.spectrumBitmap[:fb.spectrumBitmapSize])
    dpxBitmap = dpxBitmap.reshape((fb.spectrumBitmapHeight,
                                   fb.spectrumBitmapWidth))

    # Grab trace data and convert from W to dBm
    # http://www.rapidtables.com/convert/power/Watt_to_dBm.htm
    # Note: fb.spectrumTraces is a pointer to a pointer, so we need to
    # go through an additional dereferencing step
    traces = []
    for i in range(3):
        traces.append(10 * np.log10(1000 * np.array(
            fb.spectrumTraces[i][:fb.spectrumTraceLength])) + 30)
    # specTrace2 = 10 * np.log10(1000*np.array(
    #     fb.spectrumTraces[1][:fb.spectrumTraceLength])) + 30
    # specTrace3 = 10 * np.log10(1000*np.array(
    #     fb.spectrumTraces[2][:fb.spectrumTraceLength])) + 30

    # return dpxBitmap, specTrace1, specTrace2, specTrace3
    return dpxBitmap, traces


def extract_dpxogram(fb):
    # When converting a ctypes pointer to a numpy array, we need to
    # explicitly specify its length to dereference it correctly
    dpxogram = np.array(fb.sogramBitmap[:fb.sogramBitmapSize])
    dpxogram = dpxogram.reshape((fb.sogramBitmapHeight,
                                 fb.sogramBitmapWidth))
    dpxogram = dpxogram[:fb.sogramBitmapNumValidLines, :]

    return dpxogram


def dpx_example():
    print('\n\n########DPX Example########')
    search_connect()
    cf = 2.4453e9
    refLevel = -30
    span = 40e6
    rbw = 100e3

    dpxFreq, dpxAmp = config_DPX(cf, refLevel, span, rbw)
    fb = acquire_dpx_frame()

    dpxBitmap, traces = extract_dpx_spectrum(fb)
    dpxogram = extract_dpxogram(fb)
    numTicks = 11
    plotFreq = np.linspace(cf - span / 2.0, cf + span / 2.0, numTicks) / 1e9

    """################PLOT################"""
    # Plot out the three DPX spectrum traces
    fig = plt.figure(1, figsize=(15, 10))
    ax1 = fig.add_subplot(131)
    ax1.set_title('DPX Spectrum Traces')
    ax1.set_xlabel('Frequency (GHz)')
    ax1.set_ylabel('Amplitude (dBm)')
    dpxFreq /= 1e9
    st1, = plt.plot(dpxFreq, traces[0])
    st2, = plt.plot(dpxFreq, traces[1])
    st3, = plt.plot(dpxFreq, traces[2])
    ax1.legend([st1, st2, st3], ['Max Hold', 'Min Hold', 'Average'])
    ax1.set_xlim([dpxFreq[0], dpxFreq[-1]])

    # Show the colorized DPX display
    ax2 = fig.add_subplot(132)
    ax2.imshow(dpxBitmap, cmap='gist_stern')
    ax2.set_aspect(7)
    ax2.set_title('DPX Bitmap')
    ax2.set_xlabel('Frequency (GHz)')
    ax2.set_ylabel('Amplitude (dBm)')
    xTicks = map('{:.4}'.format, plotFreq)
    plt.xticks(np.linspace(0, fb.spectrumBitmapWidth, numTicks), xTicks)
    yTicks = map('{}'.format, np.linspace(refLevel, refLevel - 100, numTicks))
    plt.yticks(np.linspace(0, fb.spectrumBitmapHeight, numTicks), yTicks)

    # Show the colorized DPXogram
    ax3 = fig.add_subplot(133)
    ax3.imshow(dpxogram, cmap='gist_stern')
    ax3.set_aspect(12)
    ax3.set_title('DPXogram')
    ax3.set_xlabel('Frequency (GHz)')
    ax3.set_ylabel('Trace Lines')
    xTicks = map('{:.4}'.format, plotFreq)
    plt.xticks(np.linspace(0, fb.sogramBitmapWidth, numTicks), xTicks)

    plt.tight_layout()
    plt.show()
    rsa.DEVICE_Disconnect()


"""################IF STREAMING EXAMPLE################"""
def config_if_stream(cf=1e9, refLevel=0, fileDir='C:\SignalVu-PC Files', fileName='if_stream_test', durationMsec=100):
    rsa.CONFIG_SetCenterFreq(c_double(cf))
    rsa.CONFIG_SetReferenceLevel(c_double(refLevel))
    rsa.IFSTREAM_SetDiskFilePath(c_char_p(fileDir.encode()))
    rsa.IFSTREAM_SetDiskFilenameBase(c_char_p(fileName.encode()))
    rsa.IFSTREAM_SetDiskFilenameSuffix(IFSSDFN_SUFFIX_NONE)
    rsa.IFSTREAM_SetDiskFileLength(c_long(durationMsec))
    rsa.IFSTREAM_SetDiskFileMode(StreamingMode.StreamingModeFormatted)
    rsa.IFSTREAM_SetDiskFileCount(c_int(1))


def if_stream_example():
    print('\n\n########IF Stream Example########')
    search_connect()
    durationMsec = 100
    waitTime = durationMsec / 10 / 1000
    config_if_stream(fileDir='C:\\SignalVu-PC Files',
                     fileName='if_stream_test', durationMsec=durationMsec)
    writing = c_bool(True)

    rsa.DEVICE_Run()
    rsa.IFSTREAM_SetEnable(c_bool(True))
    while writing.value:
        sleep(waitTime)
        rsa.IFSTREAM_GetActiveStatus(byref(writing))
    print('Streaming finished.')
    rsa.DEVICE_Stop()
    rsa.DEVICE_Disconnect()


"""################IQ STREAMING EXAMPLE################"""
def config_iq_stream(cf=1e9, refLevel=0, bw=10e6, fileDir='C:\\SignalVu-PC Files',
                     fileName='iq_stream_test', dest=IQSOUTDEST.IQSOD_FILE_SIQ,
                     suffixCtl=IQSSDFN_SUFFIX_NONE,
                     dType=IQSOUTDTYPE.IQSODT_INT16,
                     durationMsec=100):
    filenameBase = fileDir + '\\' + fileName
    bwActual = c_double(0)
    sampleRate = c_double(0)
    rsa.CONFIG_SetCenterFreq(c_double(cf))
    rsa.CONFIG_SetReferenceLevel(c_double(refLevel))

    rsa.IQSTREAM_SetAcqBandwidth(c_double(bw))
    rsa.IQSTREAM_SetOutputConfiguration(dest, dType)
    rsa.IQSTREAM_SetDiskFilenameBase(c_char_p(filenameBase.encode()))
    rsa.IQSTREAM_SetDiskFilenameSuffix(suffixCtl)
    rsa.IQSTREAM_SetDiskFileLength(c_int(durationMsec))
    rsa.IQSTREAM_GetAcqParameters(byref(bwActual), byref(sampleRate))
    rsa.IQSTREAM_ClearAcqStatus()


def iqstream_status_parser(iqStreamInfo):
    # This function parses the IQ streaming status variable
    status = iqStreamInfo.acqStatus
    if status == 0:
        print('\nNo error.\n')
    if bool(status & 0x10000):  # mask bit 16
        print('\nInput overrange.\n')
    if bool(status & 0x40000):  # mask bit 18
        print('\nInput buffer > 75{} full.\n'.format('%'))
    if bool(status & 0x80000):  # mask bit 19
        print('\nInput buffer overflow. IQStream processing too slow, ',
              'data loss has occurred.\n')
    if bool(status & 0x100000):  # mask bit 20
        print('\nOutput buffer > 75{} full.\n'.format('%'))
    if bool(status & 0x200000):  # mask bit 21
        print('Output buffer overflow. File writing too slow, ',
              'data loss has occurred.\n')


def iq_stream_example():
    print('\n\n########IQ Stream Example########')
    search_connect()

    bw = 40e6
    dest = IQSOUTDEST.IQSOD_FILE_SIQ_SPLIT
    durationMsec = 100
    waitTime = 0.1
    iqStreamInfo = IQSTREAM_File_Info()

    complete = c_bool(False)
    writing = c_bool(False)

    config_iq_stream(bw=bw, dest=dest, durationMsec=durationMsec)

    rsa.DEVICE_Run()
    rsa.IQSTREAM_Start()
    while not complete.value:
        sleep(waitTime)
        rsa.IQSTREAM_GetDiskFileWriteStatus(byref(complete), byref(writing))
    rsa.IQSTREAM_Stop()
    print('Streaming finished.')
    rsa.IQSTREAM_GetFileInfo(byref(iqStreamInfo))
    iqstream_status_parser(iqStreamInfo)
    rsa.DEVICE_Stop()
    rsa.DEVICE_Disconnect()


"""################MISC################"""
def config_trigger(trigMode=TriggerMode.triggered, trigLevel=-10,
                   trigSource=TriggerSource.TriggerSourceIFPowerLevel):
    rsa.TRIG_SetTriggerMode(trigMode)
    rsa.TRIG_SetIFPowerTriggerLevel(c_double(trigLevel))
    rsa.TRIG_SetTriggerSource(trigSource)
    rsa.TRIG_SetTriggerPositionPercent(c_double(10))


def peak_power_detector(freq, trace):
    peakPower = np.amax(trace)
    peakFreq = freq[np.argmax(trace)]

    return peakPower, peakFreq


def main():
    # uncomment the example you'd like to run
    spectrum_example()
    # block_iq_example()
    # dpx_example()
    # if_stream_example()
    # iq_stream_example()

if __name__ == '__main__':
    main()
