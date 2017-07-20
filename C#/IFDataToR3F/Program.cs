using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Tektronix;

namespace IFDataToR3F
{
    class Program
    {
        static void Main(string[] args)
        {
            APIWrapper api = new APIWrapper();
            //Search for devices.
            int[] devID = null;
            string[] devSN = null;
            string[] devType = null;
            ReturnStatus rs = api.DEVICE_Search(ref devID, ref devSN, ref devType);
            
            //Connect to the first device detected.
            rs = api.DEVICE_Connect(devID[0]);

            //The following is an example on how to use the return status of an API function.
            //For simplicity, it will not be used in the rest of the program.
            //This is a fatal error: the device could not be connected.
            if (rs != ReturnStatus.noError)
            {
                Console.WriteLine("\nERROR: " + rs);
                goto end;
            }
            else // print the name of the connected device.
                Console.WriteLine("\nCONNECTED TO: " + devType[0]);
            
            // Set the center frequency and reference level.
            rs = api.CONFIG_SetCenterFreq(103.3e6);
            rs = api.CONFIG_SetReferenceLevel(-10);

            //Define parameters for file output.
            int msec = 5;//Time to record.
            int numfiles = 10;//Number of files to output.
            string fn = "IFSTREAM";//Output file name base.
            string fp = ".";//Output file path.
            StreamingMode fmode = StreamingMode.StreamingModeFramed;//Set the streaming mode.
            int fnsuffix = -1;//Filename suffix.

            //Prepare for streaming.
            rs = api.IFSTREAM_SetDiskFilePath(fp);
            rs = api.IFSTREAM_SetDiskFilenameBase(fn);
            rs = api.IFSTREAM_SetDiskFilenameSuffix(fnsuffix);
            rs = api.IFSTREAM_SetDiskFileMode(fmode);
            rs = api.IFSTREAM_SetDiskFileLength(msec);
            rs = api.IFSTREAM_SetDiskFileCount(numfiles);

            //Put the device into Run mode to begin streaming.
            rs = api.DEVICE_Run();

            //Begin streaming.
            rs = api.IFSTREAM_SetEnable(true);
            Console.WriteLine("\nIF Streaming has started...");
            bool isActive = true;

            //While IFSTREAM has Active status, continue streaming.
            while (isActive)
            {
                rs = api.IFSTREAM_GetActiveStatus(ref isActive);
            }

            //Disconnect the device and finish up.
            rs = api.IFSTREAM_SetEnable(false);

            rs = api.DEVICE_Stop();
            rs = api.DEVICE_Disconnect();

        end:
            Console.WriteLine("\nIF Data to R3F routine complete.");
            Console.WriteLine("\nPress enter key to exit...");
            Console.ReadKey();
        }
    }
}
