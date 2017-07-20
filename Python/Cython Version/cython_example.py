"""
Tektronix RSA_API Cython Example
Author: Morgan Allison
Date created: 6/17
Date edited: 6/17
Windows 7 64-bit
RSA API version 3.9.0029
Python 3.6.0 64-bit (Anaconda 4.3.0)
NumPy 1.11.3, MatPlotLib 2.0.0
Download Anaconda: http://continuum.io/downloads
Anaconda includes NumPy and MatPlotLib
Download the RSA_API: http://www.tek.com/model/rsa306-software
Download the RSA_API Documentation:
http://www.tek.com/spectrum-analyzer/rsa306-manual-6
"""

from rsa_api import *
from time import sleep
import numpy as np
import matplotlib.pyplot as plt


"""################CLASSES AND FUNCTIONS################"""
def search_connect():
    print('API Version {}'.format(DEVICE_GetAPIVersion_py()))
    try:
        numDevicesFound, deviceIDs, deviceSerial, deviceType = DEVICE_Search_py()
    except RSAError:
        print(RSAError)
    print('Number of devices: {}'.format(numDevicesFound))
    if numDevicesFound > 0:
        print('Device serial numbers: {}'.format(deviceSerial[0].decode()))
        print('Device type: {}'.format(deviceType[0].decode()))
        DEVICE_Connect_py(deviceIDs[0])
    else:
        print('No devices found, exiting script.')
        exit()
    CONFIG_Preset_py()


"""################SPECTRUM EXAMPLE################"""
def config_spectrum(cf=1e9, refLevel=0, span=40e6, rbw=300e3):
    SPECTRUM_SetEnable_py(True)
    CONFIG_SetCenterFreq_py(cf)
    CONFIG_SetReferenceLevel_py(refLevel)
    
    SPECTRUM_SetDefault_py()
    SPECTRUM_SetSettings_py(span=span, rbw=rbw, traceLength=801)
    specSet = SPECTRUM_GetSettings_py()
    return specSet


def create_frequency_array(specSet):
    # Create array of frequency data for plotting the spectrum.
    freq = np.arange(specSet['actualStartFreq'], specSet['actualStartFreq']
                     + specSet['actualFreqStepSize'] * specSet['traceLength'],
                     specSet['actualFreqStepSize'])
    return freq


def spectrum_example():
    print('\n\n########Spectrum Example########')
    search_connect()
    cf = 2.4453e9
    refLevel = 0
    span = 40e6
    rbw = 10e3
    specSet = config_spectrum(cf, refLevel, span, rbw)
    trace = SPECTRUM_Acquire_py(SpectrumTraces.SpectrumTrace1, specSet[
        'traceLength'], 100)
    freq = create_frequency_array(specSet)
    peakPower, peakFreq = peak_power_detector(freq, trace)

    plt.figure(1, figsize=(15, 10))
    ax = plt.subplot(111, facecolor='k')
    ax.plot(freq, trace, color='y')
    ax.set_title('Spectrum Trace')
    ax.set_xlabel('Frequency (Hz)')
    ax.set_ylabel('Amplitude (dBm)')
    ax.axvline(peakFreq)
    ax.text((freq[0] + specSet['span'] / 20), peakPower,
            'Peak power in spectrum: {:.2f} dBm @ {} MHz'.format(
                peakPower, peakFreq / 1e6), color='white')
    ax.set_xlim([freq[0], freq[-1]])
    ax.set_ylim([refLevel - 100, refLevel])
    plt.tight_layout()
    plt.show()
    DEVICE_Disconnect_py()


"""################BLOCK IQ EXAMPLE################"""
def config_block_iq(cf=1e9, refLevel=0, iqBw=40e6, recordLength=10000):
    CONFIG_SetCenterFreq_py(cf)
    CONFIG_SetReferenceLevel_py(refLevel)

    IQBLK_SetIQBandwidth_py(iqBw)
    IQBLK_SetIQRecordLength_py(recordLength)

    iqSampleRate = IQBLK_GetIQSampleRate_py()
    # Create array of time data for plotting IQ vs time
    time = np.linspace(0, recordLength / iqSampleRate, recordLength)
    time1 = []
    step = recordLength / iqSampleRate / (recordLength - 1)
    for i in range(recordLength):
        time1.append(i * step)
    return time


def block_iq_example():
    print('\n\n########Block IQ Example########')
    search_connect()
    cf = 2.4453e9
    refLevel = 0
    iqBw = 40e6
    recordLength = 100000

    time = config_block_iq(cf, refLevel, iqBw, recordLength)
    IQ = IQBLK_Acquire_py(recordLength=recordLength)
    
    fig = plt.figure(1, figsize=(15, 10))
    fig.suptitle('I and Q vs Time', fontsize='20')
    ax1 = plt.subplot(211, facecolor='k')
    ax1.plot(time * 1000, IQ[0], color='y')
    ax1.set_ylabel('I (V)')
    ax1.set_xlim([time[0] * 1e3, time[-1] * 1e3])
    ax2 = plt.subplot(212, facecolor='k')
    ax2.plot(time * 1000, IQ[1], color='c')
    ax2.set_ylabel('Q (V)')
    ax2.set_xlabel('Time (msec)')
    ax2.set_xlim([time[0] * 1e3, time[-1] * 1e3])
    plt.tight_layout()
    plt.show()
    DEVICE_Disconnect_py()


"""################DPX EXAMPLE################"""
def config_DPX(cf=1e9, refLevel=0, span=40e6, rbw=300e3):
    yTop = refLevel
    yBottom = yTop - 100
    yUnit = VerticalUnitType.VerticalUnit_dBm

    CONFIG_SetCenterFreq_py(cf)
    CONFIG_SetReferenceLevel_py(refLevel)

    DPX_SetEnable_py(True)
    tracePtsPerPixel = 1
    yUnit = 0#VerticalUnitType.VerticalUnit_dBm
    yTop = 0
    yBottom = yTop - 100
    infinitePersistence = False
    persistenceTimeSec = 1
    showOnlyTrigFrame = False
    DPX_SetParameters_py(span, rbw, tracePtsPerPixel, yUnit, yTop, yBottom,
                         infinitePersistence, persistenceTimeSec,
                         showOnlyTrigFrame)

    timePerBitmapLine = 0.1
    timeResolution = 0.01
    DPX_SetSogramParameters_py(timePerBitmapLine, timeResolution, yTop, yBottom)

    dpxSettings = DPX_GetSettings_py()
    dpxFreq = np.linspace((cf - span / 2), (cf + span / 2),
                          dpxSettings['bitmapWidth'])
    dpxAmp = np.linspace(yBottom, yTop, dpxSettings['bitmapHeight'])
    return dpxFreq, dpxAmp


def dpx_example():
    print('\n\n########DPX Example########')
    search_connect()
    cf = 2.4453e9
    refLevel = 0
    span = 40e6
    rbw = 100e3

    dpxFreq, dpxAmp = config_DPX(cf, refLevel, span, rbw)
    fb = DPX_AcquireFB_py()
    
    numTicks = 11
    plotFreq = np.linspace(cf - span / 2.0, cf + span / 2.0, numTicks) / 1e9

    """################PLOT################"""
    # Plot out the three DPX spectrum traces
    fig = plt.figure(1, figsize=(15, 10))
    ax1 = fig.add_subplot(131)
    ax1.set_title('DPX Spectrum Traces')
    ax1.set_xlabel('Frequency (GHz)')
    ax1.set_ylabel('Amplitude (dBm)')
    # for t in fb.spectrumTraces:
    #     ax1.plot(t)
    dpxFreq /= 1e9
    st1, = plt.plot(dpxFreq, fb.spectrumTraces[0])
    st2, = plt.plot(dpxFreq, fb.spectrumTraces[1])
    st3, = plt.plot(dpxFreq, fb.spectrumTraces[2])
    ax1.legend([st1, st2, st3], ['Max Hold', 'Min Hold', 'Average'])
    ax1.set_xlim([dpxFreq[0], dpxFreq[-1]])

    # Show the colorized DPX display
    ax2 = fig.add_subplot(132)
    ax2.imshow(fb.spectrumBitmap, cmap='gist_stern')
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
    ax3.imshow(fb.sogramBitmap, cmap='gist_stern')
    ax3.set_aspect(12)
    ax3.set_title('DPXogram')
    ax3.set_xlabel('Frequency (GHz)')
    ax3.set_ylabel('Trace Lines')
    xTicks = map('{:.4}'.format, plotFreq)
    plt.xticks(np.linspace(0, fb.sogramBitmapWidth, numTicks), xTicks)

    plt.tight_layout()
    plt.show()
    DEVICE_Disconnect_py()


"""################MISC################"""
def peak_power_detector(freq, trace):
    peakPower = np.amax(trace)
    peakFreq = freq[np.argmax(trace)]

    return peakPower, peakFreq

def main():
    # uncomment the example you'd like to run
    spectrum_example()
    block_iq_example()
    dpx_example()
0

if __name__ == '__main__':
    main()
