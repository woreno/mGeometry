
function matr2 = m_geoQuat4AngleDeg(matr)
    matr2 = zeros(size(matr));
    q = find( (matr>=0 & matr<22.5) | (matr>157.5));
    matr2(q) = 1;
    for i=1:3
        a = 22.5+45*(i-1);
        q= find( matr>=a & matr<a+45);
        matr2(q) = i+1;
    end
end