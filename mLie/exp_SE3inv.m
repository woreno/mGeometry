function  u2 = exp_SE3inv(A)
    R = matrix2angleaxis(A(1:3,1:3)); 
    u = [   A(1,4) A(2,4) A(3,4)  R(1) R(2) R(3)  ]';
    u2 = SE3_SE3inv(u);
end