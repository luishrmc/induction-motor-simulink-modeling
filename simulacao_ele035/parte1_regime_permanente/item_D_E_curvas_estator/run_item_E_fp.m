%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 1: Item E.iv - Curva de Fator de Potência x Velocidade
% =========================================================================

clearvars -except base_dir; clc;
fprintf('====================================================================\n');
fprintf('  PARTE 1: ITEM E.iv - FATOR DE POTÊNCIA x VELOCIDADE               \n');
fprintf('====================================================================\n\n');

%% 1. Parâmetros da Máquina
V_LL_nom = 220.0; f_nom = 60.0; poles = 4; p_pairs = 2;
PF_placa = 0.810; n_nom = 1715.0;
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

phi_vec = angle(Zin_vec);
PF_vec = cos(phi_vec);

[~, idx_nom] = min(abs(n_vec - n_nom));
PF_nom = PF_vec(idx_nom);
[PF_max, idx_max] = max(PF_vec);
n_pf_max = n_vec(idx_max);
PF_start = PF_vec(1);

fprintf('  Fator de Potência na Partida (s=1): %.4f\n', PF_start);
fprintf('  Fator de Potência Máximo:           %.4f em %.0f rpm\n', PF_max, n_pf_max);
fprintf('  Fator de Potência Nominal:          %.4f (Placa: %.3f)\n\n', PF_nom, PF_placa);

%% 3. Plotagem Gráfica
fig_visible = 'on';
if ~feature('ShowFigureWindows') || strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
    fig_visible = 'off';
end

fig = figure('Name', 'Item 1.E.iv - Fator de Potência vs Velocidade', ...
             'Color', 'w', 'Position', [100, 100, 850, 520], ...
             'Visible', fig_visible);
ax = axes('Parent', fig);
hold(ax, 'on');

plot(ax, n_vec, PF_vec, 'b-', 'LineWidth', 2.0, ...
    'DisplayName', '\cos\phi (Fator de Pot\^{e}ncia)');

plot(ax, n_nom, PF_nom, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b', ...
    'DisplayName', sprintf('\\cos\\phi_{calc} = %.4f (1715~\\mathrm{rpm})', PF_nom));
plot(ax, n_nom, PF_placa, 'ks', 'MarkerSize', 8, 'MarkerFaceColor', 'k', ...
    'DisplayName', sprintf('\\cos\\phi_{placa} = %.3f (1715~\\mathrm{rpm})', PF_placa));
plot(ax, n_pf_max, PF_max, 'mp', 'MarkerSize', 10, 'MarkerFaceColor', 'm', ...
    'DisplayName', sprintf('\\cos\\phi_{max} = %.4f (%.0f~\\mathrm{rpm})', PF_max, n_pf_max));

grid(ax, 'on'); box(ax, 'on');
set(ax, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax, 'Velocidade do Rotor $n$ [$\mathrm{rpm}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax, 'Fator de Pot\^{e}ncia $\cos\phi$ [-]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax, '\textbf{Curva Caracter\''{\i}stica Fator de Pot\^{e}ncia $\times$ Velocidade}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax, [0, 1800]);
ylim(ax, [0, 1.0]);
legend(ax, 'Location', 'southwest', 'Interpreter', 'latex', 'FontSize', 10);

%% 4. Salvamento
script_dir = fileparts(mfilename('fullpath'));
fig_dir = fullfile(script_dir, 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

savefig(fig, fullfile(fig_dir, 'item1e_fator_potencia_vs_speed.fig'));
exportgraphics(fig, fullfile(fig_dir, 'item1e_fator_potencia_vs_speed.png'), 'Resolution', 300);
fprintf('[OK] Gráfico salvo com sucesso em:\n  %s\n', fullfile(fig_dir, 'item1e_fator_potencia_vs_speed.png'));

if strcmp(fig_visible, 'off'), close(fig); end
