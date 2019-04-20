function [output] = Quant_Freez_Calibration_Step(start, rate,framesfrz,score,threshold_on,threshold_off,finish)
%Os valores de start e finish precisam ser em numero de frames.
%Correcao de erros nos parametros de entrada

% Parametros de entrada

time_analysis = 20;

% n=3;                                                                                % number of fps
n = rate;
count=0;                                                                            % variable to count number of passed frames

celltfrz={};
vettscore=[];
vetscore=[];
cellfrz={};

rate = (round(rate)/round((round(rate))/n));
framesfrz = rate*framesfrz;                             % Deixar ligado quando for calibrar

for k = 1:length(score)
    
    count=count+1;
    
    time = count/rate;
    
    if score(count)<=threshold_on                  %aqui o score<threshold_on == freezing
        vetscore=[vetscore score(count)];
        vettscore=[vettscore time];
    else
        if score(count)>=threshold_off             %score > threshold_off == bicho mexendo
            [~,n]=size(vetscore);
            if n>=framesfrz
                cellfrz(end+1)={vetscore};
                celltfrz(end+1)={vettscore};
            end
            vettscore=[];
            vetscore=[];
        end
        if size(vetscore)~=0
            vetscore=[vetscore score(count)];
            vettscore=[vettscore time];
        end
    end
end

if size(vettscore)~=0
    [~,i]=size(vetscore);
    if i>=framesfrz
        celltfrz(end+1)={vettscore};
    end
end


%% Total Freezing time in one vector
celltfrz = cell2mat(celltfrz);                                   % This cells turns into one vector
celltfrz = (start/round(rate))+celltfrz;
% timefrz = length(celltfrz)/rate;

%% Freezing time in N periods of x seconds

start = start/round(rate);
finish = finish/round(rate);

% timefrz = length(celltfrz)/rate;

time_intervals = ceil((finish-start)/time_analysis);
freezing_intervals = [];
freezing_intervals_split = [];

%% Section that quantify the freezing on an user defined interval. The output of this section is a matrix of all the period that freezing occurs.
for t = 1:time_intervals
    ix = celltfrz(celltfrz > (start+(time_analysis*(t-1))) & celltfrz<(start+(time_analysis*t)));           % Quantify the freezing on an user defined interval
    freezing_intervals = {ix};
    freezing_intervals(cellfun(@isempty, freezing_intervals)) = {0};
    freezing_intervals_split = [freezing_intervals_split; freezing_intervals];
    output(t) = length(cell2mat(freezing_intervals_split(t)))/rate;
end