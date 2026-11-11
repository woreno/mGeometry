function m2 = EXP_INV( m ) 
    if (det(m(1:3,1:3) )== 1)
        m2 = m;
        m2(1:3,1:3) = m2(1:3,1:3)';
        m2(1:3,4) = -m(1:3,1:3)'* m(1:3,4);  
    else
        % escala
        m2 = m;
        in = 1/norm(m(1:3,1),2);
        m2(1:3,1:3) = in*vunitsCols(m2(1:3,1:3))';
        m2(1:3,4) = -in*m(1:3,1:3)'* m(1:3,4);  
    end

end