function [X,y] = load_benchmark_dataset(name,data_dir)
%LOAD_BENCHMARK_DATASET Load and normalize an included benchmark MAT file.
if nargin<2
    root=fileparts(fileparts(mfilename('fullpath')));
    data_dir=fullfile(root,'data');
end
path=fullfile(data_dir,[name '.mat']);
if exist(path,'file')~=2, error('Dataset not found: %s',path); end
S=load(path);
if isfield(S,'X'), X=double(S.X); elseif isfield(S,'fea'), X=double(S.fea); else
    error('No X or fea field in %s.',path);
end
if isfield(S,'y'), y=double(S.y(:)); elseif isfield(S,'gnd'), y=double(S.gnd(:)); ...
        elseif isfield(S,'Y'), y=double(S.Y(:)); else
    error('No y, gnd or Y field in %s.',path);
end
if size(X,2)~=numel(y), X=X'; end
if size(X,2)~=numel(y), error('Feature/label dimension mismatch in %s.',path); end
[~,~,y]=unique(y); y=double(y);
nr=sqrt(sum(X.^2,1)); nr(nr==0)=1; X=bsxfun(@rdivide,X,nr);
end
