% triangula e reprojeta 
% in:
%     X1i,X2i:      imagem
%     X1c,X2c:    camera 
%     M12:          RT no espaco normalizado    
%     K:                 
%
% out :
%           
%     X3:             triangulados {X1,X2} nas duas
%     X2:             reprojecoes {x1,x2} nas duas
%     Perr:           raiz da soma do seguinte
%     Perrs:          produto interno das diferencas
%     
function [X3, X2, Perr, Perrs]  = m_geo2_trireproC(X1i, X2i, X1c, X2c, K, M12) 
    NP = size(X1c, 2);
    IO = eye(3,4);    
    M12i = EXP_INV(M12);
    
    % triangular, projetar e calcular erro 
    X3_1 = linearTriangulation( X1c(1:2,:),  IO, X2c(1:2,:),  M12i);
    x2_1 = homogeneoustocartCols(K * X3_1);
    
    X3_2 = M12i(1:3,1:4)*[ X3_1; ones(1,NP)] ;
    x2_2 = homogeneoustocartCols(K * X3_2);

    diffx1 = [ x2_1 - X1i(1:2,:) ];
    diffx2 = [ x2_2 - X2i(1:2,:)];
    Perrs = { piCols(diffx1), piCols(diffx2) };
    Perr  =  sqrt (   sum([Perrs{1} Perrs{2}])     );
    X2 =  {x2_1,x2_2};
    X3 =  {X3_1,X3_2};
end