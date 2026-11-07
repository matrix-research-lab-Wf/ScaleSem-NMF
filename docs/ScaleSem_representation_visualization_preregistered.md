# ScaleSem-NMF representation and basis visualization protocol

## Questions

1. Do the native low-dimensional representations of ScaleSem-NMF, HLPNMF, GOCNMF, and SNMFWLP show reproducibly different class geometry on the same unlabeled samples?
2. Do the columns of the COIL20 ScaleSem-NMF basis matrix correspond to recognizable class-related reconstruction prototypes?

## Frozen inputs

- Datasets: COIL20, PIE, and YaleB for representation visualization; COIL20 for basis visualization.
- Formal repetition: 20260627, 10% class-stratified supervision, main-table parameters.
- Representations: ScaleSem-NMF uses `F`; HLPNMF, GOCNMF, and SNMFWLP use their native coefficient matrices.
- Samples: the same class-stratified subset of at most 1500 unlabeled samples for every method on a dataset.
- Projection: MATLAB R2019a `tsne`, standardized columns, PCA preprocessing capped at 30 dimensions, three fixed projection random states.
- Display: the first fixed projection is plotted; 10-nearest-neighbor label purity is computed for all three projections as a descriptive stability check.
- Basis comparison: each column of `U` is displayed with its cosine similarity to the corresponding normalized COIL20 class mean.

## Retention rules

- Retain the representation figure only when every projection is finite and method-level differences in local label purity have the same qualitative ordering in at least two of three projection states on at least two datasets.
- Retain the basis figure only when the basis columns are finite and at least half of the class-matched cosine similarities are positive. Interpretability is described quantitatively; visual sharpness is not a retention condition.
- Neither figure is evidence of clustering superiority and neither replaces ACC/NMI.

## Result-changing outcomes

- If projection ordering is unstable, exclude the t-SNE figure and make no representation-separation claim.
- If basis similarities are mostly nonpositive or the semantic-coordinate/class correspondence is broken, exclude the basis figure and revise the prototype interpretation.
