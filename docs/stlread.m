% Function to read STL file
function [vertices, faces, normals, name] = stlread(fileName)
    % Open the file
    fid = fopen(fileName, 'r');
    
    % Read the header
    header = fread(fid, 80, 'uint8=>char')';
    name = strtrim(header);
    
    % Read the number of facets
    numFacets = fread(fid, 1, 'uint32');
    
    % Preallocate memory
    vertices = zeros(3 * numFacets, 3);
    faces = zeros(numFacets, 3);
    normals = zeros(numFacets, 3);
    
    % Read the facets
    for i = 1:numFacets
        % Read the normal vector
        normals(i, :) = fread(fid, 3, 'float32');
        
        % Read the vertices
        v1 = fread(fid, 3, 'float32');
        v2 = fread(fid, 3, 'float32');
        v3 = fread(fid, 3, 'float32');
        
        % Store the vertices
        vertices(3 * (i - 1) + 1, :) = v1;
        vertices(3 * (i - 1) + 2, :) = v2;
        vertices(3 * (i - 1) + 3, :) = v3;
        
        % Store the faces
        faces(i, :) = 3 * (i - 1) + [1, 2, 3];
        
        % Skip the attribute byte count
        fread(fid, 1, 'uint16');
    end
    
    % Close the file
    fclose(fid);
    
    % Remove duplicate vertices
    [vertices, ~, indexn] = unique(vertices, 'rows');
    faces = indexn(faces);
end