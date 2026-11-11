% artigo de Horn
% Recovering Baseline and Orientation from ‘ Essential ’ Matrix
function m_Pr = essencial_horn(m_E)
 
    m_Pr = [];
    for z=1:2
        m_Es = ((-1)^z) * m_E;
        
        m_E2 = m_Es*m_Es';
        
        % equação 12 do 
        m_b2m = 0.5 * trace(m_E2)*eye(3) - m_E2;
    
        % esta matriz é bb' (é o produto entre vetor de translação, vetor
        % de translação transposto.
        % logoos valores na diagonal são os quadrados do vetor de
        % translação.
        % sao normalizados para precisão numerica, para isso, dividindo pelo
        % o maior valor; estão na equação 13 do artigo 
        
        m_b1 = sqrt(diag(m_b2m)');
        % m_b1 é o vetor final de translação
        m_b2 = -m_b1;
 
        m_B1  = [ 0             -m_b1(3)          m_b1(2);
                   m_b1(3)       0               -m_b1(1);  
                  -m_b1(2)      m_b1(1)           0  ];
        
        m_B2  = [ 0             -m_b2(3)          m_b2(2);
                   m_b2(3)       0               -m_b2(1);  
                  -m_b2(2)      m_b2(1)           0  ];

        
        % normalizar a matriz dividindo pela raiz quadrada do maior elemento
        % na diagonal 

        m_R1 = (cofactors(m_Es)'-m_B1*m_Es) / dot(m_b1,m_b1);
        m_R2 = (cofactors(m_Es)'-m_B2*m_Es) / dot(m_b2,m_b2);
    

        
        % Normalizar
        m_b1 = m_b1./max(abs(m_b1));
        m_b2 = m_b2./max(abs(m_b2));
        m_Pr = [ m_Pr  m_R1 m_b1' m_R2 m_b2'   ];
        
    
    end
    
    
    
end