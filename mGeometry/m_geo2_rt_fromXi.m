% funcao de teste de geometria 2 vistas
%   in:
%       K: matriz de normalizacao (ex: sensor>im)
%       X1T, X2T: 2 conjunto de projecoes correspondidas X1T, X2T
%                       2xN 
%   op-in: 
%      'ransacTh',th      threshold de inliners de ransac
%                                para encontrar fundamental x2' F x1 <= th
%                                   *  especificando um ou outro, a 
%                                       distancia ortogonal do oposto `a
%                                       linha epipolar formada (def: 0.002)
%      'noAcerta'           nao corrige o sinal  
%
%      'metodo', str       str='hs', 
%       
%                                    yima       decomp SVD a 3d invitation...
%                                    hs1         decomp SVD MVG
%                                    hs2            
%                                    horn
%

%   out:      
%       E F Ps :   matrizes E, Fundamental, Projecao  x 4 solucoes
%       X3:         pontos triangulados x 4 solucoes
%       Perr:       erro da tringulacao x 4 solucoes
%       tri2D:     malha delunay
%       s, r:        as componentes de translacao e rotacao saidas do SVD
%                     usadas para calcular as bases de projecao
%       reprojs:  as reprojecoes usadas para calcular o erro x 4

%       
%
function [E,F,Ps,camValidasIdx, X3, Perr, tri2D, s , r, rimprop, reprojs, inliners, inlinersV] = ...
                     m_geo2_rt_fromXi (K, X1i, X2i, varargin)
           
    op.debug = 0;
    op.ransacTh = 0.005;
    op.inlinerTh = 0.15;
    noAcerta =0;  
    op.method = 'yima';   %'hs1' 'hs2' 'horn';
    argumentos(varargin);
    KI = K*eye(3,4); 
    X3 = {}; Perr = [inf inf inf inf];
%     tri2D = delaunay( X1T(1,:), X1T(2,:) );
    tri2D = [];
    
    X1T = cart2homogeneousCols(X1i);
    X2T = cart2homogeneousCols(X2i);
    
    % opencv: o criterio epipolar e  x2 F x1 = 0, a funcao aceita x1, x2.
    % a decomposicao que faco aqui e do tipo x1 F x2 = 0, pelo que uso
    % os argumentos trocados na funcao de opencv x2,x1.
     F = cv.findFundamentalMat(cols2cells(X2i),cols2cells(X1i),...
                                                'Param1', op.ransacTh );
    inlinersV = zeros(1,size(X1T,2));
    for i=1:numel(inlinersV)
        inlinersV(i) = abs( X1T(:,i)'*F*X2T(:,i) ) ;
    end 
    inliners = find(inlinersV <= op.inlinerTh);
    
    camValidasIdx = []; 
    rimprop =[];
    E =  K' * F * K ; 
    [ U, D ,V ] = svd(E);
   
    
    if ( strcmp( op.method , 'hs') )
        X = [0,-1,0;1,0,0;0,0,1]; 
        s = U(:,3)/ max(abs(U(:,3)) ); 
        r{1} = (U*X*V');
        r{2}=  (U*X'*V'); 
        Ps = { [ r{1} s ], [ r{1} -s ], [ r{2} s ], [ r{2} -s ] };
        for i=1:4
           if (det(Ps{i}(1:3,1:3))<0)
                rimprop(end+1)=i;
           end
        end
        if (noAcerta==0)
            r{1} = acertaR(U*X*V');
            r{2}=  acertaR(U*X'*V');
        end
        % se for valida/ confirma que a solucao valida pelo o teste
        % de triangulacao
        Ps = { [ r{1} s ], [ r{1} -s ], [ r{2} s ], [ r{2} -s ] }; % r21 t12
    else
        
        
        if ( strcmp( op.method , 'yima') )
            Ps = cell(2,1);
            
            rz  = angleaxis2matrix([0,0,pi/2]); rz = rz(1:3,1:3);
            s = U*rz*D*U';
            r = U*rz'*V';
            Ps{1} = [r s];
            
            rz  = angleaxis2matrix([0,0,-pi/2]); rz = rz(1:3,1:3);
            s = U*rz*D*U';
            r = U*rz'*V';
            Ps{2} = [r s];
            
        else
            if ( strcmp( op.method , 'hs2') )
        %     Fvgg = cv.findFundamentalMat(cols2cells(X1i),cols2cells(X2i),...
        %                                                 'Param1', op.ransacTh );
        %     vgg_P12 = vgg_P_from_F(Fvgg);
        %     [vggK, vggR, vggt] = vgg_KR_from_P(vgg_P12);
        %     vggK
        %     m_geo2_imprimeExponencial(vgg_P12);
            else
                  if ( strcmp( op.method , 'horn') )
                      
                  end
            end
            
        end
        
    end
     

    camZpos= zeros(1,4);
    camValidasIdx = 1:numel(Ps);
    reprojs = {};   
    if (~isempty(camValidasIdx))
        for i=1:numel(Ps)
            M12 = Ps{i};
            M21 = EXP_INV(M12);
            X3{i}  = linearTriangulation(X1i,  KI,  X2i,  K*M21);
    
            X3_2  = M21*[ X3{i}; ones(1,size(X3{i},2))];
            Xc      = K*X3_2;
            x        = homogeneoustocartCols(K*Xc); 
            
            camZpos(i) = numel(find(  X3{i}  (3,:)>0)) + numel(find( X3_2 (3,:)>0)) ;            
            
            dx = ((x) - X2T(1:2,:));
            Perr(i) = sum(normsCols(dx));
            reprojs{end+1} = x;
        end
    end
    
     
   %  dos z's positivos escolhe o que tem menor erro
   camValidasIdx  = find(camZpos>0);
   if (isempty(camValidasIdx))
       return;
   end
   [val, minErrIdx] = min(Perr(camValidasIdx));
   minErrIdx = intersect(  camValidasIdx, find(Perr  == val) );
   
   if (numel(minErrIdx)>1) % desempate pelo o maior numero de pontos a frente
       [val, minErrIdxB] = max(camZpos(minErrIdx));
       camValidasIdx = minErrIdx(minErrIdxB);
   else
      camValidasIdx = minErrIdx;
   end
   
    if (op.debug)
        fig = figure(6) ; 
        ax = uiaxes([2 2]);
        set(ax, 'YDir', 'normal');
        for i=1:4
             axes(ax(i));
             hold on; 
             m_plot3axis(eye(3,3), 'colors', eye(3,3));
             hg = hgtransform;
             h = m_plot3axis(eye(3,3), 'colors', eye(3,3));
             set(h, 'parent', hg); 
             set(hg, 'matrix', [Ps{i}; 0 0 0 1]);
             str = ['t' num2str(i) ':' num2str(camZpos(i))];
             if (camValidasIdx==i)
                 str = ['>' str ];
             end
             m_plot3vector(Ps{i}(1:3,4)', 'color', [ 0 0 0 ], 'l', str);
             view(0,0);
             axis equal;
             hold off;
        end
        set(fig, 'position', [680     9  1112   957]);
        grid on;
    end
    
   
   
   
   
   
    % se3, pts 3d, pts na 2ª cam (u1,u2 cameras na ident)
    function err = erroProjecao(u1, u2, X3, X1T, X2T) 

        err = 0;
        err1  = ( sum ( normsCols (   X1T(1:2,:) -   homogeneoustocartCols( [  P1* cart2homogeneousCols(X3)  ] )   ) ) );  
        err2  = ( sum ( normsCols (   X2T(1:2,:) -   homogeneoustocartCols( [  P2* cart2homogeneousCols(X3)  ] )       )        )    );  
        err = sqrt(err1+err2);
    end

    function R2 = acertaR(R)
        R2 = R;
        for i=1:3
            if (R2(i,i)<0)
               R2(:,i) = -R2(:,i);  
            end        
        end  
        end
    end
    
function argumentos(args)
   i=0;
    while (i< size(args,2) )
        i=i+1;
        switch lower(  args{i}  )
            case 'noAcerta'    
               noAcerta = 1;
            case 'ransacth'
                op.ransacTh = args{i};
                i = i+1;
            case 'method'
                op.method = args{i};
                i = i+1;
        end
    end
end