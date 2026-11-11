function [ pts , wh ] = m_geo_rect(a,b)
   % reordem por fazer
    pts = [  a,  [b(1) a(2)]', b, [a(1) b(2)]'  ];
    wh =  (b-a);
    
end