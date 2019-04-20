function Phobos_output_excel(filename, celltfrz,rate,videoframerate,start,finish,time_analysis, filename_output, pathname_output, video_row)

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

video_row = video_row + 1;

%% Analyse

start = start/round(videoframerate);
finish = finish/round(videoframerate);
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

%% Section that quantify the total time in each bin

Last_bin = rem(Total_video_time, time_analysis);
Bin_total_time_vector = time_analysis * ones(1, floor(Total_video_time/time_analysis));

if Last_bin ~= 0
    Bin_total_time_vector = [Bin_total_time_vector, Last_bin];
end


%% Section that makes the row labels

freezing_labels = {};

for t = 1:time_intervals
    freezing_labels = [freezing_labels; {['freezing ' num2str((time_analysis*(t-1))) ' to ' num2str((time_analysis*t)) ' seconds (% total bin time)']}]; % Row Labels
end

%% Saving

% Last column
atoz = char(69:90)';
single_char = cellstr(atoz);
% Column_Letter = single_char{time_intervals};

% Write xls
xlswrite([[pathname_output filename_output] '.xls'],{'Videos'}, 1,'A1');                            % Write row header
xlswrite([[pathname_output filename_output] '.xls'],{'Total video time'}, 1,'B1');                  % Write row header
xlswrite([[pathname_output filename_output] '.xls'],{'Total freezing time'}, 1,'C1');               % Write row header
xlswrite([[pathname_output filename_output] '.xls'],{'Freezing time (%)'}, 1,'D1');                 % Write row header


for t = 1:time_intervals
    xlswrite([[pathname_output filename_output] '.xls'],freezing_labels(t), 1, [atoz(t) '1']);      % Write row header
end

xlswrite([[pathname_output filename_output] '.xls'], {filename}, 1, ['A' num2str(video_row)]);                                     % Write video path
xlswrite([[pathname_output filename_output] '.xls'], round(Total_video_time, 2), 1, ['B' num2str(video_row)]);                     % Export total video time
xlswrite([[pathname_output filename_output] '.xls'], round(timefrz, 2), 1, ['C' num2str(video_row)]);                              % Export total freezing time
xlswrite([[pathname_output filename_output] '.xls'], round((timefrz * 100)/Total_video_time, 2), 1, ['D' num2str(video_row)]);     % Export percentage total freezing time


for t = 1:time_intervals
    xlswrite([[pathname_output filename_output] '.xls'], ...
        round(((length(cell2mat(freezing_intervals_split(t)))/videoframerate) * 100)/Bin_total_time_vector(1,t), 2),...
        1, [atoz(t) num2str(video_row)]);
end

