%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 1: Item E.i - Curva Característica Conjugado x Velocidade
% =========================================================================
%  Este script autônomo executa:
%    1. Carregamento dos parâmetros consolidados da máquina WEG 3.7 kW (5 cv).
%    2. Resolução analítica 100% vetorizada do circuito equivalente IEEE
%       para varredura contínua de velocidade (0 a 1800 rpm).
%    3. Cálculo do conjugado eletromagnético (Tem) e do conjugado útil no
%       eixo (Tshaft = Tem - B*omega_m), identificando Tmax e Tpartida.
%    4. Plotagem de alta resolução no MATLAB GUI com exportação de .fig e .png.
% =========================================================================

clearvars -except base_dir; clc;
fprintf('====================================================================\n');
fprintf('  PARTE 1: ITEM E.i - CONJUGADO x VELOCIDADE (WEG 3.7 kW)           \n');
fprintf('====================================================================\n\n');

%% 1. Parâmetros da Máquina e da Bancada (Tabela 2.4 e Seção 2.4)
V_LL_nom = 220.0;           % Tensão de linha nominal [V] (Triângulo)
f_nom    = 60.0;            % Frequência nominal [Hz]
poles    = 4;               % 4 polos (p = 2 pares)
p_pairs  = poles / 2;
P_nom_W  = 3700.0;          % Potência nominal de placa [W] (5 cv)
n_nom    = 1715.0;          % Velocidade nominal [rpm]

R1       = 1.189;           % Resistência do estator [Ohm]
R2_prime = 1.180;           % Resistência do rotor referida [Ohm]
L_l1     = 5.725e-3;        % Indutância de dispersão do estator [H]
L_l2_prime = 8.420e-3;      % Indutância de dispersão do rotor [H]
L_m      = 131.571e-3;      % Indutância de magnetização [H]
B        = 0.0426;          % Coeficiente de atrito viscoso da bancada [N.m.s/rad]

omega_e  = 2 * pi * f_nom;
omega_s  = omega_e / p_pairs;       % 188.496 rad/s
n_s      = 120 * f_nom / poles;     % 1800 rpm
X1       = omega_e * L_l1;          % 2.1583 Ohm
X2_prime = omega_e * L_l2_prime;    % 3.1743 Ohm
Xm       = omega_e * L_m;           % 49.6013 Ohm

omega_nom = n_nom * (2*pi/60);
T_nom_ref = P_nom_W / omega_nom;    % 20.602 N.m

%% 2. Resolução Analítica Vetorizada (0 a n_s)
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

I1_ph_vec   = V_phase ./ Zin_vec;
E1_vec      = V_phase - I1_ph_vec .* Z1;
I2_prime_vec= E1_vec ./ Z2_vec;

P_ag_vec    = 3 .* (abs(I2_prime_vec).^2) .* (R2_prime ./ s_vec);
T_em_vec    = P_ag_vec ./ omega_s;
T_rot_vec   = B .* omega_m_vec;
T_shaft_vec = T_em_vec - T_rot_vec;

% Identificação dos pontos notáveis
[T_max, idx_max] = max(T_em_vec);
n_max = n_vec(idx_max);
s_max = s_vec(idx_max);
T_start = T_em_vec(1);

% Ponto nominal (n = 1715 rpm)
[~, idx_nom] = min(abs(n_vec - n_nom));
T_em_nom = T_em_vec(idx_nom);
T_sh_nom = T_shaft_vec(idx_nom);

fprintf('  Conjugado Máximo (Tmax):       %.2f N.m em %.1f rpm (s = %.4f)\n', T_max, n_max, s_max);
fprintf('  Relação Tmax / Tn:             %.2f\n', T_max / T_nom_ref);
fprintf('  Conjugado de Partida (s=1):    %.2f N.m\n', T_start);
fprintf('  Conjugado Eletromagnético Nom: %.2f N.m (em %d rpm)\n', T_em_nom, n_nom);
fprintf('  Conjugado Útil no Eixo Nom:    %.2f N.m\n\n', T_sh_nom);

%% 3. Plotagem Gráfica de Alta Resolução
fig_visible = 'on';
if ~feature('ShowFigureWindows') || strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
    fig_visible = 'off';
end

fig = figure('Name', 'Item 1.E.i - Conjugado vs Velocidade', ...
             'Color', 'w', 'Position', [100, 100, 850, 520], ...
             'Visible', fig_visible);
ax = axes('Parent', fig);
hold(ax, 'on');

plot(ax, n_vec, T_em_vec, 'b-', 'LineWidth', 2.0, ...
    'DisplayName', 'T_{em} (Conjugado Eletromagn\^{e}tico)');
plot(ax, n_vec, T_shaft_vec, 'r--', 'LineWidth', 1.8, ...
    'DisplayName', 'T_{shaft} (Conjugado no Eixo: T_{em} - B\omega_m)');

% Marcadores de pontos notáveis
plot(ax, n_max, T_max, 'kp', 'MarkerSize', 12, 'MarkerFaceColor', 'y', ...
    'DisplayName', sprintf('T_{max} = %.2f~\\mathrm{N\\cdot m} (%.0f~\\mathrm{rpm})', T_max, n_max));
plot(ax, n_nom, T_em_nom, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b', ...
    'DisplayName', sprintf('T_{em,nom} = %.2f~\\mathrm{N\\cdot m} (1715~\\mathrm{rpm})', T_em_nom));
plot(ax, n_nom, T_nom_ref, 'rs', 'MarkerSize', 8, 'MarkerFaceColor', 'r', ...
    'DisplayName', sprintf('T_{n,placa} = %.2f~\\mathrm{N\\cdot m} (1715~\\mathrm{rpm})', T_nom_ref));
plot(ax, 0, T_start, 'm^', 'MarkerSize', 8, 'MarkerFaceColor', 'm', ...
    'DisplayName', sprintf('T_{partida} = %.2f~\\mathrm{N\\cdot m} (s=1)', T_start));

grid(ax, 'on');
box(ax, 'on');
set(ax, 'FontSize', 11, 'TickLabelInterpreter', 'latex', 'XMinorGrid', 'on', 'YMinorGrid', 'on');
xlabel(ax, 'Velocidade do Rotor $n$ [$\mathrm{rpm}$]', 'Interpreter', 'latex', 'FontSize', 12);
ylabel(ax, 'Conjugado $T$ [$\mathrm{N\cdot m}$]', 'Interpreter', 'latex', 'FontSize', 12);
title(ax, '\textbf{Curva Caracter\''{\i}stica Conjugado $\times$ Velocidade (WEG 3,7~$\mathrm{kW}$)}', ...
    'Interpreter', 'latex', 'FontSize', 13);
xlim(ax, [0, 1800]);
ylim(ax, [0, max(T_max * 1.15, 65)]);

legend(ax, 'Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 10);

%% 4. Salvamento de Artefatos (.fig e .png)
script_dir = fileparts(mfilename('fullpath'));
fig_dir = fullfile(script_dir, 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

savefig(fig, fullfile(fig_dir, 'item1e_torque_vs_speed.fig'));
exportgraphics(fig, fullfile(fig_dir, 'item1e_torque_vs_speed.png'), 'Resolution', 300);
fprintf('[OK] Gráfico salvo com sucesso em:\n  %s\n', fullfile(fig_dir, 'item1e_torque_vs_speed.png'));

if strcmp(fig_visible, 'off')
    close(fig);
end
