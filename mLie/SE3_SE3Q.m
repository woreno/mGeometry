function  A = SE3_SE3Q(u)
    q = [ angleaxis2quat(u(4:end))];
    A = [ u(1) u(2) u(3) q(1) q(2) q(3) q(4) ]';
end