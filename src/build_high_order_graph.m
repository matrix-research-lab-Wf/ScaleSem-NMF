function [L,graph] = build_high_order_graph(X,p,k)
% X is d-by-n; p excludes the sample itself.
[~,n]=size(X); aa=sum(X.^2,1);
D2=max(bsxfun(@plus,aa',aa)-2*(X'*X),0); D=sqrt(D2); D(1:n+1:end)=0;
sigma=mean(D(:)); A=exp(-D2/max(sigma^2,eps));
work=D; idx=zeros(n,p+1);
for j=1:p+1
    [~,idx(:,j)]=min(work,[],2);
    work((idx(:,j)-1)*n+(1:n)')=inf;
end
H=sparse(repmat((1:n)',p+1,1),idx(:),1,n,n);
W=spdiags(sum(A.*H',1)',0,n,n);
DeInv=spdiags(1./max(sum(H,2),eps),0,n,n);
Theta=H'*W*DeInv*H; Theta=(Theta+Theta')/2;
degree=max(sum(Theta,2),eps); Dhalf=spdiags(1./sqrt(degree),0,n,n);
P=Dhalf*Theta*Dhalf; P=(P+P')/2; Pk=P^k; Pk=(Pk+Pk')/2;
L=speye(n)-Pk; L=(L+L')/2;
graph=struct('H',H,'W',W,'P',P,'p',p,'k',k,'sigma',sigma);
end
