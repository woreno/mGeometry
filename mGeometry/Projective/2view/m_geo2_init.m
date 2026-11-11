%'debug'
function geo2 = m_geo2_init(varargin)
geo2=[];
geo2.sel = 1;
geo2.figAll = [];

argumentos(varargin);


function initDebug()
    
    geo2.fig = figure();
    set(geo2.fig, 'position', [5  128  509  837]);
    geo2.axes = zeros(4,1);
    dy=.333;
    y = 0;
    geo2.axes(4) = axes('position', [0 y 1 dy]);
    y=y+.333;
    geo2.axes(2) = axes('position', [0 y .5 dy]);
    geo2.axes(3) = axes('position', [.5 y .5 dy]);
    y=y+.333;
    geo2.axes(1) = axes('position', [0 y 1 dy]);
    set( geo2.axes, 'YTick',[], 'XTick',[]);
    set( geo2.axes(2:4), 'YDir', 'reverse');
%     set( geo2.axes, 'XDir', 'reverse');
    
    geo2.objs = [];
    geo2.objsText = [];
    for i=1:4
        axes(geo2.axes(i));
        hold on;
        geo2.objs(end+1) =  hggroup; 
    end
    
    for i=1:3
        axes(geo2.axes(i));
        hold on;
        m_plot3axis(eye(3,3), 'colors', eye(3,3));
    end
    for i=1:3
        axes(geo2.axes(1+i));
        hold on;
        h = text(0.1, 0.1, '-'); 
        set(h, 'fontsize', 15, 'fontweight', 'bold', 'backgroundcolor', [1 0 0], 'color', [1 1 1]);
        geo2.objsText(end+1) =  h;
    end
end

function argumentos(args)
   i=0;
    while (i< size(args,2) )
        i=i+1;
        switch lower(  args{i}  )
            case 'debug'    
                initDebug();
        end
    end
end
 
end