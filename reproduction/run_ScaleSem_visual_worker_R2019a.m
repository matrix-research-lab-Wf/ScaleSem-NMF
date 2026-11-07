function run_ScaleSem_visual_worker_R2019a(dataset_id, projection_id)
% 单个数据集、单个投影状态的隔离工作进程，避免 R2019a 连续 t-SNE 堆损坏。
here=fileparts(mfilename('fullpath'));
root='E:\codex\2026-10-03\referenced-chatgpt-conversation-this-is-an';
base=fullfile(root,'outputs','PCE_baseline_alignment');
addpath(fullfile(base,'config'));addpath(fullfile(base,'adapters'));
out=fullfile(here,'ScaleSem_four_method_visuals','partials');if exist(out,'dir')~=7,mkdir(out);end
names={'COIL20','PIE','YaleB'}; paths={fullfile(base,'data','COIL20.mat'),fullfile(base,'data','PIE.mat'),fullfile(base,'data','YaleB.mat')};
gp=[2 3 2];ga=[10 1000 1000];sp=[3 3 3];pseeds=[20261107 20261108 20261109];
methods={'ScaleSem-NMF','HLPNMF','GOCNMF','SNMFWLP'};seed=20260627;name=names{dataset_id};
[X,y]=load_data(paths{dataset_id});n=numel(y);c=max(y);cfg=pce_protocol_config(base);cfg.label_ratio=.1;
S=load(fullfile(here,'scale_semantic_nmf_psd_l1_iter200_tol1e-07',sprintf('%s_seed%d.mat',name,seed)),'F','order','labelled');
H=load(fullfile(here,'HLPNMF_ratio0.1_iter30',sprintf('%s_seed%d.mat',name,seed)),'V','order');
lab=logical(S.labelled(:));local_seed(seed);W0=max(rand(size(X,1),c),eps);H0=max(rand(c,n),eps);
opt=cfg;opt.dataset=name;opt.dataset_index=1;opt.seed=seed;opt.graph_p=gp(dataset_id);opt.goc_alpha=ga(dataset_id);opt.goc_parameter_tag={'fixed_visual'};
local_seed(seed);[~,ig]=run_GOCNMF(X,y,lab,W0,H0,opt);
opt.graph_p=sp(dataset_id);opt.snmfwlp_alpha=1000;opt.snmfwlp_beta=1e5;
local_seed(seed);[~,isn]=run_SNMFWLP(X,y,lab,W0,H0,opt);
R=cell(1,4);R{1}=zeros(n,c);R{1}(S.order,:)=S.F;R{2}=zeros(n,c);R{2}(H.order,:)=H.V;R{3}=ig.V;R{4}=isn.V;
pool=find(~lab);keep=stratified(y(pool),1500,seed+dataset_id);idx=pool(keep);labels=y(idx);Z=cell(1,4);purity=zeros(1,4);
for m=1:4,local_seed(pseeds(projection_id));Z{m}=do_tsne(R{m}(idx,:));purity(m)=knn_purity(Z{m},labels,10);end
save(fullfile(out,sprintf('d%d_z%d.mat',dataset_id,projection_id)),'Z','purity','labels','idx','name','methods','seed','pseeds','dataset_id','projection_id');
fprintf('DONE %s projection %d\n',name,projection_id);
end
function [X,y]=load_data(p),S=load(p);if isfield(S,'X'),X=double(S.X);else,X=double(S.fea)';end;if isfield(S,'y'),y=double(S.y(:));else,y=double(S.gnd(:));end;if size(X,2)~=numel(y),X=X';end;[~,~,y]=unique(y);y=double(y);nr=sqrt(sum(X.^2,1));nr(nr==0)=1;X=bsxfun(@rdivide,X,nr);end
function Z=do_tsne(A),A=double(A);mu=mean(A,1);sd=std(A,0,1);sd(sd<1e-12)=1;A=bsxfun(@rdivide,bsxfun(@minus,A,mu),sd);np=min([30,size(A,2),size(A,1)-1]);Z=tsne(A,'NumDimensions',2,'NumPCAComponents',np,'Standardize',false,'Verbose',0);if any(~isfinite(Z(:))),error('Non-finite t-SNE');end,end
function p=knn_purity(Z,y,k),n=size(Z,1);D=bsxfun(@plus,sum(Z.^2,2),sum(Z.^2,2)')-2*(Z*Z');D(1:n+1:end)=inf;[~,o]=sort(D,2,'ascend');nb=o(:,1:min(k,n-1));p=mean(mean(bsxfun(@eq,y(nb),y(:)),2));end
function keep=stratified(y,mx,s),local_seed(s);cl=unique(y(:))';per=max(1,floor(mx/numel(cl)));keep=[];for j=1:numel(cl),q=find(y==cl(j));q=q(randperm(numel(q)));keep=[keep;q(1:min(per,numel(q)))];end;if numel(keep)<min(mx,numel(y)),r=setdiff((1:numel(y))',keep,'stable');r=r(randperm(numel(r)));t=min(numel(r),min(mx,numel(y))-numel(keep));keep=[keep;r(1:t)];end;keep=sort(keep);end
function local_seed(s),rand('twister',s);randn('state',s);end %#ok<RAND>
