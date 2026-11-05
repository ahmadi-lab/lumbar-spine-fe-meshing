function [F_cortical_clean, V_cortical_clean, E_cortical_clean, F_cancellous, V_cancellous, E_cancellous] = meshingCorticalAndCancellous(cancellousFile, corticalFile, surfaceMeshSize,cancellousMeshSize,corticalMeshSize)

    % Read STL files for cancellous and cortical geometries
    [F_inner, V_inner] = readBinarySTL(cancellousFile);
    [F_outer, V_outer] = readBinarySTL(corticalFile);

    % Setup remeshing options
    optionStructRemesh.pointSpacing = surfaceMeshSize;
    optionStructRemesh.disp_on = 0;  % Display options

    % Remesh the inner (cancellous) and outer (cortical) geometries
    disp('Remeshing cancellous mesh...');
    [F_inner_remesh, V_inner_remesh] = ggremesh(F_inner, V_inner, optionStructRemesh);

    % F_inner_remesh=F_inner;
    % V_inner_remesh=V_inner;
    % F_outer_remesh=F_outer;
    % V_outer_remesh=V_outer;

    % Generate cancellous mesh (filled)
   [F_cancellous, Cb_cancellous, V_cancellous, E_cancellous] = meshInsideGeometry(F_inner_remesh, V_inner_remesh, cancellousMeshSize);%2
    %[F_cancellous, Cb_cancellous, V_cancellous, E_cancellous] = meshInsideGeometry_grad(F_inner_remesh, V_inner_remesh, 0.5, 2);

    disp('Remeshing cortical mesh...');
    [F_outer_remesh, V_outer_remesh] = ggremesh(F_outer, V_outer, optionStructRemesh);

    % Generate cortical mesh (hollow shell initially the same as outer geometry)
    [F_cortical, Cb_cortical, V_cortical, E_cortical] = meshInsideGeometry(F_outer_remesh, V_outer_remesh, corticalMeshSize);%1

    % Step 1: Remove intersection between cancellous and cortical
    % The cancellous geometry is completely inside the cortical geometry, so the cortical needs to be hollowed.
    inCancellous = inpolyhedron(F_inner_remesh, V_inner_remesh, V_cortical);

    % Keep only vertices that are outside the cancellous geometry
    V_cortical_clean = V_cortical(~inCancellous, :);  % Only keep points that are outside cancellous

    % Reconstruct cortical mesh without intersecting points
    F_cortical_clean = F_cortical(all(~ismember(F_cortical, find(inCancellous)), 2), :);

    % Step 2: Clean E_cortical (elements) to reflect the updated cortical mesh
    % First, create a mapping from the old vertex indices to the new ones
    oldVertexIndices = find(~inCancellous);  % Get the indices of the vertices that are still present
    [~, newIndexMap] = ismember(E_cortical, oldVertexIndices);  % Map old indices to new ones

    % Remove invalid elements (those that reference removed vertices)
    validElements = all(newIndexMap > 0, 2);  % Find elements where all vertices still exist
    E_cortical_clean = newIndexMap(validElements, :);  % Keep only valid elements

end
