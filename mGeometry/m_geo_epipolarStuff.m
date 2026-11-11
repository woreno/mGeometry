%deixa calculada numa estrutura 
%
% in: X3              3x1  na identidade
%      M1,M2        4x4

% X3:
%   xc:      na camera       
%   xcp:    no  plano da camera 
%   xi:       na imagem               
%   xcp1_2:     vetor x1 em x2 (paralelo)
%   xip1_2:      vetor x1 em x2 na imagem

% planos:
%  epc:      normal dos planos epipolares na cam
%  epi:       normal na imagem
%  epc_s:   segmentos epipolares na camera
%  epi_s:    segmentos epipolares na imagem
%  epi_se_2:          encurtado na 2a imagem
%                           pelo vetor paralelo em x2

% epipolos
%   eppc:     epipolo da camera 
%   eppi:      epipolo da camera na imagem

% t12 translacao 1->2 em 1

function S = m_geo_epipolarStuff(S, K1,M1,K2,M2,X3)
    M1i = EXP_INV(M1);
    M2i = EXP_INV(M2);
    M12 = M1i*M2;
    M21 = EXP_INV(M12);
    Ki1 = inv(K1);
    Ki2 = inv(K2);
    imSz1 = K1*[1;1;1];
    imSz2= K2*[1;1;1];
    
    
    S.M1 = M1;
    S.M2 = M2;
    S.Ms  ={M1,M2};
    
    S.t12  = M12(1:3,4);
    S.xw   = X3;
    
% X3:
%   xc:      na camera       
    S.xc1 = M1i(1:3,1:4) * [X3;1];
    S.xc2 = M2i(1:3,1:4) * [X3;1];
        S.xcs = {S.xc1, S.xc2};
    
%   xcp:    no  plano da camera 
    S.xcp1  = [ homogeneoustocart( S.xc1 );  1];
    S.xcp2  = [ homogeneoustocart( S.xc2 );  1];
        S.xcps= {S.xcp1, S.xcp2};
        
%   xi:       na imagem               
    S.xi1  = homogeneoustocart( K1*S.xc1 ); 
    S.xi2  = homogeneoustocart( K2*S.xc2 ); 
        S.xis = {S.xi1, S.xi2};
    
%   xcp1_2:     vetor x1 em 2 (paralelo)
    S.xcp1_2 = [homogeneoustocart( M21(1:3,1:3)*S.xcp1); 1];
    S.xip1_2 = K2 * S.xcp1_2;
    
%  epc:      normal dos planos epipolares na cam
    S.epc1   = vunit ( cross(  S.xc1, S.t12 ) ) ;
    S.epc2   = M12(1:3,1:3)' * S.epc1;
        S.epcs = {S.epc1,S.epc2};
        
%  epi:       normal na imagem
    S.epi1 = Ki1'* S.epc1;
    S.epi2 = Ki2'* S.epc2;
        S.epis = {S.epi1,S.epi2};
        
%   eppc:     epipolo na camera na camera oposta
    S.eppc1  = [ homogeneoustocart( M21(1:3,4) ); 1];
    S.eppc2  = [ homogeneoustocart( M12(1:3,4) ); 1];
    
%   eppi:      epipolo na camera na camera oposta (imagem)
    S.eppi1 = K1*S.eppc1;
    S.eppi2 = K2*S.eppc2;
     
%  epi_s:    segmentos epipolares na imagem
    S.epi1_s = linhaIntersetadaComRegiao(S.epi1, 0,0,imSz1(1), imSz1(2));
    S.epi2_s = linhaIntersetadaComRegiao(S.epi2, 0,0,imSz2(1), imSz2(2));
        S.epis_s = { S.epi1_s, S.epi2_s };

    if (size(S.epi1_s,2)<2)
        return;
    end
        
%  epc_s:   segmentos epipolares na camera
%  epipolar camera segmento (extremos)
    S.epc1_s = Ki1 * [S.epi1_s; ones(1,2)];
    S.epc2_s = Ki2 * [S.epi2_s; ones(1,2)];
        S.epcs_s = { S.epc1_s, S.epc2_s };
         
% segmentos epipolar encurtados na 2 cam
% intersecoes do plano, epipolo 1 em 2, vetor paralelo a 1

    % L         ou       R,       centro1 p em 2    x1 em 2
    exts = [ S.epc2_s ,    S.eppc1,                       S.xcp1_2 ] ;
    xc2p = [ homogeneoustocart( S.xc2); 1];
    vexts = exts  - repmat(xc2p,1,4);
    v = vunit(S.xc2 - S.eppc1);
    d  = v'*vexts;
    
    negIdx = find(d<0);
    [va, vidx] = min(abs(d(negIdx)));
    A = exts(:,negIdx(vidx));
    
    posIdx = find(d>=0);
    exts_vus = vunitsCols(exts);
    [va, vidx] = min(abs(d(posIdx)));
    B = exts(:,posIdx(vidx));
      
    S.epc2_se = [A B];
    S.epi2_se  = homogeneoustocartCols( K2*S.epc2_se );
 
    S.Ms = {M1,M2};
end