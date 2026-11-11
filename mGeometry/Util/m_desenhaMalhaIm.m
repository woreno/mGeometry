%   NX3   linhas          faces
%  Nx2   linhas           vertices
function [im] = m_desenhaMalhaIm(facevertex, vertexes, im, thick, lcolor, fcolor)

    %faces
    for i=1: size(facevertex,1) 
        pts =  vertexes(facevertex(i,:),:) ;
        pts = {cols2cells(pts')};
        im = cv.fillPoly( im,pts ,'Color', fcolor, 'LineType', 'AA');
    end
    
    for i=1: size(facevertex,1) 
        pts =  vertexes(facevertex(i,:),:) ;
        pts = {cols2cells(pts')};
        im = cv.polylines( im,pts ,'Thickness', thick, 'Color', lcolor, 'LineType', 'AA');
    end
%     for j=1: size(o.v,1) 
%         pts = o.v(j,:);
%     end
end