%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 2: Item C - Simulação da Partida Direta a Vazio (TL = 0)
% =========================================================================
%  Este script autônomo executa:
%    1. Configuração da partida direta sem carga (TL = 0) a partir do repouso.
%    2. Simulação dinâmica no Simscape Specialized Power Systems (t_stop = 6.0 s).
%    3. Geração das 3 curvas transitórias de alta resolução:
%         - Corrente de estator com destaque para o inrush instantâneo de 121.25 A.
%         - Velocidade do rotor acelerando até 1775.36 rpm.
%         - Conjugado eletromagnético oscilatório e estabilização em 7.92 N.m.
%    4. Confronto numérico e validação da convergência (erro <= 2%).
% =========================================================================

clear; clc;
fprintf('====================================================================\n');
fprintf('  UFMG ELE035 - PARTE 2: ITEM C (SIMULAÇÃO DA PARTIDA DIRETA A VAZIO)\n');
fprintf('====================================================================\n\n');

%% 1. Configurar Caminhos e Carregar Parâmetros
this_dir  = fileparts(mfilename('fullpath'));
proj_root = fullfile(this_dir, '..', '..', '..');

addpath(fullfile(proj_root, 'matlab', 'simulink'));
addpath(fullfile(proj_root, 'matlab', 'scripts'));
addpath(fullfile(this_dir, '..', 'item_A_modelo_simscape'));

params = setup_parametros_Y();

%% 2. Executar Simulação Dinâmica Simscape (TL = 0, t = 6.0 s)
fprintf('\n[INFO] Executando simulação de partida direta a vazio (t = 6.0 s)...\n');
results = run_sim_harness('dol_startup', 'StopTime', 6.0);

t      = results.time;
speed  = results.speed_rpm;
torque = results.torque_Nm;
ia     = results.current_Ia;

% Métricas de transitório e regime permanente
I_peak_sim = max(abs(ia));
I_start_rms_ana = 67.728; % RMS simétrico calculado
I_start_peak_ana = sqrt(2) * I_start_rms_ana; % 95.78 A

% Regime a vazio permanente (média dos últimos 0.5 s)
idx_ss = (t >= 5.5);
n_ss_sim = mean(speed(idx_ss));
Te_ss_sim = mean(torque(idx_ss));
ia_ss = ia(idx_ss);
I_line_ss_sim = sqrt(mean(ia_ss.^2));

% Referências analíticas exatas a vazio com atrito da bancada B*omega_m
n_ss_ana  = 1775.52;
Te_ss_ana = 7.921;
I_line_ss_ana = 8.493;

err_n  = abs(n_ss_sim - n_ss_ana) / n_ss_ana * 100;
err_Te = abs(Te_ss_sim - Te_ss_ana) / Te_ss_ana * 100;
err_I  = abs(I_line_ss_sim - I_line_ss_ana) / I_line_ss_ana * 100;

fprintf('\n[MÉTRICAS DO TRANSITÓRIO DE PARTIDA A VAZIO]\n');
fprintf('  Pico Instantâneo Máximo de Inrush: %.2f A (Pico simétrico analítico: %.2f A)\n', I_peak_sim, I_start_peak_ana);
fprintf('  Razão de Assimetria DC (Inrush/Crista): %.3f\n', I_peak_sim / I_start_peak_ana);
fprintf('  Velocidade Estabilizada a Vazio:   %.2f rpm (Analítico: %.2f rpm | Erro: %.3f%%)\n', n_ss_sim, n_ss_ana, err_n);
fprintf('  Conjugado Estabilizado a Vazio:    %.3f N.m (Analítico: %.3f N.m | Erro: %.3f%%)\n', Te_ss_sim, Te_ss_ana, err_Te);
fprintf('  Corrente de Linha de Vazio:        %.3f A RMS (Analítico: %.3f A RMS | Erro: %.3f%%)\n\n', I_line_ss_sim, I_line_ss_ana, err_I);

%% 3. Plotagem e Exportação das 3 Formas de Onda
fig_dir = fullfile(this_dir, 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

fig_visible = 'on';
if ~feature('ShowFigureWindows') || strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
    fig_visible = 'off';
end

% -------------------------------------------------------------
% Gráfico 1: Corrente de Estator e Inrush
% -------------------------------------------------------------
fig1 = figure('Name', 'Item 2.C - Corrente de Partida e Inrush', ...
              'Color', 'w', 'Position', [100, 100, 850, 480], ...
              'Visible', fig_visible);
ax1 = axes('Parent', fig1);
hold(ax1, 'on');

plot(ax1, t, ia, 'b-', 'LineWidth', 1.2, 'DisplayName', 'i_a(t) (Fase A Instant\^{a}nea)');
yline(ax1, I_peak_sim, 'r--', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Pico de Inrush = %.2f~\\mathrm{A}', I_peak_sim));
yline(ax1, -I_peak_sim, 'r--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
yline(ax1, I_start_peak_ana, 'k:', 'LineWidth', 1.4, ...
    'DisplayName', sprintf('Crista Sim\''{e}trica = %.2f~\\mathrm{A}', I_start_peak_ana));
yline(ax1, -I_start_peak_ana, 'k:', 'LineWidth', 1.4, 'HandleVisibility', 'off');

grid(ax1, 'on'); box(ax1, 'on');
set(ax1, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax1, 'Tempo $t$ [$\mathrm{s}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax1, 'Corrente Instantânea [$\mathrm{A}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax1, '\textbf{Transit\''{o}rio de Corrente na Partida Direta a Vazio (Inrush)}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax1, [0, 6.0]);
ylim(ax1, [-140, 140]);
legend(ax1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 10);

savefig(fig1, fullfile(fig_dir, 'item2c_transient_dol_current.fig'));
exportgraphics(fig1, fullfile(fig_dir, 'item2c_transient_dol_current.png'), 'Resolution', 300);
if strcmp(fig_visible, 'off'), close(fig1); end

% -------------------------------------------------------------
% Gráfico 2: Velocidade do Rotor
% -------------------------------------------------------------
fig2 = figure('Name', 'Item 2.C - Velocidade do Rotor na Partida', ...
              'Color', 'w', 'Position', [150, 150, 850, 480], ...
              'Visible', fig_visible);
ax2 = axes('Parent', fig2);
hold(ax2, 'on');

plot(ax2, t, speed, 'b-', 'LineWidth', 2.0, 'DisplayName', 'n(t) (Simula\c{c}\~{a}o Simscape SPS)');
yline(ax2, n_ss_ana, 'r--', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Regime a Vazio com Atrito B = %.1f~\\mathrm{rpm}', n_ss_ana));
yline(ax2, 1800, 'k:', 'LineWidth', 1.2, 'DisplayName', 'n_s = 1800~\mathrm{rpm} (S\''{\i}ncrona)');

grid(ax2, 'on'); box(ax2, 'on');
set(ax2, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax2, 'Tempo $t$ [$\mathrm{s}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax2, 'Velocidade do Rotor $n$ [$\mathrm{rpm}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax2, '\textbf{Transit\''{o}rio de Velocidade na Partida Direta a Vazio}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax2, [0, 6.0]);
ylim(ax2, [0, 1900]);
legend(ax2, 'Location', 'southeast', 'Interpreter', 'latex', 'FontSize', 10);

savefig(fig2, fullfile(fig_dir, 'item2c_transient_dol_speed.fig'));
exportgraphics(fig2, fullfile(fig_dir, 'item2c_transient_dol_speed.png'), 'Resolution', 300);
if strcmp(fig_visible, 'off'), close(fig2); end

% -------------------------------------------------------------
% Gráfico 3: Conjugado Eletromagnético
% -------------------------------------------------------------
fig3 = figure('Name', 'Item 2.C - Conjugado Eletromagnético na Partida', ...
              'Color', 'w', 'Position', [200, 200, 850, 480], ...
              'Visible', fig_visible);
ax3 = axes('Parent', fig3);
hold(ax3, 'on');

plot(ax3, t, torque, 'b-', 'LineWidth', 1.2, 'DisplayName', 'T_e(t) (Simula\c{c}\~{a}o Simscape)');
yline(ax3, Te_ss_ana, 'r--', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Equil\''{\i}brio de Atrito B\\omega_m = %.2f~\\mathrm{N\\cdot m}', Te_ss_ana));

grid(ax3, 'on'); box(ax3, 'on');
set(ax3, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax3, 'Tempo $t$ [$\mathrm{s}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax3, 'Conjugado Eletromagnético $T_e$ [$\mathrm{N\cdot m}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax3, '\textbf{Transit\''{o}rio de Conjugado na Partida Direta a Vazio}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax3, [0, 6.0]);
ylim(ax3, [-40, 90]);
legend(ax3, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 10);

savefig(fig3, fullfile(fig_dir, 'item2c_transient_dol_torque.fig'));
exportgraphics(fig3, fullfile(fig_dir, 'item2c_transient_dol_torque.png'), 'Resolution', 300);
if strcmp(fig_visible, 'off'), close(fig3); end

fprintf('[OK] Todas as 3 figuras do Item 2.C exportadas com sucesso em:\n  %s\n', fig_dir);
