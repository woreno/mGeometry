function  A = SE3_expinv(u)
     A = SE3_exp(u);
     A = EXP_INV(A);
end