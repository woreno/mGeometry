%           
%   devolve a reprojecao, da reflexao num plano situado a X1_3D
%   no referencial 1, dos versores identidade 2d 
%   num segundo referencial
%
%          _1_                  __
%     1  |         ==>      /
%         |                     /
%
function [ unitRepr, x3proj]  = m_geo2_reproj_u_ep_2vistas(X2, X1_3D,K, Kinv, M21)

    unitX3 = Kinv*[ [X2 X2 X2]+[0 0; 1 0; 0 1]'; 1 1 1]* X1_3D(3);
    x2 = homogeneoustocartCols( K*M21(1:3,1:4)*[ unitX3 ; ones(1,3)] );
    unitRepr = [x2(:,2)-x2(:,1) x2(:,3)-x2(:,1)];
    x3proj = x2(:,1);
end
