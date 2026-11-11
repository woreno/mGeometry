% o mm eixo centrado em 2 views, 
% (o obitdo por exp: vps), qual translacao unitaria
%
% entra:
%           os dois eixos vistos em cada view R1,R2
%           correspondencia de pontos x1, x2 no espaco da cam
%
% sai:
%           M12
function [M12]= m_geo_tFromAxisObs2Views( R1, R2, x1,x2) 
    R12e = R1*R2';
%     'rt vect dete:'
%     [rad2deg(matrix2angleaxis(R1)');rad2deg(matrix2angleaxis(R2)')]
%     [ rad2deg(matrix2angleaxis(R12e)')]

    rv2 = (x2' * R12e'); % <--------------- e
    x1t = x1';

    % <x1(:,3)=1>
    A =  [ rv2(:,3).*x1t(:,2)-rv2(:,2)...
              rv2(:,1)-rv2(:,3).*x1t(:,1)...
              rv2(:,2).*x1t(:,1) - rv2(:,1).*x1t(:,2)  ];
          
%   teste a expressao perto de 0?
%     c =  A*t12; %   confirma OK 
    t12e =  vunit(m_axEq0(A));

% t12 pode vir com o sinal contrario porque tambem forma
% um plano epipolar valido, para 
% corrigir sinal t: se sentido t estiver no sentido correto,
% os pontos intersectam-se em z>0; no entanto, 
% como pode haver mas associacoes, tambem podem ocorrer
% triangulacoes z < 0 mesmo com t no sentido correto; 
% mudar sinal se maioria em z < 0; e marcar os restantes como
% devido a ma's correspondencias

    M12 = [ R12e  t12e; 0 0 0 1 ];
    IO = eye(3,4);    
    M12i = EXP_INV(M12);
    KP12i = M12i(1:3,1:4);
    X3  = linearTriangulation(x1,  IO,  ...
                                            x2,  KP12i);
    %
        
    zPosNum = numel(find(X3(3,:)>0));
    zNegNum = size(X3,2)-zPosNum;
    if (     zNegNum > zPosNum)
        t12e = -t12e;
    end
    t12e = vunit(t12e);
    M12 = [ R12e  t12e; 0 0 0 1 ];
    
end
    
    
    