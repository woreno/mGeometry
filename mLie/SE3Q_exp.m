function  A = SE3Q_exp(u)
    A = [ quaternion2matrix(u(4:end))];
    A(1:3,4) = [u(1) u(2) u(3)]';
end