% =========================================================================
%  UFMG ELE035 - Parte 1, Item F: Familia de curvas V/f constante
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
% Figure 6: Scalar V/f Family Curves (100%, 75%, 50%, 25%)
% -------------------------------------------------------------
f6 = figure('Name', 'Scalar V/f Control Family', 'Visible', fig_vis, 'Position', [100, 100, 880, 560]);
colors = [0.00, 0.45, 0.74;   % Blue (100%)
          0.85, 0.33, 0.10;   % Orange (75%)
          0.47, 0.67, 0.19;   % Green (50%)
          0.49, 0.18, 0.56];  % Purple (25%)
scales = [1.00, 0.75, 0.50, 0.25];
vf_data = struct();

hold on;
for idx = 1:length(scales)
    k = scales(idx);
    V_k = k * V_LL_nom;
    f_k = k * f_nom;
    omega_e_k = 2 * pi * f_k;
    omega_s_k = omega_e_k / p_pairs;
    n_s_k     = 120 * f_k / poles;

    X1_k = omega_e_k * L1;
    X2_k = omega_e_k * L2;
    Xm_k = omega_e_k * Lm;

    n_k = linspace(0, n_s_k - 1e-4, 500);
    s_k = (n_s_k - n_k) ./ n_s_k;

    Z1_k = R1 + 1j * X1_k;
    Zm_k = 1j * Xm_k;
    Z2_k = (R2 ./ s_k) + 1j * X2_k;
    Zp_k = (Zm_k .* Z2_k) ./ (Zm_k + Z2_k);
    Zin_k = Z1_k + Zp_k;

    I1_ph_k = V_k ./ Zin_k;
    E1_k    = V_k - I1_ph_k .* Z1_k;
    I2_k    = E1_k ./ Z2_k;
    Pag_k   = 3 .* (abs(I2_k).^2) .* (R2 ./ s_k);
    Tem_k   = Pag_k ./ omega_s_k;

    % Thevenin breakdown for this frequency
    Vth_k = V_k * (1j * Xm_k) / (R1 + 1j * (X1_k + Xm_k));
    Zth_k = (Z1_k * Zm_k) / (Z1_k + Zm_k);
    Rth_k = real(Zth_k);
    Xth_k = imag(Zth_k);
    s_max_k = R2 / sqrt(Rth_k^2 + (Xth_k + X2_k)^2);
    T_max_k = (3 / (2 * omega_s_k)) * (abs(Vth_k)^2) / (Rth_k + sqrt(Rth_k^2 + (Xth_k + X2_k)^2));
    n_Tmax_k = n_s_k * (1 - s_max_k);

    % Plot curve
    lbl = sprintf('$%d\\,\\%%$ ($V=%.0f$ V, $f=%.0f$ Hz, $n_s=%.0f$ rpm)', ...
        round(k*100), V_k, f_k, n_s_k);
    plot(n_k, Tem_k, '-', 'Color', colors(idx,:), 'LineWidth', 2.0, 'DisplayName', lbl);

    % Mark breakdown torque
    plot(n_Tmax_k, T_max_k, 'o', 'Color', colors(idx,:), 'MarkerFaceColor', colors(idx,:), ...
        'MarkerSize', 7, 'HandleVisibility', 'off');

    % Vertical dashed line for synchronous speed
    xline(n_s_k, ':', 'Color', colors(idx,:), 'LineWidth', 1.2, 'HandleVisibility', 'off');

    % Store in structure
    field_name = sprintf('scale_%d', round(k*100));
    vf_data.(field_name).k = k;
    vf_data.(field_name).V = V_k;
    vf_data.(field_name).f = f_k;
    vf_data.(field_name).n_s = n_s_k;
    vf_data.(field_name).n = n_k;
    vf_data.(field_name).T_em = Tem_k;
    vf_data.(field_name).T_max = T_max_k;
    vf_data.(field_name).n_at_Tmax = n_Tmax_k;
end

% Annotate nominal operating point on 100% curve
plot(n_nom, T_em_nom_pt, 'ks', 'MarkerFaceColor', 'y', 'MarkerSize', 8, ...
    'DisplayName', sprintf('Ponto Nominal ($1715$ rpm, $%.2f$ N$\\cdot$m)', T_em_nom_pt));

% Dummy marker for legend breakdown torque representation
plot(NaN, NaN, 'ko', 'MarkerFaceColor', [0.4 0.4 0.4], 'MarkerSize', 7, ...
    'DisplayName', 'Torques M\''aximos $T_{max}$');

grid on; grid minor; box on;
xlabel('Velocidade Mec\^{a}nica $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Conjugado Eletromagn\''etico $T_{em}$ (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 12);
title('Fam\''ilia de Curvas de Controle Escalar $V/f = \mathrm{cte}$ ($100\%, 75\%, 50\%, 25\%$)', ...
      'Interpreter', 'latex', 'FontSize', 13);
xlim([0, 1850]);
ylim([0, 72]);
legend('Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 9.5);
p6 = fullfile(fig_dir, 'item1f_vf_scalar_family.png');
exportgraphics(f6, p6, 'Resolution', 300);
savefig(f6, fullfile(fig_dir, 'item1f_vf_scalar_family.fig'));
if strcmp(fig_vis, 'off'), close(f6); end
fprintf('[OK] Generated: %s\n', p6);
