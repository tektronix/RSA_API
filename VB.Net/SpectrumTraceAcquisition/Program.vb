
Imports System.Collections.Generic
Imports System.Linq
Imports System.Text
Imports System.Threading.Tasks
Imports Tektronix

Namespace SpectrumTraceAcquisition
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

            ' Assign a trace to use. In this example, use trace 1 of 3.
            Dim traceID As SpectrumTraces = SpectrumTraces.SpectrumTrace1
            Dim span As Double = 40000000.0
            ' The span of the trace.
            Dim rbw As Double = 100
            ' Resolution bandwidth.
            Dim window As SpectrumWindows = SpectrumWindows.SpectrumWindow_Kaiser
            ' Use the default window (Kaiser).
            Dim vertunits As SpectrumVerticalUnits = SpectrumVerticalUnits.SpectrumVerticalUnit_dBm
            ' Use the default vertical units (dBm).
            Dim traceLength As Integer = 801
            ' Use the default trace length of 801 points.
            Dim numTraces As Integer = 10
            ' This will be the number of traces to acquire.
            Dim fn As String = "TRACE.txt"
            ' This will be the output filename.
            ' Get the limits for the spectrum acquisition control settings.
            Dim salimits As New Spectrum_Limits()
            rs = api.SPECTRUM_GetLimits(salimits)
            If span > salimits.maxSpan Then
                span = salimits.maxSpan
            End If

            ' Set SA controls to default, and get the control values.
            Dim setSettings = New Spectrum_Settings()
            Dim getSettings = New Spectrum_Settings()
            rs = api.SPECTRUM_SetDefault()
            rs = api.SPECTRUM_GetSettings(getSettings)

            ' Assign user settings to settings struct.
            setSettings.span = span
            setSettings.rbw = rbw
            setSettings.enableVBW = True
            setSettings.vbw = 100
            setSettings.traceLength = traceLength
            setSettings.window = window
            setSettings.verticalUnit = vertunits

            ' Register the settings.
            rs = api.SPECTRUM_SetSettings(setSettings)

            ' Retrieve the settings info.
            rs = api.SPECTRUM_GetSettings(getSettings)

            'Open a file for text output.
            Dim spectrumFile = New System.IO.StreamWriter(fn)

            'Allocate memory array for spectrum output vector.
            Dim pTraceData As Single() = Nothing

            ' Start the trace capture.
            rs = api.SPECTRUM_SetEnable(True)
            Console.WriteLine(vbLf & "Trace capture is starting...")
            Dim isActive As Boolean = True
            Dim waitTimeoutMsec As Integer = 1000
            ' Maximum allowable wait time for each data acquistion.
            Dim numTimeouts As Integer = 3
            ' Maximum amount of attempts to acquire data if a timeout occurs.
            ' Note: the total wait time to acquire data is waitTimeoutMsec x numTimeouts.
            Dim timeoutCount As Integer = 0
            ' Variable to track the timeouts.
            Dim traceCount As Integer = 0
            Dim traceReady As Boolean = False
            Dim outTracePoints As Integer = 0

            While isActive
                rs = api.SPECTRUM_AcquireTrace()
                ' Wait for the trace to be ready.
                rs = api.SPECTRUM_WaitForTraceReady(waitTimeoutMsec, traceReady)
                If traceReady Then
                    ' Get spectrum trace data.
                    rs = api.SPECTRUM_GetTrace(traceID, traceLength, pTraceData, outTracePoints)
                    ' Get traceInfo struct.
                    Dim traceInfo = New Spectrum_TraceInfo()
                    rs = api.SPECTRUM_GetTraceInfo(traceInfo)
                    ' You can use this information to report any non-zero bits in AcqDataStatus word, for example.
                    If traceInfo.acqDataStatus <> 0 Then
                        Console.WriteLine(vbLf & "Trace: {0}", traceCount)
                        Console.WriteLine("AcqDataStatus: {0}", traceInfo.acqDataStatus)
                    End If
                    Console.WriteLine(pTraceData.Max())

                    ' Write data to the open file.
                    For n As Integer = 0 To outTracePoints - 1
                        spectrumFile.Write(pTraceData(n))
                    Next
                    spectrumFile.Write(vbLf)

                    traceCount += 1
                Else
                    timeoutCount += 1
                End If

                ' Stop acquiring traces when the limit is reached or the wait time is exceeded.
                If numTraces = traceCount OrElse timeoutCount = numTimeouts Then
                    isActive = False
                End If
            End While

            ' Disconnect the device and finish up.
            rs = api.SPECTRUM_SetEnable(False)
            rs = api.DEVICE_Stop()
            rs = api.DEVICE_Disconnect()

        abort:
            Console.WriteLine()
            Console.WriteLine("Spectrum trace acquisition routine complete.")
            Console.WriteLine("Press enter key to exit...")
            Console.ReadKey()
        End Sub
    End Class
End Namespace


