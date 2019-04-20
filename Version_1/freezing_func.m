function freezing_func(start,finish,video,videoframerate,rate,framesfrz,rect,filename,calibration,time_interval,threshold_on,threshold_off,default_values,gen_xls,loop_number)
%Os valores de start e finish precisam ser em numero de frames.
%Correcao de erros nos parametros de entrada
if nargin<15, loop_number=1;      end
if nargin<14, default_values = 1; end
if nargin<14, gen_xls=0;          end
if nargin<12, threshold_off=900;  end                                        % for each comparison between frames (pra tirar o score dos blocos de pixels que mudaram)
if nargin<11, threshold_on=500;   end
if nargin<10, time_interval=20;   end

% Parametros de entrada

n=1;                                                                                % number of jumped frames (if smaller, bigger resolution)
lst=1;                                                                              % to alternate 1st and 2sd lists
count=0;                                                                            % variable to count number of passed frames


celltfrz={};
vettscore=[];
vetscore=[];
cellfrz={};

resolution_factor = ((round(rect(3))*round(rect(4)))/133123);                       % Fator de correcao para diferentes resoluções


hForm2 = gcf;             % Save current figure handle
wait_window_2 = waitbar(0,strcat('Processing files...', filename));


for k = floor(start) :n: floor(finish-1)
    
    set(0, 'CurrentFigure', hForm2);
    
    count=count+1;
    
    data = read(video, k);                                                 % abre só o frame k do video
    data = imcrop(data,rect);
    level = modified_otsu(data,calibration);                                 % pra transformar em preto e branco (verificar a diferença entre só o primeiro e todos)
    
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
    
    imshow(bw_double);
    clear bw_double;
    
    time = count*n/(rate);
    
    set(0, 'CurrentFigure', wait_window_2);
    waitbar((k-start)/(finish-1-start), wait_window_2);
    
    if count~=1
        [cellfrz,vetscore,vettscore,celltfrz]=getfreezing_V2(list1,list2,cellfrz,vetscore,framesfrz,...
            threshold_on,threshold_off,vettscore,celltfrz,time,resolution_factor);
    end
   
       
end

if size(vettscore)~=0
    [~,n]=size(vetscore);
    if n>=framesfrz
        celltfrz(end+1)={vettscore};
    end
end

close(wait_window_2);

celltfrz = cell2mat(celltfrz);                                   % This cells turns into one vector
celltfrz = (start/round(videoframerate))+celltfrz;


loop_number = num2str(loop_number);

if default_values==1
    save([filename '_freezing_results_data.mat'],'video', 'rect', 'start', 'finish', 'videoframerate',...
        'framesfrz','rate','filename','calibration','celltfrz','threshold_on','threshold_off');
else
    save([filename loop_number '_freezing_calibration.mat'],'video', 'rect', 'start', 'finish', 'videoframerate',...
        'framesfrz','rate','filename','calibration','celltfrz','threshold_on','threshold_off');
end

%% Generate .xls and .mat files or only .mat files

if gen_xls==1
    Phobos_output_excel(filename,celltfrz,rate,videoframerate,start,finish,time_interval);
end


