using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Tektronix;

namespace DPXFrameAcquisition
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

            // Connect to the first device detected.
            rs = api.DEVICE_Reset(devID[0]);
            rs = api.DEVICE_Connect(devID[0]);

	        // The following is an example on how to use the return status of an API function.
	        // For simplicity, it will not be used in the rest of the program.
	        // This is a fatal error: the device could not be connected.
            if (rs != ReturnStatus.noError)
            {
                Console.WriteLine("ERROR: {0}", rs);
                goto end;
            }
            else
            {
                // print the name of the connected device.
                Console.WriteLine("CONNECTED TO: {0}", devType[0]);
            }

            // Set the center frequency and reference level.
            rs = api.CONFIG_SetCenterFreq(103.3e6);
            rs = api.CONFIG_SetReferenceLevel(-10);

            // Define the number of points in the trace, the amount of frames, and the output filename.
            int numFrames = 100;

            // Check the RBW range of the device and print the min and max values.
            double bandwidth = 40e6;
            double minRBW = 0;
            double maxRBW = 0;
            rs = api.DPX_GetRBWRange(bandwidth, ref minRBW, ref maxRBW);

            Console.WriteLine(string.Empty);
            Console.WriteLine("Minimum RBW: {0}", minRBW);
            Console.WriteLine("Maximum RBW: {0}", maxRBW);

            // Reset DPX before acquisition.
            rs = api.DPX_Reset();

            // Set the parameters for the DPX acquisition.
            double RBW = 5e6;
            int width = 200; // Width of the frame images in pixels.
            int tracepts = 1; // Trace points per pixel.
            VerticalUnitType vertunits = VerticalUnitType.VerticalUnit_dBm; // The vertical units of the frames.	
            double yTop = 0.0, yBottom = -100.0; // Y range for frames.
            bool infPersist = false, showOnlyTrigFrame = false; // Disable infinite persistence and enable DPX frame to be available continuously.
            double persistTime = 1.0; // Time for a previous signal to remain onscreen.
            rs = api.DPX_SetParameters(bandwidth, RBW, width, tracepts, vertunits, yTop, yBottom, infPersist, persistTime, showOnlyTrigFrame);

            // Enable the DPX spectrum, and don't enable the spectrogram.
            rs = api.DPX_Configure(true, false);
    
            // Set the trace type for all three traces.
            int trace1_ID = 0;
            int trace2_ID = 1;
            int trace3_ID = 2;
            TraceType trace1_traceType = TraceType.TraceTypeMax;
            TraceType trace2_traceType = TraceType.TraceTypeMin;
            TraceType trace3_traceType = TraceType.TraceTypeAverage;
            rs = api.DPX_SetSpectrumTraceType(trace1_ID, trace1_traceType);
            rs = api.DPX_SetSpectrumTraceType(trace2_ID, trace2_traceType);
            rs = api.DPX_SetSpectrumTraceType(trace3_ID, trace3_traceType);

            // Get the settings for the DPX acquisition.
            DPX_SettingsStruct getSettings = new DPX_SettingsStruct();
            rs = api.DPX_GetSettings(ref getSettings);

            // Display the settings.
            Console.WriteLine();
            Console.WriteLine("DPX Settings:");
            Console.WriteLine("\tSpectrum: {0}", getSettings.enableSpectrum ? "ON" : "OFF");
            Console.WriteLine("\tSogram: {0}", getSettings.enableSpectrogram ? "ON" : "OFF");
            Console.WriteLine("\tBitmap Width: {0}", getSettings.bitmapWidth);
            Console.WriteLine("\tBitmap Height: {0}", getSettings.bitmapHeight);
            Console.WriteLine("\tTrace Length: {0}", getSettings.traceLength);
            Console.WriteLine("\tDecay Factor: {0}", getSettings.decayFactor);
            Console.WriteLine("\tRBW: {0}", (getSettings.actualRBW / 1000000.0));

            // Initialize frame buffers.
            var frameBuffer = new DPX_FrameBuffer();
    
            // Enable DPX operation.
            rs = api.DPX_SetEnable(true); // This function must be called before DEVICE_Run().
    
            // Put the device in Run mode to start DPX.
            rs = api.DEVICE_Run();
    
            // Begin the DPX acquisition.
            int bmpidx = 10; // The index of the frame to write to a file.
            bool isActive = true; // Flag to enable DPX acquisition routine.
            long frameAvailCount = 0; // Variable to track how many times an available frame is detected.
            long frameCount = 0, fftCount = 0; // Variables to check frame count information.
            int waitTimeoutMsec = 1000; // Maximum allowable wait time for each data acquistion.
            int numTimeouts = 3; // Maximum amount of attempts to acquire data if a timeout occurs.
                                 // Note: the total wait time to acquire data is waitTimeoutMsec x numTimeouts.
            int timeoutCount = 0; // Variable to track the timeouts.

            // Create a file to write the traces to.
            var traceFile = new System.IO.StreamWriter("DPXdata.txt");

            while (isActive)
            {
                // Wait for DPX.
                bool isDpxReady = false;
                rs = api.DPX_WaitForDataReady(waitTimeoutMsec,ref isDpxReady);

                // If DPX is ready, check if the frame buffer is available.
                bool frameAvail = false;
                if(isDpxReady)
                {
                    rs = api.DPX_IsFrameBufferAvailable(ref frameAvail);
                }
                else // Keep track of how many timeouts occured.
                    timeoutCount++;

                //If the frame buffer is available, get the frame buffer.
                if(frameAvail)
                {
                    frameAvailCount++;
                    // Get DPX data.
                    rs = api.DPX_GetFrameBuffer(ref frameBuffer);
                    // Check the latest frame.
                    api.DPX_GetFrameInfo(ref frameCount, ref fftCount);
                    // Acquire the current trace information.
                    int traceLen = frameBuffer.spectrumTraceLength;
                    int numTraces = frameBuffer.numSpectrumTraces;
                    float[][] pTraces = frameBuffer.spectrumTraces;
                    // Print trace information to file.
                    for(int ntr = 0; ntr<numTraces; ntr++)
                    {
                        float[] pTrace = pTraces[ntr];
                        for (int n = 0; n < traceLen; n++)
                        {
                            traceFile.WriteLine("{0}\n", 10 * Math.Log10(pTrace[n] * 1e3));
                        }
                    }

                    // Write bitmap data to a txt file.
                    if(frameAvailCount == bmpidx)
                    {
                        // Create the txt file.
                        var bitmapFile = new System.IO.StreamWriter("DPXbitmap.txt");
                        // Acquire current trace information.
                        int bitmapWidth = frameBuffer.spectrumBitmapWidth;
                        int bitmapHeight = frameBuffer.spectrumBitmapHeight;
                        int bitmapSize = frameBuffer.spectrumBitmapSize;
                        float[] bitmap = frameBuffer.spectrumBitmap;

                        // Generate the bitmap frame.
                        for(int nh = 0; nh < bitmapHeight; nh++)
                        {
                            for (int nw = 0; nw < bitmapWidth; nw++)
                            {
                                bitmapFile.Write("{0} ", bitmap[nh * bitmapWidth + nw]);
                            }
                            bitmapFile.WriteLine();
                        }

                        Console.WriteLine("Frame generated.\n");
                    }

                    // Finish the frame buffer to get the next one.
                    api.DPX_FinishFrameBuffer();
                }

                // Check if the defined limit of traces to be generated is reached or if the wait time is exceeded.
                if(numFrames > 0 && frameAvailCount == numFrames || timeoutCount == numTimeouts)
                    isActive = false;
            }

            // Disconnect the device and finish up.
            rs = api.DPX_SetEnable(false);
            rs = api.DEVICE_Stop();
            rs = api.DEVICE_Disconnect();

            end:
                Console.WriteLine("DPX acquisition routine complete.");
                Console.WriteLine("Press enter key to exit...");
                Console.ReadKey();
        }
    }
}
