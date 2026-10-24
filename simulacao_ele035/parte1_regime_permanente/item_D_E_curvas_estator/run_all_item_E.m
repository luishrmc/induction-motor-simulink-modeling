%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 1: Item E - Script Mestre de Execução de Todas as Curvas
% =========================================================================
%  Executa em lote os 5 scripts das curvas características:
%    1. run_item_E_torque.m      (Conjugado x Velocidade)
%    2. run_item_E_corrente.m    (Corrente x Velocidade)
%    3. run_item_E_potencia.m    (Potência Ativa x Velocidade)
%    4. run_item_E_fp.m          (Fator de Potência x Velocidade)
%    5. run_item_E_rendimento.m  (Rendimento x Velocidade)
% =========================================================================

clear; clc;
fprintf('====================================================================\n');
fprintf('  UFMG ELE035 - PARTE 1: ITEM E (EXECUÇÃO DE TODAS AS 5 CURVAS)     \n');
fprintf('====================================================================\n\n');

base_dir = fileparts(mfilename('fullpath'));

fprintf('[1/5] Executando Curva de Conjugado x Velocidade...\n');
run(fullfile(base_dir, 'run_item_E_torque.m'));

fprintf('\n[2/5] Executando Curva de Corrente x Velocidade...\n');
run(fullfile(base_dir, 'run_item_E_corrente.m'));

fprintf('\n[3/5] Executando Curvas de Potência Ativa x Velocidade...\n');
run(fullfile(base_dir, 'run_item_E_potencia.m'));

fprintf('\n[4/5] Executando Curva de Fator de Potência x Velocidade...\n');
run(fullfile(base_dir, 'run_item_E_fp.m'));

fprintf('\n[5/5] Executando Curvas de Rendimento x Velocidade...\n');
run(fullfile(base_dir, 'run_item_E_rendimento.m'));

fprintf('\n====================================================================\n');
fprintf('  [SUCESSO] Todas as 5 curvas características foram geradas!        \n');
fprintf('  Arquivos .png (300 DPI) e .fig salvos em:\n');
fprintf('    %s\n', fullfile(base_dir, 'figures'));
fprintf('====================================================================\n');
