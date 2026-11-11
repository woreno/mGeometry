%
%   * cria matriz de keypoints numa janela de vistas
%      apenas com os keypoints com z positivo
%
%   * escala as matrizes M12 e as triangulacoes para 
%      concordarem com a. translacao da primeira vista
%         
%   * devolve as matrizes concatenadas
%
%   in:
%       *vistas:     cells com estruturas geo2
%                       (ids de procs, coordenadas reproj, triang, etc)
%   
%   out:
%       *estrutura geo2win: 
%           .matrizPV               matriz com pontos em 
%           .matrizPVmask       comum x vista e mascara (pontos visiveis)
%
%           .X3                         respetivos pontos 3D na identidade
%                                         vetores coluna
%
%           .x2seq                    o ponto 2D em cada camera
%                                         na sequencia linha ponto x camera
%                                         vetores coluna
%
%           .refs/refsExp          as poses concatenadas (sim3/exp), 
%                                         a primeira na identidade 
%           
%       *append a vistas:                         
%                                         p{1/2}.X3   escalados
%                                         M12,            com t escalado
%                                         scAplicada    escala aplicada
%                                           

function [ geo2win , geo2s ] = m_geo2_assocAndScale(geo2s, procs, doScale)
%adicionar coluna entre os correspondidos vista 1 e 2
pmap = [  geo2s{1}.p{2}.xIds ];
% m point x  n views 
% matrizPV = [pmap', zeros(numel(pmap),numel(geo2s)-1) ];
matrizPV = [pmap', zeros(numel(pmap),numel(geo2s)-1) ];

for i=2:numel(geo2s)
  %  currente par
    cp.A  = geo2s{i}.p{1}.xIds;
    cp.B  = geo2s{i}.p{2}.xIds;
    % para cada elemento de A
    AKeys = [];
    PKeys = [];
    for ai=1:numel(cp.A)
        % procura em p
        idx = find(pmap==cp.A(ai));
        if (~isempty(idx))
            AKeys(end+1) = ai;
            PKeys(end+1) = idx;
        end
    end
    AKeysNot  = setdiff ( [1:numel(cp.A)], AKeys);
    PKeysNot  = setdiff ( [1:numel(pmap)], PKeys);
    
    pmap_  = pmap;
    % vao mudar a correspondencia A->B
    pmap_(PKeys) = cp.B(AKeys);
    pmap_(PKeysNot) = 0; %ok
    
    % adicionar nao correspondidas
    pmap_ = [pmap_ cp.B(AKeysNot)];
    
    matrizPV_ = zeros(numel(pmap_),numel(geo2s));
    matrizPV_(1:size(matrizPV,1),1:size(matrizPV,2)) = matrizPV;
    matrizPV_( : , i ) = pmap_';
    matrizPV = matrizPV_;
    pmap = pmap_;
end
    idxs = find(matrizPV(:,1)~=0);
    matrizPV = [ zeros(size(matrizPV,1),1) matrizPV ];
    matrizPV(idxs) = geo2s{1}.p{1}.xIds(idxs);
    
    
    % retirar de Matriz PV os pontos isolados
    % garante que exista um ponto antes da ultima vista
    %, e seja possivel aceder a relacao pelo o mm idx
    idxG1 = find( sum ( (matrizPV ~= 0)' )~=1);
    matrizPV = matrizPV(idxG1,:);    
    
    % cameras apartir da identidade / exp, sim3
    if (doScale)
        geo2s  = corrigirEscala(geo2s, matrizPV);
    end
    refsExp{1} = eye(4,4);
    M = eye(4,4);
    refs = [zeros(1,6) 1];
    for i=1: numel(geo2s)
        M12 =  geo2s{i}.M12;
        M = M*M12;
        refsExp{end+1}  = M;
        refs(end+1,:)      = [exp_SE3(M)' 1];
    end
   
    % pontos na primeira vista
    % encontrar primeira cam e trazer o ponto para identidade
    X3 = zeros(3,size(matrizPV,1));
    for ptid = 1: size(matrizPV,1)
        idxsbin  = matrizPV(ptid,:)~= 0 ;
        idsCam  = find(idxsbin);
        idsCam  =  idsCam(1);
        idKp      = matrizPV(ptid,idsCam);
        % encontrar o id associado ao id do kp, na relacao entre 2 vistas
        idX3 = find ( geo2s{ idsCam }.p{1}.xIds == idKp);
        M1i    = refsExp{ idsCam }(1:3,1:4);
        % aceder ao X3 triangulado na relacao, e traze-lo para identidade
        x3    = M1i * [ geo2s{ idsCam }.p{1}.X3( :,idX3); 1];
        % encontrar o lugar de X3 
        X3(:,ptid) = x3;  
    end
    
    % eliminar pontos se necessario de matrizPV
    % aqui criterio, deve estar a frente da primera cam
    idxsValidos = find(sum(matrizPV'~= 0) > 1 &  X3(3,:)>0);
    matrizPV = matrizPV(idxsValidos,:);
    X3           = X3(:,idxsValidos); 
    
    % unir as projecoes das cameras em sequencia
    % para entregar a BA
    matrizPVmask =  double(matrizPV ~=0);
    x2n    = numel(find(matrizPVmask(:)));
%     x2seq = zeros(2,x2n);
    x2seq = [];
    x2i_      = 1;
    for i=1: size(matrizPVmask,1)
        idxsbin     = matrizPVmask(i,:)~= 0 ;
        idsCam     = find(idxsbin); 
        for j=idsCam
            idKps                 =   matrizPV(i,j);
            x2seq(:,  x2i_)  =   procs{j}.lps{1}.ptsf(:,idKps) ;
            x2i_ = x2i_  + 1;
%             if ( idKps  <  size(procs{j}.lps{1}.ptsf,2) )
%                 x2seq(:,end+1)     = procs{j}.lps{1}.ptsf(:,idKps);
%                 x2i_                      =   x2i_ + 1;
%             else
%                 'ouch'
%             end
        end
    end   
    
    
    %
    geo2win.matrizPV          = matrizPV;
    geo2win.matrizPVmask  = matrizPVmask;
    geo2win.refsExp             = refsExp;
    geo2win.refs                  = refs;
    geo2win.X3                    = X3;
    geo2win.x2n                  = x2n;
    geo2win.x2seq               = x2seq;
    
end

function [geo2s] = corrigirEscala(geo2s, matrizPV)

% escalar translacao e triangulacao de cada 
% relacao entre cameras, usando os mesmos
% pontos na relacao anterior
geo2s{1}.M12s = geo2s{1}.M12;
geo2s{1}.scAplicada = 1;

for i=2: numel(geo2s)
    h = i-1;
    j  = i+1;
    reHI = geo2s{h};
    reIJ  = geo2s{i}; %refere-se as vistas  (i,i+1)
    % precisa-se dum ponto em comum a 3 vistas em simultaneo
    % (apenas os pontos emparelhados e que estao triangulados)
    %
    % vistaPar:                         hi           hj
    %                                     /     |     /      |  
    %    vista:                       h           i            j
    %   kp idx:                    35          40         10
    %
    %  
    %
    ptComIdx = matrizPV( find( matrizPV(:,h)~=0 & matrizPV(:,i)~=0 & matrizPV(:,j)~=0 ), h:j);
    sc = zeros(1,size(ptComIdx,1));
    for pidx = 1:size(ptComIdx,1) % para cada conjunto de pontos comuns a 3 vistas
        ids = ptComIdx(pidx,:);
        % ponto triangulado na relacao anterior 
        vi_idx = find( reHI.p{2}.xIds == ids(2) );
        Xi = reHI.p{2}.X3(:, vi_idx );
        % mesmo ponto triangulado na relacao seguinte 
        % com diferente escala
        vj_idx = find( reIJ.p{1}.xIds == ids(2) ); 
        Xj = reIJ.p{1}.X3(:, vj_idx );
        % ignorar pontos com uma reprojecao^2 > 1 e com Z negativo
        % porque provavelmente sao mas correspondencias
        if (  Xi(3) <= 0 | Xj(3) <= 0 | reHI.p{1}.x2repErr(vi_idx) >1 | reIJ.p{1}.x2repErr(vj_idx) >1   )
            continue; 
        end
        sc(pidx) = mean(  Xi(3)./Xj(3)   );
    end
    Mij =  geo2s{i}.M12;
    scMean = mean(sc);
    % escalar translacao e pontos pela media em z
    Mij(1:3,4)= scMean * Mij(1:3,4);
    geo2s{i}.p{1}.X3 = geo2s{i}.p{1}.X3 * scMean;
    geo2s{i}.p{2}.X3 = geo2s{i}.p{2}.X3 * scMean;
    geo2s{i}.M12 = Mij;
    geo2s{i}.scAplicada = scMean;
end

end