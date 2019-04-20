function [cellfrz,vetscore,vettscore,celltfrz]=getfreezing_V2(list1,list2,cellfrz,vetscore,framesfrz,threshold_on,threshold_off,vettscore,celltfrz,time,gambiarra)

score = matrix_difference(list1,list2);

%teste para ajuste do score
score = round(score/gambiarra);

% disp(vettscore);

if score<=threshold_on                  %aqui o score<threshold_on == freezing
    vetscore=[vetscore score];
    vettscore=[vettscore time];
else
    if score>=threshold_off             %score > threshold_off == bicho mexendo
        [m,n]=size(vetscore);
        if n>=framesfrz
            cellfrz(end+1)={vetscore};
            celltfrz(end+1)={vettscore};
        end
        vettscore=[];
        vetscore=[];
    end
    if size(vetscore)~=0
        vetscore=[vetscore score];
        vettscore=[vettscore time];
    end
end
end