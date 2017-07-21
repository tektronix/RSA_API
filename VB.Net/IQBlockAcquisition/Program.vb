Imports System.Collections.Generic
Imports System.Linq
Imports System.Text
Imports System.Threading.Tasks
Imports Tektronix

Namespace IQBlockAcquisition
    Class Program
        Public Shared Sub Main(args As String())
            Dim api As New APIWrapper()

            ' Search for devices.
            Dim devID As Integer() = Nothing
            Dim devSN As String() = Nothing
            Dim devType As String() = Nothing
            Dim rs As ReturnStatus = api.DEVICE_Search(devID, devSN, devType)

            ' Reset and connect to the first device detected.
            rs = api.DEVICE_Reset(devID(0))
            rs = api.DEVICE_Connect(devID(0))

            ' The following is an example on how to use the return status of an API function.
            ' For simplicity, it will not be used in the rest of the program.
            ' This is a fatal error: the device could not be connected.
            If rs <> ReturnStatus.noError Then
                Console.WriteLine("ERROR: {0}", rs)
                GoTo abort
            Else
                ' print the name of the connected device.
                Console.WriteLine("CONNECTED TO: {0}", devType(0))
            End If

            ' Set the center frequency and reference level.
            rs = api.CONFIG_SetCenterFreq(103300000.0)
            rs = api.CONFIG_SetReferenceLevel(-10)

            ' Define the acquisiton parameters.
            Dim bandwidth As Double = 40000000.0
            ' default bandwidth of 40 MHz.
            Dim numPts As Integer = 1000
            Dim numAcqs As Integer = 10

            ' Check the acquisition parameter limits.
            Dim maxBW As Double = 0, minBW As Double = 0
            Dim maxSamples As Integer = 0
            api.IQBLK_GetMinIQBandwidth(minBW)
            api.IQBLK_GetMaxIQBandwidth(maxBW)
            api.IQBLK_GetMaxIQRecordLength(maxSamples)

            ' Set the parameters for IQ Block acquisition.
            rs = api.IQBLK_SetIQBandwidth(bandwidth)
            rs = api.IQBLK_SetIQRecordLength(numPts)

            ' Get the IQ bandwidth and sample rate and print the values.
            Dim iqBW As Double = 0, iqSR As Double = 0
            rs = api.IQBLK_GetIQBandwidth(iqBW)
            rs = api.IQBLK_GetIQSampleRate(iqSR)
            Console.WriteLine("IQBlk Settings:")
            Console.WriteLine(VbTab & "IQ Bandwidth: {0} MHz", (iqBW / 1000000.0))
            Console.WriteLine(VbTab & "IQ Sample Rate: {0} MS/s", (iqSR / 1000000.0))

            ' Create a file to write the data to.
            Dim iqBlockFile As New System.IO.StreamWriter("IQBlock.txt")

            ' Prepare buffer for IQ Block.
            Dim iqdata As Cplx32() = Nothing

            'Begin the IQ block acquisition.
            Dim isActive As Boolean = True
            Dim blockCount As Integer = 0
            Dim waitTimeoutMsec As Integer = 1000
            ' Maximum allowable wait time for each data acquistion.
            Dim numTimeouts As Integer = 3
            ' Maximum amount of attempts to acquire data if a timeout occurs.
            ' Note: the total wait time to acquire data is waitTimeoutMsec x numTimeouts.
            Dim timeoutCount As Integer = 0
            ' Variable to track the timeouts.
            ' In this example, pressing the ENTER key will force a trigger.	
            ' Put the device in triggered mode.
            Dim trigmode = TriggerMode.freeRun
            rs = api.TRIG_SetTriggerMode(trigmode)
            ' Set the trigger position at 25%.
            Dim trigPos As Double = 25.0
            rs = api.TRIG_SetTriggerPositionPercent(trigPos)
            Console.WriteLine("(Press ENTER key to force a trigger)")
            Dim timeSec As Int64 = 0
            Dim timeNsec As UInt64 = 0

            While isActive
                ' Put the device into Run mode before each acquisition.
                rs = api.DEVICE_Run()
                ' Acquire data.
                rs = api.IQBLK_AcquireIQData()
                ' Check if the data block is ready.
                Dim blockReady As Boolean = False
                rs = api.IQBLK_WaitForIQDataReady(waitTimeoutMsec, blockReady)

                If blockReady Then
                    blockCount += 1
                    ' Get IQ Block data.
                    Dim numPtsRtn As Integer = 0
                    Dim acqinfo = New IQBLK_ACQINFO()
                    rs = api.IQBLK_GetIQDataCplx(iqdata, numPtsRtn, numPts)
                    rs = api.IQBLK_GetIQAcqInfo(acqinfo)

                    ' Acquire the timestamp of the last trigger.
                    rs = api.REFTIME_GetTimeFromTimestamp(acqinfo.triggerTimestamp, timeSec, timeNsec)
                    If rs = ReturnStatus.noError Then
                        Console.WriteLine(VbCrLf & "Trigger timestamp (seconds): {0}", timeSec)
                    End If

                    ' Write data block to file.
                    For n As Integer = 0 To numPts - 1
                        iqBlockFile.Write("{0} {1}, ", iqdata(n).i, iqdata(n).q)
                    Next

                    iqBlockFile.Write(vbLf)

                    Console.WriteLine("Block generated.")
                Else
                    timeoutCount += 1
                End If

                ' Check if the defined limit of blocks to write has been reached or if the wait time is exceeded.
                If numAcqs > 0 AndAlso blockCount = numAcqs OrElse timeoutCount = numTimeouts Then
                    isActive = False
                End If

                ' If a ENTER is pressed, a trigger is activated.
                Dim keyinfo = Console.ReadKey()
                If keyinfo.Key = ConsoleKey.Enter Then
                    Console.WriteLine("Trigger activated")
                    api.TRIG_ForceTrigger()
                End If
            End While

            ' Disconnect the device and finish up.
            rs = api.DEVICE_Stop()
            rs = api.DEVICE_Disconnect()

        abort:
            Console.WriteLine("IQ block acquisition routine complete.")
            Console.WriteLine("Press enter key to exit...")
            Console.ReadKey()
        End Sub
    End Class

End Namespace
