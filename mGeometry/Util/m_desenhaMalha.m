% o.fv          NX3   linhas   faces
% o.v           Nx2/Nx3    linhas  vertices
function [h facesHandles] = m_desenhaMalha(o)
    h  = hgtransform;
    facesHandles = zeros(size(o.fv,1),1);
    
    for i=1: size(o.fv,1) 
        pts =  o.v(o.fv(i,:),:) ;
        h_ = fill3( pts(:,1), pts(:,2), pts(:,3), [1 0 0] );
        facesHandles(i) = h_;
        set(h_, 'parent', h, 'userdata', i ); 
    end
    
    
%     for j=1: size(o.v,1) 
%         pts = o.v(j,:);
%     end
end