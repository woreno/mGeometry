
% in: pts3 vetores coluna na camera, 4x1 (
function ptsVisiveisIdx = m_ptsVisiveisCam(ptsCam, zNear, zFar)
    ptsVisiveisIdx = [];
    %retirar pontos entre znear e zfar
    idxs1 = ptsCam(3,:)>= zNear & ptsCam(3,:)<=zFar;
    idxs1 =  find(idxs1);
    ptsCam = ptsCam(:,idxs1);
    %passar restantes para base verificar se positivos
      B = [ -1    1    1   -1
               -1   -1    1    1 
                1    1     1    1];
     B = vunitsCols(B);
     pis = ptsCam(1:3,:)'*B; %cada linha ser positiva  
     idxs2 =  (sum(pis'>0)==4);
     ptsVisiveisIdx = idxs1(idxs2);
     
end