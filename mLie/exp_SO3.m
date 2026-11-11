function  u = exp_SO3(A)
    u = matrix2angleaxis(A(1:3,1:3));
end