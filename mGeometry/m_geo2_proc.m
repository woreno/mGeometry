
% out:
% geo2
%   .inliners
%   .p{V} xIds,x2,xc, x2rep, X3
%             : ids dos vetores no original procs{V}
%               vetores na imagem, na camera
%               reprojecao, triangulacao (apenas em 1)
%   
%
%       depende de m_geo2_tFromAxisObs2Views
%                         m_geo_2tFromPts
% 
%   opcional:
%           'procoptions'           matrizes K, Kinv
%           'debug'                    visualizacao do LM
function [ geo2 ] = m_geo2_proc(match, procs, l, varargin)

    procOps.K = eye(3,3);
    procOps.distortion_coefficients  = [ 0 0 0 0 0 ];
    
    ops.debug =0;
    ops.tukey = 0;
    if (ops.debug)
        fig = figure();
        set(fig , 'position',[133    51  1125   879]);
        ops.dg.axs = uiaxes([2 2]);
        ops.dg.objs = [];
        ops.dg.errHist = [];
        for i=1:2 
            axes(ops.dg.axs(i));
            image(procs{i}.im);
        end
        set( ops.dg.axs(3) , 'YDir', 'normal');
        set( ops.dg.axs(4) , 'YDir', 'normal');
    end
    
    ops.method = 'vps';
    ops.doUndistort                 = 0;
    ops.doRansac                    = 1;
    
    ops.ransacMaxSetProp       = 0.25;
    ops.ransacMTrials               = 35;
    ops.ransacMDataTrials        = 15;
    ops.ransacInlinerReprojTh  = 4; %(pixel)
    %
    ops.doOpt                          =  1;
    ops.optMaxIts                    =  25;
    argumentos(varargin);
    
    n = size(match{1}.lps{l}.assocPts,2); 
     if (ops.doRansac)
        ops.ransacMinModelPts =  min( floor(ops.ransacMaxSetProp*n), n) ;
     end
     
    % copia de match
    for i=1:2
        xIds{i}    = match{i}.lps{l}.assocIds;
        if (ops.doUndistort)
           x2{i}    = m_undistortPoints( match{i}.lps{l}.assocPts,  procOps.K, procOps.distortion_coefficients);
        else
           x2{i}    = match{i}.lps{l}.assocPts;
        end
        xc{i}       = procOps.Kinv *[ x2{i}; ones(1,n)  ];
    end 
    inliners = 1:numel(xIds{1});

                %   se a causa da ma estimacao e' a distorcao,
                %   os inliners estarao distribuidos mais ao centro da imagem
                %   onde tem menos distorcao radial,
                %   debug votos de inliners no plano cartesiano:
                %     T.inlinerMap = zeros( size(x1c,2 ) , 1);  
    
% usar vps para estimar a rotacao?
    if (strcmp(ops.method ,'vps')),  
        fromVpsAndKps(); 
    else
        fromKps();
    end

% optimizar?
    if (ops.doOpt)
        optSE3(); 
    else
        geo2.M12 = geo2.M12e;  
    end 
     
% triangular com a matriz final
    [X3s, x2s, geo2.err, x2errs]  =...
                    m_geo2_trireproI(x2{1},  x2{2}, ...
                                                 procOps.K, geo2.M12 );
    
% retirar triangulados atras da camera 
    badIdxs     = find(X3s{1}(3,:)<= 0 | X3s{2}(3,:)<= 0);
    goodboys   = setdiff( 1:size(X3s{1},2) , badIdxs );
    
%terminar estrutura
    for i=1:2
        geo2.p{i}.xIds               = xIds{i}(goodboys);  % indices de proc.lps.ptsf
        geo2.p{i}.x2                  = x2{i}(:,goodboys);  % pontos copiados
        geo2.p{i}.xc                   = xc{i}(:,goodboys);  % cam
        geo2.p{i}.X3                  = X3s{i}(:,goodboys);  % triangulado
        geo2.p{i}.x2rep             = x2s{i}(:,goodboys); % reprojecao 
        geo2.p{i}.x2repErr         = x2errs{i}(:,goodboys); % pis da reprojecao
    end
    geo2.errMse =  geo2.err/numel(geo2.p{1}.xIds);
    
    
% -----------------------------------------------------------
% -----------------------------------------------------------
% -----------------------------------------------------------
    
% ATRAVES DE KP APENAS
function fromKps()
    % usar kps
      geo2.M12e = [];
      [E, F,  Ps,  camValidasIdx,  X3,  Perr,  tri2D, t,  r,  rimprop, reprojs,  inliners ] = ...
            m_geo2_rt_fromXi ( procOps.K, x2{1},x2{2});
      geo2.M12e = [ Ps{camValidasIdx}; 0 0 0 1];
        
    %retirar outliers
    for i=1:2
        xIds{i} = xIds{i}(:,inliners);
        xc{i} = xc{i}(:,inliners);
        x2{i} = x2{i}(:,inliners);
    end 
    
end
 
% ATRAVES DE VP + KP
function fromVpsAndKps()
% obter sabendo de antemao a
% orientacao da camera relativa a um eixo de rotacao natural
% em duas vistas
    geo2.M12e = [];
    if (ops.doRansac) 
        [geo2.M12r ,  inliners ] =...
            ransacCustom( 1:n, ...                                                % objetos
            @fromVpsAndKps_ransacProduzirModelo,...                % produzir o modelo
             [],...
            @ransacAvaliarModelo,...
            @ransacDegenModelo,...
            ops.ransacMinModelPts , ...                                                     % minimo de pontos 
            ops.ransacInlinerReprojTh,...                                              % erro de projecao individual
            ops.debug, ops.ransacMDataTrials, ...
            ops.ransacMTrials);       
        
            geo2.M12e = geo2.M12r; 
        if (ops.debug)
            disp(['*** Com Ransac '  num2str(numel(inliners)) ' inliners de set de ' num2str(size(xc{i},2)) ]);
            disp(['       modelos com ' num2str(  ops.ransacMinModelPts ) ' pontos' ]);
            m_geo2_imprimeExponencial(geo2.M12e);
        end
        
        %retirar outliers
        for i=1:2
            xIds{i} = xIds{i}(:,inliners);
            xc{i} = xc{i}(:,inliners);
            x2{i} = x2{i}(:,inliners);
        end 
    end
    
    % se ransac nao conseguiu / sem ransac
    if (isempty(geo2.M12e))
        geo2.M12e = m_geo2_tFromAxisObs2Views(procs{1}.axEst,procs{2}.axEst,x1c, x2c);
    end
end
function M                     = fromVpsAndKps_ransacProduzirModelo(idxs,params)
        M = m_geo2_tFromAxisObs2Views(procs{1}.axEst, ...
                                                           procs{2}.axEst, ...
                                                           xc{1}(:,idxs), ...
                                                           xc{2}(:,idxs));
%      disp(['****geracao de modelo: ']);
%      imprimeExponencial(M);
%      disp(['---']);
end
function [inliners, Mij]   = ransacAvaliarModelo(Mij, idxs, thrsld, params)
    
    %triangular amostra dada por idxs
    for i=1:2
        x2_{i}= x2{i}(:,idxs);
        xc_{i}= xc{i}(:,idxs);
    end
    [X3_, X2_, Perr_, Perrs_] = m_geo2_trireproI(x2_{1}, ...
                                                                             x2_{2}, procOps.K, Mij);
%     [X3_, X2_, Perr_, Perrs_] = m_geo2_trireproC(x2_{1}, ...
%                                                                              x2_{2}, ...
%                                                                              xc_{1}, ...
%                                                                              xc_{2}, procOps.K, Mij);
    PerrC  = sqrt( Perrs_{1}+Perrs_{2} );
    inliners = idxs(find(   ( X3_{1}(3,:)> 0) & ( X3_{2}(3,:)> 0) & PerrC < thrsld));
    
%     disp(['****avaliacao modelo:  err:'  num2str(Perr_)  '  inliners:' num2str(numel(inliners)) ' de ' num2str(numel(idxs)) ]);
%     imprimeExponencial(Mij);
%      disp(['---']);
%     T.inlinerMap(inliners) = T.inlinerMap(inliners) + 1;
    
%     for i=1: numel(idxs)
%     T.inlinerMap(idxs) = T.inlinerMap(idxs)
    
%     figure,
%     cla, hold on; grid on;
%     n = numel(idxs);
%     repsErrs =[Perrs{1} Perrs{2}];
%     MMerr =  [  min(repsErrs) max(repsErrs) ];
%     for i=1:n
%         if ( X3(3,i)<=0 ) 
%             h = rectangle('position', [ i MMerr(1) i+1 MMerr(2) ]); 
%             set(h, 'facecolor', [0.5 0.5 0.5]); 
%         end
%     end
%     
%     plot(Perrs{1},'color', 'red');
%     plot(Perrs{2}, 'color', 'red');
%     plot([1 n],[thrsld  thrsld]  , 'color', 'red');
    
end
function r                      = ransacDegenModelo(M, avaliarModeloFunc)
    r = 0;
end

% LM
function optSE3()
    options = optimset('fsolve');
    options.Display =  'off';
    options.MaxIter = ops.optMaxIts;
    %     options.MaxFunEvals = 5000;
    options.Algorithm ='levenberg-marquardt';
    se3 =  exp_SE3( geo2.M12e ) ;
%     figure(); hold on;
    [se3_out,   fval  , exitflag ,  output] = fsolve(@testeAvaliacaoSE3, se3, options);
    geo2.M12 =  SE3_exp(se3_out);
    
    if (ops.debug)
        disp(['*** Com optimizacao']);
        m_geo2_imprimeExponencial(geo2.M12);
    end 
end 
function erro                 = testeAvaliacaoSE3(se3)
    M12 = SE3_exp(se3);  
%     [X3_,  X2_,  erro] = ...
%             m_geo2_trireproC( x2{1},x2{2},xc{1},xc{1},  ...
%                                           procOps.K, M12);  
    [X3_, X2_, erro_, Perrs_] = ...
                m_geo2_trireproI( x2{1},x2{2},procOps.K, M12); 
            
    if ( ops.tukey )
        % aplicar tukey
        errs            = [Perrs_{1} Perrs_{2}];
        % retirar media
        err_mean   = mean(errs);
        err_std       = std(errs);
        nerrs          = abs(errs  -  err_mean);
        c           = err_std*0.95; 
        c_const = c *c / 6;
        for i=1: numel(nerrs)
            R = nerrs(i);
            if (  R > c ) 
                nerrs(i) =  c_const;
            else
                nerrs(i) =  c_const * (  1 - (  1 - (R/c)^2 )^3 );
            end
        end
        erro = sqrt(nerrs*nerrs');
    else
        erro = erro_;
    end
    
    if (ops.debug)
        ops.dg.errHist(end+1)  = erro_;
    
        if ( ~isempty( ops.dg.objs )  )
            delete( ops.dg.objs);
        end
        ops.dg.objs = [];
        axes(ops.dg.axs(1)); 
        hold on;
        str = ['erro ' num2str(erro_) '(' num2str(erro_/size(x2{1},2)) ' por pixel)'];
        if (ops.tukey)
            str = [ str ' tukey on'];
        end
        ops.dg.objs(end+1) = text(10,10, str, 'fontweight', 'bold', 'fontsize', 15, 'backgroundcolor', [1 0 0], 'color',[1 1 1 ]);
        
        for j=1:2
            axes(ops.dg.axs(j)); 
            hold on;
            for i=1:size(x2{j},2)
                m = [ x2{j}(:,i) X2_{j}(:,i) ];
                ops.dg.objs(end+1) = plot(m(1,:),m(2,:), 'linewidth', 2, 'color', 'yellow'); 
                ops.dg.objs(end+1) = plot(m(1,1),m(2,1), 'sg', 'linewidth', 2); 
                ops.dg.objs(end+1) = plot(m(1,2),m(2,2), 'sr', 'linewidth', 2); 
            end
        end
%         axes(ops.dg.axs(3));  hold on; 
%         ops.dg.objs(end+1) = bar(errs);
        
        axes(ops.dg.axs(4));  cla; hold on; 
        plot(ops.dg.errHist, 'linewidth', 4 , 'color', 'red');
        
        pause(0.01);
    end
%     disp(['****optimizacao LM']);
%     imprimeExponencial(M12);
%     disp(['---']);
end 

%
function argumentos(args)
   i=0;
    while (i< size(args,2) )
        i=i+1;
        switch lower(  args{i}  )
            case 'method'
                ops.method = lower(args{i+1});                    
                i = i+1;
            case 'opt'
                ops.doOpt = strcmp(lower(args{i+1}), 'on');
                if ( ops.doOpt )
                    ops.optMaxIts = args{i+2};
                    i = i+2;
                else
                    i = i+1;
                end
            case 'undistort'
                ops.doUndistort = 1;
            case 'options'
                ops =   args{i+1};
                i = i+1;
            case 'debug'
                ops.debug  = 1;
            case 'procoptions'
                procOps =   args{i+1};
                i = i+1;
        end
    end
end
    
end

    % ver inliners distribuidos na grid
%     figure, hold on;
%     im = zeros([480 640]);
%     for i = 1: numel(T.inlinerMap )
%         pt = T.procs{1}.lps{l}.assocPts(:,i);
%         im(pt(2),pt(1))  = T.inlinerMap(i);
%     end
%     im  = cv.blur(im,'KSize', [5 5]); 
%     imagesc(im); 


% 
% p = procs{1};   
% if (isfield(p,'mainLinesSegIdxPerVP'))
% % obter segmentos de linha principais
% % atraves dos pontos triangulados 
% % para os segmentos principais, acumular
%     p.mainLinesPtsIdxs = {};
%     p.mainLinesX3 = {};
%     for vp= 1:numel(p.mainLinesSegIdxPerVP)
%         
%         mainLines = p.mainLinesSegIdxPerVP{vp};
%         for i=1: numel(mainLines)
%             linesIdxs = mainLines{i};
%             assocIdxs  = [ p.lines(linesIdxs).ptsIdxs ];
%              % pontos 3d associados a esta linha
%             X3 = T.geo2.X3(:, assocIdxs);
%             res = find (X3(3,:)>0);
%             if ( isempty(res) )
%                 p.mainLinesX3{vp}{i} = [];
%                 continue;
%             end
%             X3 = X3(:,res);
%             X3 = X3 (: ,  find ( X3(3,:) == mode(X3(3,:)) )  );
%             X3 = X3(:,1); 
%             
%             
%             X3e = p.axEst'*X3;
%             
%             % extremos das linhas 2D
%             l_x  = p.axEst'*T.Kinv* [ p.mainSegsPerVP{vp}{i}; 1 1];
%             l_x3d = [ l_x(:,1)./l_x(3,1) l_x(:,2)./l_x(3,2)]*X3e(3);
%             % coordenadas de vp
%             l_x3d  = p.axEst * l_x3d ;
%             
%             p.mainLinesX3{vp}{i} = l_x3d ;
%         end
%         
%     end
% end
%     procs{1} = p;
%     T.procs = procs;
%     