% Read STL file and save libsurf .mat file
% Make sure you have the required MATLAB functions installed, such as stlread

% Define the STL file path
stlFilePath = fullfile('data','stl','D45.stl');

% Read the STL file
[vertices, faces, ~, ~] = stlread(stlFilePath);

% Define the .mat file path
matFilePath = fullfile('data','libSurf','D45');

% Save the faces (F) and vertices (V) to the .mat file
F = faces;
V = vertices;
save(matFilePath, 'F', 'V');

% Display a message indicating success
disp(['F and V saved to ', matFilePath]);

