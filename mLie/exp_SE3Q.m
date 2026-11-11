function  u = exp_SE3Q(A)
    R = matrix2quaternion(A(1:3,1:3));
    u = [   A(1,4) A(2,4) A(3,4)  R(1) R(2) R(3)  R(4)]';
end