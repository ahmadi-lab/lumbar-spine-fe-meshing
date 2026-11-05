function progressBar(currentIteration, totalIterations)
    % Function to display a simple progress bar
    % Input:
    %   currentIteration: The current loop iteration
    %   totalIterations: The total number of iterations
    
    % Define the width of the progress bar
    barWidth = 50;
    
    % Calculate the progress as a percentage
    progress = currentIteration / totalIterations;
    
    % Calculate how many blocks of the bar should be filled
    filledWidth = round(barWidth * progress);
    
    % Create the bar string
    bar = ['[', repmat('█', 1, filledWidth), repmat(' ', 1, barWidth - filledWidth), ']'];
    
    % Print the progress bar along with the percentage
    fprintf('\r%s %d%%', bar, round(progress * 100));
    
    % When finished, move to the next line
    if currentIteration == totalIterations
        fprintf('\n');
    end
end