using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Tektronix;

namespace IQBlockAcquisition
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
                Console.WriteLine("\nERROR: " + rs.ToString());
                goto end;
            }
            else // print the name of the connected device.
                Console.WriteLine("\nCONNECTED TO: " + devType[0]);

            // Set the center frequency and reference level.
            rs = api.CONFIG_SetCenterFreq(103.3e6);
            rs = api.CONFIG_SetReferenceLevel(-10);

            //Define the acquisiton parameters.
            double bandwidth = 40e6;//default bandwidth of 40 MHz.
            int numPts = 1000;
            int numAcqs = 10;

            //Check the acquisition parameter limits.
            double maxBW =0, minBW = 0;
            int maxSamples = 0;
            api.IQBLK_GetMinIQBandwidth(ref minBW);
            api.IQBLK_GetMaxIQBandwidth(ref maxBW);
            api.IQBLK_GetMaxIQRecordLength(ref maxSamples);

            //Set the parameters for IQ Block acquisition.
            rs = api.IQBLK_SetIQBandwidth(bandwidth);
            rs = api.IQBLK_SetIQRecordLength(numPts);

            //Get the IQ bandwidth and sample rate and print the values.
            double iqBW = 0, iqSR = 0;
            rs = api.IQBLK_GetIQBandwidth(ref iqBW);
            rs = api.IQBLK_GetIQSampleRate(ref iqSR);
            Console.WriteLine("\nIQBlk Settings:  IQBW:"+ (iqBW / 1e6) + ", IQSR:" + (iqSR / 1e6));

            //create a file to write the data to.
            System.IO.StreamWriter iqBlockFile = new System.IO.StreamWriter("IQBlock.txt");

            //Prepare buffer for IQ Block.
            Cplx32[] iqdata = null;

            //Begin the IQ block acquisition.
            bool isActive = true;
            int blockCount = 0;
            int waitTimeoutMsec = 1000;//Maximum allowable wait time for each data acquistion.
            int numTimeouts = 3;//Maximum amount of attempts to acquire data if a timeout occurs.
                                //Note: the total wait time to acquire data is waitTimeoutMsec x numTimeouts.
            int timeoutCount = 0;//Variable to track the timeouts.

            //In this example, pressing the ENTER key will force a trigger.	
            //Put the device in triggered mode.
            TriggerMode trigmode = TriggerMode.freeRun;
            rs = api.TRIG_SetTriggerMode(trigmode);
            //Set the trigger position at 25%.
            double trigPos = 25.0;
            rs = api.TRIG_SetTriggerPositionPercent(trigPos);
            Console.WriteLine("\n(Press ENTER key to force a trigger)");
            Int64 timeSec = 0;
            UInt64 timeNsec = 0;

            while (isActive)
            {
                //Put the device into Run mode before each acquisition.
                rs = api.DEVICE_Run();
                //Acquire data.
                rs = api.IQBLK_AcquireIQData();
                //Check if the data block is ready.
                bool blockReady = false;
                rs = api.IQBLK_WaitForIQDataReady(waitTimeoutMsec, ref blockReady);
                
                if (blockReady)
                {
                    blockCount++;
                    //Get IQ Block data.
                    int numPtsRtn = 0;
                    IQBLK_ACQINFO acqinfo = new IQBLK_ACQINFO();
                    rs = api.IQBLK_GetIQDataCplx(ref iqdata, ref numPtsRtn, numPts);
                    rs = api.IQBLK_GetIQAcqInfo(ref acqinfo);
                    
                    //Acquire the timestamp of the last trigger.
                    rs = api.REFTIME_GetTimeFromTimestamp(acqinfo.triggerTimestamp, ref timeSec, ref timeNsec);
                    if (rs == ReturnStatus.noError)
                        Console.WriteLine("\nTrigger timestamp (seconds): " + timeSec);

                    //Write data block to file.
                    for (int n = 0; n < numPts; n++)
                        iqBlockFile.Write(iqdata[n].i + " " + iqdata[n].q);

                    iqBlockFile.Write("\n");

                    Console.WriteLine("\nBlock generated.");

                }
                else timeoutCount++;

                //Check if the defined limit of blocks to write has been reached or if the wait time is exceeded.
                if (numAcqs > 0 && blockCount == numAcqs || timeoutCount == numTimeouts)
                    isActive = false;

                //If a ENTER is pressed, a trigger is activated.
                ConsoleKeyInfo keyinfo;
                keyinfo = Console.ReadKey();
                if(keyinfo.Key == ConsoleKey.Enter)
                {
                    Console.WriteLine("\nTrigger activated");
                    api.TRIG_ForceTrigger();
                }
            }

            //Disconnect the device and finish up.
            rs = api.DEVICE_Stop();
            rs = api.DEVICE_Disconnect();

        end:
            Console.WriteLine("\nIQ block acquisition routine complete.");
            Console.WriteLine("\nPress enter key to exit...");
            Console.ReadKey();
        }
    }

}
