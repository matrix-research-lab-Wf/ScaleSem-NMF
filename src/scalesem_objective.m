function value = scalesem_objective(X,U,s,F,L,alpha)
V=bsxfun(@times,F,s); R=X-U*V';
value=sum(R(:).^2)+alpha*sum(sum(F.*(L*F)));
end
