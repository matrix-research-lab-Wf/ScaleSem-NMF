function S=analyze_ScaleSem_label_noise_R2019a(outname)
% 汇总错误标签鲁棒性实验并生成 ACC/NMI 曲线，MATLAB R2019a。
if nargin<1||isempty(outname),outname='ScaleSem_label_noise';end
here=fileparts(mfilename('fullpath'));out=fullfile(here,outname);
raw=fullfile(out,'raw.csv');if exist(raw,'file')~=2,error('Missing %s',raw);end
T=readtable(raw);T=T(T.finite==1,:);
datasets={'COIL20','PIE','YaleB'};methods={'ScaleSem-NMF','HLPNMF','GOCNMF','SNMFWLP'};fractions=[.1 .2 .3];
expected=numel(datasets)*numel(methods)*numel(fractions)*20;
if height(T)~=expected,error('Incomplete experiment: %d finite rows, expected %d.',height(T),expected);end

dataset=cell(0,1);method=cell(0,1);noise_fraction=[];ACC_mean=[];ACC_std=[];NMI_mean=[];NMI_std=[];n=[];
for d=1:3,for f=1:3,for m=1:4
 q=strcmp(T.dataset,datasets{d})&abs(T.noise_fraction-fractions(f))<1e-9&strcmp(T.method,methods{m});
 dataset{end+1,1}=datasets{d};method{end+1,1}=methods{m};noise_fraction(end+1,1)=fractions(f); %#ok<AGROW>
 ACC_mean(end+1,1)=mean(T.ACC(q));ACC_std(end+1,1)=std(T.ACC(q)); %#ok<AGROW>
 NMI_mean(end+1,1)=mean(T.NMI(q));NMI_std(end+1,1)=std(T.NMI(q));n(end+1,1)=sum(q); %#ok<AGROW>
end,end,end
S=table(dataset,method,noise_fraction,ACC_mean,ACC_std,NMI_mean,NMI_std,n);
writetable(S,fullfile(out,'summary.csv'));save(fullfile(out,'analysis.mat'),'S','T');

colors=lines(4);marks={'o','s','d','^'};fig=figure('Color','w','Position',[80 60 1450 760]);axs=gobjects(6,1);
for d=1:3
 for metric=1:2
  ax=subplot(2,3,d+3*(metric-1));axs(d+3*(metric-1))=ax;hold(ax,'on');
  for m=1:4
   q=strcmp(S.dataset,datasets{d})&strcmp(S.method,methods{m});
   if metric==1,mu=100*S.ACC_mean(q);sd=100*S.ACC_std(q);else,mu=100*S.NMI_mean(q);sd=100*S.NMI_std(q);end
   errorbar(100*S.noise_fraction(q),mu,sd,'Color',colors(m,:), ...
    'Marker',marks{m},'LineWidth',1.2,'MarkerSize',5,'CapSize',4);
  end
  grid on;box on;xlim([8 32]);set(gca,'XTick',[10 20 30]);
  xlabel('Incorrect labeled samples (%)');
  if metric==1,ylabel('ACC (%)');else,ylabel('NMI (%)');end
  title(datasets{d},'FontWeight','normal');
 end
end
lg=legend(axs(1),methods,'Orientation','horizontal');
set(lg,'Box','off','Position',[0.335 0.955 0.33 0.03]);
set(findall(fig,'Type','axes'),'FontName','Times New Roman','FontSize',10,'LineWidth',0.8);
png=fullfile(out,'label-noise-robustness.png');pdf=fullfile(out,'label-noise-robustness.pdf');
print(fig,png,'-dpng','-r300');set(fig,'PaperPositionMode','auto');print(fig,pdf,'-dpdf','-painters');close(fig);
local_single_metric_figure(S,datasets,methods,fractions,colors,marks,'ACC',out);
local_single_metric_figure(S,datasets,methods,fractions,colors,marks,'NMI',out);
fprintf('Saved %s\n',png);
end

function local_single_metric_figure(S,datasets,methods,fractions,colors,marks,metric,out)
fig=figure('Color','w','Position',[80 80 1450 430]);axs=gobjects(3,1);
for d=1:3
 ax=subplot(1,3,d);axs(d)=ax;hold(ax,'on');
 for m=1:4
  q=strcmp(S.dataset,datasets{d})&strcmp(S.method,methods{m});
  if strcmp(metric,'ACC'),mu=100*S.ACC_mean(q);sd=100*S.ACC_std(q);else,mu=100*S.NMI_mean(q);sd=100*S.NMI_std(q);end
  errorbar(100*S.noise_fraction(q),mu,sd,'Color',colors(m,:), ...
   'Marker',marks{m},'LineWidth',1.2,'MarkerSize',5,'CapSize',4);
 end
 grid on;box on;xlim([8 32]);set(gca,'XTick',100*fractions);
 xlabel('Incorrect labeled samples (%)');ylabel([metric ' (%)']);
 title(datasets{d},'FontWeight','normal');
end
set(axs(1),'Position',[0.055 0.15 0.27 0.72]);
set(axs(2),'Position',[0.375 0.15 0.27 0.72]);
set(axs(3),'Position',[0.695 0.15 0.27 0.72]);
lg=legend(axs(1),methods,'Orientation','horizontal');
set(lg,'Box','off','Position',[0.335 0.965 0.33 0.03]);
set(findall(fig,'Type','axes'),'FontName','Times New Roman','FontSize',10,'LineWidth',0.8);
stem=lower(metric);png=fullfile(out,['label-noise-' stem '.png']);pdf=fullfile(out,['label-noise-' stem '.pdf']);
print(fig,png,'-dpng','-r300');set(fig,'PaperPositionMode','auto');print(fig,pdf,'-dpdf','-painters');close(fig);
end
