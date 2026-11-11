% azimute nos eixos dos xx
% elevação nos eixos dos yy
function [az,el] = cart2sphY(x)
    
    az = atan ( x(1)/x(3) );
    el = asin ( -x(2)/norm(x) ); 

