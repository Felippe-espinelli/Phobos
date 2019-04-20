function freezing_intervals_split = period_output_for_correlation(filename,celltfrz,rate,videoframerate,start,finish,time_analysis)

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

%% Analyse

[z,i]=size(celltfrz);
tff=0;
for z=1 : i
    [~,t1]=size(celltfrz{z});
    tff=tff+t1;                                                            % total of freezing frames
end


timefrz=tff/rate;


celltfrz = cell2mat(celltfrz);                                   % This cells turns into one vector
celltfrz = start+celltfrz;

time_intervals = ceil(((finish/videoframerate)-start)/time_analysis);
freezing_intervals = [];
freezing_intervals_split = [];

%% Section that quantify the freezing on an user defined interval. The output of this section is a matrix of all the period that freezing occurs.
for t = 1:time_intervals
    ix = celltfrz(celltfrz > (start+(time_analysis*(t-1))) & celltfrz<(start+(time_analysis*t)));           % Quantify the freezing on an user defined interval
    freezing_intervals = {ix};
    freezing_intervals(cellfun(@isempty, freezing_intervals)) = {0};
    freezing_intervals_split = [freezing_intervals_split; freezing_intervals];
end

%% Section that makes the row labels

freezing_labels = {};

for t = 1:time_intervals
    freezing_labels = [freezing_labels; {['freezing ' num2str(start+(time_analysis*(t-1))) ' to ' num2str(start+(time_analysis*t)) ' seconds']}]; % Row Labels
end

%% Saving

save([filename 'freezing_in_a_period.mat'],'videoframerate', 'freezing_intervals_split');
