# Reproducibility

Core check:

    addpath('src');
    addpath('tests');
    test_scalesem_nmf

Paper protocol:

- MATLAB R2019a
- seeds 20260627--20260646
- class-stratified 10 percent supervision
- evaluation on unlabeled samples only
- alpha 1000
- maximum 200 iterations
- relative-objective tolerance 1e-7 after 30 complete cycles
- denominator safeguard 1e-12
- Armijo sigma 1e-4 and at most 40 reductions

Dataset-level p and k are in configs/paper_protocol.m.

The scripts under reproduction regenerate the label-noise analysis, radial-mechanism diagnostic, semantic-matrix visualization, and four-method t-SNE analysis from the frozen protocol and saved outputs.

HLPNMF, GOCNMF and SNMFWLP remain third-party code. Their native graph construction, optimization, stopping and decision mechanisms must be preserved. Large model states and third-party implementations are excluded from this repository.
