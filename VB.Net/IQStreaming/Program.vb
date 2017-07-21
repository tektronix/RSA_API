
Imports System.Collections.Generic
Imports System.Linq
Imports System.Text
Imports System.Threading.Tasks
Imports Tektronix

Namespace IQStreaming
    Class Program
        Public Shared Sub Main(args As String())
            Dim api = New APIWrapper()

            ' Search for devices.
            Dim devId As Integer() = Nothing
            Dim devSn As String() = Nothing
            Dim devType As String() = Nothing
            Dim rs = api.DEVICE_Search(devId, devSn, devType)
            If devId Is Nothing Then
                Console.WriteLine("No devices found!")
                GoTo abort
            End If

            ' Reset and connect to the first device detected.
            If rs = ReturnStatus.noError Then
                rs = api.DEVICE_Reset(devId(0))
                rs = api.DEVICE_Connect(devId(0))
            End If

            ' The following is an example on how to use the return status of an API function.
            ' For simplicity, it will not be used in the rest of the program.
            ' This is a fatal error: the device could not be connected.
            If rs <> ReturnStatus.noError Then
                Console.WriteLine("ERROR: {0}", rs)
                GoTo abort
            Else
                ' print the name of the connected device.
                Console.WriteLine("CONNECTED TO: " + devType(0))
            End If

            ' Set the center frequency and reference level.
            rs = api.CONFIG_SetCenterFreq(103300000.0)
            rs = api.CONFIG_SetReferenceLevel(-10)

            ' Define the filename.
            Const  fn As String = "iqstream"
            ' Set the acquisition bandwidth before putting the device in Run mode.
            Const  span As Double = 200000.0
            rs = api.IQSTREAM_SetAcqBandwidth(span)
            ' Get the actual bandwidth and sample rate.
            Dim bwAct As Double = 0
            Dim srSps As Double = 0
            rs = api.IQSTREAM_GetAcqParameters(bwAct, srSps)

            Console.WriteLine("Bandwidth Requested: {0:F3} MHz, Actual: {1:F3} MHz", span / 1000000.0, bwAct / 1000000.0)
            Console.WriteLine("Sample Rate: {0:F} MS/s", srSps / 1000000.0)

            'Set the output configuration.
            Dim dest = IQSOUTDEST.IQSOD_FILE_TIQ
            ' Destination is a TIQ file in this example.
            Dim dtype = IQSOUTDTYPE.IQSODT_INT16
            ' Output type is a 16 bit integer.
            rs = api.IQSTREAM_SetOutputConfiguration(dest, dtype)

            ' Register the settings for the output file.
            Dim msec = 10000
            Dim fnsuffix = IQSSDFN_SUFFIX.IQSSDFN_SUFFIX_NONE
            rs = api.IQSTREAM_SetDiskFileLength(msec)
            rs = api.IQSTREAM_SetDiskFilenameBase(fn)
            rs = api.IQSTREAM_SetDiskFilenameSuffix(fnsuffix)

            ' Start the live IQ capture.
            Dim numSamples = 0UL
            Dim isActive = True
            Dim iqInfo = New IQSTRMIQINFO()
            Dim fileinfo = New IQSTRMFILEINFO()
            ' Put the device into Run mode before starting IQ capture.
            rs = api.DEVICE_Run()
            Console.WriteLine(vbLf & "IQ Capture starting...")
            rs = api.IQSTREAM_Start()
            While isActive
                ' Determine if the write is complete.
                Dim complete = False
                Dim writing = False
                rs = api.IQSTREAM_GetDiskFileWriteStatus(complete, writing)
                isActive = Not complete
                rs = api.IQSTREAM_GetDiskFileInfo(fileinfo)
                numSamples = fileinfo.numberSamples
            End While

            Console.WriteLine("{0} Samples written to tiq file.", numSamples)

            ' Disconnect the device and finish up.
            rs = api.IQSTREAM_Stop()
            rs = api.DEVICE_Stop()
            rs = api.DEVICE_Disconnect()

        abort:
            Console.WriteLine(vbLf & "IQ streaming routine complete.")
            Console.WriteLine(vbLf & "Press enter key to exit...")
            Console.ReadKey()
        End Sub
    End Class
End Namespace

