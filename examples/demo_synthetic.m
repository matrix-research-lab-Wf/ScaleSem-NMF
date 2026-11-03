function demo_synthetic()
root=fileparts(fileparts(mfilename('fullpath'))); addpath(fullfile(root,'src'));
seed=20260627; rand('twister',seed); randn('state',seed); %#ok<RAND>
d=30; c=3; m=40; n=c*m; Utrue=max(rand(d,c),0.05);
y=kron((1:c)',ones(m,1)); Ftrue=zeros(n,c);
Ftrue(sub2ind([n c],(1:n)',y))=1; s0=0.4+1.6*rand(n,1);
X=Utrue*(bsxfun(@times,Ftrue,s0))'+0.03*rand(d,n);
X=max(X,0); X=bsxfun(@rdivide,X,max(sqrt(sum(X.^2,1)),eps));
labelled=false(n,1); for q=1:c, ix=find(y==q); labelled(ix(1:4))=true; end
Y=zeros(n,c); Y(sub2ind([n c],(1:n)',y))=1;
[L,~]=build_high_order_graph(X,5,2);
opts=struct('alpha',10,'max_iter',100,'tol',1e-7,'seed',seed,'verbose',true);
[~,s,~,info]=scalesem_nmf(X,labelled,Y,L,opts);
acc=mean(info.prediction(~labelled)==y(~labelled));
fprintf('Synthetic direct-label ACC = %.4f, iterations = %d\n',acc,info.iterations);
figure; subplot(1,2,1); plot(info.objective,'LineWidth',1.5);
xlabel('Iteration'); ylabel('Objective'); title('Convergence');
subplot(1,2,2); scatter(s0,s,20,y,'filled');
xlabel('True amplitude'); ylabel('Learned amplitude'); title('Scale recovery');
end
