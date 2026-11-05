function [Fb, Cb, Vb, Eb] = meshInsideGeometry(F, V, pointSpacing)
    % Create a PDE model
    model = createpde();
    
    % Create geometry from mesh
    geometryFromMesh(model, V', F');
    
    % Generate the mesh
    mesh = generateMesh(model, 'GeometricOrder', 'linear', 'Hmax', pointSpacing);
    
    % Extract mesh elements
    nodes = mesh.Nodes;
    elements = mesh.Elements;
    
    % Boundary faces of the geometry
    boundaryFaces = findBoundaryFaces(elements, nodes); % Custom function to find boundary faces
    
    % Boundary marker/color data for the geometry (optional)
    boundaryMarker = ones(size(boundaryFaces, 1), 1); % Assign a marker value of 1 for all boundary faces
    
    % Store data in output variables
    Fb = boundaryFaces; % Boundary faces of the geometry
    Cb = boundaryMarker; % Boundary marker/color data for the geometry
    Vb = nodes'; % The vertices/nodes
    Eb = elements'; % The tet4 elements
    
    % % Visualize the mesh using a custom function 'meshView'
    % meshOutput.facesBoundary = Fb;
    % meshOutput.boundaryMarker = Cb;
    % meshOutput.nodes = Vb;
    % meshOutput.elements = Eb;
    % meshView(meshOutput);
end