# Lumbar Spine FE Meshing

MATLAB workflow for building cortical, cancellous and intervertebral disc meshes of the lumbar spine (L1-L5) from surface geometry. It accompanies:

> Ahmadi M, Chen H, Lin M, Biswas D, Doulgeris J, Tang Y, Engeberg ED, Hashemi J, Pires G, Vrionis FD. Streamlined and efficient patient-specific modeling for lumbar spine segmentation and finite element analysis. *Scientific Reports* 15, 35619 (2025). https://doi.org/10.1038/s41598-025-19664-6

## Contents

| Path | Description |
|---|---|
| [`GUIDE.md`](GUIDE.md) | Step-by-step user guide |
| `Main code.mlx` | Geometry and meshing workflow |
| `Main_code_export.m` | Plain-text copy of the live script |
| `data/libSurf/` | Input surfaces `L1`-`L5` and `D12`-`D45` (variables `F`, `V`) |
| `save_data.mat` | Stored meshes of all 26 model parts |
| `verify_article_meshes.m` | Compares `save_data.mat` with Table 2 of the article |
| `setup_paths.m` | Adds GIBBON and this repository to the MATLAB path |
| `preprocessing/` | Python script that creates surfaces from segmentation images |
| `docs/`, root `.m` files | Helper functions |
| `lib/graphicsModels.m` | GIBBON function extended with the model names above |

## Requirements

- MATLAB R2024a or later
- Partial Differential Equation Toolbox
- Statistics and Machine Learning Toolbox
- [GIBBON](https://github.com/gibbonCode/GIBBON), including `lib` and `lib_ext`

`Main code.mlx` opens ParaView at line 494 through `visualizeMultipleVTK.m`. Set the ParaView path in that file, or comment out line 494.

## Quick start

```matlab
setup_paths('path/to/GIBBON')
verify_article_meshes
```

The expected output is `Rows that differ from Table 2: 0`, with totals of 1982875, 587398 and 449280.

To rebuild the meshes, run `Main code.mlx` section by section from the repository root. Output is written to `Clean_STL`, `Clean_mesh` and `Clean_VTK`.

## Settings

| Setting | Value | `Main code.mlx` lines |
|---|---|---|
| `core_thickness`, `lambda`, `iterations` | 0.3, 0.9, 20 | 10-12 |
| Remesh spacing, cancellous and cortical | 3, 2 | 62-63 |
| `surfaceMeshSize`, `cancellousMeshSize`, `corticalMeshSize` | 0.5, 1.5, 0.8 | 131-144 |
| Disc remesh spacing | 0.5 | 268 |
| Nucleus `scaleFactor` | 0.6 | 342 |

`core_thickness` is the offset parameter of `extractShellAndCore.m`. The resulting wall depends on the surface mesh and the smoothing step, and the workflow has no separate thickness check.

The cortical shell is obtained in `meshingCorticalAndCancellous.m` by removing the elements that have a vertex inside the cancellous surface.

## Reference meshes

`save_data.mat` is the reference for the element counts in Table 2. A new run gives a similar mesh but may not reproduce the same counts.

## Data

The input surfaces are included. Image data are not part of this repository.

## License

See [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Citation

Please cite the article above. Citation metadata are in [CITATION.cff](CITATION.cff).
