"""Convert vertebra labels and a disc mask into surfaces for data/libSurf.

Usage:
    python labels_to_surfaces.py --vertebrae labels.seg.nrrd --discs discs.nii.gz --out output

The vertebra image holds one integer label per level, from L1 to L5.
The disc image holds a binary mask of the intervertebral discs.
Each surface is written as an STL file and as a MAT file with variables F and V.
Coordinates are written in the left-posterior-superior frame, in millimetres.
"""

import argparse
import gzip
import os
import re

import nibabel as nib
import numpy as np
import scipy.io as sio
import vtk
from scipy import ndimage
from vtk.util import numpy_support


def read_nrrd(path):
    """Read a gzip or raw 3D label NRRD and its index-to-LPS transform."""
    with open(path, "rb") as f:
        data = f.read()
    split = data.find(b"\n\n")
    header = data[:split].decode("latin1")
    fields = dict(re.findall(r"^([^:\n#]+):=?\s*(.*)$", header, re.M))
    sizes = [int(s) for s in fields["sizes"].split()]
    raw = data[split + 2:]
    if "gz" in fields["encoding"]:
        raw = gzip.decompress(raw)
    image = np.frombuffer(raw, dtype=np.uint8).reshape(sizes[::-1]).T
    directions = np.array([[float(x) for x in s.split(",")]
                           for s in re.findall(r"\(([^)]*)\)", fields["space directions"])])
    origin = np.array([float(x) for x in re.findall(r"\(([^)]*)\)", fields["space origin"])[0].split(",")])
    affine = np.eye(4)
    affine[:3, :3] = directions.T
    affine[:3, 3] = origin
    return image, affine


def read_nifti(path):
    """Read a NIfTI image and convert its RAS transform to LPS."""
    image = nib.load(path)
    affine = np.diag([-1.0, -1.0, 1.0, 1.0]) @ image.affine
    return np.asarray(image.dataobj), affine


def read_image(path):
    return read_nrrd(path) if path.endswith(".nrrd") else read_nifti(path)


def mask_to_surface(mask, affine, smoothing_iterations, target_faces):
    """Extract, smooth and decimate one surface from a binary mask."""
    padded = np.pad(mask.astype(np.uint8), 1)
    vtk_image = vtk.vtkImageData()
    vtk_image.SetDimensions(*padded.shape)
    scalars = numpy_support.numpy_to_vtk(padded.ravel(order="F"), deep=True, array_type=vtk.VTK_UNSIGNED_CHAR)
    vtk_image.GetPointData().SetScalars(scalars)

    contour = vtk.vtkDiscreteFlyingEdges3D()
    contour.SetInputData(vtk_image)
    contour.SetValue(0, 1)

    smoother = vtk.vtkWindowedSincPolyDataFilter()
    smoother.SetInputConnection(contour.GetOutputPort())
    smoother.SetNumberOfIterations(smoothing_iterations)
    smoother.SetPassBand(0.05)
    smoother.NonManifoldSmoothingOn()
    smoother.NormalizeCoordinatesOn()
    smoother.Update()

    surface = smoother.GetOutput()
    if target_faces < surface.GetNumberOfCells():
        decimate = vtk.vtkQuadricDecimation()
        decimate.SetInputData(surface)
        decimate.SetTargetReduction(1.0 - target_faces / surface.GetNumberOfCells())
        decimate.Update()
        surface = decimate.GetOutput()

    clean = vtk.vtkCleanPolyData()
    clean.SetInputData(surface)
    clean.Update()
    surface = clean.GetOutput()

    points = numpy_support.vtk_to_numpy(surface.GetPoints().GetData()).astype(float) - 1.0
    faces = numpy_support.vtk_to_numpy(surface.GetPolys().GetConnectivityArray()).reshape(-1, 3)
    vertices = points @ affine[:3, :3].T + affine[:3, 3]

    # The index-to-world transform can mirror the surface
    if np.linalg.det(affine[:3, :3]) < 0:
        faces = faces[:, [0, 2, 1]]
    return faces.astype(np.int64), vertices


def write_stl(path, faces, vertices):
    points = vtk.vtkPoints()
    points.SetData(numpy_support.numpy_to_vtk(vertices, deep=True))
    cells = vtk.vtkCellArray()
    for face in faces:
        cells.InsertNextCell(3, [int(i) for i in face])
    surface = vtk.vtkPolyData()
    surface.SetPoints(points)
    surface.SetPolys(cells)
    writer = vtk.vtkSTLWriter()
    writer.SetFileName(path)
    writer.SetFileTypeToBinary()
    writer.SetInputData(surface)
    writer.Write()


def save_surface(out, name, faces, vertices):
    write_stl(os.path.join(out, name + ".stl"), faces, vertices)
    sio.savemat(os.path.join(out, name + ".mat"), {"F": faces + 1.0, "V": vertices})
    print(f"{name}: {len(faces)} faces, {len(vertices)} vertices, "
          f"min {vertices.min(0).round(1)}, max {vertices.max(0).round(1)}")


def disc_masks(mask, affine, level_z):
    """Assign the disc component between each pair of adjacent vertebrae."""
    labels, count = ndimage.label(mask > 0)
    centres = np.array(ndimage.center_of_mass(mask > 0, labels, range(1, count + 1)))
    z = (np.c_[centres, np.ones(count)] @ affine.T)[:, 2]
    sizes = ndimage.sum(mask > 0, labels, range(1, count + 1))
    result = []
    for upper, lower in zip(level_z[:-1], level_z[1:]):
        inside = np.where((z < upper) & (z > lower))[0]
        if inside.size == 0:
            raise ValueError(f"No disc found between z = {lower:.1f} and z = {upper:.1f}")
        result.append(labels == inside[np.argmax(sizes[inside])] + 1)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--vertebrae", required=True, help="Label image, NRRD or NIfTI")
    parser.add_argument("--discs", required=True, help="Binary disc mask, NRRD or NIfTI")
    parser.add_argument("--out", required=True, help="Output folder")
    parser.add_argument("--labels", type=int, nargs=5, default=[1, 2, 3, 4, 5], help="Label values of L1 to L5")
    parser.add_argument("--smoothing", type=int, default=30, help="Smoothing iterations")
    parser.add_argument("--vertebra-faces", type=int, default=1000000, help="Maximum faces per vertebra")
    parser.add_argument("--disc-faces", type=int, default=1000000, help="Maximum faces per disc")
    args = parser.parse_args()
    os.makedirs(args.out, exist_ok=True)

    image, affine = read_image(args.vertebrae)
    level_z = []
    for k, value in enumerate(args.labels, start=1):
        mask = image == value
        if not mask.any():
            raise ValueError(f"Label {value} of L{k} is empty")
        faces, vertices = mask_to_surface(mask, affine, args.smoothing, args.vertebra_faces)
        save_surface(args.out, f"L{k}", faces, vertices)
        level_z.append(vertices[:, 2].mean())

    disc_image, disc_affine = read_image(args.discs)
    names = ["D12", "D23", "D34", "D45"]
    for name, mask in zip(names, disc_masks(disc_image, disc_affine, level_z)):
        faces, vertices = mask_to_surface(mask, disc_affine, args.smoothing, args.disc_faces)
        save_surface(args.out, name, faces, vertices)


if __name__ == "__main__":
    main()
