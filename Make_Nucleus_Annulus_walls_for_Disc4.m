%% For Disc 4 - Nucleus

face_centroids = (V_Nucleus4(F_Nucleus4(:,1), :) + V_Nucleus4(F_Nucleus4(:,2), :) + V_Nucleus4(F_Nucleus4(:,3), :)) / 3;

% Step 2: Use the Z-coordinates of the centroids to classify top and bottom faces
% You can adjust the Z threshold if needed, here I am using the midpoint.
z_threshold = (max(face_centroids(:, 3)) + min(face_centroids(:, 3))) / 2;
z_threshold=180;
% Initialize C4 to store the classification
C4 = zeros(size(F_Nucleus4, 1), 1);

% Assign 1 for top faces (centroids above the Z threshold) and 2 for bottom faces
C4(face_centroids(:, 3) > z_threshold) = 1; % Top faces
C4(face_centroids(:, 3) <= z_threshold) = 2; % Bottom faces

% Step 1: Extract the top and bottom boundary edges
F_top = F_Nucleus4(C4==1, :);   % Faces corresponding to the top surface
F_bottom = F_Nucleus4(C4==2, :); % Faces corresponding to the bottom surface



Eb4_top = patchBoundary(F_top); % Boundary edges for top
% 
% plotV(V_Nucleus4(Eb4_top, :), 'r.-', 'MarkerSize', 25); % Plot the top boundary edges
% hold on
% plotV(V_Nucleus4(Eb4_bottom, :), 'b.-', 'MarkerSize', 25); % Plot the top boundary edges
% hold on
% trisurf(F_Nucleus4, V_Nucleus4(:,1), V_Nucleus4(:,2), V_Nucleus4(:,3), 'FaceColor', 'green', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
% 

indList4_top = edgeListToCurve(Eb4_top); % Convert to ordered list
indList4_top = indList4_top(1:end-1); % Remove duplicate point at end

Eb4_bottom = patchBoundary(F_bottom); % Boundary edges for bottom

indList4_bottom = edgeListToCurve(Eb4_bottom); % Convert to ordered list
indList4_bottom = indList4_bottom(1:end-1); % Remove duplicate point at end

% Step 2: Handle case where top and bottom have different number of points
n1 = [numel(indList4_top), numel(indList4_bottom)];
[nMax1, indMax1] = max(n1);
nn1 = abs(diff(n1));

% Resample the boundary with fewer points
switch indMax1
    case 1
        % Resample bottom
        [F_Nucleus4, V_Nucleus4, Eb4_bottom, C4] = triSurfSplitBoundary(F_Nucleus4, V_Nucleus4, Eb4_bottom, size(Eb4_bottom, 1) + nn1, C4);
        indList4_bottom = edgeListToCurve(Eb4_bottom);
        indList4_bottom = indList4_bottom(1:end-1);
    case 2
        % Resample top
        [F_Nucleus4, V_Nucleus4, Eb4_top, C4] = triSurfSplitBoundary(F_Nucleus4, V_Nucleus4, Eb4_top, size(Eb4_top, 1) + nn1, C4);
        indList4_top = edgeListToCurve(Eb4_top);
        indList4_top = indList4_top(1:end-1);
end

% Step 3: Align the bottom list to the top (correct ordering for cylinder)
% Calculate the centroid for alignment
centroid_top = mean(V_Nucleus4(indList4_top, :), 1);
centroid_bottom = mean(V_Nucleus4(indList4_bottom, :), 1);

% Shift the top and bottom lists by aligning them based on angles from the centroid
theta_top = atan2(V_Nucleus4(indList4_top, 2) - centroid_top(2), V_Nucleus4(indList4_top, 1) - centroid_top(1));
theta_bottom = atan2(V_Nucleus4(indList4_bottom, 2) - centroid_bottom(2), V_Nucleus4(indList4_bottom, 1) - centroid_bottom(1));

% Sort both top and bottom lists by the angular positions (theta)
[~, sortIdx_top] = sort(theta_top);
[~, sortIdx_bottom] = sort(theta_bottom);

indList4_top = indList4_top(sortIdx_top);
indList4_bottom = indList4_bottom(sortIdx_bottom);

% Step 4: Smooth the curves for better lofting
nC4 = 10;
ns1 = 50;
V_Nucleus4 = smoothCurve(F_Nucleus4, V_Nucleus4, nC4, ns1, indList4_top);
V_Nucleus4 = smoothCurve(F_Nucleus4, V_Nucleus4, nC4, ns1, indList4_bottom);

% Step 5: Calculate the mean positions and normals for the top and bottom surfaces
P1_top = mean(V_Nucleus4(indList4_top, :), 1);
N1_top = mean(patchNormal(F_top, V_Nucleus4), 1);

P1_bottom = mean(V_Nucleus4(indList4_bottom, :), 1);
N1_bottom = -mean(patchNormal(F_bottom, V_Nucleus4), 1);

% Step 6: Visualize the top and bottom curves
% cFigure; hold on;
% gpatch(F_Nucleus4, V_Nucleus4, C4, 'k', 1); % Original surface
% plotV(V_Nucleus4(indList4_top, :), 'r.-', 'MarkerSize', 25, 'LineWidth', 3); % Top curve
% plotV(V_Nucleus4(indList4_bottom, :), 'r.-', 'MarkerSize', 25, 'LineWidth', 3); % Bottom curve
% 
% % Add markers and quiver to indicate normal direction
% plotV(V_Nucleus4(indList4_top(1:2), :), 'y.', 'MarkerSize', 35);
% plotV(V_Nucleus4(indList4_bottom(1:2), :), 'y.', 'MarkerSize', 35);
% quiverVec(P1_top, N1_top, 5, 'r'); % Top normal
% quiverVec(P1_bottom, N1_bottom, 5, 'r'); % Bottom normal

% Step 7: Resample curves to have equal number of points
nResample = max([numel(indList4_top), numel(indList4_bottom)]);

indList4_top = resampleCurve3D(V_Nucleus4, indList4_top, nResample);
indList4_bottom = resampleCurve3D(V_Nucleus4, indList4_bottom, nResample);

% Guide curve for the sweepLoft (simple linear interpolation)
Vg = [mean(V_Nucleus4(indList4_top, :)); mean(V_Nucleus4(indList4_bottom, :))]; % Linear guide

% Step 8: Perform the loft using sweepLoft
[Fq, Vq, Cq] = sweepLoft(V_Nucleus4(indList4_bottom, :), V_Nucleus4(indList4_top, :), N1_bottom, N1_top, Vg, 20, 0);

% Step 9: Convert quadrilateral mesh to triangular mesh using quad2tri
[Ft, Vt, Ct] = quad2tri(Fq, Vq, 'a', Cq); % Convert quads to triangles


% Step 11: Combine the vertex data (V_Nucleus4 and Vt)
V_Nucleus4_complete = [V_Nucleus4; Vt];  % Combine vertices

% Step 12: Adjust the face indices of Ft to reference the combined vertex list
Ft_adjusted = Ft + size(V_Nucleus4, 1);  % Shift Ft indices by the size of V_Nucleus4

% Step 13: Combine the face data (F_Nucleus4 and adjusted Ft)
F_Nucleus4_complete = [F_Nucleus4; Ft_adjusted];  % Combine faces


V_Annulus4_complete = [V_Annulus4; Vt];  % Combine vertices

% Step 12: Adjust the face indices of Ft to reference the combined vertex list
Ft_adjusted_an = Ft + size(V_Annulus4, 1);  % Shift Ft indices by the size of V_Nucleus4

% Step 13: Combine the face data (F_Nucleus4 and adjusted Ft)
F_Annulus4_complete = [F_Annulus4; Ft_adjusted_an];  % Combine faces

% Step 14: Visualize the combined surface
% cFigure; hold on;
% trisurf(F_Nucleus4_complete, V_Nucleus4_complete(:,1), V_Nucleus4_complete(:,2), V_Nucleus4_complete(:,3), 'FaceColor', 'green', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
% trisurf(F_Annulus4_complete, V_Annulus4_complete(:,1), V_Annulus4_complete(:,2), V_Annulus4_complete(:,3), 'FaceColor', 'blue', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
% 
% colormap gjet;
% icolorbar;
% camlight;
% lighting gouraud;
% axis equal;
% view(3);
% gdrawnow;