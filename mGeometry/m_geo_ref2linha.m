% devolve representacao de linha 3D 4x4
% associada sobre o versor Z do referencial
% (a representacao que advem da
%   matriz da concatenacao de 2 planos )
%       in = [ t | rv ] 6x1

function u = m_geo_ref2linha(r_)
        rt = SE3_exp(r_); 
        z = rt(1:3,3);
        t = rt(1:3,4);
        p1 = [ 0 -z(3) z(2) ]'; 
        p2 = vunit(cross(p1, z));  
        a = p1'*(t+z);
        b = p2'*(t+z); 
        u = [ p1' , -a ;  p2' , -b ];
end