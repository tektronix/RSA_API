using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Tektronix;

namespace IQStreaming
{
    internal static class Program
    {
        private static void Main(string[] args)
        {
            var api = new APIWrapper();

            // Search for devices.
            int[] devId = null;
            string[] devSn = null;
            string[] devType = null;
            var rs = api.DEVICE_Search(ref devId, ref devSn, ref devType);
            if (devId == null)
            {
                Console.WriteLine("\nNo devices found!");
                goto end;
            }

            // Reset and connect to the first device detected.
            if (rs == ReturnStatus.noError)
            {
                rs = api.DEVICE_Reset(devId[0]);
                rs = api.DEVICE_Connect(devId[0]);
            }

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

            // Define the filename.
            const string fn = "iqstream";
            // Set the acquisition bandwidth before putting the device in Run mode.
            const double span = 200e3;
            rs = api.IQSTREAM_SetAcqBandwidth(span);
            // Get the actual bandwidth and sample rate.
            double bwAct = 0;
            double srSps = 0;
            rs = api.IQSTREAM_GetAcqParameters(ref bwAct, ref srSps);

            Console.WriteLine("Bandwidth Requested: {0:F3} MHz, Actual: {1:F3} MHz", span / 1e6, bwAct / 1e6);
            Console.WriteLine("Sample Rate: {0:F} MS/s", srSps / 1e6);

            //Set the output configuration.
            var dest = IQSOUTDEST.IQSOD_FILE_TIQ; // Destination is a TIQ file in this example.
            var dtype = IQSOUTDTYPE.IQSODT_INT16; // Output type is a 16 bit integer.
            rs = api.IQSTREAM_SetOutputConfiguration(dest, dtype);

            // Register the settings for the output file.
            var msec = 10000;
            var fnsuffix = IQSSDFN_SUFFIX.IQSSDFN_SUFFIX_NONE;
            rs = api.IQSTREAM_SetDiskFileLength(msec);
            rs = api.IQSTREAM_SetDiskFilenameBase(fn);
            rs = api.IQSTREAM_SetDiskFilenameSuffix(fnsuffix);

            // Start the live IQ capture.
            var numSamples = 0UL;
            var isActive = true;
            var iqInfo = new IQSTRMIQINFO();
            var fileinfo = new IQSTRMFILEINFO();
            // Put the device into Run mode before starting IQ capture.
            rs = api.DEVICE_Run();
            Console.WriteLine("\nIQ Capture starting...");
            rs = api.IQSTREAM_Start();
            while (isActive)
            {
                // Determine if the write is complete.
                var complete = false;
                var writing = false;
                rs = api.IQSTREAM_GetDiskFileWriteStatus(ref complete, ref writing);
                isActive = !complete;
                rs = api.IQSTREAM_GetDiskFileInfo(ref fileinfo);
                numSamples = fileinfo.numberSamples;
            }

            Console.WriteLine("{0} Samples written to tiq file.", numSamples);

            // Disconnect the device and finish up.
            rs = api.IQSTREAM_Stop();
            rs = api.DEVICE_Stop();
            rs = api.DEVICE_Disconnect();

        end:
            Console.WriteLine("\nIQ streaming routine complete.");
            Console.WriteLine("\nPress enter key to exit...");
            Console.ReadKey();
        }
    }
}
