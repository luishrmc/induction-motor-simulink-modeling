%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 2: Item E - Operação Regenerativa e Gerador Hipersíncrono (TL = -Tnom)
% =========================================================================
%  Este script autônomo executa:
%    1. Simulação dinâmica no Simscape SPS por t = 8.0 s.
%    2. Aplicação de degrau mecânico negativo TL = -20.602 N.m em t = 5.0 s
%       (máquina motriz primária injetando potência no eixo).
%    3. Geração das 3 formas de onda de alta resolução:
%         - Velocidade acelerando para regime hipersíncrono (1836.42 rpm, s < 0).
%         - Conjugado eletromagnético negativo de frenagem (-12.41 N.m).
%         - Inversão da potência ativa (P = -2.22 kW gerados para a rede)
%           e manutenção do consumo de reativo (Q = +3.12 kvar para magnetização).
%    4. Confronto com os valores analíticos de regime gerador.
% =========================================================================

clear; clc;
fprintf('====================================================================\n');
fprintf('  UFMG ELE035 - PARTE 2: ITEM E (OPERAÇÃO REGENERATIVA TL = -Tnom)  \n');
fprintf('====================================================================\n\n');

%% 1. Configurar Caminhos e Carregar Parâmetros
this_dir  = fileparts(mfilename('fullpath'));
proj_root = fullfile(this_dir, '..', '..', '..');

addpath(fullfile(proj_root, 'matlab', 'simulink'));
addpath(fullfile(proj_root, 'matlab', 'scripts'));
addpath(fullfile(this_dir, '..', 'item_A_modelo_simscape'));

params = setup_parametros_Y();

%% 2. Executar Simulação Dinâmica Simscape (TL = -Tnom em t = 5.0 s)
fprintf('\n[INFO] Executando simulação de gerador hipersíncrono (t = 8.0 s)...\n');
results = run_sim_harness('regenerative', 'StopTime', 8.0, 'StepTime', 5.0, 'StepTorque', -params.T_nom_ref);

t      = results.time;
speed  = results.speed_rpm;
torque = results.torque_Nm;
ia     = results.current_Ia;
P_inst = results.p_inst;
Q_inst = results.q_inst;

%% 3. Auditoria de Regime Hipersíncrono (t = 7.5 s a 8.0 s)
idx_gen = (t >= 7.5);
n_gen_sim  = mean(speed(idx_gen));
Te_gen_sim = mean(torque(idx_gen));
ia_gen     = ia(idx_gen);
I_gen_sim  = sqrt(mean(ia_gen.^2));
P_gen_sim  = mean(P_inst(idx_gen));
Q_gen_sim  = mean(Q_inst(idx_gen));

% Referências analíticas exatas em s = -0.02023
n_gen_ana  = 1836.21;
Te_gen_ana = -12.411;
I_gen_ana  = 10.046;
P_gen_ana  = -2219.34;
Q_gen_ana  = 3119.08;

err_n  = abs(n_gen_sim - n_gen_ana) / n_gen_ana * 100;
err_Te = abs(Te_gen_sim - Te_gen_ana) / abs(Te_gen_ana) * 100;
err_I  = abs(I_gen_sim - I_gen_ana) / I_gen_ana * 100;
err_P  = abs(P_gen_sim - P_gen_ana) / abs(P_gen_ana) * 100;
err_Q  = abs(Q_gen_sim - Q_gen_ana) / Q_gen_ana * 100;

fprintf('\n[MÉTRICAS DO REGIME GERADOR HIPERSÍNCRONO (TL = -20.602 N.m)]\n');
fprintf('  Velocidade Hipersíncrona:    %.2f rpm (Analítico: %.2f rpm | Erro: %.3f%%)\n', n_gen_sim, n_gen_ana, err_n);
fprintf('  Escorregamento Resultante:   s = %.5f (s < 0, gerador)\n', (1800 - n_gen_sim)/1800);
fprintf('  Conjugado de Frenagem Te:    %.3f N.m (Analítico: %.3f N.m | Erro: %.3f%%)\n', Te_gen_sim, Te_gen_ana, err_Te);
fprintf('  Corrente Gerada de Estator:  %.3f A RMS (Analítico: %.3f A RMS | Erro: %.3f%%)\n', I_gen_sim, I_gen_ana, err_I);
fprintf('  Potência Ativa Gerada P:     %.2f W (Injeção na rede | Erro: %.3f%%)\n', P_gen_sim, err_P);
fprintf('  Potência Reativa Absorvida:  %.2f var (Magnetização do estator | Erro: %.3f%%)\n\n', Q_gen_sim, err_Q);

%% 4. Plotagem Gráfica de Alta Resolução (3 Figuras)
fig_dir = fullfile(this_dir, 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

fig_visible = 'on';
if ~feature('ShowFigureWindows') || strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
    fig_visible = 'off';
end

% -------------------------------------------------------------
% Gráfico 1: Velocidade Hipersíncrona
% -------------------------------------------------------------
fig1 = figure('Name', 'Item 2.E - Velocidade Hipersíncrona', ...
              'Color', 'w', 'Position', [100, 100, 850, 480], 'Visible', fig_visible);
ax1 = axes('Parent', fig1); hold(ax1, 'on');

plot(ax1, t, speed, 'b-', 'LineWidth', 2.0, 'DisplayName', 'n(t) (Simula\c{c}\~{a}o Simscape)');
xline(ax1, 5.0, 'k--', 'LineWidth', 1.4, 'DisplayName', 'M\''{a}quina Motriz Ativa (t = 5.0~s)');
yline(ax1, 1800, 'k:', 'LineWidth', 1.2, 'DisplayName', 'n_s = 1800~\mathrm{rpm} (Limiar S\''{\i}ncrono)');
yline(ax1, n_gen_ana, 'r--', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Regime Hipers\''{\i}ncrono = %.1f~\\mathrm{rpm}', n_gen_ana));

grid(ax1, 'on'); box(ax1, 'on');
set(ax1, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax1, 'Tempo $t$ [$\mathrm{s}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax1, 'Velocidade do Rotor $n$ [$\mathrm{rpm}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax1, '\textbf{Transit\''{o}rio de Velocidade na Opera\c{c}\~{a}o como Gerador Hipers\''{\i}ncrono}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax1, [0, 8.0]); ylim(ax1, [1700, 1880]);
legend(ax1, 'Location', 'southeast', 'Interpreter', 'latex', 'FontSize', 10);

savefig(fig1, fullfile(fig_dir, 'item2e_regenerative_speed.fig'));
exportgraphics(fig1, fullfile(fig_dir, 'item2e_regenerative_speed.png'), 'Resolution', 300);
if strcmp(fig_visible, 'off'), close(fig1); end

% -------------------------------------------------------------
% Gráfico 2: Conjugado Eletromagnético de Frenagem
% -------------------------------------------------------------
fig2 = figure('Name', 'Item 2.E - Conjugado Eletromagnético de Frenagem', ...
              'Color', 'w', 'Position', [150, 150, 850, 480], 'Visible', fig_visible);
ax2 = axes('Parent', fig2); hold(ax2, 'on');

plot(ax2, t, torque, 'b-', 'LineWidth', 1.2, 'DisplayName', 'T_e(t) (Conjugado de Frenagem)');
xline(ax2, 5.0, 'k--', 'LineWidth', 1.4, 'DisplayName', 'M\''{a}quina Motriz Ativa (t = 5.0~s)');
yline(ax2, 0, 'k-', 'LineWidth', 0.8, 'HandleVisibility', 'off');
yline(ax2, Te_gen_ana, 'r--', 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Equil\''{\i}brio: T_L + B\\omega_m = %.2f~\\mathrm{N\\cdot m}', Te_gen_ana));

grid(ax2, 'on'); box(ax2, 'on');
set(ax2, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax2, 'Tempo $t$ [$\mathrm{s}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax2, 'Conjugado $T_e$ [$\mathrm{N\cdot m}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax2, '\textbf{Conjugado Eletromagn\''{e}tico de Frenagem na Opera\c{c}\~{a}o Geradora}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax2, [0, 8.0]); ylim(ax2, [-20, 15]);
legend(ax2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 10);

savefig(fig2, fullfile(fig_dir, 'item2e_regenerative_torque.fig'));
exportgraphics(fig2, fullfile(fig_dir, 'item2e_regenerative_torque.png'), 'Resolution', 300);
if strcmp(fig_visible, 'off'), close(fig2); end

% -------------------------------------------------------------
% Gráfico 3: Potências Ativa (Revertida) e Reativa (Absorvida)
% -------------------------------------------------------------
fig3 = figure('Name', 'Item 2.E - Fluxo de Potências no Regime Gerador', ...
              'Color', 'w', 'Position', [200, 200, 850, 480], 'Visible', fig_visible);
ax3 = axes('Parent', fig3); hold(ax3, 'on');

plot(ax3, t, P_inst / 1e3, 'm-', 'LineWidth', 1.8, ...
    'DisplayName', ['Inje\c{c}\~{a}o na Rede ' sprintf('(P_{ss} = %.2f~\\mathrm{kW})', P_gen_sim / 1e3)]);
plot(ax3, t, Q_inst / 1e3, 'c-', 'LineWidth', 1.8, ...
    'DisplayName', ['Magnetiza\c{c}\~{a}o Gerador ' sprintf('(Q_{ss} = +%.2f~\\mathrm{kvar})', Q_gen_sim / 1e3)]);
xline(ax3, 5.0, 'k--', 'LineWidth', 1.4, 'DisplayName', 'M\''{a}quina Motriz Ativa (t = 5.0~s)');
yline(ax3, 0, 'k-', 'LineWidth', 0.8, 'HandleVisibility', 'off');

grid(ax3, 'on'); box(ax3, 'on');
set(ax3, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax3, 'Tempo $t$ [$\mathrm{s}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax3, 'Potências [$\mathrm{kW}$ / $\mathrm{kvar}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax3, '\textbf{Fluxo de Pot\^{e}ncias Ativa e Reativa na Opera\c{c}\~{a}o Regenerativa}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax3, [0, 8.0]); ylim(ax3, [-3.5, 4.5]);
legend(ax3, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 10);

savefig(fig3, fullfile(fig_dir, 'item2e_regenerative_powers.fig'));
exportgraphics(fig3, fullfile(fig_dir, 'item2e_regenerative_powers.png'), 'Resolution', 300);
if strcmp(fig_visible, 'off'), close(fig3); end

fprintf('[OK] Todas as 3 figuras do Item 2.E exportadas com sucesso em:\n  %s\n', fig_dir);
