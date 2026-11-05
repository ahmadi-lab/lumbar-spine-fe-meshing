function [F_Nucleus1_complete,V_Nucleus1_complete, F_Annulus1_complete, V_Annulus1_complete] = makeWallNucleusAnnulus(V_Nucleus1, F_Nucleus1, V_Annulus1, F_Annulus1)

    % Step 1: Calculate face centroids
    face_centroids = (V_Nucleus1(F_Nucleus1(:,1), :) + V_Nucleus1(F_Nucleus1(:,2), :) + V_Nucleus1(F_Nucleus1(:,3), :)) / 3;

    % Step 2: Use the Z-coordinates of the centroids to classify top and bottom faces
    z_threshold = (max(face_centroids(:, 3)) + min(face_centroids(:, 3))) / 2;
    C1 = zeros(size(F_Nucleus1, 1), 1);
    C1(face_centroids(:, 3) > z_threshold) = 1;
    C1(face_centroids(:, 3) <= z_threshold) = 2;

    % Step 3: Extract top and bottom boundary edges
    F_top = F_Nucleus1(C1==1, :);
    F_bottom = F_Nucleus1(C1==2, :);
    Eb1_top = patchBoundary(F_top);
    indList1_top = edgeListToCurve(Eb1_top);
    indList1_top = indList1_top(1:end-1);
    Eb1_bottom = patchBoundary(F_bottom);
    indList1_bottom = edgeListToCurve(Eb1_bottom);
    indList1_bottom = indList1_bottom(1:end-1);

    % Step 4: Handle cases where top and bottom have different number of points
    n1 = [numel(indList1_top), numel(indList1_bottom)];
    [nMax1, indMax1] = max(n1);
    nn1 = abs(diff(n1));

    switch indMax1
        case 1
            [F_Nucleus1, V_Nucleus1, Eb1_bottom, C1] = triSurfSplitBoundary(F_Nucleus1, V_Nucleus1, Eb1_bottom, size(Eb1_bottom, 1) + nn1, C1);
            indList1_bottom = edgeListToCurve(Eb1_bottom);
            indList1_bottom = indList1_bottom(1:end-1);
        case 2
            [F_Nucleus1, V_Nucleus1, Eb1_top, C1] = triSurfSplitBoundary(F_Nucleus1, V_Nucleus1, Eb1_top, size(Eb1_top, 1) + nn1, C1);
            indList1_top = edgeListToCurve(Eb1_top);
            indList1_top = indList1_top(1:end-1);
    end

    % Step 5: Resample curves to have equal number of points
    nResample = max([numel(indList1_top), numel(indList1_bottom)]);
    indList1_top = resampleCurve3D(V_Nucleus1, indList1_top, nResample);
    indList1_bottom = resampleCurve3D(V_Nucleus1, indList1_bottom, nResample);

    % Step 6: Perform lofting between top and bottom curves
    centroid_top = mean(V_Nucleus1(indList1_top, :), 1);
    centroid_bottom = mean(V_Nucleus1(indList1_bottom, :), 1);
    theta_top = atan2(V_Nucleus1(indList1_top, 2) - centroid_top(2), V_Nucleus1(indList1_top, 1) - centroid_top(1));
    theta_bottom = atan2(V_Nucleus1(indList1_bottom, 2) - centroid_bottom(2), V_Nucleus1(indList1_bottom, 1) - centroid_bottom(1));

    [~, sortIdx_top] = sort(theta_top);
    [~, sortIdx_bottom] = sort(theta_bottom);

    indList1_top = indList1_top(sortIdx_top);
    indList1_bottom = indList1_bottom(sortIdx_bottom);

    % Guide curve for lofting
    Vg = [mean(V_Nucleus1(indList1_top, :)); mean(V_Nucleus1(indList1_bottom, :))];
    [Fq, Vq, Cq] = sweepLoft(V_Nucleus1(indList1_bottom, :), V_Nucleus1(indList1_top, :), -mean(patchNormal(F_bottom, V_Nucleus1), 1), mean(patchNormal(F_top, V_Nucleus1), 1), Vg, nResample, 0);

    % Convert quadrilateral mesh to triangular mesh
    % [Ft, Vt, Ct] = quad2tri(Fq, Vq, 'a', Cq);
    % 
    % % Combine the vertex data
    % V_Nucleus1_complete = [V_Nucleus1; Vt];
    % 
    % % Adjust the face indices of Ft
    % Ft_adjusted = Ft + size(V_Nucleus1, 1);
    % 
    % % Combine the face data
    % F_Nucleus1_complete = [F_Nucleus1; Ft_adjusted];
    % 
    % % Define a scaling factor (adjust as necessary)
    % scaling_factor = 1;
    % 
    % % Compute the centroid of the original Vt
    % centroid_Vt = mean(Vt, 1);
    % 
    % % Scale Vt around the origin
    % Vt_scaled = (Vt - centroid_Vt) * scaling_factor;
    % 
    % % Translate Vt_scaled back to the original centroid
    % Vt_scaled = Vt_scaled + centroid_Vt;
    % 
    % % Append the scaled Vt to V_Annulus1
    % V_Annulus1_complete = [V_Annulus1; Vt_scaled];
    % 
    % % Now for the annulus
    % %V_Annulus1_complete = [V_Annulus1; Vt*1.2];
    % Ft_adjusted_an = Ft + size(V_Annulus1, 1);
    % F_Annulus1_complete = [F_Annulus1; Ft_adjusted_an];
    % Convert quadrilateral mesh to triangular mesh
    [Ft, Vt, Ct] = quad2tri(Fq, Vq, 'a', Cq);

    % Combine the vertex data
    V_Nucleus1_complete = [V_Nucleus1; Vt];

    % Adjust the face indices of Ft
    Ft_adjusted = Ft + size(V_Nucleus1, 1);

    % Combine the face data
    F_Nucleus1_complete = [F_Nucleus1; Ft_adjusted];

    % Now for the annulus
    V_Annulus1_complete = [V_Annulus1; Vt];
    Ft_adjusted_an = Ft + size(V_Annulus1, 1);
    F_Annulus1_complete = [F_Annulus1; Ft_adjusted_an];
end
