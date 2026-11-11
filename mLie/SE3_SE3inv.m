function u2 =SE3inv(u)
    M = SE3_exp(u);
    Mt = M;
    Mt(1:3,1:3)  = (M(1:3,1:3)');
    Mt(1:3,4)  = (-M(1:3,1:3)' * M(1:3,4) );
    u2 = exp_SE3(Mt); 
end