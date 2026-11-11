% funcao de teste de geometria 2 vistas
%   in:
%       K: matriz de normalizacao (ex: sensor>im)
%       X1T, X2T: 2 conjunto de projecoes correspondidas X1T,X2T
%                       3xN [pt2; 1] vetores coluna homogens
%
%   op-in: 
%      'noAcerta'  nao corrige o sinal
%      'tri'            cria faces por delaunay
%
%   out:      
%       E F Ps :   matrizes E, Fundamental, Projecao  x 4 solucoes
%       X3:         pontos triangulados x 4 solucoes
%       Perr:       erro da tringulacao x 4 solucoes
%       tri2D:     malha delunay 2d
%       s, r:        as componentes de translacao e rotacao saidas do SVD
%                     usadas para calcular as bases de projecao
%       reprojs:  as reprojecoes usadas para calcular o erro x 4

function geo2 = m_geo2_compute(K, X1T, X2T, varargin)
        
    noAcerta =0;  
    doDelaunay = 0;
    argumentos(varargin);
     
    
    X3 = cell(4,1); 
    X2 = cell(4,1); 
    % matrizes de p que passaram o criterio
    camValidasIdx        = 1:4;
    % matrizes de rotacao que antes da correcao eram improprias
    rimprop                   =[];
    % erro da reprojecao
    Perr                        = [inf inf inf inf];
    
    
    
    if (doDelaunay)
        tri2D = delaunay( X1T(1,:), X1T(2,:) );
    end
    F = cv.findFundamentalMat(cols2cells(homogeneoustocart(X2T)),cols2cells(homogeneoustocart(X1T)),...
        'Param1', 0.002);
    E =  K' * F * K ; 
    [ U, D ,V ] = svd(E);
    X = [0,-1,0;1,0,0;0,0,1]; 

    s = U(:,3)/ max(abs(U(:,3)) ); 
    r{1} = (U*X*V');
    r{2}=  (U*X'*V'); 

    Ps0 = { [ r{1} s ], [ r{1} -s ], [ r{2} s ], [ r{2} -s ] };
    for i=1:4
       if (det(Ps0{i}(1:3,1:3))<0)
                rimprop(end+1)=i;
        end
    end
    if (noAcerta==0)
        r{1} = acertaR(U*X*V');
        r{2}=  acertaR(U*X'*V');
        % se for valida/ confirma que a solucao valida pelo o teste
        % de triangulacao
        Ps = { [ r{1} s ], [ r{1} -s ], [ r{2} s ], [ r{2} -s ] };
    else
        Ps  = Ps0;
    end
 
    % triangular todas as configs e reprojetar, calcular erro
    for i=1:4
        [X3_ X2_ Perr_]  = m_geo2_trirepro(X1T, X2T, K, Ps{i});
        X3{i} = X3_;
        X2{i} = X2_;
        Perr(i) = Perr_;
    end
    
    if (~isempty(camValidasIdx))
        [uv idx] =  min(Perr);
        camValidasIdx = idx;
    end
    geo2.X1T  = X1T;
    geo2.X2T  = X2T;
    
    geo2.E      = E;
    geo2.F      = F;
    geo2.Ps0  = Ps0;
    geo2.Ps    = Ps;
    geo2.camValidasIdx = camValidasIdx;
    geo2.X3 = X3;
    geo2.X2 = X2;
    geo2.Perr = Perr;
    geo2.s = s;
    geo2.r = r;
    geo2.rimprop = r;
    
    
    function R2 = acertaR(R)
        R2 = R;
        for i=1:2
            if (R2(i,i)<0)
               R2(:,i) = -R2(:,i);  
            end        
        end  
        R2(:,3) = vunit(cross(R2(:,1),R2(:,2))); 
        % z  = x (x) y 
        end
    end
    
    
function argumentos(args)
   i=0;
    while (i< size(args,2) )
        i=i+1;
        switch lower(  args{i}  )
            case 'noAcerta'    
               noAcerta = 1;
            case 'tri'
                doDelaunay = 1;
        end
    end
end
