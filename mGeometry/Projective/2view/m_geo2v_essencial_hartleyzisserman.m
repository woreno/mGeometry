
function m_Pr = essencial_hartleyzisserman(m_E)

    
    m_W =zeros(3,3);
    m_W(1,2)=-1;
    m_W(2,1)=1;
    m_W(3,3)=1; 
    [m_E_U m_E_S m_E_V] = svd(m_E,0);   
    U3 = m_E_U(:,3)./max(abs(m_E_U(:,3)));
    
    m_Pr= [  m_E_U * m_W * m_E_V'  U3    m_E_U * m_W * m_E_V'   -U3      m_E_U * m_W' * m_E_V'  U3          m_E_U * m_W' * m_E_V'   -U3 ];
end