function report = test_scalesem_nmf()
root=fileparts(fileparts(mfilename('fullpath'))); addpath(fullfile(root,'src'));
seed=17; rand('twister',seed); randn('state',seed); %#ok<RAND>
d=12; n=30; c=3; X=rand(d,n); y=kron((1:c)',ones(n/c,1));
X=bsxfun(@rdivide,X,max(sqrt(sum(X.^2,1)),eps));
labelled=false(n,1); labelled([1 11 21])=true;
Y=zeros(n,c); Y(sub2ind([n c],(1:n)',y))=1;
[L,~]=build_high_order_graph(X,3,2);
opts=struct('alpha',5,'max_iter',50,'tol',1e-8,'seed',seed);
[U,s,F,info]=scalesem_nmf(X,labelled,Y,L,opts);
simplex=max(abs(sum(F,2)-1)); label_error=max(max(abs(F(labelled,:)-Y(labelled,:))));
minimum=min([U(:);s(:);F(:)]); increase=max(diff(info.objective));
report=struct('passed',simplex<1e-10 && label_error<1e-12 && minimum>=-1e-12 && increase<1e-8,...
    'simplex_error',simplex,'label_error',label_error,'minimum_entry',minimum,...
    'maximum_objective_increase',increase);
assert(report.passed,'ScaleSem-NMF self-test failed.');
fprintf('ScaleSem-NMF self-test passed.\n');
end
