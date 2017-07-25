function varargout = RSA_API_Spectrum_Example(varargin)
% RSA_API_SpectrumUI MATLAB code for RSA_API_SpectrumUI.fig
%      RSA_API_SpectrumUI, by itself, creates a new RSA_API_SpectrumUI or raises the existing
%      singleton*.
%
%      H = RSA_API_SpectrumUI returns the handle to a new RSA_API_SpectrumUI or the handle to
%      the existing singleton*.
%
%      RSA_API_SpectrumUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RSA_API_SPECTRUM_EXAMPLE.M with the given input arguments.
%
%      RSA_API_SpectrumUI('Property','Value',...) creates a new RSA_API_SpectrumUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RSA_API_Spectrum_Example_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RSA_API_Spectrum_Example_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RSA_API_SpectrumUI

% Last Modified by GUIDE v2.5 02-Dec-2015 15:24:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RSA_API_Spectrum_Example_OpeningFcn, ...
                   'gui_OutputFcn',  @RSA_API_Spectrum_Example_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before RSA_API_Spectrum_Example is made visible.
function RSA_API_Spectrum_Example_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RSA_API_Spectrum_Example (see VARARGIN)

% Choose default command line output for RSA_API_Spectrum_Example
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RSA_API_Spectrum_Example wait for user response (see UIRESUME)
% uiwait(handles);
initDevice(hObject, eventdata, handles);



% --- Outputs from this function are returned to the command line.
function varargout = RSA_API_Spectrum_Example_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function initDevice(hObject, eventdata, handles)
%add path of header file, DLL file and dependencies.
% Add_Dependency_Files

%create device object
handles.dev = icdevice('RSA_API_Driver');
%connect to handle
connect(handles.dev); 

invoke(handles.dev.Device, 'Stop');

% default axis
axis([0, 801, -100, 0])

settingsChanged(handles);
setRunState(handles, 0);

% update data in handles
guidata(hObject, handles);


function settingsChanged(handles)

% set settingsChanged flag
setappdata(handles.figure1, 'settingsChanged', 1);


function run(hObject, eventdata, handles)
try
    % set run state
    setRunState(handles, 1);
    
    while (getappdata(handles.figure1, 'running') == 1)     
        ok = setupAcq(hObject, eventdata, handles);
        if (ok == 0)
            break;
        end

        handles = guidata(hObject);
        acquireData(hObject, eventdata, handles);
    end
    
    stop(handles);
catch err
end


function stop(handles)

% stop acquiring
invoke(handles.dev.Device, 'Stop');

% disable spectrum measurement
set(handles.dev.Spectrum, 'Enable', 0);

% set stop state
setRunState(handles, 0);


function [val status] = validateUINumericValue(hObject, control, min, max, errMsg)

editStr = get(control, 'String');
[val, status] = str2num(editStr);
if (status == 0) || (val < min) || (val > max)
    status = 0;
    errordlg(errMsg,'Invalid Input','modal');
    uicontrol(hObject);
    return;
end

% set default values for fig
function ok = setupAcq(hObject, eventdata, handles)

% query limits of RSA device
limits = invoke(handles.dev.Spectrum, 'GetLimits');
minCF = invoke(handles.dev.Configure, 'GetMinCenterFreq');
maxCF = invoke(handles.dev.Configure, 'GetMaxCenterFreq');

ok = 0;

[centerFreq, status] = validateUINumericValue(hObject, handles.editCF, minCF, maxCF, 'Invalid Center Frequency');
if (status == 0) return; end

[refLevel, status] = validateUINumericValue(hObject, handles.editRefLevel, -100, 30, 'Invalid Reference Level');
if (status == 0) return; end

[span, status] = validateUINumericValue(hObject, handles.editSpan, limits.minSpan, limits.maxSpan, 'Invalid Span');
if (status == 0) return; end

[rbw, status] = validateUINumericValue(hObject, handles.editRBW, limits.minRBW, limits.maxRBW, 'Invalid RBW');
if (status == 0) return; end
if (span < rbw)
    errordlg('Span is less than RBW', 'Invalid Input','modal');
    uicontrol(hObject);
    return;
end

[traceLength, status] = validateUINumericValue(hObject, handles.editTraceLength, limits.minTraceLength, limits.maxTraceLength, 'Invalid Trace Length');
if (status == 0) return; end
% trace length need to be odd value. 1, 3, 5
if (mod(traceLength, 2) == 0)
    traceLength = traceLength + 1;
    set(handles.editTraceLength, 'String', traceLength);
end

vbw = 0;
enableVBW = get(handles.cbVBW,'Value');
if (enableVBW == 1)
    [vbw, status] = validateUINumericValue(hObject, handles.editVBW, limits.minVBW, limits.maxVBW, 'Invalid VBW');
    if (status == 0) return; end
end

window = 'SpectrumWindow_Kaiser';
comboWindowIndex = get(handles.comboWindow, 'Value');
switch(comboWindowIndex)
    case 1
        window = 'SpectrumWindow_Kaiser';
    case 2
        window = 'SpectrumWindow_Mil6dB';
    case 3
        window = 'SpectrumWindow_BlackmanHarris';
    case 4
        window = 'SpectrumWindow_Rectangle';
    case 5
        window = 'SpectrumWindow_FlatTop';
    case 6
        window = 'SpectrumWindow_Hann';
end

% query enable status of traces set by user in fig
trace1Enable = get(handles.cbTrace1Enable, 'Value');
trace2Enable = get(handles.cbTrace2Enable, 'Value');
trace3Enable = get(handles.cbTrace3Enable, 'Value');

% set user defined variables into struct for spectrum settings
spectrumSettings.span = span;
spectrumSettings.rbw = rbw;
spectrumSettings.enableVBW = enableVBW;
spectrumSettings.vbw = vbw;
spectrumSettings.traceLength = traceLength;
spectrumSettings.window = window;
spectrumSettings.verticalUnit = 'SpectrumVerticalUnit_dBm';

% set global settings in device
set(handles.dev.Configure, 'CenterFreq', centerFreq);
set(handles.dev.Configure, 'ReferenceLevel', refLevel);

% set spectrum settings in device
invoke(handles.dev.Spectrum, 'SetSettings', spectrumSettings);

% set properties of each trace
invoke(handles.dev.Spectrum, 'SetTraceType', 'SpectrumTrace1', trace1Enable, 'SpectrumDetector_PosPeak');
invoke(handles.dev.Spectrum, 'SetTraceType', 'SpectrumTrace2', trace2Enable, 'SpectrumDetector_NegPeak');
invoke(handles.dev.Spectrum, 'SetTraceType', 'SpectrumTrace3', trace3Enable, 'SpectrumDetector_AverageVRMS');

% get actual spectrum settings from device
spectrumSettings = invoke(handles.dev.Spectrum, 'GetSettings');
[enable1 detector1] = invoke(handles.dev.Spectrum, 'GetTraceType', 'SpectrumTrace1');
[enable2 detector2] = invoke(handles.dev.Spectrum, 'GetTraceType', 'SpectrumTrace2');
[enable3 detector3] = invoke(handles.dev.Spectrum, 'GetTraceType', 'SpectrumTrace3');

% store parameters in handles
handles.cf = centerFreq;
handles.refLevel = refLevel;
handles.spectrumSettings = spectrumSettings;
handles.traceSettings(1).enable = trace1Enable;
handles.traceSettings(2).enable = trace2Enable;
handles.traceSettings(3).enable = trace3Enable;

guidata(hObject, handles);

setappdata(handles.figure1, 'settingsChanged', 0);

ok = 1;


function acquireData(hObject, eventdata, handles)
try
    timeout = 1000;
    refLevel = handles.refLevel;
    vUnit = 0;      % dBm unit

    % setup frequency list
    maxTracePoints = handles.spectrumSettings.traceLength;
    freqStepSize = handles.spectrumSettings.actualFreqStepSize;
    startFreq = handles.spectrumSettings.actualStartFreq;
    endFreq = startFreq + (maxTracePoints-1) * freqStepSize;

    freqs = startFreq:freqStepSize:endFreq;

    % enable spectrum measurement
    set(handles.dev.Spectrum, 'Enable', 1);
                        
    while((getappdata(handles.figure1, 'running') == 1) && (getappdata(handles.figure1, 'settingsChanged') == 0))
        %start data acq
        invoke(handles.dev.Device, 'Run');

        %wait for data to be ready. 
        ready = 0;
        while (~ready)
            ready = invoke(handles.dev.Spectrum, 'WaitForTraceReady', timeout);
        end

        % get spectrum trace data
        trace1Enable = handles.traceSettings(1).enable;
        trace2Enable = handles.traceSettings(2).enable;
        trace3Enable = handles.traceSettings(3).enable;

        % acquire first trace if enabled
        if (trace1Enable == 1)
            invoke(handles.dev.Spectrum, 'AcquireTrace');
            ready = 0;
            while (~ready)
                ready = invoke(handles.dev.Spectrum, 'WaitForTraceReady', timeout);
            end

            traceData1 = invoke(handles.dev.Spectrum, 'GetTrace', 'SpectrumTrace1', maxTracePoints);
        end
        
        % acquire second trace if enabled
        if (trace2Enable == 1)
            invoke(handles.dev.Spectrum, 'AcquireTrace');
            while (~ready)
                ready = invoke(handles.dev.Spectrum, 'WaitForTraceReady', timeout);
            end
            traceData2 = invoke(handles.dev.Spectrum, 'GetTrace', 'SpectrumTrace2', maxTracePoints);
        end
        
        % acquire third trace if enabled
        if (trace3Enable == 1)
            invoke(handles.dev.Spectrum, 'AcquireTrace');
            while (~ready)
                ready = invoke(handles.dev.Spectrum, 'WaitForTraceReady', timeout);
            end
            traceData3 = invoke(handles.dev.Spectrum, 'GetTrace', 'SpectrumTrace3', maxTracePoints);
        end

        % plot spectrum
        switch(vUnit)
            case 0
                % plot third trace
                if (trace3Enable == 1)
                    plot(freqs, traceData3, 'r');
                    hold on;
                end

                % plot second trace
                if (trace2Enable == 1)
                    plot(freqs, traceData2, 'g');
                    hold on;
                end
                
                % plot first trace
                if (trace1Enable == 1)
                    plot(freqs, traceData1, 'y');
                    hold on;
                end

                % set parameters of graph
                set(handles.axes1, 'Color', 'black', 'XGrid', 'on', 'YGrid', 'on', 'XColor', 'blue', 'YColor', 'blue');
                axis([startFreq, endFreq, refLevel-120, refLevel]);
                hold off;
        end

        drawnow
    end
catch err
end


function setRunState(handles, enable)

if (enable == 0)
    % clear running flag
    setappdata(handles.figure1, 'running', 0);
    
    % update UI
    set(handles.buttonRun, 'Enable', 'on');
    set(handles.buttonStop, 'Enable', 'off');
    uicontrol(handles.buttonRun);
else
    % set running flag
    setappdata(handles.figure1, 'running', 1);
    
    % update UI
    set(handles.buttonRun, 'Enable', 'off');
    set(handles.buttonStop, 'Enable', 'on');
    uicontrol(handles.buttonStop);
end


% --- Executes on button press in buttonRun.
function buttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

run(hObject, eventdata, handles);


function editCF_Callback(hObject, eventdata, handles)
% hObject    handle to editCF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCF as text
%        str2double(get(hObject,'String')) returns contents of editCF as a double

settingsChanged(handles);


% --- Executes during object creation, after setting all properties.
function editCF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editRefLevel_Callback(hObject, eventdata, handles)
% hObject    handle to editRefLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRefLevel as text
%        str2double(get(hObject,'String')) returns contents of editRefLevel as a double
settingsChanged(handles);


% --- Executes during object creation, after setting all properties.
function editRefLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRefLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editTraceLength_Callback(hObject, eventdata, handles)
% hObject    handle to editTraceLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTraceLength as text
%        str2double(get(hObject,'String')) returns contents of editTraceLength as a double
settingsChanged(handles);


% --- Executes during object creation, after setting all properties.
function editTraceLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTraceLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonStop.
function buttonStop_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setRunState(handles, 0);


function editSpan_Callback(hObject, eventdata, handles)
% hObject    handle to editSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSpan as text
%        str2double(get(hObject,'String')) returns contents of editSpan as a double
settingsChanged(handles);


% --- Executes during object creation, after setting all properties.
function editSpan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editRBW_Callback(hObject, eventdata, handles)
% hObject    handle to editRBW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRBW as text
%        str2double(get(hObject,'String')) returns contents of editRBW as a double
settingsChanged(handles);


% --- Executes during object creation, after setting all properties.
function editRBW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRBW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editVBW_Callback(hObject, eventdata, handles)
% hObject    handle to editVBW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVBW as text
%        str2double(get(hObject,'String')) returns contents of editVBW as a double
settingsChanged(handles);


% --- Executes during object creation, after setting all properties.
function editVBW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVBW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbVBW.
function cbVBW_Callback(hObject, eventdata, handles)
% hObject    handle to cbVBW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbVBW

if (get(hObject,'Value') == 1)
    set(handles.editVBW, 'Enable', 'on');
else  
    set(handles.editVBW, 'Enable', 'off');
end

settingsChanged(handles);


% --- Executes on selection change in comboWindow.
function comboWindow_Callback(hObject, eventdata, handles)
% hObject    handle to comboWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboWindow contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboWindow

settingsChanged(handles);


% --- Executes during object creation, after setting all properties.
function comboWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in comboDetector.
function comboDetector_Callback(hObject, eventdata, handles)
% hObject    handle to comboDetector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comboDetector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comboDetector

settingsChanged(handles);


% --- Executes during object creation, after setting all properties.
function comboDetector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comboDetector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbTrace3Enable.
function cbTrace3Enable_Callback(hObject, eventdata, handles)
% hObject    handle to cbTrace3Enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbTrace3Enable
settingsChanged(handles);

% --- Executes on button press in cbTrace1Enable.
function cbTrace1Enable_Callback(hObject, eventdata, handles)
% hObject    handle to cbTrace1Enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbTrace1Enable
settingsChanged(handles);

% --- Executes on button press in cbTrace2Enable.
function cbTrace2Enable_Callback(hObject, eventdata, handles)
% hObject    handle to cbTrace2Enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbTrace2Enable
settingsChanged(handles);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
