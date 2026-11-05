% Compare the stored article meshes in save_data.mat with Table 2 of
% Scientific Reports 15 (2025) 35619 and report the cortical mesh connectivity.
% Run from the folder that contains save_data.mat.

S = load('save_data.mat');

names = [compose('cortical_clean%d',1:5), compose('cancellous%d',1:5), ...
         compose('Nucleus%d_joint',1:4), compose('Annulus%d_joint',1:4), ...
         strcat('CartilageData_', {'L1D1','L2D1','L2D2','L3D2','L3D3','L4D3','L4D4','L5D4'})];

% Table 2: volumetric elements, surface elements, vertices
T2 = [276374 44988 65517; 282049 45512 66887; 294735 48282 70171; 256790 42210 61369; 275650 45962 65963; ...
      76122 11270 15760; 79964 11020 16331; 90909 12146 18462; 83500 10386 16745; 83338 11630 17046; ...
      4170 936 956; 4300 960 983; 4218 986 978; 5829 1136 1285; ...
      4111 1494 1114; 4396 1612 1197; 4160 1606 1159; 5550 1842 1448; ...
      15765 31530 2731; 19067 38134 3351; 17130 34260 3083; 18144 36288 3299; ...
      21001 42002 3678; 19062 38124 3394; 18280 36560 3215; 18261 36522 3158];

nFail = 0;
total = zeros(1,3);
for i = 1:numel(names)
    c = [size(S.(['E_' names{i}]),1), size(S.(['F_' names{i}]),1), size(S.(['V_' names{i}]),1)];
    total = total + c;
    ok = isequal(c, T2(i,:));
    nFail = nFail + ~ok;
    fprintf('%-22s %8d %8d %8d  %s\n', names{i}, c, string(ok));
end
fprintf('Total %d %d %d (Table 2: 1982875 587398 449280)\n', total);
fprintf('Rows that differ from Table 2: %d\n', nFail);

for i = 1:5
    E = double(S.(sprintf('E_cortical_clean%d',i)));
    E = E - min(E(:)) + 1;
    n = max(E(:));
    A = sparse([E(:,1);E(:,1);E(:,1)], [E(:,2);E(:,3);E(:,4)], 1, n, n);
    b = conncomp(graph((A + A') ~= 0));
    fprintf('Cortical L%d connected components: %d\n', i, numel(unique(b(unique(E(:))))));
end
