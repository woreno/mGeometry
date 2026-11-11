% devolve representacao de linha 3D 2x4
% associada sobre o versor 
% (a representacao que advem da
%   matriz da concatenacao de 2 planos )
%       in = v

function u = m_geo_versor2linha(z)
        p1 = [ 0 -z(3) z(2) ]'; 
        p2 = vunit(cross(p1, z));  
        a = p1'*(z);
        b = p2'*(z); 
        u = [ p1' , -a ;  p2' , -b ];
end