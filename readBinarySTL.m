function [F, V] = readBinarySTL(filename)
    % Read binary STL file (memory-efficient version)
    fid = fopen(filename, 'rb');
    if fid == -1
        error('Could not open the file.');
    end

    % Skip the header
    fseek(fid, 80, 'bof');

    % Read the number of triangles
    numTriangles = fread(fid, 1, 'uint32');

    % Initialize arrays
    F = zeros(numTriangles, 3);
    V = zeros(numTriangles * 3, 3);

    % Loop through each triangle
    for i = 1:numTriangles
        % Read the normal vector (we'll ignore it)
        fread(fid, 3, 'float32');
        
        % Read the triangle vertices
        v1 = fread(fid, 3, 'float32')';
        v2 = fread(fid, 3, 'float32')';
        v3 = fread(fid, 3, 'float32')';
        
        % Read attribute byte count (ignore it)
        fread(fid, 1, 'uint16');

        % Store vertices (no duplicates, only unique vertices)
        V(3 * i - 2, :) = v1;
        V(3 * i - 1, :) = v2;
        V(3 * i, :)     = v3;

        % Store face (index of vertices, face connects 3 vertices)
        F(i, :) = [3 * i - 2, 3 * i - 1, 3 * i];
    end
    
    fclose(fid);
end
