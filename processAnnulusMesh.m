function [F_Annulus1_filled, V_Annulus1_filled, E_Annulus1_filled] = processAnnulusMesh(V_Nucleus1, F_Nucleus1, V_Annulus1, F_Annulus1)

pointSpacing=2;
optionStructRemesh.pointSpacing = pointSpacing;
optionStructRemesh.disp_on = 0;  % Display options
maxPerimeter=5;

face_centroids = (V_Nucleus1(F_Nucleus1(:,1), :) + V_Nucleus1(F_Nucleus1(:,2), :) + V_Nucleus1(F_Nucleus1(:,3), :)) / 3;

% Step 2: Use the Z-coordinates of the centroids to classify top and bottom faces
% You can adjust the Z threshold if needed, here I am using the midpoint.
z_threshold = (max(face_centroids(:, 3)) + min(face_centroids(:, 3))) / 2;

% Initialize C1 to store the classification
C1 = zeros(size(F_Nucleus1, 1), 1);

% Assign 1 for top faces (centroids above the Z threshold) and 2 for bottom faces
C1(face_centroids(:, 3) > z_threshold) = 1; % Top faces
C1(face_centroids(:, 3) <= z_threshold) = 2; % Bottom faces

% Step 1: Extract the top and bottom boundary edges
F_top = F_Nucleus1(C1==1, :);   % Faces corresponding to the top surface
F_bottom = F_Nucleus1(C1==2, :); % Faces corresponding to the bottom surface

Eb1_top = patchBoundary(F_top); % Boundary edges for top
indList1_top = edgeListToCurve(Eb1_top); % Convert to ordered list
indList1_top = indList1_top(1:end-1); % Remove duplicate point at end
Eb1_bottom = patchBoundary(F_bottom); % Boundary edges for bottom
indList1_bottom = edgeListToCurve(Eb1_bottom); % Convert to ordered list
indList1_bottom = indList1_bottom(1:end-1); % Remove duplicate point at end


nucleusBoundary_top = V_Nucleus1(indList1_top, :);  % Top boundary points from nucleus
nucleusBoundary_bottom = V_Nucleus1(indList1_bottom, :);  % Bottom boundary points from nucleus

% Find nearest neighbors for each nucleus boundary point in the annulus
annulusBoundary_top = zeros(size(nucleusBoundary_top));
annulusBoundary_bottom = zeros(size(nucleusBoundary_bottom));

for i = 1:size(nucleusBoundary_top, 1)
    % Compute distances between the current nucleus boundary point and all annulus points
    distances = sqrt(sum((V_Annulus1 - nucleusBoundary_top(i, :)).^2, 2));
    % Find the index of the nearest annulus point
    [~, minIdx] = min(distances);
    annulusBoundary_top(i, :) = V_Annulus1(minIdx, :);
end

for i = 1:size(nucleusBoundary_bottom, 1)
    % Compute distances between the current nucleus boundary point and all annulus points
    distances = sqrt(sum((V_Annulus1 - nucleusBoundary_bottom(i, :)).^2, 2));
    % Find the index of the nearest annulus point
    [~, minIdx] = min(distances);
    annulusBoundary_bottom(i, :) = V_Annulus1(minIdx, :);
end

% Initialize arrays to store the updated boundaries
matchedBoundary_top = zeros(size(annulusBoundary_top));
matchedBoundary_bottom = zeros(size(annulusBoundary_bottom));

% Match top boundary to the closest vertices in the cleaned mesh
for i = 1:size(annulusBoundary_top, 1)
    % Compute distances between current boundary point and all cleaned vertices
    distances = sqrt(sum((V_Annulus1 - annulusBoundary_top(i, :)).^2, 2));

    % Find the index of the closest vertex in the cleaned mesh
    [~, minIdx] = min(distances);

    % Store the closest vertex in the matched boundary
    matchedBoundary_top(i, :) = V_Annulus1(minIdx, :);
end

% Match bottom boundary to the closest vertices in the cleaned mesh
for i = 1:size(annulusBoundary_bottom, 1)
    % Compute distances between current boundary point and all cleaned vertices
    distances = sqrt(sum((V_Annulus1 - annulusBoundary_bottom(i, :)).^2, 2));

    % Find the index of the closest vertex in the cleaned mesh
    [~, minIdx] = min(distances);

    % Store the closest vertex in the matched boundary
    matchedBoundary_bottom(i, :) = V_Annulus1(minIdx, :);
end

% % Plot the cleaned geometry
% figure;
% trisurf(F_Annulus1, V_Annulus1(:,1), V_Annulus1(:,2), V_Annulus1(:,3), ...
%     'FaceColor', 'red', 'EdgeColor', 'k', 'FaceAlpha', 0.7);
% hold on;
% 
% % Plot the matched boundaries on the cleaned geometry
% plot3(matchedBoundary_top(:,1), matchedBoundary_top(:,2), matchedBoundary_top(:,3), 'b-', 'LineWidth', 2);  % Matched top boundary (blue)
% plot3(matchedBoundary_bottom(:,1), matchedBoundary_bottom(:,2), matchedBoundary_bottom(:,3), 'g-', 'LineWidth', 2);  % Matched bottom boundary (green)
% 
% % Add labels and adjust visualization
% xlabel('X'); ylabel('Y'); zlabel('Z');
% title('Matched Boundaries on Cleaned Annulus Geometry');
% axis equal;
% grid on;
% view(3);

% %%
% % Step 1: Find the centroid of the upper and lower boundaries
% % Step 1: Find the centroid of the upper and lower boundaries
% centroid_top = mean(annulusBoundary_top, 1);
% centroid_bottom = mean(annulusBoundary_bottom, 1);
%
% % Step 2: Calculate angles for each point relative to the centroid
% theta_top = atan2(annulusBoundary_top(:, 2) - centroid_top(2), annulusBoundary_top(:, 1) - centroid_top(1));
% theta_bottom = atan2(annulusBoundary_bottom(:, 2) - centroid_bottom(2), annulusBoundary_bottom(:, 1) - centroid_bottom(1));
%
% % Step 3: Sort both top and bottom boundaries based on the angles
% [~, sortIdx_top] = sort(theta_top);
% [~, sortIdx_bottom] = sort(theta_bottom);
%
% % Sort the boundary points accordingly
% annulusBoundary_top_sorted = annulusBoundary_top(sortIdx_top, :);
% annulusBoundary_bottom_sorted = annulusBoundary_bottom(sortIdx_bottom, :);
%
% % Step 4: Ensure both top and bottom boundaries have the same number of points
% if size(annulusBoundary_top_sorted, 1) ~= size(annulusBoundary_bottom_sorted, 1)
%     error('The top and bottom boundaries must have the same number of points.');
% end
%
% % Step 5: Calculate the centroid and normals for the top and bottom surfaces
% P1_top = mean(annulusBoundary_top_sorted, 1);
% N1_top = mean(patchNormal(F_Annulus1, V_Annulus1), 1);  % Normal for the top surface
%
% P1_bottom = mean(annulusBoundary_bottom_sorted, 1);
% N1_bottom = -mean(patchNormal(F_Annulus1, V_Annulus1), 1);  % Normal for the bottom surface (reverse)
%
% % Step 6: Create the guide curve (simple linear interpolation between centroids)
% Vg = [P1_bottom; P1_top];  % Linear guide between the centroids of the top and bottom boundaries
%
% % Step 7: Perform the loft using sweepLoft (using the sorted boundaries)
% % Now we connect the sorted boundaries directly
% [Fq, Vq, Cq] = sweepLoft(annulusBoundary_bottom_sorted, annulusBoundary_top_sorted, N1_bottom, N1_top, Vg, size(annulusBoundary_top_sorted, 1), 0);
%
% % Step 8: Convert quadrilateral mesh to triangular mesh using quad2tri
% [Ft, Vt, Ct] = quad2tri(Fq, Vq, 'a', Cq);  % Convert quads to triangles
%
% % Step 9: Visualize the lofted mesh
% figure;
% trisurf(Ft, Vt(:,1), Vt(:,2), Vt(:,3), 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.7);
% hold on;
% plot3(annulusBoundary_top_sorted(:, 1), annulusBoundary_top_sorted(:, 2), annulusBoundary_top_sorted(:, 3), 'r-', 'LineWidth', 2);  % Top boundary (red)
% plot3(annulusBoundary_bottom_sorted(:, 1), annulusBoundary_bottom_sorted(:, 2), annulusBoundary_bottom_sorted(:, 3), 'g-', 'LineWidth', 2);  % Bottom boundary (green)
% title('Lofted Mesh Between Sorted and Matched Annulus Boundaries');
% xlabel('X'); ylabel('Y'); zlabel('Z');
% axis equal;
% grid on;


%%
[F_Nucleus1_complete, V_Nucleus1_complete, F_Annulus1_complete, V_Annulus1_complete] = makeWallNucleusAnnulus(V_Nucleus1, F_Nucleus1, V_Annulus1, F_Annulus1);

% Apply smoothing

% [F_Annulus1_complete, V_Annulus1_complete] = patchCleanUnused(F_Annulus1_complete, V_Annulus1_complete); % Clean up unused vertices
% [F_Annulus1_complete, V_Annulus1_complete] = ggremesh(F_Annulus1_complete, V_Annulus1_complete, optionStructRemesh);
% [F_Annulus1_complete, V_Annulus1_complete] = mergeVertices(F_Annulus1_complete, V_Annulus1_complete);
%

% clear cPar;
% cPar.n = 5;  % Number of smoothing iterations
% cPar.Method = 'HC';  % Use Humprey's Classes method (or you can try other methods like 'Laplacian')
%
% V_Annulus1_complete = patchSmooth(F_Annulus1_complete, V_Annulus1_complete, [], cPar);
% % Fill small gaps in Annulus mesh
% maxPerimeter = 5.0; % Adjust the threshold for small holes as needed
% [F_Annulus1_filled, V_Annulus1_filled] = fillSmallMeshHoles(F_Annulus1_complete, V_Annulus1_complete, maxPerimeter);
%
% areaThreshold = 1e-2;  % Define a threshold for degenerate triangle area
% [F_Annulus1_filled, V_Annulus1_filled] = removeDegenerateTriangles(F_Annulus1_filled, V_Annulus1_filled, areaThreshold);
% angleThreshold = 30;           % Minimum angle threshold (in degrees)
% maxEdgeLengthRatio = 20;        % Maximum allowed edge length ratio (longest/shortest edge)
% [F_Annulus1_filled, V_Annulus1_filled] = removeBadTriangles(F_Annulus1_filled, V_Annulus1_filled, angleThreshold, maxEdgeLengthRatio);
% F_Annulus1_filled = removeNonManifoldEdges(F_Annulus1_filled, V_Annulus1_filled);
% % [F_Annulus1_filled, V_Annulus1_filled] = removeTwoEdgeFaces(F_Annulus1_filled, V_Annulus1_filled);
%
% disp('Remeshing mesh...');
% [F_Annulus1_filled, V_Annulus1_filled] = ggremesh(F_Annulus1_filled, V_Annulus1_filled, optionStructRemesh);
% [F_Annulus1_filled, V_Annulus1_filled] = mergeVertices(F_Annulus1_filled, V_Annulus1_filled);
% [F_Annulus1_filled, V_Annulus1_filled] = fillSmallMeshHoles(F_Annulus1_filled, V_Annulus1_filled, maxPerimeter);
%
% [F_Annulus1_filled, V_Annulus1_filled] = fillSmallMeshHoles(F_Annulus1_filled, V_Annulus1_filled, 10);
% [F_Annulus1_filled, V_Annulus1_filled] = fillSmallMeshHoles(F_Annulus1_filled, V_Annulus1_filled, 200);


[F_Annulus1_complete, V_Annulus1_complete] = ggremesh(F_Annulus1_complete, V_Annulus1_complete, optionStructRemesh);
[F_Annulus1_complete, V_Annulus1_complete] = ggremesh(F_Annulus1_complete, V_Annulus1_complete, optionStructRemesh);

% Clean up unused vertices and merge close vertices
[F_Annulus1_complete, V_Annulus1_complete] = patchCleanUnused(F_Annulus1_complete, V_Annulus1_complete);
[F_Annulus1_complete, V_Annulus1_complete] = mergeVertices(F_Annulus1_complete, V_Annulus1_complete);

% % Smoothing the mesh
% clear cPar;
% cPar.n = 30;  % Number of smoothing iterations
% cPar.Method = 'HC';  % Use Humprey's Classes method (or other methods like 'Laplacian')
% V_Nucleus1_complete = patchSmooth(F_Nucleus1_complete, V_Nucleus1_complete, [], cPar);
%
% % Fill small mesh holes based on the perimeter threshold
[F_Annulus1_filled, V_Annulus1_filled] = fillSmallMeshHoles(F_Annulus1_complete, V_Annulus1_complete, maxPerimeter);
[F_Annulus1_filled, V_Annulus1_filled] = ggremesh(F_Annulus1_filled, V_Annulus1_filled, optionStructRemesh);
[F_Annulus1_filled, V_Annulus1_filled] = fillSmallMeshHoles(F_Annulus1_filled, V_Annulus1_filled, maxPerimeter);
[F_Annulus1_filled, V_Annulus1_filled] = ggremesh(F_Annulus1_filled, V_Annulus1_filled, optionStructRemesh);
[F_Annulus1_filled, V_Annulus1_filled] = fillSmallMeshHoles(F_Annulus1_filled, V_Annulus1_filled, maxPerimeter);
boundaryEdges_Nucleus = patchBoundary(F_Annulus1_filled);
if ~isempty(boundaryEdges_Nucleus)
    disp('Boundary edges detected. Please Adjust parameters to handle the surface holes.');

else
    [F_Annulus1_filled, Cbs_Annulus1_filled, V_Annulus1_filled, E_Annulus1_filled] = ...
        meshInsideGeometry(F_Annulus1_filled, V_Annulus1_filled, pointSpacing);
end

end
