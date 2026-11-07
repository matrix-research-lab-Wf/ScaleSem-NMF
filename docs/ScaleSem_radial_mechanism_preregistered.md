# ScaleSem-NMF radial-mechanism verification

## Question

Does learning the sample amplitude `s` reduce the labeled-sample reconstruction restriction induced by fixed unit scale, and does the learned amplitude follow the optimal radial coefficient along the learned semantic reconstruction direction?

## Frozen comparison

- Models: the existing full ScaleSem-NMF runs and the existing fixed-scale (`s=1`) ablation.
- Datasets: YaleB, COIL20, Optdigits, PIE, AR, MSRA25, COIL100, and MNIST.
- Repetitions: the existing 20 paired repetitions under the main 10% supervision protocol.
- No parameter, split, initialization, or stopping-rule changes.

For labeled sample `i`, compute

`e_i = ||x_i - s_i U f_i||_2 / ||x_i||_2`

for the full and fixed-scale fits. For the full fit also compute

`a_i^* = max(0, (U f_i)' x_i / ||U f_i||_2^2)`

and the within-run Spearman correlation between `s_i` and `a_i^*`.

## Inferential unit

The repeated protocol run is the paired unit. Sample-level quantities are averaged within each run before paired bootstrap intervals are formed across the 20 runs.

## Retention rule

Retain the result in the manuscript only if:

1. the median paired reconstruction-error reduction is positive on at least 5 of 8 datasets;
2. the median within-run amplitude correlation is positive on at least 5 of 8 datasets; and
3. the pattern is not supported by COIL20 alone.

The experiment tests the radial reconstruction mechanism. It does not redefine the clustering-performance gate.
