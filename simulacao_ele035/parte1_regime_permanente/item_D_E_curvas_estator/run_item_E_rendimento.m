%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 1: Item E.v - Curvas de Rendimento x Velocidade
% =========================================================================

clearvars -except base_dir; clc;
fprintf('====================================================================\n');
fprintf('  PARTE 1: ITEM E.v - RENDIMENTO x VELOCIDADE                       \n');
fprintf('====================================================================\n\n');

%% 1. Parâmetros da Máquina
V_LL_nom = 220.0; f_nom = 60.0; poles = 4; p_pairs = 2;
eta_placa = 85.5; n_nom = 1715.0;
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

eta_em_vec    = max(0, (P_em_vec ./ P_elec_vec) .* 100);
eta_shaft_vec = max(0, (P_shaft_vec ./ P_elec_vec) .* 100);

[~, idx_nom] = min(abs(n_vec - n_nom));
eta_em_nom = eta_em_vec(idx_nom);
eta_sh_nom = eta_shaft_vec(idx_nom);

[eta_em_max, idx_em_max] = max(eta_em_vec);
n_em_max = n_vec(idx_em_max);

[eta_sh_max, idx_sh_max] = max(eta_shaft_vec);
n_sh_max = n_vec(idx_sh_max);

fprintf('  Rendimento Eletromagnético Nominal: %.2f%% (Placa: %.1f%%)\n', eta_em_nom, eta_placa);
fprintf('  Rendimento Global no Eixo Nominal:  %.2f%%\n', eta_sh_nom);
fprintf('  Pico de Rendimento Eletromagnético: %.2f%% em %.0f rpm\n', eta_em_max, n_em_max);
fprintf('  Pico de Rendimento no Eixo:         %.2f%% em %.0f rpm\n\n', eta_sh_max, n_sh_max);

%% 3. Plotagem Gráfica
fig_visible = 'on';
if ~feature('ShowFigureWindows') || strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
    fig_visible = 'off';
end

fig = figure('Name', 'Item 1.E.v - Rendimento vs Velocidade', ...
             'Color', 'w', 'Position', [100, 100, 850, 520], ...
             'Visible', fig_visible);
ax = axes('Parent', fig);
hold(ax, 'on');

plot(ax, n_vec, eta_em_vec, 'b-', 'LineWidth', 2.0, ...
    'DisplayName', '\eta_{em} (Rendimento Eletromagn\^{e}tico Interno: P_{em}/P_{elec})');
plot(ax, n_vec, eta_shaft_vec, 'r--', 'LineWidth', 1.8, ...
    'DisplayName', '\eta_{shaft} (Rendimento no Eixo com Bancada CC: P_{shaft}/P_{elec})');

plot(ax, n_nom, eta_em_nom, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b', ...
    'DisplayName', sprintf('\\eta_{em,nom} = %.2f\\%% (1715~\\mathrm{rpm})', eta_em_nom));
plot(ax, n_nom, eta_placa, 'ks', 'MarkerSize', 8, 'MarkerFaceColor', 'k', ...
    'DisplayName', sprintf('\\eta_{placa} = %.1f\\%% (1715~\\mathrm{rpm})', eta_placa));
plot(ax, n_nom, eta_sh_nom, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', ...
    'DisplayName', sprintf('\\eta_{shaft,nom} = %.2f\\%% (1715~\\mathrm{rpm})', eta_sh_nom));

grid(ax, 'on'); box(ax, 'on');
set(ax, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax, 'Velocidade do Rotor $n$ [$\mathrm{rpm}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax, 'Rendimento $\eta$ [$\%$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax, '\textbf{Curvas Caracter\''{\i}sticas de Rendimento $\times$ Velocidade}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax, [0, 1800]);
ylim(ax, [0, 100]);
legend(ax, 'Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 10);

%% 4. Salvamento
script_dir = fileparts(mfilename('fullpath'));
fig_dir = fullfile(script_dir, 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

savefig(fig, fullfile(fig_dir, 'item1e_rendimento_vs_speed.fig'));
exportgraphics(fig, fullfile(fig_dir, 'item1e_rendimento_vs_speed.png'), 'Resolution', 300);
fprintf('[OK] Gráfico salvo com sucesso em:\n  %s\n', fullfile(fig_dir, 'item1e_rendimento_vs_speed.png'));

if strcmp(fig_visible, 'off'), close(fig); end
