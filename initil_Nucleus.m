function [faces, vertices] = initil_Nucleus(F, V, height)
    % F: Faces of the geometry (input)
    % V: Vertices of the geometry (input)
    % height: Height of the cylinder (input)

    % Step 1: Perform PCA to find the best plane
    [coeff, ~, ~] = pca(V);

    % Step 2: Project the vertices onto the first two principal components
    V_2D = V * coeff(:,1:2);

    % Step 3: Find the boundary of the shape using the boundary function
    k = boundary(V_2D(:,1), V_2D(:,2), 0.01); % Adjust shrink factor for detail level

    % Step 4: Create the 3D cylinder by extruding the boundary points
    base_2D = V_2D(k, :); % Boundary points in 2D

    % Create vertices for the cylinder: bottom and top faces
    V_cylinder_bottom = [base_2D, zeros(size(base_2D, 1), 1)]; % z=0 for bottom
    V_cylinder_top = [base_2D, height * ones(size(base_2D, 1), 1)]; % z=height for top

    % Combine vertices for the full cylinder
    vertices = [V_cylinder_bottom; V_cylinder_top];

    % Create faces for the sidewalls of the cylinder (triangular faces)
    n = size(base_2D, 1);
    F_cylinder = [];
    for i = 1:n-1
        % Split each quadrilateral into two triangles
        F_cylinder = [F_cylinder; i, i+1, i+n; i+1, i+n+1, i+n];
    end
    % Close the cylinder by connecting the last points
    F_cylinder = [F_cylinder; n, 1, n+n; 1, n+1, n+n];

    % Step 5: Create the top and bottom faces (triangular)
    % Center points for the top and bottom
    center_bottom = mean(V_cylinder_bottom, 1);
    center_top = mean(V_cylinder_top, 1);

    % Add the center points to the vertex array
    vertices = [vertices; center_bottom; center_top];

    % Indices of the center points
    center_bottom_index = size(vertices, 1) - 1;
    center_top_index = size(vertices, 1);

    % Triangulate the bottom face
    F_bottom = [];
    for i = 1:n-1
        F_bottom = [F_bottom; center_bottom_index, i, i+1];
    end
    F_bottom = [F_bottom; center_bottom_index, n, 1]; % Close the bottom face

    % Triangulate the top face
    F_top = [];
    for i = 1:n-1
        F_top = [F_top; center_top_index, i+n, i+1+n];
    end
    F_top = [F_top; center_top_index, 2*n, n+1]; % Close the top face

    % Combine all faces (sidewalls, top, and bottom), all triangular
    faces = [F_cylinder; F_bottom; F_top];
end
