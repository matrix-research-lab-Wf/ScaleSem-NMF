function T = make_ScaleSem_semantic_matrix_figure_R2019a()
% 类均值语义矩阵与尺度分布图，MATLAB R2019a，无额外工具箱要求。
% 该图直接检查 F 的类别语义集中性和 s 的非退化分布。

here=fileparts(mfilename('fullpath'));
root='E:\codex\2026-10-03\referenced-chatgpt-conversation-this-is-an';
data_dir=fullfile(root,'outputs','PCE_baseline_alignment','data');
result_dir=fullfile(here,'scale_semantic_nmf_psd_l1_iter200_tol1e-07');
out_dir=fullfile(here,'ScaleSem_semantic_matrix_figure');
if exist(out_dir,'dir')~=7,mkdir(out_dir);end

datasets={'COIL20','PIE','YaleB'}; seed=20260627;
diagonal_mass=zeros(3,1); off_diagonal_mass=zeros(3,1);
mean_entropy=zeros(3,1); scale_cv=zeros(3,1); class_argmax_rate=zeros(3,1);
fig=figure('Color','w','Position',[80 60 1500 470]);

for d=1:3
    name=datasets{d};
    D=load(fullfile(data_dir,[name '.mat']));
    if isfield(D,'y'),y=double(D.y(:));else,y=double(D.gnd(:));end
    [~,~,y]=unique(y);y=double(y);
    R=load(fullfile(result_dir,sprintf('%s_seed%d.mat',name,seed)), ...
        'F','s','order','labelled');
    yo=y(R.order); un=~R.labelled(R.order); c=max(yo);
    M=zeros(c,c);
    for q=1:c
        rows=(yo==q)&un;
        M(q,:)=mean(R.F(rows,:),1);
    end
    rowsum=sum(M,2);rowsum(rowsum==0)=1;M=bsxfun(@rdivide,M,rowsum);
    diagonal_mass(d)=mean(diag(M));
    off_diagonal_mass(d)=mean((sum(M,2)-diag(M))/max(c-1,1));
    [~,mx]=max(M,[],2);class_argmax_rate(d)=mean(mx(:)==(1:c)');
    Fu=R.F(un,:);H=-sum(Fu.*log(max(Fu,eps)),2)/max(log(c),eps);
    mean_entropy(d)=mean(H);
    su=R.s(un);scale_cv(d)=std(su)/max(mean(su),eps);

    subplot(1,3,d);
    imagesc(M,[0 max(M(:))]);axis image;colormap(gca,parula(256));colorbar;
    xlabel('Semantic coordinate');ylabel('True class');
    title(sprintf('%s: class-mean F',name),'FontWeight','normal');
    if c<=25,set(gca,'XTick',1:c,'YTick',1:c);else,set(gca,'XTick',[],'YTick',[]);end

end
set(findall(fig,'Type','axes'),'FontName','Times New Roman','FontSize',10, ...
    'LineWidth',0.8,'Box','on');

dataset=datasets';T=table(dataset,diagonal_mass,off_diagonal_mass, ...
    class_argmax_rate,mean_entropy,scale_cv);
writetable(T,fullfile(out_dir,'semantic-matrix-statistics.csv'));
save(fullfile(out_dir,'semantic-matrix-statistics.mat'),'T','seed');
print(fig,fullfile(out_dir,'semantic-matrix-and-scale.png'),'-dpng','-r300');
set(fig,'PaperPositionMode','auto');
print(fig,fullfile(out_dir,'semantic-matrix-and-scale.pdf'),'-dpdf','-painters');
close(fig);disp(T);
end
