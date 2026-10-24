%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 1: Item E.iii - Curvas de Potência Ativa x Velocidade
% =========================================================================

clearvars -except base_dir; clc;
fprintf('====================================================================\n');
fprintf('  PARTE 1: ITEM E.iii - POTÊNCIA ATIVA x VELOCIDADE                 \n');
fprintf('====================================================================\n\n');

%% 1. Parâmetros da Máquina
V_LL_nom = 220.0; f_nom = 60.0; poles = 4; p_pairs = 2;
P_nom_W = 3700.0; n_nom = 1715.0;
R1 = 1.189; R2_prime = 1.180;
L_l1 = 5.725e-3; L_l2_prime = 8.420e-3; L_m = 131.571e-3;
B = 0.0426;

omega_e = 2 * pi * f_nom;
n_s = 120 * f_nom / poles; % 1800 rpm
X1 = omega_e * L_l1;
X2_prime = omega_e * L_l2_prime;
Xm = omega_e * L_m;

%% 2. Resolução Analítica Vetorizada
N_pts = 1000;
n_vec = linspace(0, n_s - 1e-4, N_pts);
s_vec = (n_s - n_vec) ./ n_s;
omega_m_vec = n_vec .* (2*pi/60);

V_phase = V_LL_nom;
Z1 = R1 + 1j * X1;
Zm = 1j * Xm;
Z2_vec = (R2_prime ./ s_vec) + 1j * X2_prime;
Zp_vec = (Zm .* Z2_vec) ./ (Zm + Z2_vec);
Zin_vec = Z1 + Zp_vec;

I1_ph_vec = V_phase ./ Zin_vec;
E1_vec = V_phase - I1_ph_vec .* Z1;
I2_prime_vec = E1_vec ./ Z2_vec;

P_ag_vec    = 3 .* (abs(I2_prime_vec).^2) .* (R2_prime ./ s_vec);
P_em_vec    = (1 - s_vec) .* P_ag_vec;
P_rot_vec   = B .* (omega_m_vec.^2);
P_shaft_vec = P_em_vec - P_rot_vec;
P_elec_vec  = 3 .* real(V_phase .* conj(I1_ph_vec));

[~, idx_nom] = min(abs(n_vec - n_nom));
P_elec_nom = P_elec_vec(idx_nom);
P_ag_nom   = P_ag_vec(idx_nom);
P_em_nom   = P_em_vec(idx_nom);
P_sh_nom   = P_shaft_vec(idx_nom);

fprintf('  Potência Elétrica Absorvida Nom: %.2f W\n', P_elec_nom);
fprintf('  Potência no Entreferro Nom:      %.2f W\n', P_ag_nom);
fprintf('  Potência Eletromecânica Int Nom: %.2f W\n', P_em_nom);
fprintf('  Potência Útil de Eixo Nom:       %.2f W (Placa: %.1f W)\n\n', P_sh_nom, P_nom_W);

%% 3. Plotagem Gráfica
fig_visible = 'on';
if ~feature('ShowFigureWindows') || strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
    fig_visible = 'off';
end

fig = figure('Name', 'Item 1.E.iii - Potência vs Velocidade', ...
             'Color', 'w', 'Position', [100, 100, 850, 520], ...
             'Visible', fig_visible);
ax = axes('Parent', fig);
hold(ax, 'on');

plot(ax, n_vec, P_elec_vec / 1e3, 'm-', 'LineWidth', 2.0, ...
    'DisplayName', 'P_{elec} (Pot\^{e}ncia El\''{e}trica de Entrada)');
plot(ax, n_vec, P_ag_vec / 1e3, 'b-', 'LineWidth', 1.8, ...
    'DisplayName', 'P_{ag} (Pot\^{e}ncia do Entreferro)');
plot(ax, n_vec, P_em_vec / 1e3, 'g-', 'LineWidth', 1.8, ...
    'DisplayName', 'P_{em} (Pot\^{e}ncia Eletromec\^{a}nica Convertida)');
plot(ax, n_vec, P_shaft_vec / 1e3, 'r--', 'LineWidth', 1.8, ...
    'DisplayName', 'P_{shaft} (Pot\^{e}ncia \''{U}til no Eixo)');

plot(ax, n_nom, P_sh_nom / 1e3, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', ...
    'DisplayName', sprintf('P_{sh,nom} = %.2f~\\mathrm{kW} (1715~\\mathrm{rpm})', P_sh_nom / 1e3));
plot(ax, n_nom, P_nom_W / 1e3, 'ks', 'MarkerSize', 8, 'MarkerFaceColor', 'k', ...
    'DisplayName', sprintf('P_{placa} = %.2f~\\mathrm{kW} (5~\\mathrm{cv})', P_nom_W / 1e3));

grid(ax, 'on'); box(ax, 'on');
set(ax, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax, 'Velocidade do Rotor $n$ [$\mathrm{rpm}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax, 'Pot\^{e}ncia Ativa [$\mathrm{kW}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax, '\textbf{Curvas Caracter\''{\i}sticas de Pot\^{e}ncia Ativa $\times$ Velocidade}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax, [0, 1800]);
ylim(ax, [0, max(P_elec_vec / 1e3) * 1.1]);
legend(ax, 'Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 10);

%% 4. Salvamento
script_dir = fileparts(mfilename('fullpath'));
fig_dir = fullfile(script_dir, 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

savefig(fig, fullfile(fig_dir, 'item1e_potencia_vs_speed.fig'));
exportgraphics(fig, fullfile(fig_dir, 'item1e_potencia_vs_speed.png'), 'Resolution', 300);
fprintf('[OK] Gráfico salvo com sucesso em:\n  %s\n', fullfile(fig_dir, 'item1e_potencia_vs_speed.png'));

if strcmp(fig_visible, 'off'), close(fig); end
