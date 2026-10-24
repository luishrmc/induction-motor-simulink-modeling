%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 1: Item F - Família de Curvas de Controle Escalar V/f Constante
% =========================================================================
%  Este script executa:
%    1. Resolução analítica vetorizada da máquina sob controle escalar V/f
%       constante para 4 patamares de frequência e tensão:
%         - 100%: 220 V, 60 Hz (n_s = 1800 rpm)
%         -  75%: 165 V, 45 Hz (n_s = 1350 rpm)
%         -  50%: 110 V, 30 Hz (n_s =  900 rpm)
%         -  25%:  55 V, 15 Hz (n_s =  450 rpm)
%    2. Identificação do ponto de conjugado máximo (Tmax) em cada patamar.
%    3. Plotagem conjunta das 4 curvas no mesmo gráfico com marcadores.
%    4. Salvamento de artefatos em alta resolução (.fig e .png).
% =========================================================================

clear; clc;
fprintf('====================================================================\n');
fprintf('  PARTE 1: ITEM F - CONTROLE ESCALAR V/f CONSTANTE (100, 75, 50, 25%%) \n');
fprintf('====================================================================\n\n');

%% 1. Parâmetros de Placa e Circuito Equivalente a 60 Hz
V_nom = 220.0; f_nom = 60.0; poles = 4; p_pairs = 2;
R1 = 1.189; R2_prime = 1.180;
L_l1 = 5.725e-3; L_l2_prime = 8.420e-3; L_m = 131.571e-3;

levels = [1.00, 0.75, 0.50, 0.25];
colors = {'#0072BD', '#77AC30', '#D95319', '#7E2F8E'};
names  = {'100% (220 V, 60 Hz)', '75% (165 V, 45 Hz)', ...
          '50% (110 V, 30 Hz)', '25% (55 V, 15 Hz)'};

fig_visible = 'on';
if ~feature('ShowFigureWindows') || strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
    fig_visible = 'off';
end

fig = figure('Name', 'Item 1.F - Família de Curvas Escalares V/f', ...
             'Color', 'w', 'Position', [100, 100, 900, 550], ...
             'Visible', fig_visible);
ax = axes('Parent', fig);
hold(ax, 'on');

%% 2. Varredura Vetorizada para cada Frequência
T_max_list = zeros(1, 4);
n_max_list = zeros(1, 4);

for k = 1:length(levels)
    pct = levels(k);
    f_k = f_nom * pct;
    V_k = V_nom * pct;
    
    omega_e_k = 2 * pi * f_k;
    omega_s_k = omega_e_k / p_pairs;
    n_s_k     = 120 * f_k / poles;
    
    X1_k = omega_e_k * L_l1;
    X2_k = omega_e_k * L_l2_prime;
    Xm_k = omega_e_k * L_m;
    
    N_pts = 1000;
    n_k_vec = linspace(0, n_s_k - 1e-4, N_pts);
    s_k_vec = (n_s_k - n_k_vec) ./ n_s_k;
    
    Z1_k = R1 + 1j * X1_k;
    Zm_k = 1j * Xm_k;
    Z2_k_vec = (R2_prime ./ s_k_vec) + 1j * X2_k;
    Zp_k_vec = (Zm_k .* Z2_k_vec) ./ (Zm_k + Z2_k_vec);
    Zin_k_vec = Z1_k + Zp_k_vec;
    
    I1_k_vec = V_k ./ Zin_k_vec;
    E1_k_vec = V_k - I1_k_vec .* Z1_k;
    I2_k_vec = E1_k_vec ./ Z2_k_vec;
    
    P_ag_k_vec = 3 .* (abs(I2_k_vec).^2) .* (R2_prime ./ s_k_vec);
    T_em_k_vec = P_ag_k_vec ./ omega_s_k;
    
    [T_max_k, idx_max_k] = max(T_em_k_vec);
    n_max_k = n_k_vec(idx_max_k);
    T_max_list(k) = T_max_k;
    n_max_list(k) = n_max_k;
    
    plot(ax, n_k_vec, T_em_k_vec, 'LineStyle', '-', 'Color', colors{k}, ...
        'LineWidth', 2.0, 'DisplayName', names{k});
    plot(ax, n_max_k, T_max_k, 'o', 'MarkerSize', 7, 'MarkerFaceColor', colors{k}, ...
        'Color', 'k', 'HandleVisibility', 'off');
    
    fprintf('  Nível %.0f%% (%.0f V, %.0f Hz): n_s = %.0f rpm | Tmax = %.2f N.m em %.1f rpm\n', ...
        pct*100, V_k, f_k, n_s_k, T_max_k, n_max_k);
end

grid(ax, 'on'); box(ax, 'on');
set(ax, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax, 'Velocidade do Rotor $n$ [$\mathrm{rpm}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax, 'Conjugado Eletromagn\^{e}tico $T_{em}$ [$\mathrm{N\cdot m}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax, '\textbf{Fam\''{\i}lia de Curvas de Controle Escalar $V/f = \mathrm{cte}$ (WEG 3,7~$\mathrm{kW}$)}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax, [0, 1850]);
ylim(ax, [0, 65]);
legend(ax, 'Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 10);

%% 3. Salvamento de Artefatos
script_dir = fileparts(mfilename('fullpath'));
fig_dir = fullfile(script_dir, 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

savefig(fig, fullfile(fig_dir, 'item1f_vf_scalar_family.fig'));
exportgraphics(fig, fullfile(fig_dir, 'item1f_vf_scalar_family.png'), 'Resolution', 300);
fprintf('\n[OK] Gráfico salvo com sucesso em:\n  %s\n', fullfile(fig_dir, 'item1f_vf_scalar_family.png'));

if strcmp(fig_visible, 'off'), close(fig); end
