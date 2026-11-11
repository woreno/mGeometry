% devolve a representacao do plano Z=1 4x1 associado ao referencial 
%       in = [ t | rv ] 6x1
function plano = m_geo_ref2plano(ref)
        rt = SE3_exp(ref); rt = rt(1:3,1:4);
        t = rt(:,4);
        z = rt(:,3);
        d = (z+t)'*z; 
        plano = [ z' , -d ];
end