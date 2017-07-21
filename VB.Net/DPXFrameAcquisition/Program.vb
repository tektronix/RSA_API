Imports System.Collections.Generic
Imports System.Linq
Imports System.Text
Imports System.Threading.Tasks
Imports Tektronix

Namespace DPXFrameAcquisition
    Class Program
        Public Shared Sub Main(args As String())
            Dim api As New APIWrapper()

            ' Search for devices.
            Dim devID As Integer() = Nothing
            Dim devSN As String() = Nothing
            Dim devType As String() = Nothing
            Dim rs As ReturnStatus = api.DEVICE_Search(devID, devSN, devType)

            ' Connect to the first device detected.
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

            ' Define the number of points in the trace, the amount of frames, and the output filename.
            Dim numFrames As Integer = 100

            ' Check the RBW range of the device and print the min and max values.
            Dim bandwidth As Double = 40000000.0
            Dim minRBW As Double = 0
            Dim maxRBW As Double = 0
            rs = api.DPX_GetRBWRange(bandwidth, minRBW, maxRBW)

            Console.WriteLine(String.Empty)
            Console.WriteLine("Minimum RBW: {0}", minRBW)
            Console.WriteLine("Maximum RBW: {0}", maxRBW)

            ' Reset DPX before acquisition.
            rs = api.DPX_Reset()

            ' Set the parameters for the DPX acquisition.
            Dim RBW As Double = 5000000.0
            Dim width As Integer = 200
            ' Width of the frame images in pixels.
            Dim tracepts As Integer = 1
            ' Trace points per pixel.
            Dim vertunits As VerticalUnitType = VerticalUnitType.VerticalUnit_dBm
            ' The vertical units of the frames.	
            Dim yTop As Double = 0.0, yBottom As Double = -100.0
            ' Y range for frames.
            Dim infPersist As Boolean = False, showOnlyTrigFrame As Boolean = False
            ' Disable infinite persistence and enable DPX frame to be available continuously.
            Dim persistTime As Double = 1.0
            ' Time for a previous signal to remain onscreen.
            rs = api.DPX_SetParameters(bandwidth, RBW, width, tracepts, vertunits, yTop, _
                                       yBottom, infPersist, persistTime, showOnlyTrigFrame)

            ' Enable the DPX spectrum, and don't enable the spectrogram.
            rs = api.DPX_Configure(True, False)

            ' Set the trace type for all three traces.
            Dim trace1_ID As Integer = 0
            Dim trace2_ID As Integer = 1
            Dim trace3_ID As Integer = 2
            Dim trace1_traceType As TraceType = TraceType.TraceTypeMax
            Dim trace2_traceType As TraceType = TraceType.TraceTypeMin
            Dim trace3_traceType As TraceType = TraceType.TraceTypeAverage
            rs = api.DPX_SetSpectrumTraceType(trace1_ID, trace1_traceType)
            rs = api.DPX_SetSpectrumTraceType(trace2_ID, trace2_traceType)
            rs = api.DPX_SetSpectrumTraceType(trace3_ID, trace3_traceType)

            ' Get the settings for the DPX acquisition.
            Dim getSettings As New DPX_SettingsStruct()
            rs = api.DPX_GetSettings(getSettings)

            ' Display the settings.
            Console.WriteLine()
            Console.WriteLine("DPX Settings:")
            Console.WriteLine(vbTab & "Spectrum: {0}", If(getSettings.enableSpectrum, "ON", "OFF"))
            Console.WriteLine(vbTab & "Sogram: {0}", If(getSettings.enableSpectrogram, "ON", "OFF"))
            Console.WriteLine(vbTab & "Bitmap Width: {0}", getSettings.bitmapWidth)
            Console.WriteLine(vbTab & "Bitmap Height: {0}", getSettings.bitmapHeight)
            Console.WriteLine(vbTab & "Trace Length: {0}", getSettings.traceLength)
            Console.WriteLine(vbTab & "Decay Factor: {0}", getSettings.decayFactor)
            Console.WriteLine(vbTab & "RBW: {0}", (getSettings.actualRBW / 1000000.0))

            ' Initialize frame buffers.
            Dim frameBuffer = New DPX_FrameBuffer()

            ' Enable DPX operation.
            rs = api.DPX_SetEnable(True)
            ' This function must be called before DEVICE_Run().
            ' Put the device in Run mode to start DPX.
            rs = api.DEVICE_Run()

            ' Begin the DPX acquisition.
            Dim bmpidx As Integer = 10
            ' The index of the frame to write to a file.
            Dim isActive As Boolean = True
            ' Flag to enable DPX acquisition routine.
            Dim frameAvailCount As Long = 0
            ' Variable to track how many times an available frame is detected.
            Dim frameCount As Long = 0, fftCount As Long = 0
            ' Variables to check frame count information.
            Dim waitTimeoutMsec As Integer = 1000
            ' Maximum allowable wait time for each data acquistion.
            Dim numTimeouts As Integer = 3
            ' Maximum amount of attempts to acquire data if a timeout occurs.
            ' Note: the total wait time to acquire data is waitTimeoutMsec x numTimeouts.
            Dim timeoutCount As Integer = 0
            ' Variable to track the timeouts.
            ' Create a file to write the traces to.
            Dim traceFile = New System.IO.StreamWriter("DPXdata.txt")

            While isActive
                ' Wait for DPX.
                Dim isDpxReady As Boolean = False
                rs = api.DPX_WaitForDataReady(waitTimeoutMsec, isDpxReady)

                ' If DPX is ready, check if the frame buffer is available.
                Dim frameAvail As Boolean = False
                If isDpxReady Then
                    rs = api.DPX_IsFrameBufferAvailable(frameAvail)
                Else
                    ' Keep track of how many timeouts occured.
                    timeoutCount += 1
                End If

                'If the frame buffer is available, get the frame buffer.
                If frameAvail Then
                    frameAvailCount += 1
                    ' Get DPX data.
                    rs = api.DPX_GetFrameBuffer(frameBuffer)
                    ' Check the latest frame.
                    api.DPX_GetFrameInfo(frameCount, fftCount)
                    ' Acquire the current trace information.
                    Dim traceLen As Integer = frameBuffer.spectrumTraceLength
                    Dim numTraces As Integer = frameBuffer.numSpectrumTraces
                    Dim pTraces As Single()() = frameBuffer.spectrumTraces
                    ' Print trace information to file.
                    For ntr As Integer = 0 To numTraces - 1
                        Dim pTrace As Single() = pTraces(ntr)
                        For n As Integer = 0 To traceLen - 1
                            traceFile.WriteLine("{0}" & vbLf, 10 * Math.Log10(pTrace(n) * 1000.0))
                        Next
                    Next

                    ' Write bitmap data to a txt file.
                    If frameAvailCount = bmpidx Then
                        ' Create the txt file.
                        Dim bitmapFile = New System.IO.StreamWriter("DPXbitmap.txt")
                        ' Acquire current trace information.
                        Dim bitmapWidth As Integer = frameBuffer.spectrumBitmapWidth
                        Dim bitmapHeight As Integer = frameBuffer.spectrumBitmapHeight
                        Dim bitmapSize As Integer = frameBuffer.spectrumBitmapSize
                        Dim bitmap As Single() = frameBuffer.spectrumBitmap

                        ' Generate the bitmap frame.
                        For nh As Integer = 0 To bitmapHeight - 1
                            For nw As Integer = 0 To bitmapWidth - 1
                                bitmapFile.Write("{0} ", bitmap(nh * bitmapWidth + nw))
                            Next
                            bitmapFile.WriteLine()
                        Next

                        Console.WriteLine("Frame generated." & vbLf)
                    End If

                    ' Finish the frame buffer to get the next one.
                    api.DPX_FinishFrameBuffer()
                End If

                ' Check if the defined limit of traces to be generated is reached or if the wait time is exceeded.
                If numFrames > 0 AndAlso frameAvailCount = numFrames OrElse timeoutCount = numTimeouts Then
                    isActive = False
                End If
            End While

            ' Disconnect the device and finish up.
            rs = api.DPX_SetEnable(False)
            rs = api.DEVICE_Stop()
            rs = api.DEVICE_Disconnect()

        abort:
            Console.WriteLine("DPX acquisition routine complete.")
            Console.WriteLine("Press enter key to exit...")
            Console.ReadKey()
        End Sub
    End Class
End Namespace
