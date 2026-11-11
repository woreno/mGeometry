% vetores linha
function o = tritest(pts, p)

    
    pts2 = [  pts;  pts(1,:) ];
    o = 1;
    for i = 1:size(pts2,1)-1
        ab = pts2(i+1,:)- pts2(i,:); 
        n = sqrt(ab*ab');
        abu = ab/n;
        ap = p - pts2(i,:);
        abu = [ -abu(2) abu(1) ]
        d = abu*ap';
        
        if (d<0)
            o = 0; 
            break;
        end
            
    end
    
    
end