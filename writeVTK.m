function writeVTK(F, V, E, filename)
    % F: Faces (<>x3 array)
    % V: Vertices (<>x3 array)
    % E: Elements (<>x4 array)
    % filename: Name of the VTK file to save

    % Open the file for writing
    fid = fopen([filename, '.vtk'], 'w');
    
    if fid == -1
        error('Could not open file for writing.');
    end

    % Write the VTK header
    fprintf(fid, '# vtk DataFile Version 3.0\n');
    fprintf(fid, 'Unstructured Grid Example\n');
    fprintf(fid, 'ASCII\n');
    fprintf(fid, 'DATASET UNSTRUCTURED_GRID\n');

    % Write the vertices (points)
    numVertices = size(V, 1);
    fprintf(fid, 'POINTS %d float\n', numVertices);
    for i = 1:numVertices
        fprintf(fid, '%f %f %f\n', V(i, 1), V(i, 2), V(i, 3));
    end

    % Write the cells (faces or elements)
    numFaces = size(F, 1);
    numElements = size(E, 1);

    totalCells = numFaces + numElements;
    
    % Compute total cell size (VTK format requires an additional integer per cell
    % indicating the number of points in the cell)
    totalCellSize = numFaces * 4 + numElements * 5;

    fprintf(fid, 'CELLS %d %d\n', totalCells, totalCellSize);

    % Write faces (triangles: 3 vertices + 1 for cell size)
    for i = 1:numFaces
        fprintf(fid, '3 %d %d %d\n', F(i, 1) - 1, F(i, 2) - 1, F(i, 3) - 1);
    end

    % Write elements (tetrahedrons: 4 vertices + 1 for cell size)
    for i = 1:numElements
        fprintf(fid, '4 %d %d %d %d\n', E(i, 1) - 1, E(i, 2) - 1, E(i, 3) - 1, E(i, 4) - 1);
    end

    % Write the cell types (5 for triangles, 10 for tetrahedrons in VTK)
    fprintf(fid, 'CELL_TYPES %d\n', totalCells);
    
    for i = 1:numFaces
        fprintf(fid, '5\n'); % VTK_TRIANGLE
    end
    for i = 1:numElements
        fprintf(fid, '10\n'); % VTK_TETRA
    end

    % Close the file
    fclose(fid);

    disp(['File saved as ', filename, '.vtk']);
end
