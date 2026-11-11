% r, bbox: x y w h
% sz expansao
function r = m_expRect(r, bbox, sz)
    
    s2 = sz*2; 
    w = r(3)+ s2; 
    h = r(4)+s2; 
    r(1) = r(1)-sz;
    r(2) = r(2)-sz;
    r(3) = w ;
    r(4) = h ;
   
    if (r(1)< bbox(1)) 
        r(1) = 0;
    end
    if (r(2)< bbox(2)) 
        r(2) = 0;
    end
    
    bw  = bbox(1)+bbox(3);
    bh  = bbox(2)+bbox(4);
    if (r(1) + w>= bw) 
        r(3) = bbox(1)+bbox(3)-r(1);
    end
    
    if (r(2) + h>= bh) 
        r(4) = bbox(2)+bbox(4)-r(2);
    end
end