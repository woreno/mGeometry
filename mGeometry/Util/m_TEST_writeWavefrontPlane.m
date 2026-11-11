clc
im = imread('sample/image/testchart.png'); 
ims = size(im);
ims = [ims(2) ims(1) ]';

imb = rgb2gray(im);
kps = cv.FAST(imb);
vert2 = cat(1, kps.pt )';
% plot ( pts(1,:), pts(2,:), 'x', 'linewidth', 40 );
 vert3 =   [ diag(1./ims) *vert2; rand(1, size(vert2,2)) ];
faces = delaunay( vert2(1,:), vert2(2,:)  );
m_writeWavefrontPlane( 'sample\tri\' , 'tv', vert2, vert3, faces, im)