function P = project_simplex_rows(Z)
[m,c]=size(Z); P=zeros(m,c);
for i=1:m
    u=sort(Z(i,:),'descend'); cssv=cumsum(u)-1;
    rho=find(u-cssv./(1:c)>0,1,'last'); theta=cssv(rho)/rho;
    P(i,:)=max(Z(i,:)-theta,0);
end
end
