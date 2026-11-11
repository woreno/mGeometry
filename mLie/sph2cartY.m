% azimute nos eixos dos xx
% elevação nos eixos dos yy
function X = sph2cartY(az,el)
ca = cos(az);
sa = sin(az);
ce = cos(el);
se = sin(el);
x = sa*ce;
y = -se;
z = ca*ce;

X = [ x y z]';