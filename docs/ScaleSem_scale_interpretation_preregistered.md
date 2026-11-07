# Scale interpretation and paired label-noise analysis

## Reconstruction-scale figure

- Dataset: COIL20.
- Formal run: seed 20260627, frozen main-comparison model.
- Classes: 1, 10, and 20.
- Samples: unlabeled, correctly decoded samples closest to the 10th, 50th, and 90th percentiles of learned amplitude within each class.
- Display: original and reconstructed normalized images use one common intensity range within each class. No per-image contrast normalization is permitted.
- Retention rule: retain the figure only if reconstruction norm and learned amplitude have the same ordering in at least two of the three fixed classes and the reconstructions remain recognizable.

## Incorrect-label paired statistics

- Comparison: ScaleSem-NMF minus HLPNMF.
- Units: paired repetition within each dataset and noise level.
- Metrics: ACC and NMI.
- Uncertainty: 95% percentile-bootstrap intervals from 10,000 paired resamples with fixed random state 20261107.
- Interpretation: an interval wholly above zero supports a stable positive paired effect; an interval containing zero is reported as an unresolved paired difference.
