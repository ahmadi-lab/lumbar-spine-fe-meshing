function [F_filled, V_filled] = fillSmallMeshHoles(F_complete, V_complete, maxPerimeter)
    % Step 1: Identify boundary edges
    Eb_complete = patchBoundary(F_complete); % Find the boundary edges
    
    % Step 2: Group boundary edges into connected loops (holes)
    boundaryLoops = extractBoundaryLoops(Eb_complete, V_complete);
    
    % Step 3: Initialize new faces
    F_new = [];
    
    % Step 4: Loop through each boundary loop to determine if it's small enough to fill
    for i = 1:length(boundaryLoops)
        loopVertices = boundaryLoops{i};
        
        % Ensure that the loop has at least 3 vertices to form triangles
        if length(loopVertices) < 3
            continue; % Skip this loop if it has fewer than 3 vertices
        end
        
        % Step 5: Calculate the perimeter of the boundary loop
        % Ensure that the loopVertices are correctly indexed and form a closed loop
        V_loop = V_complete(loopVertices, :); % Vertices of the loop
        diffLoop = sqrt(sum(diff([V_loop; V_loop(1, :)], 1, 1).^2, 2)); % Calculate distances between consecutive points
        perimeter = sum(diffLoop); % Total perimeter
        
        % Fill the hole only if the perimeter is smaller than the threshold
        if perimeter < maxPerimeter
            % Step 6: Triangulate the small hole
            boundaryCoords = V_complete(loopVertices, :);
            boundaryTri = delaunay(boundaryCoords(:,1), boundaryCoords(:,2)); % Triangulate the 2D projection
            
            % Adjust the face indices to reference the complete vertex list
            F_new = [F_new; loopVertices(boundaryTri)]; %#ok<AGROW> Add new faces
        end
    end
    
    % Step 7: Combine the original faces with the new filled faces
    F_filled = [F_complete; F_new]; % Combine the faces
    V_filled = V_complete; % No new vertices are added, just filled faces
end

% Helper function to extract boundary loops from boundary edges
function boundaryLoops = extractBoundaryLoops(Eb_complete, V_complete)
    % Create an adjacency matrix for edges
    edgeAdj = sparse([Eb_complete(:,1); Eb_complete(:,2)], [Eb_complete(:,2); Eb_complete(:,1)], 1, size(V_complete, 1), size(V_complete, 1));
    
    % Find connected components (loops)
    boundaryLoops = {};
    visited = false(size(V_complete, 1), 1);
    
    for i = 1:size(Eb_complete, 1)
        if ~visited(Eb_complete(i,1))
            % Perform a depth-first search (DFS) to find a connected loop
            currentLoop = dfsBoundaryLoop(Eb_complete(i,1), edgeAdj, visited);
            boundaryLoops{end+1} = currentLoop; %#ok<AGROW>
        end
    end
end

% Depth-First Search to extract a single boundary loop
function currentLoop = dfsBoundaryLoop(startVertex, edgeAdj, visited)
    currentLoop = startVertex;
    visited(startVertex) = true;
    
    while true
        neighbors = find(edgeAdj(currentLoop(end), :));
        nextVertex = neighbors(~visited(neighbors));
        if isempty(nextVertex)
            break;
        end
        currentLoop(end+1) = nextVertex(1); %#ok<AGROW>
        visited(nextVertex(1)) = true;
    end
end
