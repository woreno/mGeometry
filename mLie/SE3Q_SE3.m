function  A = SE3Q_SE3(u)
   a = u(4:7);
    A = [ u(1) u(2) u(3)   quat2angleaxis(a(:)') ]';
end