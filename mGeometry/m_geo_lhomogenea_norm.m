% normaliza uma linha homogenea para
% que esteja na fique na forma l = [ n  ,  -n'n]

function l2 = m_geo_lhomogenea_norm( l )
    a = -l(3)/( [l(1) l(2)]*[l(1) l(2)]' );
    l2 = l*a;
end

