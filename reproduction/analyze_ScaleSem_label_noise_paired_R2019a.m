function S=analyze_ScaleSem_label_noise_paired_R2019a()
% ScaleSem-NMF 与 HLPNMF 的错误标签实验配对差异及Bootstrap区间。
here=fileparts(mfilename('fullpath'));indir=fullfile(here,'ScaleSem_label_noise');
T=readtable(fullfile(indir,'raw.csv'));datasets={'COIL20','PIE','YaleB'};fractions=[.1 .2 .3];metrics={'ACC','NMI'};
dataset=cell(18,1);noise_fraction=zeros(18,1);metric=cell(18,1);mean_difference=zeros(18,1);ci_low=zeros(18,1);ci_high=zeros(18,1);positive_count=zeros(18,1);n=zeros(18,1);
local_seed(20261107);r=0;B=10000;
for d=1:3,for f=1:3,for k=1:2
 r=r+1;qS=strcmp(T.dataset,datasets{d})&abs(T.noise_fraction-fractions(f))<1e-9&strcmp(T.method,'ScaleSem-NMF');
 qH=strcmp(T.dataset,datasets{d})&abs(T.noise_fraction-fractions(f))<1e-9&strcmp(T.method,'HLPNMF');
 A=T(qS,{'seed',metrics{k}});H=T(qH,{'seed',metrics{k}});A.Properties.VariableNames{2}='a';H.Properties.VariableNames{2}='h';P=innerjoin(A,H,'Keys','seed');delta=P.a-P.h;
 boot=zeros(B,1);nn=numel(delta);for b=1:B,boot(b)=mean(delta(randi(nn,nn,1)));end;boot=sort(boot);
 dataset{r}=datasets{d};noise_fraction(r)=fractions(f);metric{r}=metrics{k};mean_difference(r)=mean(delta);ci_low(r)=boot(max(1,round(.025*B)));ci_high(r)=boot(min(B,round(.975*B)));positive_count(r)=sum(delta>0);n(r)=nn;
end,end,end
S=table(dataset,noise_fraction,metric,mean_difference,ci_low,ci_high,positive_count,n);
writetable(S,fullfile(indir,'paired-ScaleSem-vs-HLPNMF.csv'));save(fullfile(indir,'paired-ScaleSem-vs-HLPNMF.mat'),'S');disp(S);
end
function local_seed(s),rand('twister',s);randn('state',s);end %#ok<RAND>
