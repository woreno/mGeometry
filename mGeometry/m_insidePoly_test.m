

function pontomovel() 
    close all;
    clear;
    clc
    points = [   60.5004  155.6534
                  175.0965  124.6217
                  212.1515  172.4897
                  52.1515  32.4897
                  ];
    ui_fig =  figure() ;
    set(ui_fig, 'position', [ 55          57        1805         892]); 
    axes('xlim', [0 320], 'ylim', [0 240]); 
    ui_objs = hggroup; 
    for i=1:size(points,1)
        h = impoint(gca, points(i,:));  
        addNewPositionCallback( h, @(x)chgcoords(x,i) ); 
    end
    set(ui_fig,  'WindowButtonUpFcn', @upf); 
    upf(0,0);
    
    function chgcoords(coords,i)
       points(i,:) = coords;        
    end
    
    
    function upf(e,v)
        
        if (ishandle(ui_objs))
            delete(ui_objs); 
        end
        hold on;
        ui_objs = hggroup; 
        h = fill(points(1:3,1), points(1:3,2), [0 1 1]);
        set(h, 'parent', ui_objs, 'facealpha', 0);
        on = tritest(points(1:3,:), points(4,:))
        if (on)
            color  =  [0 1 0];
        else
            color =  [1 0 0];
        end
        h = circle(points(4,:), 10, 20);
        set(h, 'parent', ui_objs, 'color', color, 'linewidth', 6);
        
        
%         centro = points(2,:);
%         objeto = points(1,:); 


     end



end