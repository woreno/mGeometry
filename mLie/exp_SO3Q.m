function  q = exp_SO3Q(A)
    q = matrix2quaternion(A(1:3,1:3));
end