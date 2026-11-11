% obtem contornos alisados por kernel gausiano
%   in: 
%         pontos  2D ( vetores coluna ), 
%         desvio padrao da gausiana / 2
%   out: 
%          novos pontos, 
%          coeficientes das curvaturas, 
%          inflecoes (indices dos pontos q passaram o teste do coef de curvatura)
function [ nc, k, infl ]  = m_alisaCurva(c, sigma)
    N = round( 2*( 1+ (sigma-0.8)/0.3 )  ); 
    NO2 = round(  (N-1)/2 ); 
    sigmaP2 = sigma^2;
    sigmaIP2 = sigmaP2^-1;
    sigmaIP4 = sigmaIP2*sigmaIP2;
    %gauss 
%         clc
%         N
    G = fspecial('gaussian', [ 1 N ], sigma );
%         size(G) 
%         size((-NO2:NO2))
    dGdu =  - G.*(-NO2:NO2)  * sigmaIP2;


    dG2du2 =  sigmaIP4  * G.*(  sigmaP2 - (-NO2:NO2).^2 ); 
    % ampliar a curva com os pontos dos extremos
    % para evitar comparações; admitir curva fechada
    c =   [ c(:,end-NO2:end)  c  c(:, 1:NO2 ) ] ;
    % nova curva
    nc = zeros( size(c) );  
    for u=NO2+1: size(c,2)-NO2
        % calcular o novo ponto  
        % convolução das componentes: produto interno as posições 2xN * Nx1 = 2XN
        nc(:,u) = c(:, u-NO2:u+NO2 ) * G';       
    end    

    % calcular curvatura em todos os pontos da nova curva
    k =  zeros( 1, size(c,2) );          
    for u=NO2+1: size(c,2)-NO2
            % necessario:
                %   2 primeiras derivadas da convolução anterior
                dXdu      = nc(:,  u-NO2:u+NO2 ) * dGdu';
                d2Xdu2  =  nc(:, u-NO2:u+NO2  )  * dG2du2';
                k(u) =  (dXdu(1)*d2Xdu2(2) -  dXdu(2)*d2Xdu2(1) )/ ( dXdu(1)^2 + dXdu(2)^2 )^(3/2);
    end    

    % encontrar inflexoes
    infl = [];          
    for u=NO2+1: size(c,2)-NO2-1
        if (   sign(k(u)) * sign(k(u+1)) < 0   ) 
            infl(end+1) =u-NO2+1; 
        end
    end

    % nova curva
    nc  = round(nc(:,NO2+1:end-NO2)); 
    k = k(:,NO2+1:end-NO2);
end