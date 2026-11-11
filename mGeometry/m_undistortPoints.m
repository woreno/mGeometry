%  ponto:2x1, K:3x3, D: distort 5x1
%  out:     YRT radial e tangencial
%              YR apenas radial

function [YRT, YR] = m_undistortPoints(X_, K, D)
% clear
% clc
% cam  = visionlab_loadCamCalibration('microsofthd_640480'); 
% k = cam.distortion_coefficients;
%  
% X = [124 68]';  
YRT =[];
YR =[];
% algoritmo do opencv para retirar a distorção ao ponto
 for j=1: size(X_,2)
    X = X_(:,j); 
    x = K^-1* [X;1];
    x0 = x; 
    k = D;
    iters = 5;
    % x'
    for j=1:iters
        r2 = x(1:2)'*x(1:2);
    %     estes coefs nao sao usados
    %     icdist = (1 + ((k(8)*r2 + k(7))*r2 + k(6))*r2)/...
    %                (1 + ((k(5)*r2 + k(2))*r2 + k(1))*r2); 
        icdist =  (1 + ((k(5)*r2 + k(2))*r2 + k(1))*r2)^-1;
        deltaX = 2*k(3)*x(1)*x(2)   +  k(4)*(r2 + 2*x(1)*x(1));
        deltaY = 2*k(4)*x(1)*x(2)   +  k(3)*(r2 + 2*x(2)*x(2)) ;
        x(1) = (x0(1) - deltaX)*icdist;
        x(2) = (x0(2) - deltaY)*icdist;
%     cam.K* x
    end 


    YRT(:,end+1) = homogeneoustocart(K* x )';

    icdist =  (1 + ((k(5)*r2 + k(2))*r2 + k(1))*r2)^-1;
    x(1) = x0(1)*icdist;
    x(2) =  x0(2)*icdist;
    YR(:,end+1) = homogeneoustocart(  K* x )';
 
 end
end
    