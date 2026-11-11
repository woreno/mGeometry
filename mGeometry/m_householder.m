%reflete um vetor nd x sobre um plano v na origem
function hx = m_householder(v,x)
    n = norm(v,2)^2;
    hx = (eye(numel(x),numel(x)) - (v*v')*(2/n) )  * x;
end
