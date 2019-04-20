function varargout = UserFreezingPlayer(varargin)
% USERFREEZINGPLAYER MATLAB code for UserFreezingPlayer.fig
%      USERFREEZINGPLAYER, by itself, creates a new USERFREEZINGPLAYER or raises the existing
%      singleton*.
%
%      H = USERFREEZINGPLAYER returns the handle to a new USERFREEZINGPLAYER or the handle to
%      the existing singleton*.
%
%      USERFREEZINGPLAYER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in USERFREEZINGPLAYER.M with the given input arguments.
%
%      USERFREEZINGPLAYER('Property','Value',...) creates a new USERFREEZINGPLAYER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UserFreezingPlayer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UserFreezingPlayer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UserFreezingPlayer

% Last Modified by GUIDE v2.5 11-Sep-2018 11:47:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @UserFreezingPlayer_OpeningFcn, ...
    'gui_OutputFcn',  @UserFreezingPlayer_OutputFcn, ...
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
end

% --- Executes just before UserFreezingPlayer is made visible.
function UserFreezingPlayer_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UserFreezingPlayer (see VARARGIN)

% Choose default command line output for UserFreezingPlayer
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UserFreezingPlayer wait for user response (see UIRESUME)
% uiwait(handles.figure1);

set(handles.Freezing_Toggle,'string','Freezing off',...
    'BackgroundColor','red',...
    'Enable', 'off',...
    'Value',0);

set(handles.listbox1,'Value',1);
set(handles.Begin_Button,'enable','off');
set(handles.Pause_Button,'string','Pause',...
    'enable','off');
set(handles.begin_calibration_button,'enable','off');
set(handles.Stop_quantification,'enable','off');


handles.ResultNum = 0;

end

% --- Outputs from this function are returned to the command line.
function varargout = UserFreezingPlayer_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, ~, handles)

global filename_2
if isfield(handles,'ResultsData_2') && ~isempty(handles.ResultsData_2)
    ResultsData_2 = handles.ResultsData_2;
    ResultNum_2 = handles.ResultNum_2;
    
    % Set up the results data structure
else
    ResultsData_2 = struct('RunName',[]);
    ResultNum_2 = 1;
end

% Default Parameters - editable

% Import video
[filename_2, pathname_2] = uigetfile('*.avi', 'Select an AVI file.','MultiSelect','on');
if isequal(filename_2,0) || isequal(pathname_2,0)
    disp('User selected cancel')
    return;
else
    if ischar(filename_2) == 1
        filename_2 = cellstr(filename_2);
        numfiles = size(filename_2,2);
        pathname_2 = cellstr(pathname_2);
    else
        numfiles = size(filename_2,2);
    end
    
    set(handles.Begin_Button,'enable','off');
    set(handles.begin_calibration_button,'enable','off');
    set(handles.Remove_video,'enable','off');
    set(handles.pushbutton1,'enable','off');
    set(handles.Stop_quantification,'enable','off');

    uiwait(msgbox('Press OK to define the start and finish time of each video. It is recommended to choose 2 min of one video in this step.'));
    
    % Video list
    for ii = 1:numfiles
        
        % Video info
        filename_2 = cellstr(filename_2);
        pathname_2 = cellstr(pathname_2); % Care for the correct type
        
        video = fullfile(pathname_2{1},filename_2{ii});
        video = VideoReader(video);
        
        % Start and Finish Parameters
        [starting, ending,~, cancel_check] = Get_start_and_finish_from_videos_PHOBOS(video, 1, 0);
        
        if cancel_check == 0
            % Filename in the list
            ResultsData_2(ResultNum_2).RunName = filename_2{ii};
            ResultsData_2(ResultNum_2).RunPath = pathname_2{1};
            ResultsData_2(ResultNum_2).RunStart = starting;
            ResultsData_2(ResultNum_2).RunFinish = ending;
            
            ResultsStr = get(handles.listbox1,'string');
            if ResultNum_2 == 1
                ResultsStr = {[ResultsData_2(1).RunName,'       ',num2str(starting/video.FrameRate),'      ',num2str(ending/video.FrameRate)]};
            else
                ResultsStr = [ResultsStr; {[ResultsData_2(ResultNum_2).RunName,'       ', num2str(starting/video.FrameRate),'       ', num2str(ending/video.FrameRate)]}];
            end
            
            set(handles.listbox1,'string',ResultsStr);
            
            ResultNum_2 = ResultNum_2+1;
            
            % Store the new ResultsData
            handles.ResultsData_2 = ResultsData_2;
            handles.ResultNum_2 = ResultNum_2;
            guidata(hObject, handles);
        end
        
        
    end
    % Message: "Phobos successfully loaded the video"
    
    set(handles.Pause_Button,'enable','off');
    set(handles.Begin_Button,'enable','on');
    set(handles.Stop_quantification,'enable','on');
    set(handles.begin_calibration_button,'enable','on');
    set(handles.Remove_video,'enable','on');
    set(handles.pushbutton1,'enable','on');
    if cancel_check == 0
        msgbox('Phobos successfully loaded the video','Success','none');
    end
end
end

% --- Executes on button press in Begin_Button.
function Begin_Button_Callback(~, ~, handles)
% hObject    handle to Begin_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global filename_2 PPause Close frFreez FreezOn;
global Timer_display stopwatch_time Ccancel Timer_display_total stopwatch_time_total;

set(handles.Freezing_Toggle,'string','Freezing off',...
    'BackgroundColor','red',...
    'Enable', 'on',...
    'Value',0);

Close=0;
PPause=0;
Ccancel = 0;

if isfield(handles,'ResultsData_2') && ~isempty(handles.ResultsData_2)
    ResultsData_2 = handles.ResultsData_2;
    ResultNum_2 = handles.ResultNum_2;
    
    set(handles.Pause_Button,'enable','on');
    set(handles.Begin_Button,'enable','off');
    set(handles.begin_calibration_button,'enable','off');
    set(handles.Remove_video,'enable','off');
    set(handles.pushbutton1,'enable','off');
else
    msgbox('Load some videos before pressing this button');
    return;
end

%% Start Image/Video Loop

for v = 1:(ResultNum_2-1)
    set(handles.Freezing_Toggle,'string','Freezing off',...
        'BackgroundColor','red',...
        'Enable', 'on',...
        'Value',0);
    
    CellFreez = [];
    video = fullfile(ResultsData_2(v).RunPath,ResultsData_2(v).RunName);
    vid = VideoReader(video);
    uiwait(msgbox(strcat('Press Ok to start. Loading video ',cellstr(ResultsData_2(v).RunName)),'Success','modal'))
    count= 1;
    numFrames = get(vid, 'NumberOfFrames');
    videoDuration = vid.Duration;
    rate = numFrames/videoDuration;
    numFrames = rate*videoDuration;
    videoframerate = rate;
    frame_by_frame_time_original = 1/videoframerate;
    finish = round(ResultsData_2(v).RunFinish);
    start = round(ResultsData_2(v).RunStart);
    
    
    frFreez=zeros(finish-start,1);
    
    
    axes(handles.axes1);
    
    % INITIATE STOPWATCH
    
    
    TIMER_FIGURE = figure('Name','Stopwatch',...
        'Numbertitle','off',...
        'Position',[100 500 350 100],...
        'Menubar','none',...
        'Resize','off');
    
    TIMER_FIGURE_TOTAL = figure('Name','Stopwatch',...
        'Numbertitle','off',...
        'Position',[100 635 350 100],...
        'Menubar','none',...
        'Resize','off');
    
    % Stopwatch Time Display
    Timer_display = uicontrol(TIMER_FIGURE,'Style','text',...
        'Position',[10 45 330 55],...
        'BackgroundColor',[0 1 0],...
        'FontSize',35);
    
    Timer_display_total = uicontrol(TIMER_FIGURE_TOTAL,'Style','text',...
        'Position',[10 30 330 55],...
        'BackgroundColor',[0 1 0],...
        'FontSize',35);
    
    set(TIMER_FIGURE,'HandleVisibility','off');
    set(TIMER_FIGURE,'CloseRequestFcn','');
    set(TIMER_FIGURE_TOTAL,'HandleVisibility','off');
    set(TIMER_FIGURE_TOTAL,'CloseRequestFcn','');
    
    stopwatch_time = formatTimeFcn(0);
    stopwatch_time_total = formatTimeFcn(0);
    set(Timer_display,'String',stopwatch_time);
    set(Timer_display_total,'String',stopwatch_time);
    
    % START VIDEO LOOP
    for k=start:finish-1
        tic
        ss  = read(vid,k);
        
        image(ss,'Parent',handles.axes1);
        set(gca,'visible','off');
        
        drawnow;
        frame_normalization = toc;
        if frame_normalization < frame_by_frame_time_original
            pause(frame_by_frame_time_original - frame_normalization);
        end
        
        Time_elapsed_total = k-start/videoframerate;
        stopwatch_time_total = formatTimeFcn(Time_elapsed_total);
        set(Timer_display_total,'String',stopwatch_time_total);
        
        % FREEZING ON CONDITION
        if FreezOn
            frFreez(k)=1;
            CellFreez(count)=k/videoframerate;
            count=count+1;
            
            % STOPWATCH START
            Time_elapsed = count/videoframerate;
            stopwatch_time = formatTimeFcn(Time_elapsed);
            set(Timer_display,'String',stopwatch_time);
            
        end
        
        % FREEZING OFF CONDITION
        if ~FreezOn
            
            
        end
        clear ss;
        
        % CLOSING PROGRAM DURING QUANTIFYING
        if Close==1
            close(fig)
            break
        end
        
        % PAUSE CONDITION
        while get(handles.Pause_Button, 'Value') == 1
            pause(frame_by_frame_time_original);
        end
        
        % PAUSE CONDITION
        if PPause==1
            while PPause==1
                pause(0.5);
                if Ccancel==1
                    break
                end
            end
        end
        
        % STOP THE PROCESS
        if Ccancel==1
            break
        end
        
    end
    
    if Ccancel==1
        break
    end
    
    starting = start/videoframerate;
    starting = floor(starting);
    ending = finish/videoframerate;
    ending = floor(ending);
    
    FileName = ResultsData_2(v).RunName;
    
    % Save File Structure
    save([getappdata(0,'PathName_to_save') '\Manual_Quantification_files\' [ResultsData_2(v).RunName] 'output.mat'], 'FileName',...
        'CellFreez','rate','videoframerate','starting','ending','vid');
    
    % Update Freezing Button
    set(handles.Freezing_Toggle,'string','Freezing off',...
        'BackgroundColor','red',...
        'Value',0);
    clear FileName;
    
    uiwait(msgbox('Video quantified. If the total freezing time was less than 10 sec or the total non-freezing time was less than 10 sec of the video, consider using another video.','Success','modal'))
    
    %Close Timer figure
    delete(TIMER_FIGURE);
    delete(TIMER_FIGURE_TOTAL);
    
end
set(handles.Freezing_Toggle,'string','Freezing off',...
    'BackgroundColor','red',...
    'Enable','off',...
    'Value',0);
set(handles.Begin_Button,'enable','on');
set(handles.begin_calibration_button,'enable','on');
set(handles.Remove_video,'enable','on');
set(handles.pushbutton1,'enable','on');
set(handles.Pause_Button,'enable','off');

delete(TIMER_FIGURE);
delete(TIMER_FIGURE_TOTAL);

if Ccancel == 0
    uiwait(msgbox('Quantification completed!'));
end

if Ccancel==1
    Ccancel = 0;
end

end

% --- Executes on button press in Pause_Button.
function Pause_Button_Callback(~, ~, handles)

global PPause;
if PPause == 0
    PPause = 1;
    set(handles.Pause_Button,'string','Play');
else
    PPause = 0;
    set(handles.Pause_Button,'string','Pause');
end

end
% hObject    handle to Pause_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in begin_calibration_button.
function begin_calibration_button_Callback(~, ~, handles)
% hObject    handle to begin_calibration_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Close;
if Close==0
    Close=1;
end

if isfield(handles,'ResultsData_2') && ~isempty(handles.ResultsData_2)
else
    msgbox('Load some videos before pressing this button');
    return;
end

ResultsData_2 = handles.ResultsData_2;
ResultNum_2 = handles.ResultNum_2;

lista_manual_quant = {};
for v = 1:(ResultNum_2-1)
    lista_manual_quant(v) = {[getappdata(0,'PathName_to_save') '\Manual_Quantification_files\' [ResultsData_2(v).RunName] 'output.mat']};
end

Phobos_Calibration_Step_main;
end



% --- Executes on button press in Freezing_Toggle.
function Freezing_Toggle_Callback(~, ~, handles)
% hObject    handle to Freezing_Toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Freezing_Toggle
global FreezOn;

if FreezOn==1
    FreezOn=0;
    set(handles.Freezing_Toggle,'string','Freezing off',...
        'BackgroundColor','red',...
        'Value',0);
else
    FreezOn=1;
    set(handles.Freezing_Toggle,'string','Freezing on',...
        'BackgroundColor','green',...
        'Value',1);
end
end



% --- Executes on selection change in listbox1.
function listbox1_Callback(~, ~, ~)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

end

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, ~, ~)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Chronometer
function stopwatch_time = formatTimeFcn(float_time)
% Format the Time String
float_time = abs(float_time);
hrs = floor(float_time/3600);
mins = floor(float_time/60 - 60*hrs);
secs = float_time - 60*(mins + 60*hrs);
h = sprintf('%1.0f:',hrs);
m = sprintf('%1.0f:',mins);
s = sprintf('%1.3f',secs);
if hrs < 10
    h = sprintf('0%1.0f:',hrs);
end
if mins < 10
    m = sprintf('0%1.0f:',mins);
end
if secs < 9.9995
    s = sprintf('0%1.3f',secs);
end
stopwatch_time = [h m s];
end


% --- Executes on key press with focus on Freezing_Toggle and none of its controls.
function Freezing_Toggle_KeyPressFcn(~, ~, ~)
% hObject    handle to Freezing_Toggle (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
end


% --- Executes on button press in Remove_video.
function Remove_video_Callback(hObject, eventdata, handles)
% hObject    handle to Remove_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'ResultsData_2') && ~isempty(handles.ResultsData_2)
    
else
    return;
end

currentVal = get(handles.listbox1,'Value');
ResultsStr = get(handles.listbox1,'String');
numResults = size(ResultsStr,1);

% Remove the data and list entry for the selected value
ResultsStr(currentVal) = [];
handles.ResultsData_2(currentVal) = [];
handles.ResultNum_2 = handles.ResultNum_2-1;

% If there are no other entries, disable the Remove button and change the list string to <empty>
if isequal(numResults,length(currentVal))
    ResultsStr = {'<empty>'};
    currentVal = 1;
    set([handles.Remove_video],'Enable','off');
    set(handles.begin_calibration_button,'enable','off');
    set(handles.Begin_Button,'enable','off');
    set(handles.Stop_quantification,'enable','off');
end

% Ensure that list box Value is valid, then reset Value and String
currentVal = min(currentVal,size(ResultsStr,1));
set(handles.listbox1,'Value',currentVal,'String',ResultsStr);

% Store the new ResultsData
guidata(hObject, handles)

end


% --- Executes on button press in Stop_quantification.
function Stop_quantification_Callback(hObject, eventdata, handles)
% hObject    handle to Stop_quantification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Ccancel;
if Ccancel == 0
    Ccancel = 1;
end
end
