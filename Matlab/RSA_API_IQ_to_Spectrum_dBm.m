function RSA_API_IQ_to_Spectrum_dBm(dev, I, Q, plotTitle)

centerFreq = get(dev.Configure, 'CenterFreq');
status = invoke(dev.IQStream, 'GetEnable');

%Determine if IQ Stream or IQ Block is being called to plot
if status == true
    [bandwidth, sampleRate] = invoke(dev.IQStream, 'GetAcqParameters');
    [notUsed,numI] = size(I);
    recordLength = single(numI);
else
    recordLength = get(dev.Iqblock, 'IQRecordLength');
    bandwidth = get(dev.Iqblock, 'IQBandwidth');
    sampleRate = invoke(dev.Iqblock, 'GetIQSampleRate');
end

%Create parameters for boundaries of plot
lowerBound = centerFreq-sampleRate/2;   
upperBound = centerFreq+sampleRate/2;
divisions = sampleRate/recordLength;
x = lowerBound:divisions:upperBound;
lowerSpanBound = centerFreq-bandwidth/2;
upperSpanBound = centerFreq+bandwidth/2;
[notUsed,n] = size(x);

%Fix range if needed
if n > recordLength
    x = x(1:recordLength);
end

%Convert IQ data to spectrum in dBm
spec = fftshift(abs(fft(I+Q*1i)));
power = ((spec/recordLength).^2)/(2*50);
spectrum = 10*log10(power*1000);

%Plot spectrum with given titles and red lines to show span range
plot(x, spectrum)
axis([lowerBound, upperBound, -140, 20]);
ylabel('Power Ratio (dBm)')
xlabel('Frequency (Hz)')
title(plotTitle)
y = get(gca,'YLim');
line([lowerSpanBound lowerSpanBound],y,'Color','r');
line([upperSpanBound upperSpanBound],y,'Color','r');
legend('Spectrum', 'Span Bounds')
drawnow

end