function [Start_choice, Finish_choice, rect, cancel_process] = Get_start_and_finish_from_videos_PHOBOS(video,Crop_check,Time_stamps_check)
% function [Start_choice, Finish_choice, data] = Get_start_and_finish_from_videos_PHOBOS(video)

%%% Function to get the start and finish values for the main GUI. Also get
%%% the crop coordinates.

%% INITIAL PARAMETERS
Start = 1;
Finish = video.NumberOfFrames;
Frame_choice = 1;
Play_stop_changes = 0;
Start_choice = 0;
Finish_choice = 0;
Time_choice = 10;
rect = 0;
Return_check = 0;
cancel_process = 0;

%% STARTING FIGURE

MAIN_WINDOW = figure('visible','off','position',...
    [720 1000 700 700]);

set(MAIN_WINDOW,'CloseRequestFcn',@do_not_exit);

SLIDER = uicontrol('style','slider','position',[50 560 600 40],...
    'min',1,...
    'max',video.NumberOfFrames,...
    'Value', 1,...
    'SliderStep', [1,1] / (Finish - Start),...
    'callback',@slider_callback);

%% TEXTs
uicontrol(MAIN_WINDOW,'style','text',...
    'position',[100 630 100 50],...
    'FontSize', 14,...
    'visible','on',...
    'String','Start time:');

uicontrol(MAIN_WINDOW,'style','text',...
    'position',[300 630 100 50],...
    'FontSize', 14,...
    'visible','on',...
    'String','Finish time:');

uicontrol(MAIN_WINDOW,'style','text',...
    'position',[500 630 110 50],...
    'FontSize', 14,...
    'visible','on',...
    'String','Current time:');

Start_time_text = uicontrol(MAIN_WINDOW,'style','text',...
    'position',[80 600 150 50],...
    'FontSize', 14,...
    'visible','off');

Finish_time_text = uicontrol(MAIN_WINDOW,'style','text',...
    'position',[280 600 150 50],...
    'FontSize', 14,...
    'visible','off');

Chronometer_text = uicontrol(MAIN_WINDOW,'style','text',...
    'position',[480 600 150 50],...
    'FontSize', 14,...
    'visible','off');

%% BUTTONS


Play_button = uicontrol(MAIN_WINDOW,'Style','PushButton',...
    'Position',[50 30 125 50],...
    'String','Play',...
    'Callback',@Set_Play_button);

Return_button = uicontrol(MAIN_WINDOW,'Style','PushButton',...
    'Position',[212 30 125 50],...
    'String','Back',...
    'Enable','off',...
    'Callback',@Set_Return_button);

Start_Finish_button = uicontrol(MAIN_WINDOW,'Style','PushButton',...
    'Position',[362 30 125 50],...
    'String','SET START TIME',...
    'Callback',@Set_Video_Start);

uicontrol(MAIN_WINDOW,'Style','PushButton',...
    'Position',[525 30 125 50],...
    'String','Cancel',...
    'Callback',@Cancel_button_func);

%%
video_window = axes('units','pixels','position',[50 100 600 450]);
Video_frame = read(video, 2);
image(Video_frame,'Parent',video_window);
set(gca,'visible','off');


movegui(MAIN_WINDOW,'center');
set(MAIN_WINDOW,'visible','on');

% With time tick enabled in main GUI
if Time_stamps_check == 1
    set(Start_Finish_button,'String','SET CROP','Callback',@Set_Crop_Image);
    set(Return_button,'Enable','off');
    uiwait(msgbox(['Define a time which you can see the animal to make a proper crop.'...
        newline 'It will not be possible to move the time slider after you press the SET CROP button']));
end


% Send the output only when MAIN_WINDOW is closed
waitfor(MAIN_WINDOW);


%% SLIDER CALLBACK
    function slider_callback(~,~)
        Frame_choice = round(get(SLIDER,'value'));
        Video_frame = read(video, Frame_choice);
        image(Video_frame,'Parent',video_window);
        set(gca,'visible','off');
        set(Chronometer_text,'visible','on','string',[num2str(round(Frame_choice/(video.NumberOfFrames/video.Duration),2)) ' seconds']);
    end

%% SET PLAY BUTTON
    function Set_Play_button(~,~)
        Play_stop_changes = 0;
        if Play_stop_changes == 0
            set(Play_button,'String','Stop',...
                'Callback',@Set_Stop_button);
            
            % Video Loop
            for k = Frame_choice:Finish
                %                 disp(k);
                set(SLIDER,'value',k);
                Video_frame = read(video,k);
                image(Video_frame,'Parent',video_window);
                set(video_window,'visible','off');
                drawnow;
                
                Frame_choice = k;
                set(Chronometer_text,'visible','on','string',[num2str(round(Frame_choice/(video.NumberOfFrames/video.Duration),2)) ' seconds']);
                
                % STOP BUTTON
                while Play_stop_changes == 1
                    pause(0.0001);
                end
                
                if Play_stop_changes == 2
                    break
                end
                
                
            end
        end
    end

%% SET STOP VIDEO BUTTON
    function Set_Stop_button(~,~)
        set(Play_button,'String','Play',...
            'Callback',@Set_Play_button);
        Play_stop_changes = 1;
        
    end

%% SET START BUTTON CALLBACK
    function Set_Video_Start(~,~)
        Time_choice = get(SLIDER,'value');
        Start_choice = Time_choice;
        set(Start_Finish_button,'String','SET FINISH TIME','Callback',@Set_Video_Finish);
        set(Return_button,'Enable','On');
        set(Start_time_text,'visible','on','String',[num2str(round(Start_choice/(video.NumberOfFrames/video.Duration),2)) ' seconds']);
        Return_check = 1;
    end

%% SET FINISH BUTTON CALLBACK
    function Set_Video_Finish(~,~)
        % Defining Finish Time
        if Time_stamps_check == 0
            Time_choice = get(SLIDER,'value');
            Finish_choice = Time_choice;
            set(Start_Finish_button,'String','SET CROP','Callback',@Set_Crop_Image);
            set(Finish_time_text,'visible','on','String',[num2str(round(Finish_choice/(video.NumberOfFrames/video.Duration),2)) ' seconds']);
            Play_stop_changes = 1;
            set(Play_button,'Enable','off',...
                'String','Play',...
                'Callback',@Set_Play_button);
        end
        
        if Crop_check == 1
            % To break the function after crop
            Play_stop_changes = 2;
            
            % Close player
            closereq;
        end
        
        Return_check = 2;
    end

%% SET CROP IMAGE
    function Set_Crop_Image(~,~)
        set(Start_Finish_button,'Enable','off');
        set(Return_button,'Enable','off');
        % Crop Image
        if Crop_check == 0
            Time_choice = get(SLIDER,'value');
            Time_choice = floor(Time_choice);
            uiwait(msgbox(['Please read the instruction to crop the image defining the area where the animal is going to move' ...
                newline '1. Wait for the mouse pointer changes to crosshair. Move the pointer over the image to see this change.' ...
                newline '2. Select the area. Using the mouse, draw a rectangle over the portion of the image that you want to crop.' ...
                newline '3. Double click in the selected area to crop the image.']));
            data = read(video, Time_choice);
            [~,~,~,rect] = imcrop(data);
        end
        
        % To break the function after crop
        Play_stop_changes = 2;
        
        % Close player
        closereq;
    end

%% SET RETURN
    function Set_Return_button(~,~)
        if Time_stamps_check == 0           % With time tick disabled in main GUI
            if Return_check == 1
                set(Start_Finish_button,'String','SET START TIME','Callback',@Set_Video_Start);
                set(Return_button,'Enable','off');
                Return_check = 0;
            end
            
            if Return_check == 2
                set(Start_Finish_button,'String','SET FINISH TIME','Callback',@Set_Video_Finish);
                Return_check = 1;
                set(Play_button,'Enable','on');
            end
        end
    end

%% SET CANCEL BUTTON
    function Cancel_button_func(~,~)
        % To break the function after cancel
        Play_stop_changes = 2;
        
        cancel_process = 2;
        closereq;
    end
%% SET PROGRAM EXIT
    function do_not_exit(~,~)
        uiwait(msgbox('Sorry, you are not allowed to do this'));
    end
end

