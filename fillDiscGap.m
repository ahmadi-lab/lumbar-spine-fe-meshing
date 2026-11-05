function newVds = fillDiscGap(V, Vds, threshold)
    % Function to fill the gap between vertebra and disc
    % Inputs:
    % V - vertebra vertices (Nx3 matrix)
    % Vds - disc vertices (Mx3 matrix)
    % threshold - distance threshold (in mm)
    % Output:
    % newVds - updated disc vertices after filling the gap

    % Number of vertices in the disc and vertebra
    numDiscVertices = size(Vds, 1);
    
    % Initialize new disc vertices
    newVds = Vds;

    % Loop over disc vertices
    for i = 1:numDiscVertices
        % Get the current disc vertex
        discVertex = Vds(i, :);
        
        % Calculate the distance from the current disc vertex to all vertebra vertices
        distances = sqrt(sum((V - discVertex).^2, 2));
        
        % Find the closest vertebra vertex
        [minDistance, idx] = min(distances);
        
        % If the distance is less than the threshold, connect the disc vertex to the closest vertebra vertex
        if minDistance < threshold
            % Snap the disc vertex to the closest vertebra vertex
            newVds(i, :) = V(idx, :);
        end
    end
end
