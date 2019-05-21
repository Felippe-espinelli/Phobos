function Phobos_output_excel(filename, celltfrz,rate,videoframerate,start,finish,time_analysis, filename_output, pathname_output, video_row, video_list_size)

% Essa função oferece como saida, um arquivo .xls com o tempo de freezing
% total do video e dividido em intervalos de tempo definidos pelo usuario.
% Parametros:
% filename: nome do arquivo.
% celltfrz: Celulas com os tempos onde ocorreu freezing.
% rate: taxa de frame do video dividido pelo numero de frames a ser pulado
% durante a analise do video.
% videoframerate: taxa de frame do video.
% start: Primeiro frame a ser utilizado.
% finish: Ultimo frame a ser utilizado.
% time_analysis: Intervalo de tempo definido pelo usuario.

% video_row = video_row + 1;

%% Analyse

% start = start/round(videoframerate);
% finish = finish/round(videoframerate);
% Total_frames = finish-start;
start = start/videoframerate;
finish = finish/videoframerate;
Total_video_time = finish - start;


timefrz = length(celltfrz)/rate;

time_intervals = ceil((finish-start)/time_analysis);
freezing_intervals = [];
freezing_intervals_split = [];

%% Section that quantify the freezing on an user defined interval. The output of this section is a matrix of all the period that freezing occurs.
for t = 1:time_intervals
    ix = celltfrz(celltfrz > (start+(time_analysis*(t-1))) & celltfrz<(start+(time_analysis*t)));           % Quantify the freezing on an user defined interval
    freezing_intervals = {ix};
    freezing_intervals(cellfun(@isempty, freezing_intervals)) = {0};
    freezing_intervals_split = [freezing_intervals_split; freezing_intervals];
end

clear freezing_intervals

%% Section that quantify the total time in each bin

Last_bin = rem(Total_video_time, time_analysis);
Bin_total_time_vector = time_analysis * ones(1, floor(Total_video_time/time_analysis));

if Last_bin ~= 0
    Bin_total_time_vector = [Bin_total_time_vector, Last_bin];
end

frames_per_bin = Bin_total_time_vector*videoframerate;

%% Section that makes the row labels

freezing_labels_perc = {};
freezing_labels_raw = {};

for t = 1:time_intervals
    freezing_labels_perc = [freezing_labels_perc; {[num2str((time_analysis*(t-1))) ' - ' num2str((time_analysis*t)) 's (%)']}]; % Row Labels
    freezing_labels_raw = [freezing_labels_raw; {[num2str((time_analysis*(t-1))) ' - ' num2str((time_analysis*t)) 's (s)']}]; % Row Labels

end

%% Saving

% Last column
atoz = char(68:90)';
single_char = cellstr(atoz);
% Column_Letter = single_char{time_intervals};

%--------------------------------------------------------------------------
% PERCENTAGE SESSION

% Write xls
xlswrite([[pathname_output filename_output]],{'FREEZING PERCENTAGES'}, 1,'A2');                            % Write row header
xlswrite([[pathname_output filename_output]],{'Videos'}, 1,'A3');                            % Write row header
xlswrite([[pathname_output filename_output]],{'Video duration (s)'}, 1,'B3');                % Write row header
xlswrite([[pathname_output filename_output]],{'Total freezing (%)'}, 1,'C3');                % Write row header

for t = 1:time_intervals
    xlswrite([[pathname_output filename_output]],freezing_labels_perc(t), 1, [atoz(t) '3']);      % Write row header
end

xlswrite([[pathname_output filename_output]], {filename}, 1, ['A' num2str(3 + video_row)]);                                  % Write video path
xlswrite([[pathname_output filename_output]], round(Total_video_time, 2), 1, ['B' num2str(3 + video_row)]);                  % Export total video time
xlswrite([[pathname_output filename_output]], round((timefrz * 100)/Total_video_time, 2), 1, ['C' num2str(3 + video_row)]);  % Export percentage total freezing time


% Time bins
for t = 1:time_intervals
    if cell2mat(freezing_intervals_split(t)) == 0                               % In case of a 0s freezing
        xlswrite([[pathname_output filename_output]], ...
        0,...
        1, [atoz(t) num2str(3 + video_row)]);
    else
        xlswrite([[pathname_output filename_output]], ...
        round(((length(cell2mat(freezing_intervals_split(t))) / videoframerate) * 100)/(  floor(frames_per_bin(1,t)) / videoframerate  ), 2),...
        1, [atoz(t) num2str(3 + video_row)]);
    end
end

%--------------------------------------------------------------------------
% RAW TIME SESSION

% Write xls
xlswrite([[pathname_output filename_output]],{'TOTAL FREEZING TIMES'}, 1, ['A' num2str(3 + video_list_size + 2)]);           % Write row header
xlswrite([[pathname_output filename_output]],{'Videos'}, 1, ['A' num2str(3 + video_list_size + 3)]);                         % Write row header
xlswrite([[pathname_output filename_output]],{'Video duration (s)'}, 1, ['B' num2str(3 + video_list_size + 3)]);             % Write row header
xlswrite([[pathname_output filename_output]],{'Total freezing (s)'}, 1, ['C' num2str(3 + video_list_size + 3)]);             % Write row header

for t = 1:time_intervals
    xlswrite([[pathname_output filename_output]],freezing_labels_raw(t), 1, [atoz(t) num2str(3 + video_list_size + 3)]);     % Write row header
end

xlswrite([[pathname_output filename_output]], {filename}, 1,...                                  % Write video path
    ['A' num2str(3 + video_list_size + 3 + video_row)]);                                     
xlswrite([[pathname_output filename_output]], round(Total_video_time, 2), 1,...                  % Export total video time
    ['B' num2str(3 + video_list_size + 3 + video_row)]);                     
xlswrite([[pathname_output filename_output]], round(timefrz, 2), 1,...                           % Export total freezing time
    ['C' num2str(3 + video_list_size + 3 + video_row)]);                                 


% Time bins
for t = 1:time_intervals
    if cell2mat(freezing_intervals_split(t)) == 0                               % In case of a 0s freezing
        xlswrite([[pathname_output filename_output]], ...
            0,...
            1, [atoz(t) num2str(3 + video_list_size + 3 + video_row)]);
    else
        xlswrite([[pathname_output filename_output]], ...
            round(length(cell2mat(freezing_intervals_split(t)))/videoframerate, 2),...
            1, [atoz(t) num2str(3 + video_list_size + 3 + video_row)]);
    end
    
    
end

xlswrite([[pathname_output filename_output]],...
    {['% values refer to the total time within each bin. Note that the last counted bin might contain less than ' num2str(time_analysis) 's']}, 1,...        % Write row header
    'A1');                                    


