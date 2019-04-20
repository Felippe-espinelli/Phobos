function score = matrix_difference(matrix_A, matrix_B)

score = 0;

matrix_C = matrix_A - matrix_B;
[x_tot,y_tot] = size(matrix_C);

for y=1:y_tot
    for x=1:x_tot
        if matrix_C(x,y) == 0
        end;
        if matrix_C(x,y) ~= 0
            score = score + 1;
        end;
    end;
end;