function exportToSTL(F, V, F_in, V_in, outerFilename, innerFilename)
    % Export outer and inner geometries as separate binary STL files
    
    % Export outer geometry to binary STL
    writeBinarySTL(outerFilename, F, V);
    disp(['Outer wall geometry exported to ', outerFilename]);
    
    % Export inner geometry to binary STL
    writeBinarySTL(innerFilename, F_in, V_in);
    disp(['Inner wall geometry exported to ', innerFilename]);
end

function writeBinarySTL(filename, F, V)
    % Function to write STL file in binary format
    fid = fopen(filename, 'wb');
    
    % Write the 80-byte header (can be left empty or used for a description)
    header = uint8(zeros(1, 80));
    fwrite(fid, header, 'uint8');
    
    % Write the number of triangles (facets)
    numTriangles = size(F, 1);
    fwrite(fid, numTriangles, 'uint32');
    
    % Write the triangle data
    for i = 1:numTriangles
        % Get the vertices of the triangle
        v1 = V(F(i, 1), :);
        v2 = V(F(i, 2), :);
        v3 = V(F(i, 3), :);
        
        % Calculate the face normal
        normal = cross(v2 - v1, v3 - v1);
        normal = normal / norm(normal);  % Normalize the normal vector
        if any(isnan(normal))  % If the normal is not valid, set it to zero
            normal = [0 0 0];
        end
        
        % Write the normal vector (3 floats)
        fwrite(fid, normal, 'float32');
        
        % Write the vertices (3 floats for each vertex)
        fwrite(fid, v1, 'float32');
        fwrite(fid, v2, 'float32');
        fwrite(fid, v3, 'float32');
        
        % Write the attribute byte count (2 bytes, typically 0)
        fwrite(fid, 0, 'uint16');
    end
    
    % Close the file
    fclose(fid);
end
