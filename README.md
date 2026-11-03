# ScaleSem-NMF

MATLAB R2019a implementation of Scale-Semantic Separated Nonnegative Matrix Factorization for Semi-Supervised Clustering.

Quick start:

    addpath('src');
    addpath('examples');
    demo_synthetic

Numerical self-test:

    addpath('src');
    addpath('tests');
    report = test_scalesem_nmf;

Run an included benchmark dataset:

    addpath('src');
    addpath('configs');
    addpath('examples');
    result = run_benchmark_example('COIL20');

No toolbox is required for the core solver or synthetic example.

Repository layout:

- src: core solver and graph construction.
- examples: synthetic demonstration and included-dataset entry point.
- tests: numerical smoke test.
- configs: frozen paper protocol.
- results: compact result summaries.
- paper: LaTeX source, PDF and PNG figures.
- docs: data and reproduction instructions.

The exact benchmark MAT files used in the paper are included under data. See docs/DATASETS.md and data/DATA_MANIFEST.csv.

The code was developed for MATLAB R2019a on Windows. No GPU or Parallel Computing Toolbox is required.

License status: no open-source license has yet been selected. Copyright is reserved until a license file is added.
