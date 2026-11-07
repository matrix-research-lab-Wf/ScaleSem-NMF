function run_ScaleSem_label_noise_R2019a(selected_d,seeds,outname,fractions)
% 错误标签鲁棒性实验，兼容 MATLAB R2019a，可中断续跑。
if nargin<1||isempty(selected_d),selected_d=1:3;end
if nargin<2||isempty(seeds),seeds=20260627:20260646;end
if nargin<3||isempty(outname),outname='ScaleSem_label_noise';end
if nargin<4||isempty(fractions),fractions=[.1 .2 .3];end

here=fileparts(mfilename('fullpath'));
root='E:\codex\2026-10-03\referenced-chatgpt-conversation-this-is-an';
base=fullfile(root,'outputs','PCE_baseline_alignment');src=fullfile(root,'work','HLPNMF-author-audit');
addpath(here);addpath(src);addpath(fullfile(base,'config'));addpath(fullfile(base,'adapters'));
cfg=pce_protocol_config(base);
names={'COIL20','PIE','YaleB'};globalId=[2 4 1];
paths={fullfile(base,'data','COIL20.mat'),fullfile(base,'data','PIE.mat'),fullfile(base,'data','YaleB.mat')};
gocp=[3 3 2];goca=[10 1000 1000];snp=[3 3 3];methods={'ScaleSem-NMF','HLPNMF','GOCNMF','SNMFWLP'};
out=fullfile(here,outname);if exist(out,'dir')~=7,mkdir(out);end
raw=fullfile(out,'raw.csv');
if exist(raw,'file')~=2
 fid=fopen(raw,'w');fprintf(fid,['dataset,noise_fraction,seed,method,ACC,NMI,runtime,iterations,' ...
  'objective_increases,corruption_id,n_corrupted,n_labeled,finite,status\n']);fclose(fid);
end
done=local_done(raw);

for d=selected_d
 [X,y]=local_load(paths{d});n=numel(y);c=max(y);
 for seed=seeds
  local_seed(seed);labelled=local_split(y,.1);un=~labelled;
  local_seed(seed);W0=max(rand(size(X,1),c),eps);H0=max(rand(c,n),eps);
  for f=fractions
   [label_y,cid,ncorr]=local_corrupt_labels(y,labelled,f,seed,d);
   order=mod((0:3)+seed+d+round(100*f),4)+1;
   for jj=1:4
    m=order(jj);method=methods{m};key=sprintf('%s|%.6f|%d|%s',names{d},f,seed,method);
    if any(strcmp(done,key)),continue;end
    acc=NaN;nmi=NaN;rt=NaN;iters=NaN;inc=NaN;status='OK';
    try
     if m==1
      od=fullfile(out,'runs',sprintf('%s_f%02d',names{d},round(100*f)),'ScaleSem-NMF');
      ov=struct('X',X,'y',y,'label_y',label_y,'labelled',labelled,'output_dir',od);
      T=run_scale_semantic_nmf_birth_gate_R2019a(globalId(d),'l1',seed,200,1e-7,'full',.1,ov);
      acc=T.ACC(1);nmi=T.NMI(1);rt=T.end_to_end_runtime(1);iters=T.iterations(1);inc=T.objective_increases(1);
     elseif m==2
      od=fullfile(out,'runs',sprintf('%s_f%02d',names{d},round(100*f)),'HLPNMF');
      ov=struct('X',X,'y',y,'label_y',label_y,'labelled',labelled);
      T=run_HLPNMF_extended_R2019a(seed,30,.1,globalId(d),od,ov);
      acc=T.ACC(1);nmi=T.NMI(1);rt=T.end_to_end_runtime(1);iters=T.iterations(1);inc=T.objective_increases(1);
     elseif m==3
      clear run_GOCNMF;opt=cfg;opt.dataset=sprintf('%s_labelnoise_%02d_seed%d',names{d},round(100*f),seed);
      opt.dataset_index=1;opt.seed=seed;opt.graph_p=gocp(d);opt.goc_alpha=goca(d);opt.goc_parameter_tag={'label_noise_frozen'};
      local_seed(seed);[pred,info]=run_GOCNMF(X,label_y,labelled,W0,H0,opt);
      [acc,nmi]=local_metrics(y(un),pred(un));rt=info.runtime_sec;iters=info.iterations;
     else
      clear run_SNMFWLP;opt=cfg;opt.dataset=sprintf('%s_labelnoise_%02d_seed%d',names{d},round(100*f),seed);
      opt.dataset_index=1;opt.seed=seed;opt.graph_p=snp(d);opt.snmfwlp_alpha=1000;opt.snmfwlp_beta=1e5;
      local_seed(seed);[pred,info]=run_SNMFWLP(X,label_y,labelled,W0,H0,opt);
      [acc,nmi]=local_metrics(y(un),pred(un));rt=info.runtime_sec;iters=info.iterations;
     end
     finite=double(all(isfinite([acc nmi rt iters]))&&(~strcmp(method,'ScaleSem-NMF')||inc==0));
     if ~finite,status='FAILED_INTEGRITY';end
    catch ME
     finite=0;status=['FAILED_' local_clean(ME.identifier)];fprintf(2,'LABELNOISE %s failed: %s\n',key,ME.message);
    end
    fid=fopen(raw,'a');fprintf(fid,'%s,%.6f,%d,%s,%.17g,%.17g,%.17g,%.17g,%.17g,%s,%d,%d,%d,%s\n', ...
     names{d},f,seed,method,acc,nmi,rt,iters,inc,cid,ncorr,sum(labelled),finite,status);fclose(fid);
    done{end+1}=key; %#ok<AGROW>
    fprintf('LABELNOISE %s f=%.2f seed=%d %s ACC=%.6f NMI=%.6f\n',names{d},f,seed,method,acc,nmi);
    clear pred info T;
   end
  end
 end
 clear X y;
end
fprintf('ALL REQUESTED LABEL-NOISE RUNS COMPLETE\n');
end

function done=local_done(raw)
done={};T=readtable(raw);for i=1:height(T),done{end+1}=sprintf('%s|%.6f|%d|%s',T.dataset{i},T.noise_fraction(i),T.seed(i),T.method{i});end %#ok<AGROW>
end
function [X,y]=local_load(path)
S=load(path);if isfield(S,'X'),X=double(S.X);else,X=double(S.fea)';end
if isfield(S,'y'),y=double(S.y(:));else,y=double(S.gnd(:));end
if size(X,2)~=numel(y),X=X';end;[~,~,y]=unique(y);y=double(y);nr=sqrt(sum(X.^2,1));nr(nr==0)=1;X=bsxfun(@rdivide,X,nr);
end
function L=local_split(y,r)
L=false(numel(y),1);for k=1:max(y),ix=find(y==k);ix=ix(randperm(numel(ix)));L(ix(1:max(1,floor(r*numel(ix)))))=true;end
end
function [yn,cid,ncorr]=local_corrupt_labels(y,L,f,seed,dataset_id)
yn=y;local_seed(seed+700000+1000*dataset_id+round(100*f));changed=[];c=max(y);
for k=1:c
 q=find(L&y==k);q=q(randperm(numel(q)));nk=min(numel(q),round(f*numel(q)));q=q(1:nk);
 for j=1:numel(q),z=randi(c-1);if z>=k,z=z+1;end;yn(q(j))=z;end
 changed=[changed;q(:)]; %#ok<AGROW>
end
ncorr=numel(changed);cid=sprintf('d%d_s%d_f%02d_n%d_sig%.0f',dataset_id,seed,round(100*f),ncorr,sum(double(changed).*(1:ncorr)'));
end
function local_seed(s),rand('twister',s);randn('state',s);end %#ok<RAND>
function [acc,nmi]=local_metrics(a,b)
a=a(:);b=b(:);mapped=bestMap(a,b);acc=mean(mapped(:)==a);n=numel(a);[~,~,a]=unique(a);[~,~,b]=unique(b);C=accumarray([a b],1,[max(a) max(b)]);pa=sum(C,2)/n;pb=sum(C,1)/n;p=C/n;I=0;
for i=1:size(C,1),for j=1:size(C,2),if p(i,j)>0,I=I+p(i,j)*log(p(i,j)/(pa(i)*pb(j)));end,end,end
Ha=-sum(pa(pa>0).*log(pa(pa>0)));Hb=-sum(pb(pb>0).*log(pb(pb>0)));nmi=I/max(sqrt(Ha*Hb),eps);
end
function s=local_clean(s),if isempty(s),s='unknown';else,s=regexprep(s,'[^A-Za-z0-9_]','_');end,end
