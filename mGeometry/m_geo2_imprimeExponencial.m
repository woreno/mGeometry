function m_geo2_imprimeExponencial(M)
    rv  = matrix2angleaxis( M(1:3,1:3) );
    [ rvu, rang ]  = vunit(rv);
    rang = round(rad2deg(rang));
    t   = M(1:3,4); 
    [rmvaxis, rmaxis] = max(abs(rv));
    [tmvaxis, tmaxis] = max(abs(t));
    
    raxistr = {'elv','azmt','roll'};
    taxistr = {'X','Y','Z'}; 
    if (rvu(rmaxis)>0)
        rsignstr = 'positiva';
    else
       rsignstr = 'negativa';
    end
    if (t(tmaxis)>0)
        tsignstr = 'frente';
    else
       tsignstr = 'tras';
    end
    disp([' descricao bold de Mij ']);
    disp(['  t:'  num2str(t')  '  | | rv:'  num2str(rvu') ]);
    disp([' translacao para ' tsignstr ' sobre eixo ' taxistr{tmaxis} '; rotacao ' rsignstr ' em ' raxistr{rmaxis} ' de ' num2str(rang) ' graus ']);
end