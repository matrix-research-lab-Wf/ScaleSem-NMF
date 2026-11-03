function result = run_benchmark_example(name)
%RUN_BENCHMARK_EXAMPLE Run one included dataset with the frozen parameters.
if nargin<1, name='COIL20'; end
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'src')); addpath(fullfile(root,'configs'));
cfg=paper_protocol(); q=find(strcmp(cfg.datasets,name),1);
if isempty(q), error('Unknown dataset: %s',name); end
[X,y]=load_benchmark_dataset(name,fullfile(root,'data'));
n=numel(y); c=max(y); rand('twister',cfg.seeds(1)); %#ok<RAND>
labelled=false(n,1);
for k=1:c
    ix=find(y==k); ix=ix(randperm(numel(ix)));
    labelled(ix(1:max(1,floor(cfg.label_ratio*numel(ix)))))=true;
end
Y=zeros(n,c); Y(sub2ind([n c],(1:n)',y))=1;
order=[find(labelled);find(~labelled)]; Xo=X(:,order); yo=y(order);
labelled_o=false(n,1); labelled_o(1:sum(labelled))=true; Yo=Y(order,:);
[L,~]=build_high_order_graph(Xo,cfg.p(q),cfg.k(q));
opts=struct('alpha',cfg.alpha,'max_iter',cfg.max_iter,'tol',cfg.tol,...
    'min_iter',cfg.min_iter,'seed',cfg.seeds(1),'verbose',true);
[~,~,~,info]=scalesem_nmf(Xo,labelled_o,Yo,L,opts);
truth=yo(~labelled_o); pred=info.prediction(~labelled_o);
result=struct('dataset',name,'direct_accuracy',mean(truth==pred),...
    'iterations',info.iterations,'objective',info.objective);
fprintf('%s direct-label ACC = %.6f\n',name,result.direct_accuracy);
end
