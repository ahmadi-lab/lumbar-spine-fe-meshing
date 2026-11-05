function [F_shell, V_shell, F_core, V_core_smoothed] = extractShellAndCore(F, V, core_thickness, lambda, iterations)
    % Function to extract the shell and core from the input faces and vertices
    % Input:
    %   F: Faces of the geometry (Nx3 matrix)
    %   V: Vertices of the geometry (Mx3 matrix)
    %   core_thickness: Thickness of the core (distance between shell and core)
    %   lambda: Smoothing factor for the core (0 < lambda <= 1)
    %   iterations: Number of smoothing iterations for the core
    % Output:
    %   F_shell: Faces of the shell (same as F)
    %   V_shell: Vertices of the shell (same as V)
    %   F_core: Faces of the core (same as F)
    %   V_core_smoothed: Smoothed vertices of the core

    % Compute face normals
    face_normals = faceNormal(triangulation(F, V));

    % Initialize the core vertices (same as original vertices initially)
    V_core = V;

    % Loop through each face and move vertices inward by core_thickness
    for i = 1:size(F, 1)
        face_vertices = F(i, :);
        % Move each vertex inward along the normal vector
        V_core(face_vertices, :) = V_core(face_vertices, :) - core_thickness * face_normals(i, :);
    end

    % Apply Laplacian smoothing to the core vertices
    V_core_smoothed = V_core;
    for iter = 1:iterations
        % Compute the centroid of each face
        centroids = (V_core_smoothed(F(:, 1), :) + V_core_smoothed(F(:, 2), :) + V_core_smoothed(F(:, 3), :)) / 3;

        % For each vertex, replace its position with the average of neighboring face centroids
        for v = 1:size(V_core_smoothed, 1)
            % Find the faces that include this vertex
            faces_with_vertex = find(any(F == v, 2));

            % Compute the average of the centroids of these faces
            avg_centroid = mean(centroids(faces_with_vertex, :), 1);

            % Move the vertex toward the average centroid
            V_core_smoothed(v, :) = (1 - lambda) * V_core_smoothed(v, :) + lambda * avg_centroid;
        end
    end

    % Output shell and core
    F_shell = F;
    V_shell = V;
    F_core = F;
end

% function [F_shell, V_shell, F_core, V_core_smoothed] = extractShellAndCore(F, V, core_thickness, lambda, iterations)
%     % Function to extract the shell and core from the input faces and vertices
%     % Input:
%     %   F: Faces of the geometry (Nx3 matrix)
%     %   V: Vertices of the geometry (Mx3 matrix)
%     %   core_thickness: Thickness of the core (distance between shell and core)
%     %   lambda: Smoothing factor for the core (0 < lambda <= 1)
%     %   iterations: Number of smoothing iterations for the core
%     % Output:
%     %   F_shell: Faces of the shell (same as F)
%     %   V_shell: Vertices of the shell (same as V)
%     %   F_core: Faces of the core
%     %   V_core_smoothed: Smoothed vertices of the core
% 
%     % Compute face normals
%     face_normals = faceNormal(triangulation(F, V));
% 
%     % Initialize the core vertices (same as original vertices initially)
%     V_core = V;
% 
%     % Loop through each face and move vertices inward by core_thickness
%     for i = 1:size(F, 1)
%         face_vertices = F(i, :);
%         % Move each vertex inward along the normal vector
%         V_core(face_vertices, :) = V_core(face_vertices, :) - core_thickness * face_normals(i, :);
%     end
% 
%     % Apply Laplacian smoothing to the core vertices
%     V_core_smoothed = V_core;
%     for iter = 1:iterations
%         % Compute the centroid of each face
%         centroids = (V_core_smoothed(F(:, 1), :) + V_core_smoothed(F(:, 2), :) + V_core_smoothed(F(:, 3), :)) / 3;
% 
%         % For each vertex, replace its position with the average of neighboring face centroids
%         for v = 1:size(V_core_smoothed, 1)
%             % Find the faces that include this vertex
%             faces_with_vertex = find(any(F == v, 2));
% 
%             % Compute the average of the centroids of these faces
%             avg_centroid = mean(centroids(faces_with_vertex, :), 1);
% 
%             % Move the vertex toward the average centroid
%             V_core_smoothed(v, :) = (1 - lambda) * V_core_smoothed(v, :) + lambda * avg_centroid;
%         end
%     end
% 
%     % Recompute faces for the core based on V_core_smoothed
%     valid_faces = false(size(F, 1), 1);
%     for i = 1:size(F, 1)
%         % Check if all vertices of the face are distinct after smoothing
%         face_vertices = V_core_smoothed(F(i, :), :);
%         if rank(face_vertices) == 3  % This ensures the vertices form a valid triangle
%             valid_faces(i) = true;
%         end
%     end
% 
%     % Keep only valid faces for the core
%     F_core = F(valid_faces, :);
% 
%     % Output shell and core
%     F_shell = F;
%     V_shell = V;
% 
%     [F_shell, V_shell] = patchCleanUnused(F_shell, V_shell);
%     [F_shell, V_shell] = mergeVertices(F_shell, V_shell);
%     [F_core, V_core_smoothed] = patchCleanUnused(F_core, V_core_smoothed);
%     [F_core, V_core_smoothed] = mergeVertices(F_core, V_core_smoothed);
%     maxPerimeter=200;
%     optionStructRemesh.pointSpacing = 0.5;
%     optionStructRemesh.disp_on = 0;  % Display options
% 
%     [F_shell, V_shell] = fillSmallMeshHoles(F_shell, V_shell, maxPerimeter);
%     [F_shell, V_shell] = ggremesh(F_shell, V_shell, optionStructRemesh);
%     [F_shell, V_shell] = fillSmallMeshHoles(F_shell, V_shell, maxPerimeter);
% 
%     [F_core, V_core_smoothed] = fillSmallMeshHoles(F_core, V_core_smoothed, maxPerimeter);
%     [F_core, V_core_smoothed] = ggremesh(F_core, V_core_smoothed, optionStructRemesh);
%     [F_core, V_core_smoothed] = fillSmallMeshHoles(F_core, V_core_smoothed, maxPerimeter);
%         % clear cPar;
% 
% 
% end
