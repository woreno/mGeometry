% coordenadas  e arestas dum hipercubo centrado
% de aresta 1 centrado em 0
%   FE: edges/fac
%   FC:
% exp [pts arestas] = getHypercubo(3)
%
%

function [ pts arestas FE FC FP ] = getHypercubo(dims, varargin)

    % pontos
    v = [];
    for i=0:dims-1
        b = 2^(dims-i-1); 
        v(:, dims-i) = repmat( [ zeros(2^i,1); ones(2^i,1) ], b, 1);
    end
    pts =v;
    % matriz simetr de arestas 
    e = zeros( size(pts,1),  size(pts,1)   );
    ec = zeros( size(pts,1),  size(pts,1)   );
    for i = 1: size(pts,1)
        % por cada dimensao uma aresta,
        for j=1:dims
            pt = pts(i,:); 
            pt(j)=~pt(j);
            k = bin2dec(num2str(pt)); 
            e(i, k+1) = 1;
            ec(i, k+1) = j; % dimensao da arestas
        end    
    end
    
      
    arestas = []; 
    for i = 1: size(pts,1)
        for j= i: size(pts,1)
            if (e(i,j))
                arestas(:,end+1) = [i j]';
            end
        end
    end
    pts=v;
    
    % ca 
    % corner-arestas
    ca = zeros( size(pts,1), size(arestas,2)  ); 
    for i = 1: size( pts, 1  ) 
            ca(i, [ find(arestas(1,:)==i)  find(arestas(2,:)==i) ] ) = 1;       
    end
    
    % matriz de arestas-arestas
    aa = zeros(size(arestas,2),size(arestas,2));
    for i = 1: size(arestas,2)-1
         for j= i+1: size(arestas,2)
             if (   sum(  ca(:,i).*ca(:,j) ) > 0  )
                aa(i,j) = 1;
                aa(j,i) = 1;
             end
         end
    end

    % encontrar arestas que tem tem 2 arestas
    % comum 

FE =[];
FC =[];
F= [];
% procurar 2 arestas em comun a 2 
for i=1:size(arestas,2)-1
    for j=i+1:size(arestas,2)
%         [ i j]
        intersE = aa(i,:).*aa(j,:);
        if ( sum ( intersE )   == 2)
             edges = [j find(intersE)];
             nf = i;
            % ordenar arestas
            while( numel(edges)>1 )
                %  EDG{nf(end)}
                %  arestas ligadas a aresta
                 es = find( aa(nf(end),:));
                % encontrar o ultimo elemento de nf
                % no vetor de edges
                x  = find  ( ismember( edges,  es ) ) ;
                % retirar este elemento de edges e
                % colocar na cauda de nf
                x= x(1);
                nf(end+1) = edges(x);
                edges = [ edges(1:x-1) edges(x+1:end) ];
            end
            fp=[];
            fe = [ nf edges] ;
            fe2 = [fe fe(1)];
            for z=2: numel(fe2)
              x = find(ca(:,fe2(z-1)).*ca(:,fe2(z)) );
              % encontrar os cantos
              if (~isempty(x))
             fp(end+1,:) = x; 
              end 
            end
        
              fp= unique(fp)';
              
         c =  (find(sum(ismember( FC, fp)')==4)) ;
           
          if (numel(fp==4) && isempty(c) )
            FE(:,end+1) = fe';
            FC(:,end+1) = fp'; %:4!
          end

        end
    end
end

%     pts = [ v ones(2^(dims),1) ]'; 
pts = pts';
%   obj.W  =  [ zeros(1, dims-1) 3  zeros(1, dims-1) 0 1  1 ]; 
if (nargin==1)
   pts= pts-.5;
end

FP=[];
if (dims==3)
   FP =  [ 2 0 4 6;  0 2 3 1; 1 5 7 3; 3 7 6 2;  6 7 5 4;  4 0 1 5 ]+1;     
end



end