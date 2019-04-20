function varargout = Phobos_UI_V2(varargin)
% PHOBOS_UI_V2 MATLAB code for Phobos_UI_V2.fig
%      PHOBOS_UI_V2, by itself, creates a new PHOBOS_UI_V2 or raises the existing
%      singleton*.
%
%      H = PHOBOS_UI_V2 returns the handle to a new PHOBOS_UI_V2 or the handle to
%      the existing singleton*.
%
%      PHOBOS_UI_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHOBOS_UI_V2.M with the given input arguments.
%
%      PHOBOS_UI_V2('Property','Value',...) creates a new PHOBOS_UI_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Phobos_UI_V2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Phobos_UI_V2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Phobos_UI_V2

% Last Modified by GUIDE v2.5 03-Sep-2018 23:26:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Phobos_UI_V2_OpeningFcn, ...
    'gui_OutputFcn',  @Phobos_UI_V2_OutputFcn, ...
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

% --- Executes just before Phobos_UI_V2 is made visible.
function Phobos_UI_V2_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% varargin   command line arguments to Phobos_UI_V2 (see VARARGIN)

handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes Phobos_UI_V2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial Parameters %%%%%%%%%%%%
set(handles.time_interval,'String',20);
set(handles.listbox1,'Value',1);
set(handles.PathFile_Auto_Videos,'string','Select a folder to save the output files',...
    'Value',0);
set(handles.Crop_check,'Value',0);
set(handles.Time_stamps_check,'Value',0);
set([handles.Remove_Video],'Enable','off');

handles.ResultNum = 0;

end

% --- Outputs from this function are returned to the command line.
function varargout = Phobos_UI_V2_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;

end

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, ~, handles)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% Update handles structure
guidata(hObject, handles);


end

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, ~, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Update handles structure
guidata(hObject, handles);

end

% --- Executes on button press in load_video.
function load_video_Callback(hObject, ~, handles)

global rect;

cancel_check = 0;

if get(handles.PathFile_Auto_Videos,'Value') == 0
    uiwait(msgbox(['ERROR!' newline 'Output folder not selected']));
end


if get(handles.PathFile_Auto_Videos,'Value') == 1
    % Retrieve old results data structure
    if isfield(handles,'ResultsData') && ~isempty(handles.ResultsData)
        ResultsData = handles.ResultsData;
        ResultNum = handles.ResultNum;
        
        % Set up the results data structure
    else
        ResultsData = struct('RunName',[]);
        ResultNum = 1;
    end
    
    % Default Parameters - editable
    
    % Disable Button not allowing user to load/remove video during parameters
    set(handles.load_video,'Enable','off');
    set(handles.Remove_Video,'Enable','off');
    
    
    n=1;                                                                                % number of jumped frames (if smaller, bigger resolution)
    % f=1;                                                                              % variable to set minimum freezing in sec
    
    
    % Import video
    [filename, pathname] = uigetfile('*.avi', 'Select an AVI file.','MultiSelect','on');
    if isequal(filename,0) || isequal(pathname,0)
        disp('User selected cancel')
        set(handles.load_video,'Enable','on');
        set(handles.Remove_Video,'Enable','on');
        return;
    else
        if ischar(filename) == 1
            filename = cellstr(filename);
            numfiles = size(filename,2);
        else
            numfiles = size(filename,2);
        end
        
        
        % Put in axes
        axes(handles.axes1);
        
        % Video list
        for ii = 1:numfiles
            if cancel_check == 0
                % Video info
                filename = cellstr(filename);           % Care for the correct type
                video = fullfile(pathname,filename{ii});
                video = VideoReader(video);
                
                % Resolution and frames
                rate = video.NumberOfFrames/video.Duration;
                videoframerate = rate;
                
                
                % Crop image
                if ResultNum == 1
                    [start,finish,rect, cancel_check] = Get_start_and_finish_from_videos_PHOBOS(video, 0, 0);
                end
                
                if ResultNum ~= 1
                    if get(handles.Crop_check,'value') == 1 && get(handles.Time_stamps_check,'value') == 0
                        [start,finish,~, cancel_check] = Get_start_and_finish_from_videos_PHOBOS(video, get(handles.Crop_check,'value'), get(handles.Time_stamps_check,'value'));
                        load([get(handles.PathFile_Auto_Videos,'string') '\Videolist_files\' ResultsData(1).RunName 'parameters.mat'],'rect');
                    end
                    
                    if get(handles.Time_stamps_check,'value') == 1 && get(handles.Crop_check,'value') == 0
                        [~,~,rect, cancel_check] = Get_start_and_finish_from_videos_PHOBOS(video, get(handles.Crop_check,'value'), get(handles.Time_stamps_check,'value'));
                        load([get(handles.PathFile_Auto_Videos,'string') '\Videolist_files\' ResultsData(1).RunName 'parameters.mat'],'start', 'finish');
                    end
                    
                    if get(handles.Crop_check,'value') == 0 && get(handles.Time_stamps_check,'value') == 0
                        [start,finish,rect, cancel_check] = Get_start_and_finish_from_videos_PHOBOS(video, get(handles.Crop_check,'value'), get(handles.Time_stamps_check,'value'));
                    end
                    
                    if get(handles.Crop_check,'value') == 1 && get(handles.Time_stamps_check,'value') == 1
                        load([get(handles.PathFile_Auto_Videos,'string') '\Videolist_files\' ResultsData(1).RunName 'parameters.mat'],'start', 'finish', 'rect');
                    end
                end
                if cancel_check == 0
                    % Save parameters and data in a text file
                    filename_to_save = filename{ii};
                    
                    save([get(handles.PathFile_Auto_Videos,'string') '\Videolist_files\' filename{ii} 'parameters.mat'],'video', 'rect',...
                        'start', 'finish', 'videoframerate','rate','filename_to_save','pathname');
                    
                    ResultsData(ResultNum).RunName = filename{ii};
                    
                    ResultsStr = get(handles.listbox1,'string');
                    if ResultNum == 1
                        ResultsStr = {[ResultsData(1).RunName,'       ',num2str(start/round(rate)),'      ',num2str(finish/round(rate))]};
                    else
                        ResultsStr = [ResultsStr; {[ResultsData(ResultNum).RunName,'       ', num2str(start/round(rate)),'       ', num2str(finish/round(rate))]}];
                    end
                    
                    set(handles.listbox1,'string',ResultsStr);
                    
                    ResultNum = ResultNum+1;
                end
            end
            % Enable remove button
            set([handles.Remove_Video],'Enable','on');
            
            % Store the new ResultsData
            handles.ResultsData = ResultsData;
            handles.ResultNum = ResultNum;
            guidata(hObject, handles);
            
            
        end
        % Message: "Phobos successfully loaded the video"
        if cancel_check == 0
            msgbox('Phobos successfully loaded the video(s)','Success','none');
        end
        
        set(handles.load_video,'Enable','on');
        set(handles.Remove_Video,'Enable','on');
    end
    
end
end


% --- Executes on button press in run_program.
function run_program_Callback(hObject, eventdata, handles)

handles = guidata(hObject);

%%% DEFAULT PARAMETERS - EDITABLE

time_interval = str2num(get(handles.time_interval,'String'));
if isfield(handles,'ResultsData') && ~isempty(handles.ResultsData)
    ResultsData = handles.ResultsData;
    ResultNum = handles.ResultNum;
else
    msgbox('Load some video(s) before pressing this button');
    return;
end

hForm = gcf;             % Save current figure handle
% wait_window = waitbar(0,'Processing video...');
%
% close(wait_window);

Pathname_to_save = 0;
%%% GET BEST PARAMETERS
setappdata(0,'PathName_to_save',get(handles.PathFile_Auto_Videos,'String'));
UserFreezingPlayer;

end


% --- Executes on button press in Remove_Video.
function Remove_Video_Callback(hObject, eventdata, handles)

if isfield(handles,'ResultsData') && ~isempty(handles.ResultsData)
    
else
    return;
end

currentVal = get(handles.listbox1,'Value');
ResultsStr = get(handles.listbox1,'String');
numResults = size(ResultsStr,1);

% Remove the data and list entry for the selected value
ResultsStr(currentVal) = [];
handles.ResultsData(currentVal) = [];
handles.ResultNum = handles.ResultNum-1;

% If there are no other entries, disable the Remove button and change the list string to <empty>
if isequal(numResults,length(currentVal))
    ResultsStr = {'<empty>'};
    currentVal = 1;
    set([handles.Remove_Video],'Enable','off');
end

% Ensure that list box Value is valid, then reset Value and String
currentVal = min(currentVal,size(ResultsStr,1));
set(handles.listbox1,'Value',currentVal,'String',ResultsStr);

% Store the new ResultsData
guidata(hObject, handles)

end


% --- Executes during object creation, after setting all properties.
function time_interval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_interval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in Run_with_Calibration_File.
function Run_with_Calibration_File_Callback(hObject, eventdata, handles)
% hObject    handle to Run_with_Calibration_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);

%%% DEFAULT PARAMETERS - EDITABLE

time_interval = str2num(get(handles.time_interval,'String'));
if isfield(handles,'ResultsData') && ~isempty(handles.ResultsData)
    ResultsData = handles.ResultsData;
    ResultNum = handles.ResultNum;
    %     disp(ResultNum);
else
    msgbox('Load some video(s) before pressing this button');
    return;
end

hForm = gcf;             % Save current figure handle

%%% GET BEST PARAMETERS

[FileName_Manual, FilePath_Manual] = uigetfile('*.mat','Select the calibration .mat file');

load([FilePath_Manual FileName_Manual],'threshold_on', 'threshold_off', 'framesfrz');

%%% QUANTIFY FREEZING OF THE VIDEOS WITH THE BEST PARAMETERS

for v = 1:(ResultNum-1)
    % set the waitbar to be the current figure before it is updated
    % note: this syntax will ensure window order will be preserved
    % with waitbar on top
    set(0, 'CurrentFigure', hForm);
    set(gca,'visible','off');
    
    load([get(handles.PathFile_Auto_Videos,'string') '\Videolist_files\' [ResultsData(v).RunName] 'parameters.mat']);
    
    freezing_func(start,finish,video,videoframerate,rate,framesfrz,rect,[get(handles.PathFile_Auto_Videos,'string') '\Results_files\' filename_to_save],...
        1,time_interval,threshold_on,threshold_off,1,2,0);
    
    clear start finish video videoframerate rate rect filename_to_save
end

msgbox('Done!','Success','none');

end

% --- Executes on button press in xls_generation.
function xls_generation_Callback(hObject, eventdata, handles)
% hObject    handle to xls_generation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

time_interval = str2num(get(handles.time_interval,'String'));

[filename_for_excel, pathname_for_excel] = uigetfile('*.mat','Select the freezing results .mat file','MultiSelect','on');
if isequal(filename_for_excel,0) || isequal(pathname_for_excel,0)
    disp('User selected cancel')
    return;
else
    numfiles_for_excel = size(filename_for_excel,2);
    
    [filename_output, pathname_output] = uiputfile('*.xls', 'Choose a file name');
    
    for ii = 1:numfiles_for_excel
        
        video_row = ii;
        
        filename_for_excel = cellstr(filename_for_excel);           % Care for the correct type
        
        load(fullfile(pathname_for_excel, filename_for_excel{ii}),'filename', 'celltfrz','start', 'finish', 'rate', 'videoframerate');
        
        Phobos_output_excel(filename,celltfrz,rate,videoframerate,start,finish,time_interval, filename_output, pathname_output, video_row);
        
    end
    msgbox('Done!','Success','none');
end
end


% --- Executes on button press in Crop_check.
function Crop_check_Callback(hObject, eventdata, handles)
% hObject    handle to Crop_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Crop_check
handles.Crop_check = get(hObject,'Value');

end

% --- Executes on button press in Time_stamps_check.
function Time_stamps_check_Callback(hObject, eventdata, handles)
% hObject    handle to Time_stamps_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Time_stamps_check
handles.Time_stamps_check = get(hObject,'Value');

end


function PathFile_Auto_Videos_Callback(hObject, eventdata, handles)
% hObject    handle to PathFile_Auto_Videos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PathFile_Auto_Videos as text
%        str2double(get(hObject,'String')) returns contents of PathFile_Auto_Videos as a double
end

% --- Executes during object creation, after setting all properties.
function PathFile_Auto_Videos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PathFile_Auto_Videos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in Folder_Path.
function Folder_Path_Callback(hObject, eventdata, handles)
% hObject    handle to Folder_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Folder_path = uigetdir;
if handles.Folder_path ~= 0
    set(handles.PathFile_Auto_Videos,'string',handles.Folder_path,...
        'Value',1);
    mkdir (handles.Folder_path, 'Calibration_files');
    mkdir (handles.Folder_path, 'Manual_Quantification_files');
    mkdir (handles.Folder_path, 'Videolist_files');
    mkdir (handles.Folder_path, 'Results_files');
end
end
