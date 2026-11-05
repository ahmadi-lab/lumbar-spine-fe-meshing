function setup_paths(gibbonRoot)
    % Add GIBBON and this repository to the MATLAB path.
    % Input:
    %   gibbonRoot: Folder that contains the GIBBON lib and lib_ext folders

    if ~isfolder(fullfile(gibbonRoot, 'lib')) || ~isfolder(fullfile(gibbonRoot, 'lib_ext'))
        error('GIBBON lib and lib_ext folders were not found in %s', gibbonRoot);
    end

    addpath(genpath(fullfile(gibbonRoot, 'lib')));
    addpath(genpath(fullfile(gibbonRoot, 'lib_ext')));

    % This repository comes last so that its graphicsModels.m takes priority
    repoRoot = fileparts(mfilename('fullpath'));
    addpath(genpath(repoRoot));
    rmpath(genpath(fullfile(repoRoot, '.git')));
    cd(repoRoot);
end
