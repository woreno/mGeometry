 function m_writeWavefrontPlane( fpath , fn, vert2, vert3, faces, im)
    fn_obj = [ fn '.obj'] ;
    fn_mtl = [ fn '.mtl'] ;
    fn_im = [ fn '.png'] ;
    ims = 1./[ size(im,2) size(im,1)];
    imwrite(im,  [fpath fn_im]); 
    O.name = 'mesh';
    M.name = 'face-default';
    M.Kd = 1*ones(1,3); % difuso
    M.Ka = .2*ones(1,3); % ambiente
    M.Ks = 0*ones(1,3); % spec
    M.d =  1;         % opacidade  
    M.Ns = 10;      % expoent de Ks 0..1000
    M.illum = 2;    % tipo de iluminação   
                                % 1. Color on and Ambient on 
                                % 2. Highlight on
                                % 3. Reflection on and Ray trace on
                                % 4. Transparency: Glass on, Reflection: Ray trace on
                                % 5. Reflection: Fresnel on and Ray trace on
                                % 6. Transparency: Refraction on, Reflection: Fresnel off and Ray trace on
                                % 7. Transparency: Refraction on, Reflection: Fresnel on and Ray trace on
                                % 8. Reflection on and Ray trace off
                                % 9. Transparency: Glass on, Reflection: Ray trace off
                                % 10. Casts shadows onto invisible surfaces 2. Highlight on
    
    %obj
    fid = fopen(  [fpath fn_obj], 'w');
        str = sprintf(  'o %s \n' ,  O.name);    fwrite(fid,str); 
        % 3d vertexes
        for i=1: size(vert3,2)
            v = vert3(:,i); 
            str = sprintf( 'v %f %f %f \n', v(1), v(2), v(3) ); 
            fwrite(fid,str); 
        end 
        % 2D
        for i=1: size(vert2,2)
            v = diag(ims) * vert2(1:2,i); 
            str = sprintf( 'vt %f %f 0\n', v(1), v(2)); 
            fwrite(fid,str); 
        end
        % normais
        str = sprintf(  'vn 0 0 1 \n' );    fwrite(fid,str); 
        % faces        
        str = sprintf(  'mtllib %s \n' ,  fn_mtl);    fwrite(fid,str); 
        str = sprintf(  'usemtl %s \n' ,    M.name );     fwrite(fid,str); 
        for i=1: size(faces,1)
            f = faces(i,:); 
            str = sprintf( 'f %i/%i/%i %i/%i/%i %i/%i/%i \n', f(1), f(1), 1,   f(2), f(2), 1, f(3),f(3), 1  ); 
            fwrite(fid,str); 
        end
    fclose(fid);
    %mtl
    fid = fopen(  [fpath fn_mtl], 'w');
        strL = sprintf( 'Ka %f %f %f\nKd %f %f %f\nKs %f %f %f\nd %f\nNs %f\nillum %f', M.Kd,M.Ks,M.Ka,M.d,M.Ns,M.illum);
        str = sprintf(  'newmtl %s\n%s\n',    M.name  ,strL  );      fwrite(fid,str); 
        str = sprintf(  'map_Kd %s\n',    fn_im  );      fwrite(fid,str); 
%         str = sprintf(  'map_Ka%s\nnmap_Ks%s\nnmap_Ks%s\n',    fn_im,fn_im,fn_im  );      fwrite(fid,str); 
        
     fclose(fid);
end
