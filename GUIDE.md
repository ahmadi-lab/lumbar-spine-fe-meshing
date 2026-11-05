# User Guide

This guide explains how to run the meshing workflow and check its output. Line numbers refer to `Main code.mlx` and `Main_code_export.m`.

## 1. Setup

1. Install MATLAB with the Partial Differential Equation Toolbox and the Statistics and Machine Learning Toolbox.
2. Download [GIBBON](https://github.com/gibbonCode/GIBBON).
3. Clone this repository.
4. In MATLAB, run:

```matlab
cd('path/to/lumbar-spine-fe-meshing')
setup_paths('path/to/GIBBON')
```

`setup_paths` gives this repository priority over GIBBON, so `lib/graphicsModels.m` loads the surfaces in `data/libSurf`.

## 2. Check the stored meshes

```matlab
verify_article_meshes
```

The script lists all 26 parts and compares volumetric elements, surface elements and vertices with Table 2. It then reports the connected components of each cortical mesh.

## 3. Run the workflow

Open `Main code.mlx` and run it section by section from the repository root.

| Step | Lines | Operation | Output |
|---|---|---|---|
| Load surfaces | 1-6 | Reads `L1`-`L5` | Workspace |
| Shell and core | 9-21 | `extractShellAndCore` | Workspace |
| Surface remeshing | 62-88 | `ggremesh` and STL export | `Clean_STL` |
| Volumetric meshing | 130-145 | `meshingCorticalAndCancellous` | Workspace |
| Save bone meshes | 147-189 | MAT and VTK export | `Clean_mesh`, `Clean_VTK` |
| Disc refinement | 201-292 | `fillDiscGap`, `patchSmooth`, `ggremesh`, `meshInsideGeometry` | `Clean_mesh` |
| Nucleus and annulus faces | 334-375 | `processNucleusAnnulus` | Workspace |
| Nucleus mesh | 376-417 | Wall construction and `processNucleusMesh` | `Clean_mesh`, `Clean_VTK` |
| Annulus mesh | 469-488 | `processAnnulusMesh` | `Clean_mesh`, `Clean_VTK` |

## 4. Meshing call

```matlab
meshingCorticalAndCancellous(cancellousFile, corticalFile, surfaceMeshSize, cancellousMeshSize, corticalMeshSize)
```

The workflow uses `surfaceMeshSize = 0.5`, `cancellousMeshSize = 1.5` and `corticalMeshSize = 0.8`.

## 5. Using your own surfaces

Save each surface as a MAT file with faces `F` and vertices `V` in `data/libSurf`, using the names `L1`-`L5` and `D12`-`D45`. `docs/stl_to_libsurf.m` converts one STL file; edit its two path lines for each surface.

To create these files from segmentation images, use `preprocessing/labels_to_surfaces.py`:

```bash
pip install -r preprocessing/requirements.txt
python preprocessing/labels_to_surfaces.py --vertebrae labels.seg.nrrd --discs discs.nii.gz --out output
```

The vertebra image needs one integer label per level, by default 1 to 5 from L1 to L5. The disc image is a binary mask. NRRD and NIfTI files are supported. The script writes one STL and one MAT file per surface. Copy the MAT files to `data/libSurf`.

The surfaces in `data/libSurf` are the reference inputs. Results from this script can vary slightly with the smoothing settings.

## 6. Troubleshooting

| Message | Solution |
|---|---|
| `GIBBON lib and lib_ext folders were not found` | Pass the GIBBON root folder to `setup_paths` |
| `graphicsModels` does not recognize `L1` | Run `setup_paths` again so that this repository's copy takes priority |
| `createpde` or `pca` is undefined | Install the required toolbox |
| ParaView does not open | Set the path in `visualizeMultipleVTK.m`, or comment out line 494 |
