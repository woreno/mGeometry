function geo2 =  m_geo2_view(geo2)
figure(geo2.fig); 

function uiWheel(e_,v_)
    geo2.sel = geo2.sel+1;
    if (geo2.sel>4) 
        geo2.sel = 1;
    end
    m_geo2_view(geo2);
end



function uiTestOp(e_,v_)
 clc
    geo2.lastEst = geo2.est;
    geo2.est.opt = cell(4,1);
    for i=1:4
        ['optimizando projecao de config ' num2str(i)]
        x0 =  exp_SE3( geo2.est.Ps{i} ) ;
        [x,fval,exitflag,output] = fsolve(@avaliacao, x0)  ;
        opt.x0 = x0;
        opt.x1 = x;
        geo2.est.opt{i} = opt;
        P = SE3_exp(x); 
        geo2.est.Ps{i} = P(1:3,1:4);
        geo2.est.Perr(i) = geo2.op.Perr;
        geo2.est.X3{i} = geo2.opt.X3;
        geo2.est.X2{i} = geo2.opt.X2;
    end
    uiMostrarTodasConfig(0,0);
end

 %err de reprojecao
function erro = avaliacao(se3)
    P12 = SE3_exp(se3); 
    [geo2.opt.X3, geo2.opt.X2, geo2.op.Perr] =  m_geo2_trirepro(geo2.est.X1T, geo2.est.X2T, eye(3,3), P12);
     erro =  geo2.op.Perr;
end 
     
 
function uiMostrarTodasConfig(e_,v_)
    
    geo2.figAll = figure();
    
    set(  geo2.figAll, 'position', [125    18  1739   931]);
    hold on;
    colors = [ eye(3,3); 1 1 0 ]/2;
    for i=1:4
         colorr = repmat(colors(i,:), 3 ,1 );
         [ facesH facesHs  ] = desenhar3D(i, colorr');
        set(facesHs, 'edgecolor', colors(i,:));
    end
    grid on;
    axis equal
     
    axes('position', [0,0, 1, 0.1])
    hold on;
    for i=1:4
        text(0+0.10*i,0.3,[num2str(i) ' : ' num2str(geo2.est.Perr(i))],'color', colors(i,:), 'fontsize', 20, 'fontweight', 'bold');
    end
    h = uicontrol('style', 'pushbutton', 'string', 'tri opt', 'callback', @uiTestOp);
end


function [ facesH facesHs  ] = desenhar3D(sel, p12color)
  xlim([-3  3]); 
   ylim([-3  3]); 
   zlim([-3  3]); 
   %draw 3d
   P12 = geo2.est.Ps{sel};
   hgt = hgtransform;
   h = m_plot3axis(eye(3,3), 'colors', p12color  ,'text',{{'x','y','z'},{}} );
   set( h, 'parent', hgt);
   set( hgt, 'matrix',  [P12;0 0 0 1] );
   m_plot3vector(P12(1:3,4)', 'color', [ 0 0 0]);
 
   facesHs = [];
   facesH = hggroup;
   x3 = geo2.est.X3{ sel };
   for i=1: size(geo2.obj.faces,1)
       fIdxs = geo2.obj.faces(i,:);
       a = find( geo2.obj.vidx == fIdxs(1)  ) ;
       b = find( geo2.obj.vidx == fIdxs(2)  ) ;
       c = find( geo2.obj.vidx == fIdxs(3)  ) ;
       pts = [ x3(:,a), x3(:,b), x3(:,c) ];
       h = fill3( pts(1,:), pts(2,:), pts(3,:), [1 0 0] );
       facesHs(end+1) = h;
       set(h,'parent', facesH, 'facealpha' , 0);
   end
   axis equal
end
function [ facesH facesHs  ] = desenhar2D(sel,selproj)
    hold on;
    X2 = geo2.est.X2{sel};
    x2 = X2{selproj};  
    facesH = hggroup;
    facesHs =[];
    for i=1: size(geo2.obj.faces,1)
       fIdxs = geo2.obj.faces(i,:);
       a = find( geo2.obj.vidx == fIdxs(1)  ) ;
       b = find( geo2.obj.vidx == fIdxs(2)  ) ;
       c = find( geo2.obj.vidx == fIdxs(3)  ) ;
       pts = [ x2(:,a), x2(:,b), x2(:,c) ];
       h = fill( pts(1,:), pts(2,:), [1 0 0] );
       facesHs(end+1) = h;
       set(h,'parent', facesH, 'facealpha' , 0);
    end
end


if (isfield(geo2,'obj'))
   axes(geo2.axes(1));
   cla;
   hold on; 
   m_plot3axis(eye(3,3), 'colors', eye(3,3));
   desenhar3D(geo2.sel, eye(3,3));
    
   %draw projs
   for j=1:2
        axisID  = 1+j;
        axes(geo2.axes(axisID));
        cla;
        m_plot3axis(eye(3,3), 'colors', eye(3,3));
        desenhar2D(geo2.sel, j);
        xlim([-1 1]);  ylim([-1 1]);
   end

end

axes(geo2.axes(2));
h = text(0.1, 0.1, '-'); 
set(h, 'fontsize', 15, 'fontweight', 'bold', 'backgroundcolor', [1 0 0], 'color', [1 1 1]);
set(h, 'position', [-1 -1 0 ] );
set(h, 'string', [ 'config ' num2str(  geo2.sel ) ]);
 

axes(geo2.axes(4));
cla;
xlim([-1 1]);  ylim([-1 1]);
h = text(-1,1, '-'); 
set(h, 'fontsize', 15, 'fontweight', 'bold', 'backgroundcolor', [1 0 0], 'color', [1 1 1]);
set(h, 'string', ['err '  num2str(geo2.est.Perr(geo2.sel))  ]);

set(geo2.fig ,'WindowScrollWheelFcn',   @uiWheel);   
set(geo2.fig ,'WindowButtonDownFcn', @uiMostrarTodasConfig);   


end