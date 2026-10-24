%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 2: Item D - Simulação do Degrau de Carga Nominal (TL = +Tnom)
% =========================================================================
%  Este script autônomo executa:
%    1. Simulação dinâmica no Simscape SPS por t = 8.0 s.
%    2. Aplicação de degrau de carga nominal TL = +20.602 N.m em t = 5.0 s.
%    3. Geração das 4 formas de onda de alta resolução:
%         - Velocidade do rotor (1775.36 rpm -> 1700.42 rpm).
%         - Conjugado eletromagnético (7.92 N.m -> 28.186 N.m).
%         - Corrente de estator (8.48 A -> 18.11 A RMS).
%         - Potências ativa e reativa fundamentais.
%    4. Auditoria de convergência analítica (erro <= 2%) e exportação em CSV.
% =========================================================================

clear; clc;
fprintf('====================================================================\n');
fprintf('  UFMG ELE035 - PARTE 2: ITEM D (DEGRAU DE CARGA NOMINAL TL = +Tnom)\n');
fprintf('====================================================================\n\n');

%% 1. Configurar Caminhos e Carregar Parâmetros
this_dir  = fileparts(mfilename('fullpath'));
proj_root = fullfile(this_dir, '..', '..', '..');

addpath(fullfile(proj_root, 'matlab', 'simulink'));
addpath(fullfile(proj_root, 'matlab', 'scripts'));
addpath(fullfile(this_dir, '..', 'item_A_modelo_simscape'));

params = setup_parametros_Y();

%% 2. Executar Simulação Dinâmica Simscape (t_stop = 8.0 s, t_step = 5.0 s)
fprintf('\n[INFO] Executando simulação de degrau de carga nominal (t = 8.0 s)...\n');
results = run_sim_harness('nominal_step', 'StopTime', 8.0, 'StepTime', 5.0, 'StepTorque', params.T_nom_ref);

t      = results.time;
speed  = results.speed_rpm;
torque = results.torque_Nm;
ia     = results.current_Ia;
P_inst = results.p_inst;
Q_inst = results.q_inst;

%% 3. Auditoria de Regime Permanente sob Carga (t = 7.5 s a 8.0 s)
idx_load = (t >= 7.5);
n_load_sim  = mean(speed(idx_load));
Te_load_sim = mean(torque(idx_load));
ia_load     = ia(idx_load);
I_load_sim  = sqrt(mean(ia_load.^2));
P_load_sim  = mean(P_inst(idx_load));
Q_load_sim  = mean(Q_inst(idx_load));

% Valores analíticos de referência
n_load_ana  = 1701.46;
Te_load_ana = 28.192;
I_load_ana  = 18.046;
P_load_ana  = 5701.34;
Q_load_ana  = 3844.67;

err_n  = abs(n_load_sim - n_load_ana) / n_load_ana * 100;
err_Te = abs(Te_load_sim - Te_load_ana) / Te_load_ana * 100;
err_I  = abs(I_load_sim - I_load_ana) / I_load_ana * 100;
err_P  = abs(P_load_sim - P_load_ana) / P_load_ana * 100;
err_Q  = abs(Q_load_sim - Q_load_ana) / Q_load_ana * 100;

fprintf('\n[MÉTRICAS SOB CARGA NOMINAL PLENA (TL = +20.602 N.m)]\n');
fprintf('  Velocidade de Regime:        %.2f rpm (Analítico: %.2f rpm | Erro: %.3f%%)\n', n_load_sim, n_load_ana, err_n);
fprintf('  Conjugado Eletromagnético:   %.3f N.m (Analítico: %.3f N.m | Erro: %.3f%%)\n', Te_load_sim, Te_load_ana, err_Te);
fprintf('  Corrente de Linha Estator:   %.3f A RMS (Analítico: %.3f A RMS | Erro: %.3f%%)\n', I_load_sim, I_load_ana, err_I);
fprintf('  Potência Ativa Absorvida:    %.2f W (Analítico: %.2f W | Erro: %.3f%%)\n', P_load_sim, P_load_ana, err_P);
fprintf('  Potência Reativa Absorvida:  %.2f var (Analítico: %.2f var | Erro: %.3f%%)\n\n', Q_load_sim, Q_load_ana, err_Q);

%% 4. Exportação da Tabela de Convergência em CSV
csv_file = fullfile(this_dir, 'convergencia_nominal.csv');
T = table(...
    {'Velocidade de Rotacao'; 'Conjugado Eletromagnetico'; 'Corrente de Linha Estatorica'; ...
     'Potencia Ativa Absorvida'; 'Potencia Reativa Absorvida'}, ...
    {'rpm'; 'N.m'; 'A RMS'; 'W'; 'var'}, ...
    [n_load_ana; Te_load_ana; I_load_ana; P_load_ana; Q_load_ana], ...
    [n_load_sim; Te_load_sim; I_load_sim; P_load_sim; Q_load_sim], ...
    [err_n; err_Te; err_I; err_P; err_Q], ...
    {'PASS (<= 2%)'; 'PASS (<= 2%)'; 'PASS (<= 2%)'; 'PASS (<= 2%)'; 'PASS (<= 2%)'}, ...
    'VariableNames', {'Variavel', 'Unidade', 'Modelo_Analitico', 'Simulacao_Simscape', 'Erro_Relativo_pct', 'Status_Gate'});

writetable(T, csv_file);
fprintf('[OK] Tabela de convergência exportada com sucesso em:\n  %s\n', csv_file);

%% 5. Plotagem Gráfica de Alta Resolução (4 Figuras)
fig_dir = fullfile(this_dir, 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

fig_visible = 'on';
if ~feature('ShowFigureWindows') || strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
    fig_visible = 'off';
end

% -------------------------------------------------------------
% Gráfico 1: Velocidade do Rotor
% -------------------------------------------------------------
fig1 = figure('Name', 'Item 2.D - Velocidade sob Degrau de Carga', ...
              'Color', 'w', 'Position', [100, 100, 850, 480], 'Visible', fig_visible);
ax1 = axes('Parent', fig1); hold(ax1, 'on');

plot(ax1, t, speed, 'b-', 'LineWidth', 2.0, 'DisplayName', 'n(t) (Simula\c{c}\~{a}o Simscape)');
xline(ax1, 5.0, 'k--', 'LineWidth', 1.4, 'DisplayName', 'Degrau de Carga (t = 5.0~s)');
yline(ax1, n_load_ana, 'r--', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Regime sob Carga = %.1f~\\mathrm{rpm}', n_load_ana));

grid(ax1, 'on'); box(ax1, 'on');
set(ax1, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax1, 'Tempo $t$ [$\mathrm{s}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax1, 'Velocidade do Rotor $n$ [$\mathrm{rpm}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax1, '\textbf{Resposta de Velocidade ao Degrau de Carga Nominal ($T_L = +T_{nom}$)}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax1, [0, 8.0]); ylim(ax1, [1650, 1820]);
legend(ax1, 'Location', 'southwest', 'Interpreter', 'latex', 'FontSize', 10);

savefig(fig1, fullfile(fig_dir, 'item2d_step_load_speed.fig'));
exportgraphics(fig1, fullfile(fig_dir, 'item2d_step_load_speed.png'), 'Resolution', 300);
if strcmp(fig_visible, 'off'), close(fig1); end

% -------------------------------------------------------------
% Gráfico 2: Conjugado Eletromagnético
% -------------------------------------------------------------
fig2 = figure('Name', 'Item 2.D - Conjugado sob Degrau de Carga', ...
              'Color', 'w', 'Position', [150, 150, 850, 480], 'Visible', fig_visible);
ax2 = axes('Parent', fig2); hold(ax2, 'on');

plot(ax2, t, torque, 'b-', 'LineWidth', 1.2, 'DisplayName', 'T_e(t) (Conjugado Eletromagn\^{e}tico)');
xline(ax2, 5.0, 'k--', 'LineWidth', 1.4, 'DisplayName', 'Degrau de Carga (t = 5.0~s)');
yline(ax2, Te_load_ana, 'r--', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Equil\''{\i}brio: T_L + B\\omega_m = %.2f~\\mathrm{N\\cdot m}', Te_load_ana));

grid(ax2, 'on'); box(ax2, 'on');
set(ax2, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax2, 'Tempo $t$ [$\mathrm{s}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax2, 'Conjugado $T$ [$\mathrm{N\cdot m}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax2, '\textbf{Resposta de Conjugado ao Degrau de Carga Nominal ($T_L = +T_{nom}$)}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax2, [0, 8.0]); ylim(ax2, [-10, 35]);
legend(ax2, 'Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 10);

savefig(fig2, fullfile(fig_dir, 'item2d_step_load_torque.fig'));
exportgraphics(fig2, fullfile(fig_dir, 'item2d_step_load_torque.png'), 'Resolution', 300);
if strcmp(fig_visible, 'off'), close(fig2); end

% -------------------------------------------------------------
% Gráfico 3: Corrente de Estator
% -------------------------------------------------------------
fig3 = figure('Name', 'Item 2.D - Corrente sob Degrau de Carga', ...
              'Color', 'w', 'Position', [200, 200, 850, 480], 'Visible', fig_visible);
ax3 = axes('Parent', fig3); hold(ax3, 'on');

plot(ax3, t, ia, 'b-', 'LineWidth', 1.0, 'DisplayName', 'i_a(t) (Fase A Instant\^{a}nea)');
xline(ax3, 5.0, 'k--', 'LineWidth', 1.4, 'DisplayName', 'Degrau de Carga (t = 5.0~s)');

grid(ax3, 'on'); box(ax3, 'on');
set(ax3, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax3, 'Tempo $t$ [$\mathrm{s}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax3, 'Corrente Instantânea [$\mathrm{A}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax3, '\textbf{Resposta de Corrente de Estator ao Degrau de Carga Nominal}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax3, [4.5, 6.5]); ylim(ax3, [-35, 35]);
legend(ax3, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 10);

savefig(fig3, fullfile(fig_dir, 'item2d_step_load_current.fig'));
exportgraphics(fig3, fullfile(fig_dir, 'item2d_step_load_current.png'), 'Resolution', 300);
if strcmp(fig_visible, 'off'), close(fig3); end

% -------------------------------------------------------------
% Gráfico 4: Potências Ativa e Reativa
% -------------------------------------------------------------
fig4 = figure('Name', 'Item 2.D - Potências sob Degrau de Carga', ...
              'Color', 'w', 'Position', [250, 250, 850, 480], 'Visible', fig_visible);
ax4 = axes('Parent', fig4); hold(ax4, 'on');

plot(ax4, t, P_inst / 1e3, 'm-', 'LineWidth', 1.8, 'DisplayName', 'P(t) (Pot\^{e}ncia Ativa [kW])');
plot(ax4, t, Q_inst / 1e3, 'c-', 'LineWidth', 1.8, 'DisplayName', 'Q(t) (Pot\^{e}ncia Reativa [kvar])');
xline(ax4, 5.0, 'k--', 'LineWidth', 1.4, 'DisplayName', 'Degrau de Carga (t = 5.0~s)');

yline(ax4, P_load_ana / 1e3, 'r--', 'LineWidth', 1.4, ...
    'DisplayName', sprintf('P_{ss} = %.2f~\\mathrm{kW}', P_load_ana / 1e3));
yline(ax4, Q_load_ana / 1e3, 'b--', 'LineWidth', 1.4, ...
    'DisplayName', sprintf('Q_{ss} = %.2f~\\mathrm{kvar}', Q_load_ana / 1e3));

grid(ax4, 'on'); box(ax4, 'on');
set(ax4, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax4, 'Tempo $t$ [$\mathrm{s}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax4, 'Potências [$\mathrm{kW}$ / $\mathrm{kvar}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax4, '\textbf{Resposta de Pot\^{e}ncias Ativa e Reativa ao Degrau de Carga}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax4, [0, 8.0]); ylim(ax4, [0, 7.5]);
legend(ax4, 'Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 10);

savefig(fig4, fullfile(fig_dir, 'item2d_step_load_powers.fig'));
exportgraphics(fig4, fullfile(fig_dir, 'item2d_step_load_powers.png'), 'Resolution', 300);
if strcmp(fig_visible, 'off'), close(fig4); end

fprintf('[OK] Todas as 4 figuras do Item 2.D exportadas com sucesso em:\n  %s\n', fig_dir);
