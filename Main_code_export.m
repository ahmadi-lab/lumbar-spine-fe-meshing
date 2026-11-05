clear
[F1,V1]=graphicsModels('L1');
[F2,V2]=graphicsModels('L2');
[F3,V3]=graphicsModels('L3');
[F4,V4]=graphicsModels('L4');
[F5,V5]=graphicsModels('L5');
%0.1, 0.5, 10 fine values
%0.3,0.9,20
% Define core thickness, smoothing factor, and iterations
core_thickness = 0.3; % mm
lambda = 0.9;       % Smoothing factor
iterations = 20;    % Number of smoothing iterations

% Extract shell and core for each geometry
tic
[F_cortical1, V_cortical1, F_cancellous1, V_cancellous1] = extractShellAndCore(F1, V1, core_thickness, lambda, iterations);
[F_cortical2, V_cortical2, F_cancellous2, V_cancellous2] = extractShellAndCore(F2, V2, core_thickness, lambda, iterations);
[F_cortical3, V_cortical3, F_cancellous3, V_cancellous3] = extractShellAndCore(F3, V3, core_thickness, lambda, iterations);
[F_cortical4, V_cortical4, F_cancellous4, V_cancellous4] = extractShellAndCore(F4, V4, core_thickness, lambda, iterations);
[F_cortical5, V_cortical5, F_cancellous5, V_cancellous5] = extractShellAndCore(F5, V5, core_thickness, lambda, iterations);
toc
figure;
% Plot geometry 1
trisurf(F_cortical1, V_cortical1(:,1), V_cortical1(:,2), V_cortical1(:,3), 'FaceColor', '#F0E68C', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
hold on;
trisurf(F_cancellous1, V_cancellous1(:,1), V_cancellous1(:,2), V_cancellous1(:,3), 'FaceColor', '#D2B48C', 'EdgeColor', 'none', 'FaceAlpha', 1);
hold on;
% Plot geometry 2
trisurf(F_cortical2, V_cortical2(:,1), V_cortical2(:,2), V_cortical2(:,3), 'FaceColor', '#F0E68C', 'EdgeColor', 'none', 'FaceAlpha',0.3);
hold on;
trisurf(F_cancellous2, V_cancellous2(:,1), V_cancellous2(:,2), V_cancellous2(:,3), 'FaceColor', '#D2B48C', 'EdgeColor', 'none', 'FaceAlpha', 1);
hold on;
% Plot geometry 3
trisurf(F_cortical3, V_cortical3(:,1), V_cortical3(:,2), V_cortical3(:,3), 'FaceColor', '#F0E68C', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
hold on;
trisurf(F_cancellous3, V_cancellous3(:,1), V_cancellous3(:,2), V_cancellous3(:,3), 'FaceColor', '#D2B48C', 'EdgeColor', 'none', 'FaceAlpha', 1);
hold on;
% Plot geometry 4
trisurf(F_cortical4, V_cortical4(:,1), V_cortical4(:,2), V_cortical4(:,3), 'FaceColor', '#F0E68C', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
hold on;
trisurf(F_cancellous4, V_cancellous4(:,1), V_cancellous4(:,2), V_cancellous4(:,3), 'FaceColor', '#D2B48C', 'EdgeColor', 'none', 'FaceAlpha', 1);
hold on;
% Plot geometry 5
trisurf(F_cortical5, V_cortical5(:,1), V_cortical5(:,2), V_cortical5(:,3), 'FaceColor', '#F0E68C', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
hold on;
trisurf(F_cancellous5, V_cancellous5(:,1), V_cancellous5(:,2), V_cancellous5(:,3), 'FaceColor', '#D2B48C', 'EdgeColor', 'none', 'FaceAlpha', 1);

% Set lighting and camera properties
camlight('headlight');
lighting gouraud;
axis equal;
xlabel('X(mm)');
ylabel('Y(mm)');
zlabel('Z(mm)');
title('cortical and cancellous surface for L1 - L5');
view(3);

% Update the figure
drawnow;

hold off;
pointSpacing_cancellous=3; %Approximate/desired node spacing
pointSpacing_cortical=2;
optionStructRemesh1.pointSpacing=pointSpacing_cancellous; %Set desired point spacing
optionStructRemesh1.disp_on=0; % Turn off command window text display
optionStructRemesh2.pointSpacing=pointSpacing_cortical; %Set desired point spacing
optionStructRemesh2.disp_on=0; % Turn off command window text display
tic
[F_cancellous1,V_cancellous1]=ggremesh(F_cancellous1,V_cancellous1,optionStructRemesh1);
[F_cancellous2,V_cancellous2]=ggremesh(F_cancellous2,V_cancellous2,optionStructRemesh1);
[F_cancellous3,V_cancellous3]=ggremesh(F_cancellous3,V_cancellous3,optionStructRemesh1);
[F_cancellous4,V_cancellous4]=ggremesh(F_cancellous4,V_cancellous4,optionStructRemesh1);
[F_cancellous5,V_cancellous5]=ggremesh(F_cancellous5,V_cancellous5,optionStructRemesh1);

[F_cortical1,V_cortical1]=ggremesh(F_cortical1,V_cortical1,optionStructRemesh2);
[F_cortical2,V_cortical2]=ggremesh(F_cortical2,V_cortical2,optionStructRemesh2);
[F_cortical3,V_cortical3]=ggremesh(F_cortical3,V_cortical3,optionStructRemesh2);
[F_cortical4,V_cortical4]=ggremesh(F_cortical4,V_cortical4,optionStructRemesh2);
[F_cortical5,V_cortical5]=ggremesh(F_cortical5,V_cortical5,optionStructRemesh2);
toc
% % % Export geometries to Gmsh .geo file
% % exportToGmsh(F_cortical1, V_cortical1,F_cancellous1, V_cancellous1, 'complex_geometry2.geo');
% % exportTo3PLY(F_cortical1, V_cortical1,F_cancellous1, V_cancellous1, 'complex_geometry.ply');
exportToSTL(F_cortical1, V_cortical1,F_cancellous1, V_cancellous1, 'Clean_STL/cortical1.stl', 'Clean_STL/cancellous1.stl')
exportToSTL(F_cortical2, V_cortical2,F_cancellous2, V_cancellous2, 'Clean_STL/cortical2.stl', 'Clean_STL/cancellous2.stl')
exportToSTL(F_cortical3, V_cortical3,F_cancellous3, V_cancellous3, 'Clean_STL/cortical3.stl', 'Clean_STL/cancellous3.stl')
exportToSTL(F_cortical4, V_cortical4,F_cancellous4, V_cancellous4, 'Clean_STL/cortical4.stl', 'Clean_STL/cancellous4.stl')
exportToSTL(F_cortical5, V_cortical5,F_cancellous5, V_cancellous5, 'Clean_STL/cortical5.stl', 'Clean_STL/cancellous5.stl')

figure;
% Plot geometry 1
trisurf(F_cortical1, V_cortical1(:,1), V_cortical1(:,2), V_cortical1(:,3), 'FaceColor', '#F0E68C', 'EdgeColor', 'k', 'FaceAlpha', 0.3);
hold on;
trisurf(F_cancellous1, V_cancellous1(:,1), V_cancellous1(:,2), V_cancellous1(:,3), 'FaceColor', '#D2B48C', 'EdgeColor', 'r', 'FaceAlpha', 1);
hold on;
% Plot geometry 2
trisurf(F_cortical2, V_cortical2(:,1), V_cortical2(:,2), V_cortical2(:,3), 'FaceColor', '#F0E68C', 'EdgeColor', 'k', 'FaceAlpha', 0.3);
hold on;
trisurf(F_cancellous2, V_cancellous2(:,1), V_cancellous2(:,2), V_cancellous2(:,3), 'FaceColor', '#D2B48C', 'EdgeColor', 'r', 'FaceAlpha', 1);
hold on;
% Plot geometry 3
trisurf(F_cortical3, V_cortical3(:,1), V_cortical3(:,2), V_cortical3(:,3), 'FaceColor', '#F0E68C', 'EdgeColor', 'k', 'FaceAlpha', 0.3);
hold on;
trisurf(F_cancellous3, V_cancellous3(:,1), V_cancellous3(:,2), V_cancellous3(:,3), 'FaceColor', '#D2B48C', 'EdgeColor', 'r', 'FaceAlpha', 1);
hold on;
% Plot geometry 4
trisurf(F_cortical4, V_cortical4(:,1), V_cortical4(:,2), V_cortical4(:,3), 'FaceColor', '#F0E68C', 'EdgeColor', 'k', 'FaceAlpha', 0.3);
hold on;
trisurf(F_cancellous4, V_cancellous4(:,1), V_cancellous4(:,2), V_cancellous4(:,3), 'FaceColor', '#D2B48C', 'EdgeColor', 'r', 'FaceAlpha', 1);
hold on;
% Plot geometry 5
trisurf(F_cortical5, V_cortical5(:,1), V_cortical5(:,2), V_cortical5(:,3), 'FaceColor', '#F0E68C', 'EdgeColor', 'k', 'FaceAlpha', 0.3);
hold on;
trisurf(F_cancellous5, V_cancellous5(:,1), V_cancellous5(:,2), V_cancellous5(:,3), 'FaceColor', '#D2B48C', 'EdgeColor', 'r', 'FaceAlpha', 1);

% Set lighting and camera properties
camlight('headlight');
lighting gouraud;
axis equal;
xlabel('X(mm)');
ylabel('Y(mm)');
zlabel('Z(mm)');
title('Shell and Core Geometries using trisurf');
view(3);

% Update the figure
drawnow;

hold off;
tic
[F_cortical_clean1, V_cortical_clean1, E_cortical_clean1, F_cancellous1, V_cancellous1, E_cancellous1] ...
= meshingCorticalAndCancellous('Clean_STL/cancellous1.stl', 'Clean_STL/cortical1.stl', 0.5,1.5,0.8);

[F_cortical_clean2, V_cortical_clean2, E_cortical_clean2, F_cancellous2, V_cancellous2, E_cancellous2] ...
= meshingCorticalAndCancellous('Clean_STL/cancellous2.stl', 'Clean_STL/cortical2.stl', 0.5,1.5,0.8);

[F_cortical_clean3, V_cortical_clean3, E_cortical_clean3, F_cancellous3, V_cancellous3, E_cancellous3] ...
= meshingCorticalAndCancellous('Clean_STL/cancellous3.stl', 'Clean_STL/cortical3.stl', 0.5,1.5,0.8);

[F_cortical_clean4, V_cortical_clean4, E_cortical_clean4, F_cancellous4, V_cancellous4, E_cancellous4] ...
= meshingCorticalAndCancellous('Clean_STL/cancellous4.stl', 'Clean_STL/cortical4.stl', 0.5,1.5,0.8);

[F_cortical_clean5, V_cortical_clean5, E_cortical_clean5, F_cancellous5, V_cancellous5, E_cancellous5] ...
= meshingCorticalAndCancellous('Clean_STL/cancellous5.stl', 'Clean_STL/cortical5.stl', 0.5,1.5,0.8);
toc

% Step 3: Save the cleaned cortical mesh and elements
% Save L1
save('Clean_mesh/cortical_clean1.mat', 'F_cortical_clean1', 'V_cortical_clean1', 'E_cortical_clean1');
save('Clean_mesh/cancellous_clean1.mat', 'F_cancellous1', 'V_cancellous1', 'E_cancellous1');

% Save L2
save('Clean_mesh/cortical_clean2.mat', 'F_cortical_clean2', 'V_cortical_clean2', 'E_cortical_clean2');
save('Clean_mesh/cancellous_clean2.mat', 'F_cancellous2', 'V_cancellous2', 'E_cancellous2');

% Save L3
save('Clean_mesh/cortical_clean3.mat', 'F_cortical_clean3', 'V_cortical_clean3', 'E_cortical_clean3');
save('Clean_mesh/cancellous_clean3.mat', 'F_cancellous3', 'V_cancellous3', 'E_cancellous3');

% Save L4
save('Clean_mesh/cortical_clean4.mat', 'F_cortical_clean4', 'V_cortical_clean4', 'E_cortical_clean4');
save('Clean_mesh/cancellous_clean4.mat', 'F_cancellous4', 'V_cancellous4', 'E_cancellous4');

% Save L5
save('Clean_mesh/cortical_clean5.mat', 'F_cortical_clean5', 'V_cortical_clean5', 'E_cortical_clean5');
save('Clean_mesh/cancellous_clean5.mat', 'F_cancellous5', 'V_cancellous5', 'E_cancellous5');


% saveGmshMesh('output.msh', V_cortical_clean, F_cortical_clean, E_cortical_clean);

% Write VTK for L1
writeVTK(F_cortical_clean1, V_cortical_clean1, E_cortical_clean1, 'Clean_VTK/cortical_final1');
writeVTK(F_cancellous1, V_cancellous1, E_cancellous1, 'Clean_VTK/cancellous_final1');

% Write VTK for L2
writeVTK(F_cortical_clean2, V_cortical_clean2, E_cortical_clean2, 'Clean_VTK/cortical_final2');
writeVTK(F_cancellous2, V_cancellous2, E_cancellous2, 'Clean_VTK/cancellous_final2');

% Write VTK for L3
writeVTK(F_cortical_clean3, V_cortical_clean3, E_cortical_clean3, 'Clean_VTK/cortical_final3');
writeVTK(F_cancellous3, V_cancellous3, E_cancellous3, 'Clean_VTK/cancellous_final3');

% Write VTK for L4
writeVTK(F_cortical_clean4, V_cortical_clean4, E_cortical_clean4, 'Clean_VTK/cortical_final4');
writeVTK(F_cancellous4, V_cancellous4, E_cancellous4, 'Clean_VTK/cancellous_final4');

% Write VTK for L5
writeVTK(F_cortical_clean5, V_cortical_clean5, E_cortical_clean5, 'Clean_VTK/cortical_final5');
writeVTK(F_cancellous5, V_cancellous5, E_cancellous5, 'Clean_VTK/cancellous_final5');
vtkFiles = {
    'Clean_VTK/cortical_final1', 'Clean_VTK/cancellous_final1', ...
    'Clean_VTK/cortical_final2', 'Clean_VTK/cancellous_final2', ...
    'Clean_VTK/cortical_final3', 'Clean_VTK/cancellous_final3',...
    'Clean_VTK/cortical_final4', 'Clean_VTK/cancellous_final4', ...
    'Clean_VTK/cortical_final5', 'Clean_VTK/cancellous_final5'

};
% 
% % Visualize the VTK files in ParaView
%visualizeMultipleVTK(vtkFiles);
clear
% Plot settings
fontSize=15;
faceAlpha1=1;
faceAlpha2=0.3;
markerSize1=25;
markerSize2=10;
lineWidth=2;
boneColor=[1.0000    0.9500    0.8000];
discColor=[0.8500    0.5000    0.3000];
load Clean_mesh/cortical_clean1
load Clean_mesh/cortical_clean2
load Clean_mesh/cortical_clean3
load Clean_mesh/cortical_clean4
load Clean_mesh/cortical_clean5

[Fds1,Vds1]=graphicsModels('D12');
[Fds2,Vds2]=graphicsModels('D23');
[Fds3,Vds3]=graphicsModels('D34');
[Fds4,Vds4]=graphicsModels('D45');

tic
gapthreshold=2;
% For vertebra 1 and vertebra 2 with disc 1
Vds1 = fillDiscGap(V_cortical_clean1, Vds1, 2);
Vds1 = fillDiscGap(V_cortical_clean2, Vds1, 3);

% For vertebra 2 and vertebra 3 with disc 2
Vds2 = fillDiscGap(V_cortical_clean2, Vds2, 1);
Vds2 = fillDiscGap(V_cortical_clean3, Vds2, 1);

% For vertebra 3 and vertebra 4 with disc 3
Vds3 = fillDiscGap(V_cortical_clean3, Vds3, 2);
Vds3 = fillDiscGap(V_cortical_clean4, Vds3, 2);

% For vertebra 4 and vertebra 5 with disc 4
Vds4 = fillDiscGap(V_cortical_clean4, Vds4, 3.5);
Vds4 = fillDiscGap(V_cortical_clean5, Vds4, 3.5);

% Set smoothing parameters
clear cPar;
cPar.n = 10;  % Number of smoothing iterations
cPar.Method = 'HC';  % Smoothing method

angleThreshold = 90;

% Modify and smooth disc 1
[Fds1, Vds1] = modifyAcuteAngles(Fds1, Vds1, angleThreshold);
cPar.RigidConstraints = unique(patchBoundary(Fds1)); 
Vds1 = patchSmooth(Fds1, Vds1, [], cPar);

% Modify and smooth disc 2
[Fds2, Vds2] = modifyAcuteAngles(Fds2, Vds2, angleThreshold);
cPar.RigidConstraints = unique(patchBoundary(Fds2)); 
Vds2 = patchSmooth(Fds2, Vds2, [], cPar);

% Modify and smooth disc 3
[Fds3, Vds3] = modifyAcuteAngles(Fds3, Vds3, angleThreshold);
cPar.RigidConstraints = unique(patchBoundary(Fds3)); 
Vds3 = patchSmooth(Fds3, Vds3, [], cPar);

% Modify and smooth disc 4
[Fds4, Vds4] = modifyAcuteAngles(Fds4, Vds4, angleThreshold);
cPar.RigidConstraints = unique(patchBoundary(Fds4)); 
Vds4 = patchSmooth(Fds4, Vds4, [], cPar);

% Update the faces of the disc if necessary (no change in structure)
pointSpacing=0.5;
optionStructRemesh.pointSpacing = pointSpacing;
optionStructRemesh.disp_on = 0;  % Display options
disp('Remeshing cancellous mesh...');

% Remeshing and meshing inside geometry for disc 1
[Fds1, Vds1] = ggremesh(Fds1, Vds1, optionStructRemesh);
[Fds1, Cbsd1, Vds1, Eds1] = meshInsideGeometry(Fds1, Vds1, pointSpacing);

% Remeshing and meshing inside geometry for disc 2
[Fds2, Vds2] = ggremesh(Fds2, Vds2, optionStructRemesh);
[Fds2, Cbsd2, Vds2, Eds2] = meshInsideGeometry(Fds2, Vds2, pointSpacing);

% Remeshing and meshing inside geometry for disc 3
[Fds3, Vds3] = ggremesh(Fds3, Vds3, optionStructRemesh);
[Fds3, Cbsd3, Vds3, Eds3] = meshInsideGeometry(Fds3, Vds3, pointSpacing);

% Remeshing and meshing inside geometry for disc 4
[Fds4, Vds4] = ggremesh(Fds4, Vds4, optionStructRemesh);
[Fds4, Cbsd4, Vds4, Eds4] = meshInsideGeometry(Fds4, Vds4, pointSpacing);
toc
save('Clean_mesh/Disc_clean1.mat', 'Fds1', 'Vds1', 'Eds1');
save('Clean_mesh/Disc_clean2.mat', 'Fds2', 'Vds2', 'Eds2');
save('Clean_mesh/Disc_clean3.mat', 'Fds3', 'Vds3', 'Eds3');
save('Clean_mesh/Disc_clean4.mat', 'Fds4', 'Vds4', 'Eds4');


% Display the updated disc and vertebra
figure;

% Plot vertebra 1 and disc 1
trisurf(F_cortical_clean1, V_cortical_clean1(:,1), V_cortical_clean1(:,2), V_cortical_clean1(:,3), 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.9);
hold on;
trisurf(Fds1, Vds1(:,1), Vds1(:,2), Vds1(:,3), 'FaceColor', 'red', 'EdgeColor', 'k', 'FaceAlpha', 0.9);

% Plot vertebra 2 and disc 2
trisurf(F_cortical_clean2, V_cortical_clean2(:,1), V_cortical_clean2(:,2), V_cortical_clean2(:,3), 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.9);
trisurf(Fds2, Vds2(:,1), Vds2(:,2), Vds2(:,3), 'FaceColor', 'red', 'EdgeColor', 'k', 'FaceAlpha', 0.9);

% Plot vertebra 3 and disc 3
trisurf(F_cortical_clean3, V_cortical_clean3(:,1), V_cortical_clean3(:,2), V_cortical_clean3(:,3), 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.9);
trisurf(Fds3, Vds3(:,1), Vds3(:,2), Vds3(:,3), 'FaceColor', 'red', 'EdgeColor', 'k', 'FaceAlpha', 0.9);

% Plot vertebra 4 and disc 4
trisurf(F_cortical_clean4, V_cortical_clean4(:,1), V_cortical_clean4(:,2), V_cortical_clean4(:,3), 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.9);
trisurf(Fds4, Vds4(:,1), Vds4(:,2), Vds4(:,3), 'FaceColor', 'red', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
hold on;

% Plot vertebra 5 (without disc)
trisurf(F_cortical_clean5, V_cortical_clean5(:,1), V_cortical_clean5(:,2), V_cortical_clean5(:,3), 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha', 0.9);

% Set visualization properties
camlight;
lighting gouraud;
axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
view(3);  % Set to 3D view

xlim("auto")
ylim("auto")
zlim("auto")

% [Fds1,Vds1]=graphicsModels('D12');
% [Fds2,Vds2]=graphicsModels('D23');
% [Fds3,Vds3]=graphicsModels('D34');
% [Fds4,Vds4]=graphicsModels('D45');
clear

load Clean_mesh/Disc_clean1
load Clean_mesh/Disc_clean2
load Clean_mesh/Disc_clean3
load Clean_mesh/Disc_clean4

% Input parameters for scale factor and height
scaleFactor = 0.6;% Area of Nuclues is 60% of the disc
height = 60;% a control paramter
tic
% Call the function to process the nucleus and annulus geometries for all datasets
[F_Nucleus1, V_Nucleus1, F_Annulus1, V_Annulus1] = processNucleusAnnulus(Fds1, Vds1, scaleFactor, height);
[F_Nucleus2, V_Nucleus2, F_Annulus2, V_Annulus2] = processNucleusAnnulus(Fds2, Vds2, scaleFactor, height);
[F_Nucleus3, V_Nucleus3, F_Annulus3, V_Annulus3] = processNucleusAnnulus(Fds3, Vds3, scaleFactor, height);
[F_Nucleus4, V_Nucleus4, F_Annulus4, V_Annulus4] = processNucleusAnnulus(Fds4, Vds4, scaleFactor, height);
toc
% Step 4: Visualize the result for all datasets in one plot
figure;
% Plot for Disc L1/L2
trisurf(F_Nucleus1, V_Nucleus1(:,1), V_Nucleus1(:,2), V_Nucleus1(:,3), 'FaceColor', 'blue', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
hold on;
trisurf(F_Annulus1, V_Annulus1(:,1), V_Annulus1(:,2), V_Annulus1(:,3), 'FaceColor', 'red', 'EdgeColor', 'k', 'FaceAlpha', 0.9);

% Plot for Disc L3/L3
trisurf(F_Nucleus2, V_Nucleus2(:,1), V_Nucleus2(:,2), V_Nucleus2(:,3), 'FaceColor', 'green', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
trisurf(F_Annulus2, V_Annulus2(:,1), V_Annulus2(:,2), V_Annulus2(:,3), 'FaceColor', 'yellow', 'EdgeColor', 'k', 'FaceAlpha', 0.9);

% Plot for Disc L3/L4
trisurf(F_Nucleus3, V_Nucleus3(:,1), V_Nucleus3(:,2), V_Nucleus3(:,3), 'FaceColor', 'cyan', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
trisurf(F_Annulus3, V_Annulus3(:,1), V_Annulus3(:,2), V_Annulus3(:,3), 'FaceColor', 'magenta', 'EdgeColor', 'k', 'FaceAlpha', 0.9);

% Plot for Disc L4/L5
trisurf(F_Nucleus4, V_Nucleus4(:,1), V_Nucleus4(:,2), V_Nucleus4(:,3), 'FaceColor', 'red', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
trisurf(F_Annulus4, V_Annulus4(:,1), V_Annulus4(:,2), V_Annulus4(:,3), 'FaceColor', 'yellow', 'EdgeColor', 'k', 'FaceAlpha', 0.9);

% Add lighting and axis settings
camlight;
lighting gouraud;
axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Visualization of Nucleus and Annulus for 4 Discs');
tic
Make_Nucleus_Annulus_walls_for_Disc1;
Make_Nucleus_Annulus_walls_for_Disc2;
Make_Nucleus_Annulus_walls_for_Disc3;
Make_Nucleus_Annulus_walls_for_Disc4;


 % Example parameters
pointSpacing = 2;
maxPerimeter = 200.0;         % Adjusted threshold for small holes
areaThreshold = 1e-2;         % Threshold for degenerate triangle area
angleThreshold = 30;          % Minimum angle threshold (in degrees)
maxEdgeLengthRatio = 20;      % Maximum allowed edge length ratio (longest/shortest edge)

% Call the function with your mesh data and parameters
[F_Nucleus1_filled, V_Nucleus1_filled, E_Nucleus1_filled] = processNucleusMesh(F_Nucleus1_complete, V_Nucleus1_complete, ...
                                                                              pointSpacing, maxPerimeter, ...
                                                                              areaThreshold, angleThreshold, ...
                                                                              maxEdgeLengthRatio);
[F_Nucleus2_filled, V_Nucleus2_filled, E_Nucleus2_filled] = processNucleusMesh(F_Nucleus2_complete, V_Nucleus2_complete, ...
                                                                              pointSpacing, maxPerimeter, ...
                                                                              areaThreshold, angleThreshold, ...
                                                                              maxEdgeLengthRatio);
[F_Nucleus3_filled, V_Nucleus3_filled, E_Nucleus3_filled] = processNucleusMesh(F_Nucleus3_complete, V_Nucleus3_complete, ...
                                                                              pointSpacing, maxPerimeter, ...
                                                                              areaThreshold, angleThreshold, ...
                                                                              maxEdgeLengthRatio);
[F_Nucleus4_filled, V_Nucleus4_filled, E_Nucleus4_filled] = processNucleusMesh(F_Nucleus4_complete, V_Nucleus4_complete, ...
                                                                              pointSpacing, maxPerimeter, ...
                                                                              areaThreshold, angleThreshold, ...
                                                                              maxEdgeLengthRatio);
toc
save('Clean_mesh/Nucleus1_clean.mat', 'F_Nucleus1_filled', 'V_Nucleus1_filled', 'E_Nucleus1_filled');
save('Clean_mesh/Nucleus2_clean.mat', 'F_Nucleus2_filled', 'V_Nucleus2_filled', 'E_Nucleus2_filled');
save('Clean_mesh/Nucleus3_clean.mat', 'F_Nucleus3_filled', 'V_Nucleus3_filled', 'E_Nucleus3_filled');
save('Clean_mesh/Nucleus4_clean.mat', 'F_Nucleus4_filled', 'V_Nucleus4_filled', 'E_Nucleus4_filled');

% Optionally write the result to a VTK file
writeVTK(F_Nucleus1_filled, V_Nucleus1_filled, E_Nucleus1_filled, 'Clean_VTK/Nucleus1_filled');
writeVTK(F_Nucleus2_filled, V_Nucleus2_filled, E_Nucleus2_filled, 'Clean_VTK/Nucleus2_filled');
writeVTK(F_Nucleus3_filled, V_Nucleus3_filled, E_Nucleus3_filled, 'Clean_VTK/Nucleus3_filled');
writeVTK(F_Nucleus4_filled, V_Nucleus4_filled, E_Nucleus4_filled, 'Clean_VTK/Nucleus4_filled');

% Step 14: Visualize the combined surface
figure;

% Subplot 1
subplot(2,2,1);
hold on;
trisurf(F_Nucleus1_filled, V_Nucleus1_filled(:,1), V_Nucleus1_filled(:,2), V_Nucleus1_filled(:,3), 'FaceColor', 'green', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
colormap gjet;
camlight;
lighting gouraud;
axis equal;
view(3); % 3D view
title('Nucleus L1/L2');

% Subplot 2
subplot(2,2,2);
hold on;
trisurf(F_Nucleus2_filled, V_Nucleus2_filled(:,1), V_Nucleus2_filled(:,2), V_Nucleus2_filled(:,3), 'FaceColor', 'green', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
colormap gjet;
camlight;
lighting gouraud;
axis equal;
view(3); % 3D view
title('Nucleus L2/L3');

% Subplot 3
subplot(2,2,3);
hold on;
trisurf(F_Nucleus3_filled, V_Nucleus3_filled(:,1), V_Nucleus3_filled(:,2), V_Nucleus3_filled(:,3), 'FaceColor', 'green', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
colormap gjet;
camlight;
lighting gouraud;
axis equal;
view(3); % 3D view
title('Nucleus L3/L4');

% Subplot 4
subplot(2,2,4);
hold on;
trisurf(F_Nucleus4_filled, V_Nucleus4_filled(:,1), V_Nucleus4_filled(:,2), V_Nucleus4_filled(:,3), 'FaceColor', 'green', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
colormap gjet;
camlight;
lighting gouraud;
axis equal;
title('Nucleus L4/L5');
view(3);
% [F_clean1, V_clean1, E_clean1] = makeAnnulus(Fds1, Vds1, Eds1, F_Nucleus1_filled, V_Nucleus1_filled);
% [F_clean2, V_clean2, E_clean2] = makeAnnulus(Fds2, Vds2, Eds2, F_Nucleus2_filled, V_Nucleus2_filled);
% [F_clean3, V_clean3, E_clean3] = makeAnnulus(Fds3, Vds3, Eds3, F_Nucleus3_filled, V_Nucleus3_filled);
% [F_clean4, V_clean4, E_clean4] = makeAnnulus(Fds4, Vds4, Eds4, F_Nucleus4_filled, V_Nucleus4_filled);
tic
[F_Annulus1_filled, V_Annulus1_filled, E_Annulus1_filled] = ...
processAnnulusMesh(V_Nucleus1, F_Nucleus1, V_Annulus1, F_Annulus1);
[F_Annulus2_filled, V_Annulus2_filled, E_Annulus2_filled] = ...
processAnnulusMesh(V_Nucleus2, F_Nucleus2, V_Annulus2, F_Annulus2);
[F_Annulus3_filled, V_Annulus3_filled, E_Annulus3_filled] = ...
processAnnulusMesh(V_Nucleus3, F_Nucleus3, V_Annulus3, F_Annulus3);
[F_Annulus4_filled, V_Annulus4_filled, E_Annulus4_filled] = ...
processAnnulusMesh(V_Nucleus4, F_Nucleus4, V_Annulus4, F_Annulus4);
toc
save('Clean_mesh/F_Annulus1_clean.mat', 'F_Annulus1_filled', 'V_Annulus1_filled', 'E_Annulus1_filled');
save('Clean_mesh/F_Annulus2_clean.mat', 'F_Annulus2_filled', 'V_Annulus2_filled', 'E_Annulus2_filled');
save('Clean_mesh/F_Annulus3_clean.mat', 'F_Annulus3_filled', 'V_Annulus3_filled', 'E_Annulus3_filled');
save('Clean_mesh/F_Annulus4_clean.mat', 'F_Annulus4_filled', 'V_Annulus4_filled', 'E_Annulus4_filled');


writeVTK(F_Annulus1_filled, V_Annulus1_filled, E_Annulus1_filled, 'Clean_VTK/Annulus1_filled');
writeVTK(F_Annulus2_filled, V_Annulus2_filled, E_Annulus2_filled, 'Clean_VTK/Annulus2_filled');
writeVTK(F_Annulus3_filled, V_Annulus3_filled, E_Annulus3_filled, 'Clean_VTK/Annulus3_filled');
writeVTK(F_Annulus4_filled, V_Annulus4_filled, E_Annulus4_filled, 'Clean_VTK/Annulus4_filled');

vtkFiles = {
    'Clean_VTK/Annulus1_filled','Clean_VTK/Annulus2_filled','Clean_VTK/Annulus3_filled','Clean_VTK/Annulus4_filled'};
% 
% % Visualize the VTK files in ParaView
visualizeMultipleVTK(vtkFiles);

figure;
% First subplot: clean1 and nucleus1
subplot(2, 2, 1);
hold on;
trisurf(F_Annulus1_filled, V_Annulus1_filled(:,1), V_Annulus1_filled(:,2), V_Annulus1_filled(:,3), 'FaceColor', 'red', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
trisurf(F_Nucleus1_filled, V_Nucleus1_filled(:,1), V_Nucleus1_filled(:,2), V_Nucleus1_filled(:,3), 'FaceColor', 'green', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
colormap gjet;
camlight;
lighting gouraud;
axis equal;
view(3);
title('Disc L1/L2');
% Second subplot: clean2 and nucleus2
subplot(2, 2, 2);
hold on;
trisurf(F_Annulus2_filled, V_Annulus2_filled(:,1), V_Annulus2_filled(:,2), V_Annulus2_filled(:,3), 'FaceColor', 'red', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
trisurf(F_Nucleus2_filled, V_Nucleus2_filled(:,1), V_Nucleus2_filled(:,2), V_Nucleus2_filled(:,3), 'FaceColor', 'green', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
colormap gjet;
camlight;
lighting gouraud;
axis equal;
view(3);
title('Disc L2/L3');

% Third subplot: clean1 only
subplot(2, 2, 3);
hold on;
trisurf(F_Annulus3_filled, V_Annulus3_filled(:,1), V_Annulus3_filled(:,2), V_Annulus3_filled(:,3), 'FaceColor', 'red', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
trisurf(F_Nucleus3_filled, V_Nucleus3_filled(:,1), V_Nucleus3_filled(:,2), V_Nucleus3_filled(:,3), 'FaceColor', 'green', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
colormap gjet;
camlight;
lighting gouraud;
axis equal;
view(3);
title('Disc L3/L4');

% Fourth subplot: nucleus2 only
subplot(2, 2, 4);
hold on;
trisurf(F_Annulus4_filled, V_Annulus4_filled(:,1), V_Annulus4_filled(:,2), V_Annulus4_filled(:,3), 'FaceColor', 'red', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
trisurf(F_Nucleus4_filled, V_Nucleus4_filled(:,1), V_Nucleus4_filled(:,2), V_Nucleus4_filled(:,3), 'FaceColor', 'green', 'EdgeColor', 'k', 'FaceAlpha', 0.9);
colormap gjet;
camlight;
lighting gouraud;
axis equal;
view(3);
title('Disc L4/L5');

vtkFiles = {
    'Clean_VTK/cortical_final1', 'Clean_VTK/cancellous_final1', ...
    'Clean_VTK/cortical_final2', 'Clean_VTK/cancellous_final2', ...
    'Clean_VTK/cortical_final3', 'Clean_VTK/cancellous_final3', ...
    'Clean_VTK/cortical_final4', 'Clean_VTK/cancellous_final4', ...
    'Clean_VTK/cortical_final5', 'Clean_VTK/cancellous_final5',...
    'Clean_VTK/Annulus1_filled','Clean_VTK/Annulus2_filled',...
    'Clean_VTK/Annulus3_filled','Clean_VTK/Annulus4_filled',...
    'Clean_VTK/Nucleus1_filled','Clean_VTK/Nucleus2_filled',...
    'Clean_VTK/Nucleus3_filled','Clean_VTK/Nucleus4_filled' };

% % Visualize the VTK files in ParaView
%visualizeMultipleVTK(vtkFiles);
