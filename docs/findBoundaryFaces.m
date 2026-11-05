function boundaryFaces = findBoundaryFaces(elements, nodes)
    TR = triangulation(elements', nodes');
    boundaryFaces = freeBoundary(TR);
end