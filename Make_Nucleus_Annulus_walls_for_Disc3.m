%% For Disc 3 - Nucleus

face_centroids = (V_Nucleus3(F_Nucleus3(:,1), :) + V_Nucleus3(F_Nucleus3(:,2), :) + V_Nucleus3(F_Nucleus3(:,3), :)) / 3;

% Step 2: Use the Z-coordinates of the centroids to classify top and bottom faces
% You can adjust the Z threshold if needed, here I am using the midpoint.
z_threshold = (max(face_centroids(:, 3)) + min(face_centroids(:, 3))) / 2;

% Initialize C3 to store the classification
C3 = zeros(size(F_Nucleus3, 1), 1);

% Assign 1 for top faces (centroids above the Z threshold) and 2 for bottom faces
C3(face_centroids(:, 3) > z_threshold) = 1; % Top faces
C3(face_centroids(:, 3) <= z_threshold) = 2; % Bottom faces

% Step 1: Extract the top and bottom boundary edges
F_top = F_Nucleus3(C3==1, :);   % Faces corresponding to the top surface
F_bottom = F_Nucleus3(C3==2, :); % Faces corresponding to the bottom surface

Eb3_top = patchBoundary(F_top); % Boundary edges for top
indList3_top = edgeListToCurve(Eb3_top); % Convert to ordered list
indList3_top = indList3_top(1:end-1); % Remove duplicate point at end

Eb3_bottom = patchBoundary(F_bottom); % Boundary edges for bottom
indList3_bottom = edgeListToCurve(Eb3_bottom); % Convert to ordered list
indList3_bottom = indList3_bottom(1:end-1); % Remove duplicate point at end

% Step 2: Handle case where top and bottom have different number of points
n1 = [numel(indList3_top), numel(indList3_bottom)];
[nMax1, indMax1] = max(n1);
nn1 = abs(diff(n1));

% Resample the boundary with fewer points
switch indMax1
    case 1
        % Resample bottom
        [F_Nucleus3, V_Nucleus3, Eb3_bottom, C3] = triSurfSplitBoundary(F_Nucleus3, V_Nucleus3, Eb3_bottom, size(Eb3_bottom, 1) + nn1, C3);
        indList3_bottom = edgeListToCurve(Eb3_bottom);
        indList3_bottom = indList3_bottom(1:end-1);
    case 2
        % Resample top
        [F_Nucleus3, V_Nucleus3, Eb3_top, C3] = triSurfSplitBoundary(F_Nucleus3, V_Nucleus3, Eb3_top, size(Eb3_top, 1) + nn1, C3);
        indList3_top = edgeListToCurve(Eb3_top);
        indList3_top = indList3_top(1:end-1);
end

% Step 3: Align the bottom list to the top (correct ordering for cylinder)
% Calculate the centroid for alignment
centroid_top = mean(V_Nucleus3(indList3_top, :), 1);
centroid_bottom = mean(V_Nucleus3(indList3_bottom, :), 1);

% Shift the top and bottom lists by aligning them based on angles from the centroid
theta_top = atan2(V_Nucleus3(indList3_top, 2) - centroid_top(2), V_Nucleus3(indList3_top, 1) - centroid_top(1));
theta_bottom = atan2(V_Nucleus3(indList3_bottom, 2) - centroid_bottom(2), V_Nucleus3(indList3_bottom, 1) - centroid_bottom(1));

% Sort both top and bottom lists by the angular positions (theta)
[~, sortIdx_top] = sort(theta_top);
[~, sortIdx_bottom] = sort(theta_bottom);

indList3_top = indList3_top(sortIdx_top);
indList3_bottom = indList3_bottom(sortIdx_bottom);

% Step 4: Smooth the curves for better lofting
nC3 = 10;
ns1 = 50;
V_Nucleus3 = smoothCurve(F_Nucleus3, V_Nucleus3, nC3, ns1, indList3_top);
V_Nucleus3 = smoothCurve(F_Nucleus3, V_Nucleus3, nC3, ns1, indList3_bottom);

% Step 5: Calculate the mean positions and normals for the top and bottom surfaces
P1_top = mean(V_Nucleus3(indList3_top, :), 1);
N1_top = mean(patchNormal(F_top, V_Nucleus3), 1);

P1_bottom = mean(V_Nucleus3(indList3_bottom, :), 1);
N1_bottom = -mean(patchNormal(F_bottom, V_Nucleus3), 1);

% Step 6: Visualize the top and bottom curves
% cFigure; hold on;
% gpatch(F_Nucleus3, V_Nucleus3, C3, 'k', 1); % Original surface
% plotV(V_Nucleus3(indList3_top, :), 'r.-', 'MarkerSize', 25, 'LineWidth', 3); % Top curve
% plotV(V_Nucleus3(indList3_bottom, :), 'r.-', 'MarkerSize', 25, 'LineWidth', 3); % Bottom curve
% 
% % Add markers and quiver to indicate normal direction
% plotV(V_Nucleus3(indList3_top(1:2), :), 'y.', 'MarkerSize', 35);
% plotV(V_Nucleus3(indList3_bottom(1:2), :), 'y.', 'MarkerSize', 35);
% quiverVec(P1_top, N1_top, 5, 'r'); % Top normal
% quiverVec(P1_bottom, N1_bottom, 5, 'r'); % Bottom normal

% Step 7: Resample curves to have equal number of points
nResample = max([numel(indList3_top), numel(indList3_bottom)]);

indList3_top = resampleCurve3D(V_Nucleus3, indList3_top, nResample);
indList3_bottom = resampleCurve3D(V_Nucleus3, indList3_bottom, nResample);

% Guide curve for the sweepLoft (simple linear interpolation)
Vg = [mean(V_Nucleus3(indList3_top, :)); mean(V_Nucleus3(indList3_bottom, :))]; % Linear guide

% Step 8: Perform the loft using sweepLoft
[Fq, Vq, Cq] = sweepLoft(V_Nucleus3(indList3_bottom, :), V_Nucleus3(indList3_top, :), N1_bottom, N1_top, Vg, 20, 0);

% Step 9: Convert quadrilateral mesh to triangular mesh using quad2tri
[Ft, Vt, Ct] = quad2tri(Fq, Vq, 'a', Cq); % Convert quads to triangles


% Step 11: Combine the vertex data (V_Nucleus3 and Vt)
V_Nucleus3_complete = [V_Nucleus3; Vt];  % Combine vertices

% Step 12: Adjust the face indices of Ft to reference the combined vertex list
Ft_adjusted = Ft + size(V_Nucleus3, 1);  % Shift Ft indices by the size of V_Nucleus3

% Step 13: Combine the face data (F_Nucleus3 and adjusted Ft)
F_Nucleus3_complete = [F_Nucleus3; Ft_adjusted];  % Combine faces


V_Annulus3_complete = [V_Annulus3; Vt];  % Combine vertices

% Step 12: Adjust the face indices of Ft to reference the combined vertex list
Ft_adjusted_an = Ft + size(V_Annulus3, 1);  % Shift Ft indices by the size of V_Nucleus3

% Step 13: Combine the face data (F_Nucleus3 and adjusted Ft)
F_Annulus3_complete = [F_Annulus3; Ft_adjusted_an];  % Combine faces

% Step 14: Visualize the combined surface
% cFigure; hold on;
% trisurf(F_Nucleus3_complete, V_Nucleus3_complete(:,1), V_Nucleus3_complete(:,2), V_Nucleus3_complete(:,3), 'FaceColor', 'green', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
% trisurf(F_Annulus3_complete, V_Annulus3_complete(:,1), V_Annulus3_complete(:,2), V_Annulus3_complete(:,3), 'FaceColor', 'red', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
% 
% colormap gjet;
% icolorbar;
% camlight;
% lighting gouraud;
% axis equal;
% view(3);
% gdrawnow;