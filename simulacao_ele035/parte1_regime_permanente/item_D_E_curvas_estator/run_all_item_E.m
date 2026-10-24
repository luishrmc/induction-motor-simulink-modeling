%% UFMG ELE035 - Parte 1, Item E: executa as 5 curvas em lote
%  Cada script run_item_E_*.m e autonomo (preserva apenas base_dir).
clear; clc;
base_dir = fileparts(mfilename('fullpath'));
run(fullfile(base_dir, 'run_item_E_torque.m'));
run(fullfile(base_dir, 'run_item_E_corrente.m'));
run(fullfile(base_dir, 'run_item_E_potencia.m'));
run(fullfile(base_dir, 'run_item_E_fp.m'));
run(fullfile(base_dir, 'run_item_E_rendimento.m'));
fprintf('[OK] 5 curvas do Item E geradas em %s\n', fullfile(base_dir, 'figures'));
