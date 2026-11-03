function cfg = paper_protocol()
cfg.datasets={'YaleB','COIL20','Optdigits','PIE','AR','MSRA25','COIL100','MNIST'};
cfg.p=[2 2 5 3 5 10 2 5]; cfg.k=[3 3 1 5 1 1 3 1];
cfg.alpha=1000; cfg.max_iter=200; cfg.tol=1e-7; cfg.min_iter=30;
cfg.label_ratio=0.10; cfg.seeds=20260627:20260646;
cfg.evaluate_unlabelled_only=true;
end
