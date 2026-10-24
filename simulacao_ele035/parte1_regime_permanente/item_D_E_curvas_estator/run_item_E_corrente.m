%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 1: Item E.ii - Curva de Corrente de Estator x Velocidade
% =========================================================================

clearvars -except base_dir; clc;
fprintf('====================================================================\n');
fprintf('  PARTE 1: ITEM E.ii - CORRENTE DE ESTATOR x VELOCIDADE             \n');
fprintf('====================================================================\n\n');

%% 1. Parâmetros da Máquina
V_LL_nom = 220.0; f_nom = 60.0; poles = 4; p_pairs = 2;
I_nom_placa = 14.0; n_nom = 1715.0;
R1 = 1.189; R2_prime = 1.180;
L_l1 = 5.725e-3; L_l2_prime = 8.420e-3; L_m = 131.571e-3;

omega_e = 2 * pi * f_nom;
n_s = 120 * f_nom / poles; % 1800 rpm
X1 = omega_e * L_l1;
X2_prime = omega_e * L_l2_prime;
Xm = omega_e * L_m;

%% 2. Resolução Analítica Vetorizada
N_pts = 1000;
n_vec = linspace(0, n_s - 1e-4, N_pts);
s_vec = (n_s - n_vec) ./ n_s;

V_phase = V_LL_nom;
Z1 = R1 + 1j * X1;
Zm = 1j * Xm;
Z2_vec = (R2_prime ./ s_vec) + 1j * X2_prime;
Zp_vec = (Zm .* Z2_vec) ./ (Zm + Z2_vec);
Zin_vec = Z1 + Zp_vec;

I1_ph_vec = V_phase ./ Zin_vec;
I_line_vec = sqrt(3) .* abs(I1_ph_vec);
I_ph_vec = abs(I1_ph_vec);

I_start_line = I_line_vec(1);
I_start_ph   = I_ph_vec(1);
[~, idx_nom] = min(abs(n_vec - n_nom));
I_line_nom   = I_line_vec(idx_nom);
I_ph_nom     = I_ph_vec(idx_nom);
I_vazio      = I_line_vec(end);

fprintf('  Corrente de Linha de Partida (s=1): %.2f A RMS (Pico sim.: %.2f A)\n', ...
    I_start_line, sqrt(2)*I_start_line);
fprintf('  Corrente de Linha Nominal:          %.2f A RMS (Placa: %.1f A)\n', ...
    I_line_nom, I_nom_placa);
fprintf('  Corrente de Linha a Vazio (s~0):    %.2f A RMS\n\n', I_vazio);

%% 3. Plotagem Gráfica
fig_visible = 'on';
if ~feature('ShowFigureWindows') || strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
    fig_visible = 'off';
end

fig = figure('Name', 'Item 1.E.ii - Corrente vs Velocidade', ...
             'Color', 'w', 'Position', [100, 100, 850, 520], ...
             'Visible', fig_visible);
ax = axes('Parent', fig);
hold(ax, 'on');

plot(ax, n_vec, I_line_vec, 'b-', 'LineWidth', 2.0, ...
    'DisplayName', 'I_{line} (Corrente de Linha RMS)');
plot(ax, n_vec, I_ph_vec, 'c--', 'LineWidth', 1.8, ...
    'DisplayName', 'I_{ph} (Corrente de Fase RMS: I_{line}/\surd 3)');

plot(ax, 0, I_start_line, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', ...
    'DisplayName', sprintf('I_{partida} = %.2f~\\mathrm{A_{rms}} (s=1)', I_start_line));
plot(ax, n_nom, I_line_nom, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b', ...
    'DisplayName', sprintf('I_{calc,nom} = %.2f~\\mathrm{A_{rms}} (1715~\\mathrm{rpm})', I_line_nom));
plot(ax, n_nom, I_nom_placa, 'ks', 'MarkerSize', 8, 'MarkerFaceColor', 'k', ...
    'DisplayName', sprintf('I_{placa} = %.2f~\\mathrm{A_{rms}} (1715~\\mathrm{rpm})', I_nom_placa));

grid(ax, 'on'); box(ax, 'on');
set(ax, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax, 'Velocidade do Rotor $n$ [$\mathrm{rpm}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax, 'Corrente de Estator [$\mathrm{A_{rms}}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax, '\textbf{Curva Caracter\''{\i}stica Corrente de Estator $\times$ Velocidade}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax, [0, 1800]);
ylim(ax, [0, 75]);
legend(ax, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 10);

%% 4. Salvamento
script_dir = fileparts(mfilename('fullpath'));
fig_dir = fullfile(script_dir, 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

savefig(fig, fullfile(fig_dir, 'item1e_corrente_vs_speed.fig'));
exportgraphics(fig, fullfile(fig_dir, 'item1e_corrente_vs_speed.png'), 'Resolution', 300);
fprintf('[OK] Gráfico salvo com sucesso em:\n  %s\n', fullfile(fig_dir, 'item1e_corrente_vs_speed.png'));

if strcmp(fig_visible, 'off'), close(fig); end
