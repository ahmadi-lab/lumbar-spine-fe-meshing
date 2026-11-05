% Function to modify the most acute angles
function [Fds, Vds] = modifyAcuteAngles(Fds, Vds, angleThreshold)
    % Fds: Face matrix of the disc
    % Vds: Vertex matrix of the disc
    % angleThreshold: threshold for detecting acute angles (in degrees)
    
    numFaces = size(Fds, 1);
    acuteVertices = false(size(Vds, 1), 1);  % Mark acute vertices

    % Loop over each face and its neighbors
    for i = 1:numFaces
        face1 = Fds(i, :);
        
        % Find adjacent faces that share edges with the current face
        adjacentFaces = findAdjacentFaces(Fds, face1);

        for j = 1:length(adjacentFaces)
            face2 = Fds(adjacentFaces(j), :);
            
            % Compute angle between face1 and face2
            normal1 = computeFaceNormal(Vds, face1);
            normal2 = computeFaceNormal(Vds, face2);
            angle = acosd(dot(normal1, normal2));
            
            % If angle is smaller than threshold, mark the vertices for adjustment
            if angle < angleThreshold
                acuteVertices(face1) = true;
                acuteVertices(face2) = true;
            end
        end
    end

    % Adjust acute vertices by averaging their position with neighboring vertices
    for i = find(acuteVertices)'
        neighbors = findNeighbors(Fds, i);
        Vds(i, :) = mean(Vds(neighbors, :), 1);  % Average position
    end
end

% Function to compute face normal
function normal = computeFaceNormal(V, face)
    v1 = V(face(2), :) - V(face(1), :);
    v2 = V(face(3), :) - V(face(1), :);
    normal = cross(v1, v2);
    normal = normal / norm(normal);  % Normalize
end

% Function to find adjacent faces sharing an edge
function adjacentFaces = findAdjacentFaces(F, face)
    adjacentFaces = find(sum(ismember(F, face), 2) == 2);
end

% Function to find neighboring vertices for vertex i
function neighbors = findNeighbors(F, i)
    neighbors = unique(F(any(F == i, 2), :));
    neighbors(neighbors == i) = [];
end