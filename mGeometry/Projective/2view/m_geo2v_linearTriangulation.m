%
%   triangula um ponto nas coordenadas do mundo 1ª ca,    
%   se conhecidas as projeções em dois planos e as
%   respetivas matrizes de projeção segundo
%   Hartley, Richard I.  Sturm, Peter
%   secção 5.1

% [ e mais uma forma de chegar ao produ externo 4ª
% wedge product confirma deps]

%  x0,x1 vetores coluna
%  P2 = KP21
%   o sistema linear homogeneo ?dado por
%       (P(3,:)*x - P(1,:) )X = 0 
%       (P(3,:)*y - P(2,:) )X = 0
% 
% vetores coluna in out
function  X = linearTriangulation( x0, P1, x1, P2 ) 
    X = zeros(3, size(x0,2));
    for i=1: size(x0,2)
        u1 = x0(:,i);
        u2 = x1(:,i);
        % equações para a primeira matriz    
        A = [
                P1(3,:)*u1(1)  - P1(1,:) ;
                P1(3,:)*u1(2)  - P1(2,:) ;
                P2(3,:)*u2(1)  - P2(1,:) ;
                P2(3,:)*u2(2)  - P2(2,:)  
            ]; 
       % decomposição SVD 
       [ U D V ] = svd(A,0);   % tal que U D V' = A 
       x = V(:,end)./V(end,end); % normalização
       X(:,i) = x(1:3);
    end 
end