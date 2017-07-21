
Imports System.Collections.Generic
Imports System.Linq
Imports System.Text
Imports System.Threading.Tasks
Imports Tektronix

Namespace IFDataToR3F
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

            ' Define parameters for file output.
            Dim msec As Integer = 5
            ' Time to record.
            Dim numfiles As Integer = 10
            ' Number of files to output.
            Dim fn As String = "IFSTREAM"
            ' Output file name base.
            Dim fp As String = "."
            ' Output file path.
            Dim fmode As StreamingMode = StreamingMode.StreamingModeFramed
            ' Set the streaming mode.
            Dim fnsuffix As Integer = -1
            ' Filename suffix.
            ' Prepare for streaming.
            rs = api.IFSTREAM_SetDiskFilePath(fp)
            rs = api.IFSTREAM_SetDiskFilenameBase(fn)
            rs = api.IFSTREAM_SetDiskFilenameSuffix(fnsuffix)
            rs = api.IFSTREAM_SetDiskFileMode(fmode)
            rs = api.IFSTREAM_SetDiskFileLength(msec)
            rs = api.IFSTREAM_SetDiskFileCount(numfiles)

            ' Put the device into Run mode to begin streaming.
            rs = api.DEVICE_Run()

            ' Begin streaming.
            rs = api.IFSTREAM_SetEnable(True)
            Console.WriteLine("IF Streaming has started...")
            Dim isActive As Boolean = True

            ' While IFSTREAM has Active status, continue streaming.
            While isActive
                rs = api.IFSTREAM_GetActiveStatus(isActive)
            End While

            ' Disconnect the device and finish up.
            rs = api.IFSTREAM_SetEnable(False)

            rs = api.DEVICE_Stop()
            rs = api.DEVICE_Disconnect()

        abort:
            Console.WriteLine("IF Data to R3F routine complete.")
            Console.WriteLine("Press enter key to exit...")
            Console.ReadKey()
        End Sub
    End Class
End Namespace

