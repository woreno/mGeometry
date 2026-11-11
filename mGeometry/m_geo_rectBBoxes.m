% vetores coluna
% 
%   in:
%           pt4                                vetor coluna
% out 
%       outer, inner
%           pts:  4 pontos            2x4      vetores coluna 
%           sw:   1 ponto, w, h     1x4      vetore linha
function rects = m_geo_rectBBoxes(xQuad)

    a = [ min(xQuad(1,:)) ,  min(xQuad(2,:))]';
    b = [ max(xQuad(1,:)) , max(xQuad(2,:))]';
    [ xQRo, xQRoW ] =  m_geo_rect(a ,b );
    rects.outer.pts =  xQRo;
    rects.outer.sw =[ xQRo(1,1) xQRo(2,1) xQRoW(1) xQRoW(2) ];

    a = [ max( xQuad(1,1),xQuad(1,4) ),  max( xQuad(2,1),xQuad(2,2) ) ]';
    b = [ min( xQuad(1,2),xQuad(1,3) ),  min( xQuad(2,3),xQuad(2,4) ) ]';
    [ xQRi, xQRiW ] =  m_geo_rect(a ,b );
    rects.inner.pts =  xQRi;
    rects.inner.sw =[ xQRi(1,1) xQRi(2,1) xQRiW(1) xQRiW(2) ];


end