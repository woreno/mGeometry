function MF = m_mov_stepFun(MF,dir_)

    idxs = [ MF.i+ dir_*MF.passo 0  0] ; 
     
 
     for i=1:3
        idx = idxs(i);
        if (idx <=0 ) 
            idx = size(MF.cts,2)-1;
        else 
            if (idx > size(MF.cts,2) ) 
                idx = 1;
            end
        end
        idxs(i)  = idx;
        if (i==1)
             idxs(2) =  idx-MF.dpasso;
             idxs(3) =  idx+MF.dpasso;
        end
     end
     
    MF.i = idxs(1); 
   
    MF.tv = MF.cts(:,  MF.i) ;
    R = eye(3,3);
    switch (MF.olhar)
        case 'tangente'
            MF.v = vunit([ MF.cts(1,idxs(2)) - MF.cts(1,idxs(1)) ,  ... 
                                   MF.cts(3,idxs(2)) - MF.cts(3,idxs(1))]); 
            az = atan2(MF.v(1),MF.v(2));
        case 'normal' 
            MF.v = vunit([ MF.cts(1,idxs(2)) - MF.cts(1,idxs(1)) ,  ... 
                                   MF.cts(3,idxs(2)) - MF.cts(3,idxs(1))]); 
            
            MF.v  = [ -MF.v(2) MF.v(1)];
        case 'centro'
            MF.v = vunit([  -MF.tv(1 ) ,  -MF.tv(3 )]); 
             
        case 'nao'
            MF.tvrv = [ MF.tv' 0 0 0];
            MF.base = [ R MF.tv; 0 0 0 1];
            return
    end
    
    MF.v = MF.sentido * MF.v;
    az = atan2(MF.v(1),MF.v(2));
   
    R = angleaxis2matrix( [ 0 az 0 ]);
    R = MF.base0(1:3,1:3) * R(1:3,1:3);
    aax = matrix2angleaxis(R);
    MF.tvrv = [ MF.tv' aax'];
    MF.base = [ R MF.tv; 0 0 0 1];
        
end