% axx
% versor rotacao
% angulo
function [ aax w  ang]= SO3Q_SO3(q)
    % a = ang/2
    %q = [ cos a sin a w ]
    % qr = cos a
    % qi = sin a wi
    % qj = sin a wj
    % qk = sin a wk
    %
    %  cos(ang/2) =qr <=> cos a = qr <=>  acos(qr) = a   <=> a = ang/2 <=> a*2 = ang;  
    %   qijk/sin(a) = wijk 
    a = acos(q(1)); 
    ang = 2*a;
    if (sin(ang)==0)
        ang = 2*pi;
    end
        w = q(2:4)./sin(ang) ;
        w = vunit(w);
        aax = w*ang;
    
%     rad2deg(ang);

end
