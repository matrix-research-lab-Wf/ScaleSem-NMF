# ScaleSem-NMF label-noise robustness experiment

## Question

How rapidly do ScaleSem-NMF and the three frozen baselines lose unlabeled-sample ACC and NMI when a controlled fraction of the available labels is incorrect?

## Frozen protocol

- Datasets: COIL20, PIE, and YaleB.
- Methods: ScaleSem-NMF, HLPNMF, GOCNMF, and SNMFWLP.
- Supervision budget: the same class-stratified 10% request used by the main comparison.
- Noise fractions: 10%, 20%, and 30% of labeled samples in every class.
- Corruption: selected labeled samples receive a uniformly chosen wrong class; unlabeled ground truth is never supplied to a method.
- Repetitions: the same 20 paired runs used by the main comparison.
- Model parameters, stopping rules, initialization convention, graph settings, and each external baseline's native decision mechanism remain unchanged.
- Evaluation: ACC and NMI on the unchanged unlabeled set, against the clean ground truth.

## Decision rule

The experiment supports label-noise robustness only when the paired degradation curves are finite and reproducible and ScaleSem-NMF is not systematically worse than all three baselines across both metrics and all three datasets. Results do not alter the clean-label main table.

## Result-changing outcome

If ScaleSem-NMF degrades more rapidly than the strongest baseline on most dataset-metric cells, the paper must state sensitivity to incorrect supervision and must not claim general supervision robustness.
