function [F_Nucleus1_filled, V_Nucleus1_filled, E_Nucleus1_filled] = processNucleusMesh(F_Nucleus1_complete, V_Nucleus1_complete, pointSpacing, maxPerimeter, areaThreshold, angleThreshold, maxEdgeLengthRatio)

    % Set options for remeshing
    optionStructRemesh.pointSpacing = pointSpacing;
    optionStructRemesh.disp_on = 0;  % Display options

    % Remesh the mesh
    disp('Remeshing mesh...');
    [F_Nucleus1_complete, V_Nucleus1_complete] = ggremesh(F_Nucleus1_complete, V_Nucleus1_complete, optionStructRemesh);
    [F_Nucleus1_complete, V_Nucleus1_complete] = ggremesh(F_Nucleus1_complete, V_Nucleus1_complete, optionStructRemesh);

    % Clean up unused vertices and merge close vertices
    [F_Nucleus1_complete, V_Nucleus1_complete] = patchCleanUnused(F_Nucleus1_complete, V_Nucleus1_complete);
    [F_Nucleus1_complete, V_Nucleus1_complete] = mergeVertices(F_Nucleus1_complete, V_Nucleus1_complete);

    % % Smoothing the mesh
    % clear cPar;
    % cPar.n = 30;  % Number of smoothing iterations
    % cPar.Method = 'HC';  % Use Humprey's Classes method (or other methods like 'Laplacian')
    % V_Nucleus1_complete = patchSmooth(F_Nucleus1_complete, V_Nucleus1_complete, [], cPar);
    % 
    % % Fill small mesh holes based on the perimeter threshold
    [F_Nucleus1_filled, V_Nucleus1_filled] = fillSmallMeshHoles(F_Nucleus1_complete, V_Nucleus1_complete, maxPerimeter);
    [F_Nucleus1_filled, V_Nucleus1_filled] = ggremesh(F_Nucleus1_filled, V_Nucleus1_filled, optionStructRemesh);
    [F_Nucleus1_filled, V_Nucleus1_filled] = fillSmallMeshHoles(F_Nucleus1_filled, V_Nucleus1_filled, maxPerimeter);
    boundaryEdges_Nucleus = patchBoundary(F_Nucleus1_filled);
    if ~isempty(boundaryEdges_Nucleus)
        disp('Boundary edges detected. Please Adjust parameters to handle the surface holes.');

    else
    [F_Nucleus1_filled, Cbs_Nucleus1_filled, V_Nucleus1_filled, E_Nucleus1_filled] = meshInsideGeometry(F_Nucleus1_filled, V_Nucleus1_filled, pointSpacing);
    end

    % 
    % % Remove degenerate triangles based on area threshold
    % [F_Nucleus1_filled, V_Nucleus1_filled] = removeDegenerateTriangles(F_Nucleus1_filled, V_Nucleus1_filled, areaThreshold);
    % 
    % % Remove bad triangles based on angle and edge length thresholds
    % [F_Nucleus1_filled, V_Nucleus1_filled] = removeBadTriangles(F_Nucleus1_filled, V_Nucleus1_filled, angleThreshold, maxEdgeLengthRatio);
    % 
    % % Remove duplicate and non-manifold edges
    % F_Nucleus1_filled = removeDuplicateEdges(F_Nucleus1_filled);
    % F_Nucleus1_filled = removeNonManifoldEdges(F_Nucleus1_filled, V_Nucleus1_filled);
    % 
    % % Fill small mesh holes again to ensure continuity
    % [F_Nucleus1_filled, V_Nucleus1_filled] = fillSmallMeshHoles(F_Nucleus1_filled, V_Nucleus1_filled, maxPerimeter);
    % 
    % % Remesh the mesh again to improve uniformity
    % disp('Remeshing mesh...');
    % [F_Nucleus1_filled, V_Nucleus1_filled] = ggremesh(F_Nucleus1_filled, V_Nucleus1_filled, optionStructRemesh);
    % 
    % [F_Nucleus1_filled, V_Nucleus1_filled] = fillSmallMeshHoles(F_Nucleus1_filled, V_Nucleus1_filled, maxPerimeter);
    % 
    % % Mesh the inside of the geometry with the provided point spacing
    % 
    % Return the filled mesh data
end
