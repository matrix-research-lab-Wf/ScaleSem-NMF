function out=analyze_ScaleSem_radial_mechanism_R2019a()
% 完整 ScaleSem-NMF 与固定尺度消融的径向重构机制分析。
% 兼容 MATLAB R2019a。
here=fileparts(mfilename('fullpath'));
root='E:\codex\2026-10-03\referenced-chatgpt-conversation-this-is-an';
base=fullfile(root,'outputs','PCE_baseline_alignment');
full_dir=fullfile(here,'scale_semantic_nmf_psd_l1_iter200_tol1e-07');
fixed_dir=fullfile(here,'scale_semantic_nmf_psd_l1_fixed_s_iter200_tol1e-07');
out_dir=fullfile(here,'ScaleSem_radial_mechanism');if exist(out_dir,'dir')~=7,mkdir(out_dir);end
names={'YaleB','COIL20','Optdigits','PIE','AR','MSRA25','COIL100','MNIST'};
seeds=20260627:20260646; nd=numel(names); ns=numel(seeds);
err_full=nan(nd,ns);err_fixed=nan(nd,ns);rho=nan(nd,ns);nlab=zeros(nd,ns);
scatter_data=struct();
for d=1:nd
    [X,~]=load_data(base,root,names{d});
    for z=1:ns
        seed=seeds(z); A=load(fullfile(full_dir,sprintf('%s_seed%d.mat',names{d},seed)),'U','F','s','order','labelled');
        B=load(fullfile(fixed_dir,sprintf('%s_seed%d.mat',names{d},seed)),'U','F','s','order','labelled');
        [ef,sval,astar]=run_values(X,A); [eb,~,~]=run_values(X,B);
        err_full(d,z)=mean(ef);err_fixed(d,z)=mean(eb);nlab(d,z)=numel(ef);
        rho(d,z)=spearman_local(sval,astar);
        if seed==seeds(1) && any(strcmp(names{d},{'COIL20','PIE','YaleB'}))
            scatter_data.(names{d})=[sval(:),astar(:)];
        end
    end
end
delta=err_fixed-err_full;ci=zeros(nd,2);mu=zeros(nd,1);med_delta=zeros(nd,1);med_rho=zeros(nd,1);
local_seed(20261107);B=10000;
for d=1:nd
    v=delta(d,:);mu(d)=mean(v);med_delta(d)=median(v);med_rho(d)=median(rho(d,:));boot=zeros(B,1);
    for b=1:B,ix=randi(ns,1,ns);boot(b)=mean(v(ix));end
    boot=sort(boot);ci(d,:)=[boot(max(1,round(.025*B))),boot(min(B,round(.975*B)))];
end

rows=cell(nd*ns,8);rr=0;
for d=1:nd,for z=1:ns,rr=rr+1;rows(rr,:)={names{d},seeds(z),nlab(d,z),err_full(d,z),err_fixed(d,z),delta(d,z),rho(d,z),true};end;end
T=cell2table(rows,'VariableNames',{'dataset','seed','n_labeled','error_full','error_fixed','fixed_minus_full','rho_s_astar','finite'});
writetable(T,fullfile(out_dir,'per-run.csv'));
S=table(names',mean(err_full,2),mean(err_fixed,2),mu,ci(:,1),ci(:,2),med_delta,med_rho, ...
    'VariableNames',{'dataset','mean_error_full','mean_error_fixed','mean_reduction','ci_low','ci_high','median_reduction','median_rho'});
writetable(S,fullfile(out_dir,'summary.csv'));

fig=figure('Color','w','Position',[50 50 1550 520]);
subplot(1,3,1);hold on;for d=1:nd,plot([d-.16 d+.16],[mean(err_fixed(d,:)) mean(err_full(d,:))],'-','Color',[.75 .75 .75]);end
plot((1:nd)-.16,mean(err_fixed,2),'s','MarkerFaceColor',[.85 .33 .10],'MarkerEdgeColor','none','MarkerSize',7);
plot((1:nd)+.16,mean(err_full,2),'o','MarkerFaceColor',[0 .45 .74],'MarkerEdgeColor','none','MarkerSize',7);
set(gca,'XTick',1:nd,'XTickLabel',names,'XTickLabelRotation',38);ylabel('Mean labeled relative error');title('(a) Fixed versus learned scale');grid on;box on;legend({'Paired dataset','Fixed scale','Learned scale'},'Location','best');
subplot(1,3,2);hold on;cols=lines(3);sel={'COIL20','PIE','YaleB'};lo=inf;hi=0;for j=1:3,Q=scatter_data.(sel{j});qok=Q(:,1)>0 & Q(:,2)>0;Q=Q(qok,:);lo=min(lo,min(Q(:)));hi=max(hi,max(Q(:)));scatter(Q(:,1),Q(:,2),14,cols(j,:),'filled','MarkerFaceAlpha',.45);end
plot([lo hi],[lo hi],'k--','LineWidth',.9);set(gca,'XScale','log','YScale','log');xlabel('Learned amplitude s_i');ylabel('Optimal radial amplitude a_i^*');title('(b) Radial agreement');grid on;box on;legend([sel {'a_i^*=s_i'}],'Location','best');
subplot(1,3,3);hold on;for d=1:nd,plot(ci(d,:),[d d],'-','Color',[.2 .2 .2],'LineWidth',1.2);plot(mu(d),d,'o','MarkerFaceColor',[0 .45 .74],'MarkerEdgeColor','none');end
plot([0 0],[.5 nd+.5],'--','Color',[.5 .5 .5]);set(gca,'YTick',1:nd,'YTickLabel',names,'YDir','reverse');xlabel('Fixed minus learned relative error');title('(c) Paired mean reduction, 95% interval');grid on;box on;
set(findall(fig,'Type','axes'),'FontName','Times New Roman','FontSize',9,'LineWidth',.8);
png=fullfile(out_dir,'radial-mechanism.png');pdf=fullfile(out_dir,'radial-mechanism.pdf');print(fig,png,'-dpng','-r300');set(fig,'PaperPositionMode','auto');print(fig,pdf,'-dpdf','-painters');close(fig);
save(fullfile(out_dir,'analysis.mat'),'T','S','err_full','err_fixed','delta','rho','scatter_data','seeds','names');
out=struct('summary',S,'png',png,'pdf',pdf,'pass_error',sum(med_delta>0)>=5,'pass_rho',sum(med_rho>0)>=5);
fprintf('Positive median error reduction: %d/8\n',sum(med_delta>0));fprintf('Positive median rho: %d/8\n',sum(med_rho>0));
end
function [e,s,a]=run_values(X,R)
Xo=X(:,R.order);mask=logical(R.labelled(R.order));F=double(R.F(mask,:));s=double(R.s(mask));U=double(R.U);Xm=Xo(:,mask);G=U*F';pred=bsxfun(@times,G,s');den=sqrt(sum(Xm.^2,1));den(den<eps)=1;e=(sqrt(sum((Xm-pred).^2,1))./den)';gn=sum(G.^2,1)';a=max(0,sum(G.*Xm,1)'./max(gn,eps));
end
function r=spearman_local(a,b)
a=a(:);b=b(:);ra=tiedrank(a);rb=tiedrank(b);ra=ra-mean(ra);rb=rb-mean(rb);r=(ra'*rb)/max(norm(ra)*norm(rb),eps);
end
function [X,y]=load_data(base,root,name)
p=fullfile(base,'data',[name '.mat']);if exist(p,'file')~=2,if strcmp(name,'AR'),p=fullfile(root,'work','HLPNMF-author-audit','AR.mat');elseif strcmp(name,'MSRA25'),p=fullfile(base,'vendor','EDNMF','MSRA25.mat');elseif strcmp(name,'MNIST'),p=fullfile(root,'work','HLPNMF-author-audit','MNIST_Han.mat');else,error('Missing %s',name);end;end
D=load(p);if isfield(D,'X'),X=double(D.X);else,X=double(D.fea)';end;if isfield(D,'y'),y=double(D.y(:));else,y=double(D.gnd(:));end;if size(X,2)~=numel(y),X=X';end;[~,~,y]=unique(y);y=double(y);nr=sqrt(sum(X.^2,1));nr(nr==0)=1;X=bsxfun(@rdivide,X,nr);
end
function local_seed(s),rand('twister',s);randn('state',s);end %#ok<RAND>
