function h = m_mov_plot(MF)

   cts2 = MF.cts;
    h = fill3(cts2(1,1:end-2), cts2(2,1:end-2), cts2(3,1:end-2), [1 0 0 ]);
    set(h, 'edgecolor', [.3 .3 .3], 'linewidth', 4, 'edgeAlpha', 0.4, 'facealpha', 0); 

    
end