% =========================================================================
%  UFMG ELE035 - Parte 1, Item E.iii: Potencia Ativa x Velocidade
%  Origem: matlab/analytical/plot_steady_state_curves.m (formatacao preservada)
% =========================================================================
clearvars -except base_dir; clc;

%% 1. Machine Parameters (Table 2.4 and Section 2.4 of Lab Report)
V_LL_nom = 220.0;           % Rated line RMS voltage [V]
f_nom    = 60.0;            % Rated frequency [Hz]
poles    = 4;               % Poles
p_pairs  = poles / 2;       % Pole pairs (p = 2)
P_nom_W  = 3700.0;          % Rated power [W] (5 cv)
I_nom_A  = 14.0;            % Rated line current [A RMS]
n_nom    = 1715.0;          % Rated speed [rpm]
pf_plate = 0.81;            % Nameplate power factor
eta_plate= 0.855;           % Nameplate efficiency

R1 = 1.189;                 % Stator resistance [Ohm]
R2 = 1.180;                 % Referred rotor resistance [Ohm]
L1 = 5.725e-3;              % Stator leakage inductance [H]
L2 = 8.420e-3;              % Referred rotor leakage inductance [H]
Lm = 131.571e-3;            % Magnetizing inductance [H]
% J = 0.701;                % Total inertia [kg.m^2] (used in dynamic simulation)
B = 0.0426;                 % Viscous friction coefficient [N.m.s/rad]

omega_e = 2 * pi * f_nom;
omega_s = omega_e / p_pairs;
n_s     = 120 * f_nom / poles;       % 1800 rpm
s_nom   = (n_s - n_nom) / n_s;
omega_nom = (1 - s_nom) * omega_s;
T_nom_ref = P_nom_W / omega_nom;

X1 = omega_e * L1;
X2 = omega_e * L2;
Xm = omega_e * Lm;


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

% -------------------------------------------------------------
% Figure 3: Active Power vs. Speed (Pa x n)
% -------------------------------------------------------------
f3 = figure('Name', 'Power vs Speed', 'Visible', fig_vis, 'Position', [100, 100, 850, 540]);
plot(n_vec, P_elec_vec ./ 1000, 'b-', 'LineWidth', 2.0, 'DisplayName', 'Pot\^{e}ncia Ativa El\''etrica $P_{elec}$ (kW)');
hold on;
plot(n_vec, P_ag_vec ./ 1000, 'g-.', 'LineWidth', 1.8, 'DisplayName', 'Pot\^{e}ncia de Entreferro $P_{ag}$ (kW)');
plot(n_vec, P_em_vec ./ 1000, 'm--', 'LineWidth', 1.8, 'DisplayName', 'Pot\^{e}ncia Eletromec\^{a}nica $P_{em}$ (kW)');
plot(n_vec, P_shaft_vec ./ 1000, 'r-', 'LineWidth', 2.0, 'DisplayName', 'Pot\^{e}ncia \''Util de Eixo $P_{shaft}$ (kW)');
plot(n_nom, P_elec_nom_pt / 1000, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 7, ...
    'DisplayName', sprintf('Nominal $P_{elec} = %.2f$ kW', P_elec_nom_pt/1000));
plot(n_nom, P_shaft_nom_pt / 1000, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7, ...
    'DisplayName', sprintf('Nominal $P_{shaft} = %.2f$ kW', P_shaft_nom_pt/1000));
plot(n_nom, P_nom_W / 1000, 'ks', 'MarkerFaceColor', 'y', 'MarkerSize', 8, ...
    'DisplayName', sprintf('Pot\\^{e}ncia Nominal de Placa $P_n = %.1f$ kW', P_nom_W/1000));
grid on; grid minor; box on;
xlabel('Velocidade Mec\^{a}nica $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Pot\^{e}ncia Ativa (kW)', 'Interpreter', 'latex', 'FontSize', 12);
title('Pot\^{e}ncia Ativa $\times$ Velocidade ($220\ \mathrm{V},\ 60\ \mathrm{Hz}$)', ...
      'Interpreter', 'latex', 'FontSize', 13);
xlim([0, 1850]);
ylim([0, max(P_elec_vec)/1000 * 1.25]);
legend('Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 9.5);
p3 = fullfile(fig_dir, 'item1e_potencia_vs_speed.png');
exportgraphics(f3, p3, 'Resolution', 300);
savefig(f3, fullfile(fig_dir, 'item1e_potencia_vs_speed.fig'));
if strcmp(fig_vis, 'off'), close(f3); end
fprintf('[OK] Generated: %s\n', p3);
