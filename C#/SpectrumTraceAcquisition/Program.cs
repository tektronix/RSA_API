using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Tektronix;

namespace SpectrumTraceAcquisition
{
    class Program
    {
        static void Main(string[] args)
        {
            APIWrapper api = new APIWrapper();
            
            // Search for devices.
            int[] devID = null;
            string[] devSN = null;
            string[] devType = null;
            ReturnStatus rs = api.DEVICE_Search(ref devID, ref devSN, ref devType);

            // Reset and connect to the first device detected.
            rs = api.DEVICE_Reset(devID[0]);
            rs = api.DEVICE_Connect(devID[0]);

            // The following is an example on how to use the return status of an API function.
            // For simplicity, it will not be used in the rest of the program.
            // This is a fatal error: the device could not be connected.
            if (rs != ReturnStatus.noError)
            {
                Console.WriteLine("\nERROR: " + rs);
                goto end;
            }
            else // print the name of the connected device.
            {
                Console.WriteLine("\nCONNECTED TO: " + devType[0]);
            }

            // Set the center frequency and reference level.
            rs = api.CONFIG_SetCenterFreq(103.3e6);
            rs = api.CONFIG_SetReferenceLevel(-10);

            // Assign a trace to use. In this example, use trace 1 of 3.
            SpectrumTraces traceID = SpectrumTraces.SpectrumTrace1;
            double span = 40e6; // The span of the trace.
            double rbw = 100; // Resolution bandwidth.
            SpectrumWindows window = SpectrumWindows.SpectrumWindow_Kaiser; // Use the default window (Kaiser).
            SpectrumVerticalUnits vertunits = SpectrumVerticalUnits.SpectrumVerticalUnit_dBm; // Use the default vertical units (dBm).
            int traceLength = 801; // Use the default trace length of 801 points.
            int numTraces = 10; // This will be the number of traces to acquire.
            string fn = "TRACE.txt"; // This will be the output filename.

            // Get the limits for the spectrum acquisition control settings.
            Spectrum_Limits salimits = new Spectrum_Limits();
            rs = api.SPECTRUM_GetLimits(ref salimits);
            if (span > salimits.maxSpan)
                span = salimits.maxSpan;

            // Set SA controls to default, and get the control values.
            var setSettings = new Spectrum_Settings();
            var getSettings = new Spectrum_Settings();
            rs = api.SPECTRUM_SetDefault();
            rs = api.SPECTRUM_GetSettings(ref getSettings);

            // Assign user settings to settings struct.
            setSettings.span = span;
            setSettings.rbw = rbw;
            setSettings.enableVBW = true;
            setSettings.vbw = 100;
            setSettings.traceLength = traceLength;
            setSettings.window = window;
            setSettings.verticalUnit = vertunits;

            // Register the settings.
            rs = api.SPECTRUM_SetSettings(setSettings);

            // Retrieve the settings info.
            rs = api.SPECTRUM_GetSettings(ref getSettings);

            //Open a file for text output.
            var spectrumFile = new System.IO.StreamWriter(fn);

            //Allocate memory array for spectrum output vector.
            float[] pTraceData = null;

            // Start the trace capture.
            rs = api.SPECTRUM_SetEnable(true);
            Console.WriteLine("\nTrace capture is starting...");
            bool isActive = true;
            int waitTimeoutMsec = 1000; // Maximum allowable wait time for each data acquistion.
            int numTimeouts = 3; // Maximum amount of attempts to acquire data if a timeout occurs.
                                 // Note: the total wait time to acquire data is waitTimeoutMsec x numTimeouts.
            int timeoutCount = 0; // Variable to track the timeouts.
            int traceCount = 0;
            bool traceReady = false;
            int outTracePoints = 0;

            while (isActive)
            {
                rs = api.SPECTRUM_AcquireTrace();
                // Wait for the trace to be ready.
                rs = api.SPECTRUM_WaitForTraceReady(waitTimeoutMsec, ref traceReady);
                if (traceReady)
                {
                    // Get spectrum trace data.
                    rs = api.SPECTRUM_GetTrace(traceID, traceLength, ref pTraceData, ref outTracePoints);
                    // Get traceInfo struct.
                    var traceInfo = new Spectrum_TraceInfo();
                    rs = api.SPECTRUM_GetTraceInfo(ref traceInfo);
                    // You can use this information to report any non-zero bits in AcqDataStatus word, for example.
                    if (traceInfo.acqDataStatus != 0)
                        Console.WriteLine("\nTrace:" + traceCount + ", AcqDataStatus:" + traceInfo.acqDataStatus);
                    Console.WriteLine(pTraceData.Max());

                    // Write data to the open file.
                    for (int n = 0; n < outTracePoints; n++)
                        spectrumFile.Write(pTraceData[n]);
                    spectrumFile.Write("\n");

                    traceCount++;

                }
                else
                {
                    timeoutCount++;
                }

                // Stop acquiring traces when the limit is reached or the wait time is exceeded.
                if (numTraces == traceCount || timeoutCount == numTimeouts)
                    isActive = false;
            }

            // Disconnect the device and finish up.
            rs = api.SPECTRUM_SetEnable(false);
            rs = api.DEVICE_Stop();
            rs = api.DEVICE_Disconnect();

        end:
            Console.WriteLine("\nSpectrum trace acquisition routine complete.");
            Console.WriteLine("\nPress enter key to exit...");
            Console.ReadKey();
        }
    }
}
