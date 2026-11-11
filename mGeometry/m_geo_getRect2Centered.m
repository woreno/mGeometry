% sz: impar
function r = m_geo_getRect2Centered(c,sz)
    l  = (sz-1)/2;
    l = [ -l -l ; l -l; l l; -l l ]';
    r  =[ c, c, c, c ] - l;
end