function [F_Nucleus, V_Nucleus, F_Annulus, V_Annulus] = processNucleusAnnulus(Fds, Vds, scaleFactor, height)

    % Step 1: Initialize Nucleus using the initil_Nucleus function
    [Fds_n, Vds_n] = initil_Nucleus(Fds, Vds, height);

    % Step 2: Apply scaling to the vertices
    Vds_n = Vds_n * scaleFactor;

    % Step 3: Remesh using the provided remesh function
    pointSpacing = 0.5;
    optionStructRemesh.pointSpacing = pointSpacing;
    optionStructRemesh.disp_on = 0;  % Display options
    [Fds_n, Vds_n] = ggremesh(Fds_n, Vds_n, optionStructRemesh);

    % Step 4: Inside meshing
    [Fds_n, Cbs1_n, Vds_n, Eds1_n] = meshInsideGeometry(Fds_n, Vds_n, pointSpacing);

    % Step 5: Compute centroids and translation to align geometries
    centroid_disc = mean(Vds, 1); % Centroid of original disc
    centroid_secondary = mean(Vds_n, 1); % Centroid of the nucleus geometry
    translation_vector = centroid_disc - centroid_secondary;
    Vds1_nu = Vds_n + translation_vector;

    % Step 6: Check which vertices of the disc are inside the secondary geometry using inpolyhedron
    in = inpolyhedron(Fds_n, Vds1_nu, Vds);

    % Step 7: Remove faces where all vertices are inside the secondary geometry for the Annulus
    faceMask_Annulus = all(in(Fds), 2);  % Find faces where all vertices are inside
    F_Annulus = Fds(~faceMask_Annulus, :);  % Keep faces that are not fully inside the secondary geometry
    V_Annulus = Vds;  % Vertices remain unchanged unless you want to reindex unused vertices

    % Step 8: Keep faces where at least one vertex is inside for the Nucleus
    faceMask_Nucleus = any(in(Fds), 2);  % Find faces where at least one vertex is inside
    F_Nucleus = Fds(faceMask_Nucleus, :);  % Keep faces that are partially or fully inside the secondary geometry
    V_Nucleus = Vds;  % Vertices remain unchanged unless you want to reindex unused vertices

end
