%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 2: Item A - Script de Abertura e Parametrização no Simulink GUI
% =========================================================================
%  Este script utilitário:
%    1. Carrega todos os parâmetros físicos no Base Workspace via setup_parametros_Y().
%    2. Abre o diagrama de simulação 'mit_simscape_model.slx' diretamente
%       no canvas do Simulink para visualização interativa e inspeção de blocos.
%    3. Permite dar 'Run' diretamente no botão de Play do Simulink.
% =========================================================================

clear; clc;
fprintf('====================================================================\n');
fprintf('  UFMG ELE035 - ABRIR MODELO SIMSCAPE SPECIALIZED POWER SYSTEMS     \n');
fprintf('====================================================================\n\n');

%% 1. Inicializar Parâmetros no Base Workspace
model_dir = fileparts(mfilename('fullpath'));
addpath(model_dir);

fprintf('[1/2] Carregando parâmetros do motor no Workspace...\n');
setup_parametros_Y();

%% 2. Abrir o Modelo no Simulink GUI
model_name = 'mit_simscape_model';
model_file = fullfile(model_dir, [model_name '.slx']);

if ~exist(model_file, 'file')
    error('[ERRO] Arquivo do modelo não encontrado em: %s', model_file);
end

fprintf('[2/2] Abrindo diagrama no Simulink GUI: %s.slx...\n', model_name);
open_system(model_file);

fprintf('\n====================================================================\n');
fprintf('  [PRONTO] Modelo Simscape aberto com sucesso no Simulink!\n');
fprintf('  Dicas de Inspeção no MATLAB/Simulink GUI:\n');
fprintf('    1. Dê duplo clique no bloco "Asynchronous Machine" para ver a\n');
fprintf('       parametrização em unidades SI (R1_Y, R2_Y, L1_Y, L2_Y, Lm_Y, J, B).\n');
fprintf('    2. Inspecione o barramento trifásico e o bloco "Voltage Source (Three-Phase)".\n');
fprintf('    3. Você pode clicar no botão verde de "Run" para simular interativamente.\n');
fprintf('====================================================================\n');
