function [  s, l ]= m_lineRhoTetaToS(rho,teta,box)
    versorO = [ cos(teta) sin(teta) ];
    versor =   [versorO(2) -versorO(1)];
    p0 = versorO*rho;
    p1 = p0 + versor;
    l = linhahomogenea(p0,p1);
    s = linhaIntersetadaComRegiao(l, box(1), box(2), box(3), box(4));       
end