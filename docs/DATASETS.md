# Datasets

The exact MATLAB files used in the reported experiments are included under the data directory.

| Dataset | Samples | Features | Classes |
|---|---:|---:|---:|
| YaleB | 2414 | 1024 | 38 |
| COIL20 | 1440 | 1024 | 20 |
| Optdigits | 5620 | 64 | 10 |
| PIE | 2856 | 1024 | 68 |
| AR | 1680 | 2000 | 120 |
| MSRA25 | 1799 | 256 | 12 |
| COIL100 | 7200 | 1024 | 100 |
| MNIST | 6996 | 784 | 10 |

Except Optdigits, the benchmark versions follow the HLPNMF author repository:
https://github.com/ljisxz/HLPNMF

Optdigits uses the standard UCI version. Expected MATLAB fields are either X and y, or fea and gnd. The loader converts data to d-by-n, remaps labels to consecutive positive integers, converts features to double, and normalizes each nonzero sample to unit Euclidean norm.

DATA_MANIFEST.csv records file sizes and SHA-256 checksums. Users remain responsible for complying with the terms of the original dataset providers.
