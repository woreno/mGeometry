%v:  vetores linha
function [ G ] =  m_readWavefront( fpath )
    
  
    fid = fopen(  fpath , 'r');
    
    g.v = [];
    g.vt = [];
    g.vn = [];
    g.fv  = [];
    g.fvt  = [];
    g.fvn  = [];
    g.bbox = [inf inf inf -inf -inf -inf];
    
    while( ~feof(fid) )

        l = fgetl(fid);
        l_args = m_substrings(l, ' ');
        
        if (numel(l_args)>2)  
            if (strcmp(char(l_args{1}),'v')) 
                g.v(end+1,:) = [ str2num(l_args{2})  str2num(l_args{3})  str2num(l_args{4})];
                x = g.v(end,:);
                g.bbox(1:3) = min( x(1:3), g.bbox(1:3) ) ;
                g.bbox(4:6) = max( x(1:3), g.bbox(4:6) )  ;
                
            else
                if (strcmp(l_args{1},'vt'))
                    %..
                else
                   if (strcmp(l_args{1},'f'))
                        l_args21 = m_substrings(l_args{2},'/' );   
                        if (numel(l_args21)==3)       
                            l_args22 = m_substrings(l_args{3},'/' );   
                            l_args23 = m_substrings(l_args{4},'/' );   
                            g.fv(end+1,:) =  [ str2num(l_args21{1}) str2num(l_args22{1}) str2num(l_args23{1}) ]; 
                        else
                            if (numel(l_args21)==4)      
                                l_args22 = m_substrings(l_args{3},'/' );   
                                l_args23 = m_substrings(l_args{4},'/' );   
                                l_args24 = m_substrings(l_args{5},'/' );   
                                g.fv(end+1,:) =  [ str2num(l_args21{1}) str2num(l_args22{1}) str2num(l_args23{1})  str2num(l_args24{1}) ]; 
                            end
                        end
                   else
                   
                   end
                end
            end
        end
%         l_args

    end
    g.centroid = ( (g.bbox(1:3)+g.bbox(4:6))/2)';
    G = g;
    fclose(fid);
end
