% %%
% caminho_da_pasta = uigetdir(getappdata(0,'PathName_to_save'),'Select the manual quantification output(s)');
% 
% if (ischar(caminho_da_pasta))
%     diretorio = dir(caminho_da_pasta);
%     lista_arquivos = {diretorio.name};                                                               % Lista do nome dos arquivos que aparecem na pasta
%     
%     
%     [s,v] = listdlg('PromptString','Choose the files:',...
%         'SelectionMode','multiple',...
%         'ListString',lista_arquivos);
% else
%     v = false;
% end
% 
% lista_manual_quant = {};
% 
% if (v)
%     
%     for k = 1:length(s)
%         p =strcat(caminho_da_pasta,'\');
%         nomes_arquivos = strcat(p,lista_arquivos(s(k)));
%         lista_manual_quant = [lista_manual_quant, nomes_arquivos];
%     end
%     
%     clear lista_arquivos caminho_da_pasta diretorio nomes_arquivos;
% end

%% Variables

temp_score = [];                                            % Matrix with the score from each video
calibration = 1;
FileName_vector = [];
% manual_freezing_times = [];
corr_matrix = zeros(400,1);
slope_vector = zeros(400,1);
intercept_vector = zeros(400,1);
time_analysis = 20;
time_intervals = 0;
total_duration = 0;
start = zeros(length(lista_manual_quant),1);
finish = zeros(length(lista_manual_quant),1);
time_intervals_per_video = zeros(length(lista_manual_quant),1);

%% Quantify score for each video

uiwait(msgbox(['Please read the instruction to crop the image defining the area where the animal is going to move' ...
    newline '1. Wait for the mouse pointer changes to crosshair. Move the pointer over the image to see this change.' ...
    newline '2. Select the area. Using the mouse, draw a rectangle over the portion of the image that you want to crop.' ...
    newline '3. Double click in the selected area to crop the image.']));

for file_number = 1:length(lista_manual_quant)
    load(lista_manual_quant{file_number});
    time_analysis = 20;
    
    n = 1;
    n = (round(rate)/round((round(rate))/n));                                           % number of jumped frames (if smaller, bigger resolution)
    lst=1;                                                                              % to alternate 1st and 2sd lists
    count=0;                                                                            % variable to count number of passed frames
    
    start(file_number) = floor(starting*videoframerate);
    finish(file_number) = floor(ending*videoframerate);
    
    data = read(vid, round(start(file_number)));
    [~,~,~,rect] = imcrop(data);
    
    resolution_factor = ((round(rect(3))*round(rect(4)))/133123);                       % Fator de correcao para diferentes resoluções
    
    hForm2 = gcf;             % Save current figure handle
    wait_window_2 = waitbar(0,'Processing files...');
    
    % inicio = start*round(videoframerate);
    total_frames = length(start(file_number):n:finish(file_number)-1);
    score = zeros(1,total_frames);
    
    
    for k = start(file_number) :n: finish(file_number)-1
        
        set(0, 'CurrentFigure', hForm2);
        
        count=count+1;
        
        data = read(vid, k);                                                 % abre só o frame k do video
        data = imcrop(data,rect);
        level = modified_otsu(data,calibration);                               % pra transformar em preto e branco (verificar a diferença entre só o primeiro e todos)
        
        bw=im2bw(data,level);
        
        bw_double=bw+0;                                                        % converting binary to double matrix
        
        clear bw;
        
        if lst==1
            list1 = bw_double;
            lst=2;
        else
            list2 = bw_double;
            lst = 1;
        end
        
        %     imshow(bw_double);
        clear bw_double;
        
        %     time = count*n/(rate);
        
        set(0, 'CurrentFigure', wait_window_2);
        waitbar((k-start(file_number))/(finish(file_number)-start(file_number)), wait_window_2);
        
        if count~=1
            
            score(count) = matrix_difference(list1,list2);
            score(count) = round(score(count)/resolution_factor);
            
        end
    end
    
    close(wait_window_2);
    temp_score = [temp_score; score];
    
    FileName_vector = strcat(FileName_vector, FileName);
    %     time_intervals_temp = ceil(round((ending-starting))/time_analysis);
    time_intervals_temp = ceil(round((ending-starting))/time_analysis);
    time_intervals_per_video(file_number) = time_intervals_temp;
    time_intervals = time_intervals + time_intervals_temp;
    
    %     total_duration = total_duration + (finish-start);
end

%% Automatic quantification
wait_window_3 = waitbar(0,'Still Processing...');

% total_t_matrix = zeros(400,time_intervals*length(lista_manual_quant));
total_t_matrix = zeros(1020,time_intervals);

threshold_on_vector = zeros(1020,1);
threshold_off_vector = zeros(1020,1);
freezing_time_vector = zeros(1020,1);


for k = 1:length(lista_manual_quant)
    
    loop_counter = 1;
    for threshold = 100:100:6000
        
        for freezing_time = 0:0.25:4
            
            %%% equal thresholds
            total_time_in_periods = Quant_Freez_Calibration_Step(start(k), videoframerate, freezing_time, temp_score(k,:), threshold, threshold, finish(k));
            if k == 1
                total_t_matrix(loop_counter, 1:time_intervals_per_video(1)) = total_time_in_periods(1:time_intervals_per_video(1));
            else
                total_t_matrix(loop_counter, sum( time_intervals_per_video(1:k-1) )+1 : sum( time_intervals_per_video(1:k-1) ) + time_intervals_per_video(k)) = total_time_in_periods(1:time_intervals_per_video(1));
            end
            threshold_on_vector(loop_counter) = threshold;
            threshold_off_vector(loop_counter) = threshold;
            freezing_time_vector(loop_counter) = freezing_time;
            loop_counter = loop_counter + 1;
            
            
        end
    end
    loop_counter = 1;
    
end






%% Manual quantification
manual_freezing_times = [];

for k = 1:length(lista_manual_quant)
    load(lista_manual_quant{k});
    time_analysis = 20;
    time_intervals = ceil(round((ending-starting))/time_analysis);
    freezing_intervals = [];
    freezing_intervals_split = [];
    
    for t = 1:time_intervals
        ix = CellFreez(CellFreez > (starting+(time_analysis*(t-1))) & CellFreez<(starting+(time_analysis*t)));      % Quantify the freezing on an user defined interval
        freezing_intervals = {ix};
        freezing_intervals(cellfun(@isempty, freezing_intervals)) = {0};
        freezing_intervals_split = [freezing_intervals_split; freezing_intervals];
        
        temp(t) = length(cell2mat(freezing_intervals_split(t)))/videoframerate;
        
    end
    manual_freezing_times = [manual_freezing_times, temp];
end

k = 1;

%% Optimizing parameters
for i = 1:1020
    
    corr_matrix(i) = corr(manual_freezing_times', total_t_matrix(i,:)');
    temp_coefficients = polyfit(manual_freezing_times, total_t_matrix(i,:),1);
    slope_vector(i) = temp_coefficients(1);
    intercept_vector(i) = temp_coefficients(2);
    
    clear temp_coefficients;
end

%%% Correlation -> Slope -> Intercept
slope_matrix(:,k) = slope_vector;
intercept_matrix(:,k) = intercept_vector;
N_1 = 10;
N_2 = 5;
N_3 = 1;

% Finding N best correlations
corr_matrix(isnan(corr_matrix)) = 0;
[correlations_max_temp, best_corr_index] = sort(corr_matrix,'descend');
correlations_max_N = correlations_max_temp(1:N_1,:);
best_corr_index = best_corr_index(1:N_1,1);

% Finding N best slopes
max_slope_vector_01(:,k) = slope_matrix(best_corr_index,k);
TempCalc = abs(max_slope_vector_01(:,k)-1);
[Temp_Calc_Value,max_slope_vector_index] = sort(TempCalc,'ascend');
Slope_max_N_01 = Temp_Calc_Value(1:N_2,1);
max_slope_vector_index = max_slope_vector_index(1:N_2,1);
best_corr_slope_index_01(1,k) = (best_corr_index(max_slope_vector_index(1,1),1));

clear TempCalc Temp_Calc_Value

% Finding N best intercepts
max_intercept_vector_01(:,k) = intercept_matrix(best_corr_index(max_slope_vector_index,1),k);
TempCalc = abs(max_intercept_vector_01(:,k)-0);
[Temp_Calc_Value,max_intercept_vector_index_01] = sort(TempCalc,'ascend');
intercept_max_N_01(:,k) = Temp_Calc_Value(1:N_3,1);
max_intercept_vector_index_01 = max_intercept_vector_index_01(1:N_3,1);
best_corr_slope_intercept_index_01(1,k) = best_corr_index(max_slope_vector_index(max_intercept_vector_index_01(1,1),1),1);

close(wait_window_3);

%% Output
threshold_on = threshold_on_vector(best_corr_slope_intercept_index_01);
threshold_off = threshold_off_vector(best_corr_slope_intercept_index_01);
framesfrz = freezing_time_vector(best_corr_slope_intercept_index_01)*videoframerate;

if corr_matrix(best_corr_slope_intercept_index_01) < 0.963 || slope_matrix(best_corr_slope_intercept_index_01) <0.84
    msgbox(['r value and slope obtained during calibration were too small.' newline 'r = ' num2str(corr_matrix(best_corr_slope_intercept_index_01)) ...
        newline 'Slope = ' num2str(slope_matrix(best_corr_slope_intercept_index_01))...
        newline 'Please consider using another video to calibrate' ...
        newline 'If not, just press OK and close the manual quantification player'],'Poor calibration');
    
elseif corr_matrix(best_corr_slope_intercept_index_01) < 0.963
    msgbox(['r value obtained during calibration was too small.' newline 'r = ' num2str(corr_matrix(best_corr_slope_intercept_index_01)) ...
        newline 'Slope = ' num2str(slope_matrix(best_corr_slope_intercept_index_01))...
        newline 'Please consider using another video to calibrate' ...
        newline 'If not, just press OK and close the manual quantification player'],'Poor calibration');
    
elseif slope_matrix(best_corr_slope_intercept_index_01) <0.84
    msgbox(['Slope obtained during calibration was too small.' newline 'r = ' num2str(corr_matrix(best_corr_slope_intercept_index_01)) ...
        newline 'Slope = ' num2str(slope_matrix(best_corr_slope_intercept_index_01))...
        newline 'Please consider using another video to calibrate' ...
        newline 'If not, just press OK and close the manual quantification player'],'Poor calibration');
    
else
    msgbox(['Calibration done!' newline 'r = ' num2str(corr_matrix(best_corr_slope_intercept_index_01))...
        newline 'Slope = ' num2str(slope_matrix(best_corr_slope_intercept_index_01))...
        newline 'Press OK and close the manual quantification player to continue the process']);
end

%% Saving
save([getappdata(0,'PathName_to_save') '\Calibration_files\' 'Calibration_using_' FileName_vector '.mat'],'threshold_on','threshold_off','framesfrz');


