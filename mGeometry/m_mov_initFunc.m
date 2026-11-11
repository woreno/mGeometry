function MF = m_mov_initFunc(fn,varargin)
opt.alisa     = 0;
opt.base     = eye(4,4);
MF = [];
MF.tangente = 0;
MF.i   = 1;
MF.i2 = 1;
MF.passo =1;
MF.dpasso = 4;
MF.base0 = eye(3,3);

argumentos(varargin);

im = imread(fn);
bw = rgb2gray(im); 
cts = cv.findContours((bw==0)*255);
cts = cell2mat(cts{1}(:))';
if (opt.alisa>0)
    [cts, ctsK, ctsI] = m_alisaCurva(cts,opt.alisa*2+1);
end
cts(1,:)  = cts(1,:)./size(im,2) ;
cts(2,:)  = cts(2,:)./size(im,1) ;
nps = size(cts,2);
cts2 = zeros(3,nps);
p0 =mean(cts,2);
cts2(1,:) = cts(1,:) -  p0(1);
cts2(3,:) = cts(2,:) -  p0(2);

MF.cts =MF.base0(1:3,1:4)*[ cts2; ones(1,nps) ];
    

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
            case 'tangente'
                MF.tangente =1;
            case 'passo'
                MF.passo = args{i+1};
                i = i+1;
        end 
    end
end


end