
function  A = SO3_exp(u)
    A = [ angleaxis2matrix(u(1:end))]; 
end