% Funcao que correlaciona o freezing manual e o freezing automatico. A saida da funcao é o melhor calibration para o vídeo.

function [threshold_on, threshold_off,rho,maximum_correlation,difference_index,indice_final] = correlation_calibration_image(filename)

%% carrega os dados do freezing manual
% % Teste
% filename = 'WEB_13.avi';

load([filename 'manual_freezing1_freezing_in_a_period.mat'],'freezing_intervals_split', 'videoframerate');

manual_freezing_cells = zeros(length(freezing_intervals_split),1);

for t=1:length(freezing_intervals_split)
    manual_freezing_cells(t) = length(cell2mat(freezing_intervals_split(t)))/videoframerate;
end

clear freezing_intervals_split videoframerate;

%% Carrega os dados do freezing automatico e faz correlação

rho = zeros(6,1);

for loop_number = 23:29
    
    number = num2str(loop_number);
    load([filename number '_freezing_in_a_period.mat'],'freezing_intervals_split', 'videoframerate');
    
    automatic_freezing_cells = zeros(length(freezing_intervals_split),1);
    
    for t=1:length(freezing_intervals_split)
        automatic_freezing_cells(t) = length(cell2mat(freezing_intervals_split(t)))/videoframerate;
    end
    
    clear freezing_intervals_split videoframerate;
        
    rho(loop_number) = corr(manual_freezing_cells,automatic_freezing_cells);
end

%% Pega os melhores parâmetros da correlação

maximum_correlation = find(rho == max(rho));

difference_index = zeros(length(maximum_correlation),1);

for threshold_index = 1:length(maximum_correlation)
    
    load([filename num2str(maximum_correlation(threshold_index)) 'freezing_RAW.mat'], 'calibration');
    total_difference = 1 - calibration;
    difference_index(threshold_index) = total_difference;
    clear total_difference calibration;
    
end
clear threshold_index;

threshold_index = find(difference_index == min(difference_index));
indice_final = maximum_correlation(threshold_index);

load([filename num2str(indice_final) 'freezing_RAW.mat'], 'threshold_on', 'threshold_off','calibration');

save(['best_parameters_with_' filename '.mat'], 'threshold_on', 'threshold_off', 'calibration');
