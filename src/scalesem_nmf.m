function [U,s,F,info] = scalesem_nmf(X,labelled,Y,L,opts)
%SCALESEM_NMF Scale-semantic separated NMF, MATLAB R2019a compatible.
if nargin<5, opts=struct(); end
[d,n]=size(X); c=size(Y,2);
assert(all(X(:)>=0) && all(isfinite(X(:))),'X must be finite and nonnegative.');
assert(numel(labelled)==n && all(size(L)==[n n]),'Dimension mismatch.');
labelled=logical(labelled(:));
alpha=local_opt(opts,'alpha',1000); max_iter=local_opt(opts,'max_iter',200);
tol=local_opt(opts,'tol',1e-7); min_iter=local_opt(opts,'min_iter',30);
seed=local_opt(opts,'seed',20260627); sigma=local_opt(opts,'armijo_sigma',1e-4);
shrink=local_opt(opts,'armijo_shrink',0.5); max_bt=local_opt(opts,'max_backtrack',40);
verbose=local_opt(opts,'verbose',false); eps0=1e-12;
rand('twister',seed); randn('state',seed); %#ok<RAND>
U=max(rand(d,c),eps); V0=max(rand(n,c),eps);
s=sum(V0,2); F=bsxfun(@rdivide,V0,s); F(labelled,:)=Y(labelled,:);
G=U*F(labelled,:)'; s(labelled)=max(0,sum(X(:,labelled).*G,1)'./max(sum(G.^2,1)',eps0));
obj=zeros(max_iter+1,1); obj(1)=scalesem_objective(X,U,s,F,L,alpha); step=[];
for it=1:max_iter
    V=bsxfun(@times,F,s); U=U.*((X*V)./max(U*(V'*V),eps0));
    G=U*F'; s=max(0,sum(X.*G,1)'./max(sum(G.^2,1)',eps0));
    beta=norm(U,'fro'); if beta>0, U=U/beta; s=beta*s; end
    grad=2*(bsxfun(@times,F*(U'*U),s.^2)-bsxfun(@times,X'*U,s)+alpha*(L*F));
    base=scalesem_objective(X,U,s,F,L,alpha);
    if isempty(step), step=1/max(2*(max(s)^2*norm(U'*U,2)+alpha),eps0);
    else, step=min(1,1.5*step); end
    accepted=false;
    for bt=1:max_bt
        Ft=F; Ft(~labelled,:)=project_simplex_rows(F(~labelled,:)-step*grad(~labelled,:));
        Ft(labelled,:)=Y(labelled,:); ft=scalesem_objective(X,U,s,Ft,L,alpha);
        direction=Ft-F;
        if isfinite(ft) && ft<=base+sigma*sum(sum(grad.*direction))
            F=Ft; accepted=true; break;
        end
        step=shrink*step;
    end
    if ~accepted, step=0; end
    obj(it+1)=scalesem_objective(X,U,s,F,L,alpha);
    if verbose, fprintf('iter=%d obj=%.9e step=%.3e\n',it,obj(it+1),step); end
    if it>=min_iter && abs(obj(it+1)-obj(it))/max(1,abs(obj(it)))<=tol, break; end
end
obj=obj(1:it+1); [~,prediction]=max(F,[],2);
info=struct('objective',obj,'iterations',it,'prediction',prediction,'step',step,...
    'alpha',alpha,'tol',tol,'seed',seed);
end
function value=local_opt(opts,name,default)
if isfield(opts,name), value=opts.(name); else, value=default; end
end
