function Ep = m_geo_plotEpipolarStuff(Ep, drawPlane)
    
    if (isfield(Ep,'plotObjs'))
        delete (Ep.plotObjs); 
    end
    plotObjs = [];
    hold on;
    
    for i=1:2
        id = num2str(i);
    % vetores X no plano
        hg = hgtransform;
        h = m_plot3vector(Ep.xcps{i}', 'color', [ 0 0 0 ], 'l', ['x_' id]);
        set(hg,'matrix', Ep.Ms{i});
        set(h, 'parent', hg);
        plotObjs(end+1)    = hg;
    
    %normal dos planos epipolares
        hg = hgtransform;
        h = m_plot3vector(Ep.epcs{i}', 'color', [ 0 0 0 ], 'l', ['ep_' id]);
        set(hg,'matrix', Ep.Ms{i});
        set(h, 'parent', hg);
        plotObjs(end+1)    = hg;
    
    %segmentos do plano epipolar
    if (isfield(Ep,'epcs_s')) 
        hg = hgtransform;
        m = Ep.epcs_s{i};
        h = plot3(m(1,:),m(2,:),m(3,:), 'linewidth',1, 'color', [0 0 0]);
        set(hg,'matrix', Ep.Ms{i});
        set(h, 'parent', hg);
        plotObjs(end+1)    = hg;
    end
    end
    
    if (isfield(Ep,'epcs_s')) 
    %epipolo 1 em 2
        hg = hgtransform;
        m = Ep.epc2_se;
        h = m_plot3vector(Ep.eppc1', 'color', [ 0 0 0 ], 'l', 'epp1'); 
        set(hg,'matrix', Ep.Ms{2});
        set(h, 'parent', hg);
        plotObjs(end+1)    = hg;
    
    
    %segmentos encurtado epipolar na 2 vista
        hg = hgtransform;
        m = Ep.epc2_se;
        h = plot3(m(1,:),m(2,:),m(3,:), 'linewidth',3, 'color', [0 0 0]);
        set(hg,'matrix', Ep.Ms{i});
        set(h, 'parent', hg);
        plotObjs(end+1)    = hg;
    end
    
    
    if (drawPlane)
        %disco do plano epipolar em 1
        hg = hgtransform;
        m  = [Ep.xw  Ep.M1(1:3,4)   Ep.M2(1:3,4)];
        h = fill3(m(1,:), m(2,:), m(3,:), [1 0 0]);
        set(h, 'parent', hg, 'facealpha', 0.3, 'edgecolor', [0 0  0]);
        plotObjs(end+1)    = h;
    end
    
    %vetor paralelo em 2
    hg = hgtransform;
    h = m_plot3vector(Ep.xcp1_2', 'color', [ 0 0 0 ], 'l', 'x_12');
    set(hg,'matrix', Ep.Ms{2});
    set(h, 'parent', hg);
    plotObjs(end+1)    = hg;
    
    %segmento encurtado em 2
%     hg = hgtransform;
%     m  = [Ep.xw  Ep.M1(1:3,4)   Ep.M2(1:3,4)];
%     h = fill3(m(1,:), m(2,:), m(3,:), [1 0 0]);
%     set(h, 'parent', hg, 'facealpha', 0.3, 'edgecolor', [0 0  0]);
%     plotObjs(end+1)    = h;
    
    
    Ep.plotObjs   = plotObjs;
        
    
end

