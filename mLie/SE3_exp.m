function  A = SE3_exp(u)
    A = [ angleaxis2matrix(u(4:6))];
    A(1:3,4) = [u(1) u(2) u(3)]';
end