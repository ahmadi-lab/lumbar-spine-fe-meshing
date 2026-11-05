
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

% Step 2: Handle case where top and bottom have different number of points
n1 = [numel(indList1_top), numel(indList1_bottom)];
[nMax1, indMax1] = max(n1);
nn1 = abs(diff(n1));

% Resample the boundary with fewer points
switch indMax1
    case 1
        % Resample bottom
        [F_Nucleus1, V_Nucleus1, Eb1_bottom, C1] = triSurfSplitBoundary(F_Nucleus1, V_Nucleus1, Eb1_bottom, size(Eb1_bottom, 1) + nn1, C1);
        indList1_bottom = edgeListToCurve(Eb1_bottom);
        indList1_bottom = indList1_bottom(1:end-1);
    case 2
        % Resample top
        [F_Nucleus1, V_Nucleus1, Eb1_top, C1] = triSurfSplitBoundary(F_Nucleus1, V_Nucleus1, Eb1_top, size(Eb1_top, 1) + nn1, C1);
        indList1_top = edgeListToCurve(Eb1_top);
        indList1_top = indList1_top(1:end-1);
end

% Step 3: Align the bottom list to the top (correct ordering for cylinder)
% Calculate the centroid for alignment
centroid_top = mean(V_Nucleus1(indList1_top, :), 1);
centroid_bottom = mean(V_Nucleus1(indList1_bottom, :), 1);

% Shift the top and bottom lists by aligning them based on angles from the centroid
theta_top = atan2(V_Nucleus1(indList1_top, 2) - centroid_top(2), V_Nucleus1(indList1_top, 1) - centroid_top(1));
theta_bottom = atan2(V_Nucleus1(indList1_bottom, 2) - centroid_bottom(2), V_Nucleus1(indList1_bottom, 1) - centroid_bottom(1));

% Sort both top and bottom lists by the angular positions (theta)
[~, sortIdx_top] = sort(theta_top);
[~, sortIdx_bottom] = sort(theta_bottom);

indList1_top = indList1_top(sortIdx_top);
indList1_bottom = indList1_bottom(sortIdx_bottom);

% Step 4: Smooth the curves for better lofting
nc1 = 10;
ns1 = 50;
V_Nucleus1 = smoothCurve(F_Nucleus1, V_Nucleus1, nc1, ns1, indList1_top);
V_Nucleus1 = smoothCurve(F_Nucleus1, V_Nucleus1, nc1, ns1, indList1_bottom);

% Step 5: Calculate the mean positions and normals for the top and bottom surfaces
P1_top = mean(V_Nucleus1(indList1_top, :), 1);
N1_top = mean(patchNormal(F_top, V_Nucleus1), 1);

P1_bottom = mean(V_Nucleus1(indList1_bottom, :), 1);
N1_bottom = -mean(patchNormal(F_bottom, V_Nucleus1), 1);

% Step 6: Visualize the top and bottom curves
% cFigure; hold on;
% gpatch(F_Nucleus1, V_Nucleus1, C1, 'k', 1); % Original surface
% plotV(V_Nucleus1(indList1_top, :), 'r.-', 'MarkerSize', 25, 'LineWidth', 3); % Top curve
% plotV(V_Nucleus1(indList1_bottom, :), 'r.-', 'MarkerSize', 25, 'LineWidth', 3); % Bottom curve
% 
% % Add markers and quiver to indicate normal direction
% plotV(V_Nucleus1(indList1_top(1:2), :), 'y.', 'MarkerSize', 35);
% plotV(V_Nucleus1(indList1_bottom(1:2), :), 'y.', 'MarkerSize', 35);
% quiverVec(P1_top, N1_top, 5, 'r'); % Top normal
% quiverVec(P1_bottom, N1_bottom, 5, 'r'); % Bottom normal

% Step 7: Resample curves to have equal number of points
nResample = max([numel(indList1_top), numel(indList1_bottom)]);

indList1_top = resampleCurve3D(V_Nucleus1, indList1_top, nResample);
indList1_bottom = resampleCurve3D(V_Nucleus1, indList1_bottom, nResample);

% Guide curve for the sweepLoft (simple linear interpolation)
Vg = [mean(V_Nucleus1(indList1_top, :)); mean(V_Nucleus1(indList1_bottom, :))]; % Linear guide

% Step 8: Perform the loft using sweepLoft
[Fq, Vq, Cq] = sweepLoft(V_Nucleus1(indList1_bottom, :), V_Nucleus1(indList1_top, :), N1_bottom, N1_top, Vg, 20, 0);

% Step 9: Convert quadrilateral mesh to triangular mesh using quad2tri
[Ft, Vt, Ct] = quad2tri(Fq, Vq, 'a', Cq); % Convert quads to triangles


% Step 11: Combine the vertex data (V_Nucleus1 and Vt)
V_Nucleus1_complete = [V_Nucleus1; Vt];  % Combine vertices

% Step 12: Adjust the face indices of Ft to reference the combined vertex list
Ft_adjusted = Ft + size(V_Nucleus1, 1);  % Shift Ft indices by the size of V_Nucleus1

% Step 13: Combine the face data (F_Nucleus1 and adjusted Ft)
F_Nucleus1_complete = [F_Nucleus1; Ft_adjusted];  % Combine faces


V_Annulus1_complete = [V_Annulus1; Vt];  % Combine vertices

% Step 12: Adjust the face indices of Ft to reference the combined vertex list
Ft_adjusted_an = Ft + size(V_Annulus1, 1);  % Shift Ft indices by the size of V_Nucleus1

% Step 13: Combine the face data (F_Nucleus1 and adjusted Ft)
F_Annulus1_complete = [F_Annulus1; Ft_adjusted_an];  % Combine faces