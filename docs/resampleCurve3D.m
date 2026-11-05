function newIndList = resampleCurve3D(V, indList, nPoints)
    % Extract the 3D points corresponding to the indices
    curvePoints = V(indList, :);
    
    % Calculate the cumulative distance along the curve
    distances = [0; cumsum(sqrt(sum(diff(curvePoints).^2, 2)))];
    
    % Normalize distances to the range [0, 1]
    distances = distances / distances(end);
    
    % Create new distance values for the resampled curve
    newDistances = linspace(0, 1, nPoints);
    
    % Interpolate the 3D positions along the curve
    resampledPoints = interp1(distances, curvePoints, newDistances, 'linear');
    
    % Find the closest vertices in V to the resampled points
    newIndList = knnsearch(V, resampledPoints);
end
