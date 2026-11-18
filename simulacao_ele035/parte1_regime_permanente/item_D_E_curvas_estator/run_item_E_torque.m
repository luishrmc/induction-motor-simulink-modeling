% =========================================================================
%  UFMG ELE035 - Parte 1, Item E.i: Conjugado x Velocidade
%  Origem: matlab/analytical/plot_steady_state_curves.m (formatacao preservada)
% =========================================================================
clearvars -except base_dir; clc;

%% 1. Load Centralized Machine Parameters (utils/data/04_Mecanicos.csv & 05_Resumo_Circuito.csv)
addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..'));
p = parametros_motor();

V_LL_nom  = p.V_LL_nom;
f_nom     = p.f_nom;
poles     = p.poles;
p_pairs   = p.p_pairs;
P_nom_W   = p.P_nom_W;
I_nom_A   = p.I_nom_A;
n_nom     = p.n_nom;
pf_plate  = p.pf_plate;
eta_plate = p.eta_plate;

R1 = p.R1;
R2 = p.R2;
L1 = p.L1;
L2 = p.L2;
Lm = p.Lm;
B  = p.B;

omega_e   = p.omega_e;
omega_s   = p.omega_s;
n_s       = p.n_s;
s_nom     = p.s_nom;
omega_nom = p.omega_nom;
T_nom_ref = p.T_nom_ref;

X1 = p.X1;
X2 = p.X2;
Xm = p.Xm;


%% 2. Diretorio de saida e modo de exibicao
fig_dir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
fig_vis = 'off';
if feature('ShowFigureWindows') && ~strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
    fig_vis = 'on';   % sessao interativa (MATLAB GUI)
end

%% 3. Resolucao analitica vetorizada (0 a n_s)
%% 3. Nominal Full-Speed Vectorized Calculation (0 to n_s)
N_pts = 1000;
% Speed sweep vector from 0 to synchronous speed (avoid s = 0 division by small epsilon)
n_vec = linspace(0, n_s - 1e-4, N_pts);
s_vec = (n_s - n_vec) ./ n_s;
omega_m_vec = n_vec .* (2 * pi / 60);

% Pure vectorized equivalent circuit calculations
V_phase = V_LL_nom;                          % Delta connection: V_ph = V_LL
Z1 = R1 + 1j * X1;
Zm = 1j * Xm;
Z2_vec = (R2 ./ s_vec) + 1j * X2;

% Parallel branch: Zp = (Zm .* Z2) ./ (Zm + Z2)
Zp_vec = (Zm .* Z2_vec) ./ (Zm + Z2_vec);
Zin_vec = Z1 + Zp_vec;

% Currents
I1_ph_vec   = V_phase ./ Zin_vec;
I1_line_vec = sqrt(3) .* abs(I1_ph_vec);
E1_vec      = V_phase - I1_ph_vec .* Z1;
I2_vec      = E1_vec ./ Z2_vec;

% Powers
P_ag_vec    = 3 .* (abs(I2_vec).^2) .* (R2 ./ s_vec);
P_em_vec    = (1 - s_vec) .* P_ag_vec;
P_elec_vec  = 3 .* real(V_phase .* conj(I1_ph_vec));
Q_elec_vec  = 3 .* imag(V_phase .* conj(I1_ph_vec));
S_elec_vec  = 3 .* V_phase .* abs(I1_ph_vec);
cos_phi_vec = P_elec_vec ./ S_elec_vec;

% Mechanical and shaft metrics
P_rot_vec   = B .* (omega_m_vec.^2);
P_shaft_vec = P_em_vec - P_rot_vec;
T_em_vec    = P_ag_vec ./ omega_s;
T_shaft_vec = T_em_vec - B .* omega_m_vec;

% Efficiencies (bounded to physical 0-100% range)
eta_em_vec    = max(P_em_vec, 0) ./ P_elec_vec;
eta_shaft_vec = max(P_shaft_vec, 0) ./ P_elec_vec;

% Thevenin breakdown calculations
V_th = V_phase * (1j * Xm) / (R1 + 1j * (X1 + Xm));
Z_th = (Z1 * Zm) / (Z1 + Zm);
R_th = real(Z_th);
X_th = imag(Z_th);
s_max = R2 / sqrt(R_th^2 + (X_th + X2)^2);
n_at_Tmax = n_s * (1 - s_max);
T_max = (3 / (2 * omega_s)) * (abs(V_th)^2) / (R_th + sqrt(R_th^2 + (X_th + X2)^2));

% Interpolate values at nominal speed (n = 1715 rpm)
T_em_nom_pt    = interp1(n_vec, T_em_vec, n_nom);
T_shaft_nom_pt = interp1(n_vec, T_shaft_vec, n_nom);
I_line_nom_pt  = interp1(n_vec, I1_line_vec, n_nom);
cos_phi_nom_pt = interp1(n_vec, cos_phi_vec, n_nom);
P_elec_nom_pt  = interp1(n_vec, P_elec_vec, n_nom);
P_shaft_nom_pt = interp1(n_vec, P_shaft_vec, n_nom);
eta_em_nom_pt  = interp1(n_vec, eta_em_vec, n_nom);
eta_shaft_nom_pt = interp1(n_vec, eta_shaft_vec, n_nom);

%% 4. Figura (formatacao original)
set(groot, 'defaultAxesFontSize', 11);
set(groot, 'defaultAxesFontName', 'Helvetica');
set(groot, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');

% -------------------------------------------------------------
% Figure 1: Torque vs. Speed (T x n)
% -------------------------------------------------------------
f1 = figure('Name', 'Torque vs Speed', 'Visible', fig_vis, 'Position', [100, 100, 850, 540]);
plot(n_vec, T_em_vec, 'b-', 'LineWidth', 2.0, 'DisplayName', 'Conjugado Eletromagn\''etico $T_{em}$');
hold on;
plot(n_vec, T_shaft_vec, 'r--', 'LineWidth', 1.8, 'DisplayName', 'Conjugado \''Util no Eixo $T_{shaft}$');
% Mark nominal operating points
plot(n_nom, T_em_nom_pt, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 7, ...
    'DisplayName', ['Ponto Nominal ' sprintf('($T_{em} = %.2f~\\mathrm{N\\cdot m}$)', T_em_nom_pt)]);
plot(n_nom, T_shaft_nom_pt, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7, ...
    'DisplayName', ['Ponto Nominal ' sprintf('($T_{shaft} = %.2f~\\mathrm{N\\cdot m}$)', T_shaft_nom_pt)]);
plot(n_nom, T_nom_ref, 'ks', 'MarkerFaceColor', 'y', 'MarkerSize', 8, ...
    'DisplayName', ['Refer\^{e}ncia de Placa ' sprintf('($T_n = %.2f~\\mathrm{N\\cdot m}$)', T_nom_ref)]);
% Mark breakdown torque
plot(n_at_Tmax, T_max, 'kp', 'MarkerFaceColor', 'm', 'MarkerSize', 11, ...
    'DisplayName', ['Torque M\''aximo ' sprintf('($T_{max} = %.2f~\\mathrm{N\\cdot m}$, $%.0f~\\mathrm{rpm}$)', T_max, n_at_Tmax)]);
% Mark starting torque
plot(0, T_em_vec(1), 'kd', 'MarkerFaceColor', 'c', 'MarkerSize', 8, ...
    'DisplayName', ['Partida ' sprintf('($T_{part} = %.2f~\\mathrm{N\\cdot m}$)', T_em_vec(1))]);
grid on; grid minor; box on;
xlabel('Velocidade Mec\^{a}nica $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Conjugado ($\mathrm{N\cdot m}$)', 'Interpreter', 'latex', 'FontSize', 12);
title('Curva Caracter\''istica Conjugado $\times$ Velocidade ($220~\mathrm{V}$, $60~\mathrm{Hz}$)', ...
      'Interpreter', 'latex', 'FontSize', 13);
xlim([0, 1850]);
ylim([0, 70]);
legend('Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 9.5);
p1 = fullfile(fig_dir, 'item1e_torque_vs_speed.png');
exportgraphics(f1, p1, 'Resolution', 300);
savefig(f1, fullfile(fig_dir, 'item1e_torque_vs_speed.fig'));
if strcmp(fig_vis, 'off'), close(f1); end
fprintf('[OK] Generated: %s\n', p1);
