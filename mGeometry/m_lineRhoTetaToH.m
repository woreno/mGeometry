
function [  l ]= m_lineRhoTetaToH(li)  
rho=li(1);
teta=li(2);
versorO = [ cos(teta) sin(teta) ];
    versor =   [versorO(2) -versorO(1)];
    p0 = versorO*rho;
    p1 = p0 + versor;
    l = linhahomogenea(p0,p1);
end