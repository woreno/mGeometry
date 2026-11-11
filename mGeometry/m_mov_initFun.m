%  preenche uma estrutura para iterar uma 
%  base 3d sobre um caminho 3d
%
% exemplo:
%  inicializacao:
%             M = m_mov_initFun('data/caminho.png', ...
%                                             'olhar', 'centro',...
%                                             'base', M, ...
%                                             'passo', 6, ...
%                                             'alisa', 18,...
%                                             'corda', 3);
%
% iteracao:   
%             M = m_mov_stepFun(M);
%               
% campos da estrutura:  
%            M.base,        matriz expoencial 4x4
%            M.rv             rotacao em rep eixo de rotacao
% argumentos:
%
% in:
%   fn                           nome ficheiro bitmap com traco preto
% op:
%   'sino',periodo,elev   eleva os pontos com seno elev*sin(2pi*(i/P)) 
%   'base',M44              aplica transformacao M44
%   'olhar':tipo     tipo:   'centro' (default),  'tangente' , 'normal' , 'nao'
%   'contrario'                inverte o olhar 
%   'alisa', n                   com kernel guassiano de  n*2+1
%   'passo', n, dn           tamanho do passo e da corda                
%
function MF = m_mov_initFun(fn,varargin)
opt.alisa  = 0;
op.sino    = [];
  
MF = [];
MF.base0 = eye(4,4);
MF.tangente = 0;
MF.i = 1;
MF.olhar ='centro';
MF.sentido =1;
MF.passo =1;
MF.dpasso =5;
argumentos(varargin);

im = imread(fn);
bw = rgb2gray(im); 
cts = cv.findContours((bw==0)*255);
cts = cell2mat(cts{1}(:))';
if (opt.alisa>0)
    [cts, ctsK, ctsI] = m_alisaCurva(cts,opt.alisa*2);
end
cts(1,:)  = cts(1,:)./size(im,2) ;
cts(2,:)  = cts(2,:)./size(im,1) ;
nps = size(cts,2);
cts2 = zeros(3,nps);

if (~isempty(op.sino))
      cts2(2,:) = cts(2,:) + op.sino(2)*sin(2*pi*([1:nps]/op.sino(1))) ;
 end

p0 =mean(cts,2);
cts2(1,:) = cts(1,:) -  p0(1);
cts2(3,:) = cts(2,:) -  p0(2);

MF.cts =  MF.base0(1:3,1:4)*[ cts2; ones(1,nps) ];
    
MF.base0(1:3,1:3) = vunitsCols(MF.base0(1:3,1:3));

function argumentos(args)
   i=0;
    while (i< size(args,2) )
        i=i+1;
        switch lower(  args{i}  )
            case 'alisa' 
                opt.alisa = args{i+1};
                i = i+1;
            case 'base'
               MF.base0 = args{i+1};
                i = i+1;
            case 'olhar'
                MF.olhar = args{i+1};
                i = i+1; 
            case 'passo'
                MF.passo = args{i+1};
                i = i+1;
            case 'contrario'
                MF.sentido = -1;
                i = i+1;
            case 'sino'
                op.sino = [ args{i+1}  args{i+2}];               
                i = i+2;
        end 
    end
end


end