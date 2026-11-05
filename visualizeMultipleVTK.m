function visualizeMultipleVTK(vtkFileNames)
    % vtkFileNames: Cell array of VTK filenames (without extension)

    % Full path to the ParaView executable (update this path accordingly)
    paraviewPath = '"C:\Program Files\ParaView 5.11.0\bin\paraview.exe"';
    
    % Check if vtkFileNames is a cell array
    if ~iscell(vtkFileNames)
        error('vtkFileNames should be a cell array of file names.');
    end
    
    % Initialize the command to open all VTK files in a single ParaView window
    paraviewCommand = [paraviewPath];
    
    % Loop over all provided VTK files and append to the command
    for i = 1:length(vtkFileNames)
        vtkFileName = vtkFileNames{i};  % Get the current VTK file name
        
        % Check if the file exists
        if exist([vtkFileName, '.vtk'], 'file') ~= 2
            warning(['File ', vtkFileName, '.vtk does not exist. Skipping.']);
            continue;
        end
        
        % Append the VTK file to the ParaView command
        paraviewCommand = [paraviewCommand, ' ', vtkFileName, '.vtk'];
    end
    
    % Add the '&' at the end of the command to run it in the background
    paraviewCommand = [paraviewCommand, ' &'];
    
    % Run the ParaView command from MATLAB to open all files in a single window
    status = system(paraviewCommand);
    
    if status == 0
        disp('ParaView launched successfully with all specified VTK files.');
    else
        disp('Error: Could not launch ParaView with the specified VTK files.');
    end
end
