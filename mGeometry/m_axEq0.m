function x0 = m_axEq0(P)
     [ U D V ] = svd(P); 
     x0  = V(:,end);
end
