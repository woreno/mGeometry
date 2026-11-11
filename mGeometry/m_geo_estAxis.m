%   reconstruir um eixo com linhas homogeneas
%
%   in:
%       linhas:     3xN
%       idxs:        idxs das linhas dos eixos
%       axesId:    xy, xz, yz: [1 2],[1 3], [2 3]
%
%       nao garante q seja ortogonal
%
%  out:
%       axs: 
%       NL:   {idxs1, idxs2, idxs3}
%       NL2: idx por linha
%       reclassifica as linhas
%
function [axs, NL, NL2,error, naxes] = m_geo_getAxis(linhas, idxs, axesIds)
    axSid  = setdiff([1 2 3],axesIds);
    axs = eye(3,3);
    for i=1:2
        j=axesIds(i);
        ls = linhas(idxs{i},:);
        ax = m_axEq0(ls);
        if ( ax(j)< 0)
            ax  = -ax;
        end
        axs(1:3,j) = ax';
    end
    
    if (axesIds(1)==1 && axesIds(2)==2)
    % xy :   z = x,z
        axs(:,axSid) =  vunit ( cross(axs(:,1), axs(:,2)) ) ;
    else
        if (axesIds(1)==1 && axesIds(2)==3)
        % xz :   y = x,-z
            axs(:,axSid) =  vunit ( cross(axs(:,1), -axs(:,3)) ) ;
        else
            if (axesIds(1)==2 && axesIds(2)==3)
            % yz:  x= y z
                axs(:,axSid) =  vunit ( cross(axs(:,2), axs(:,3)) ) ;
            end
        end
    end
    
    [U, D, V] = svd(axs);
    axs = U*V';
    for j= 1:3
        if ( axs(j,j)<0 )
            axs(:,j) = -axs(:,j);
        end
    end
    
    pis = abs(linhas*axs);
    [ v, idx ] = min(pis'); 
    error = v*v';
    
    badIdxs = find(v>0.1);
    if (~isempty(badIdxs))
        idx(badIdxs) = 4;
        naxes = 4;
    else
        naxes = 3;
    end
    
    NL ={};
    NL2 = idx;
    for i=1:3
        idxs = find(idx==i);
        NL{i} = idxs;
    end
    

end