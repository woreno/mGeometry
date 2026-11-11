% devolve a representacao do plano Z=0 4x1 associado ao referencial 
%       in = [ t | rv ] 6x1
function plano = m_geo_ref2planoZ0(ref)
        rt = SE3_exp(ref);  
        t  = rt(1:3,4); 
        rz = rt(1:3,1:3)';
        rz = rz(3,1:3);
        plano = [ rz , -rz*t ];
end