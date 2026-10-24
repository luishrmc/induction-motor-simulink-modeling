function curves = plot_steady_state_curves()
% PLOT_STEADY_STATE_CURVES
% Vectorized computation and publication-quality visualization of
% steady-state characteristics and scalar V/f control family for the
% WEG 3.7 kW (5 cv), 220 V Delta, 4-pole, 60 Hz squirrel-cage induction motor.
%
% Generates 6 high-resolution figures in out/figures/:
%   1. torque_vs_speed.png        - T_em and T_shaft vs speed (0 to 1800 rpm)
%   2. current_vs_speed.png       - Line and phase currents vs speed
%   3. power_vs_speed.png         - Electrical, airgap, and shaft powers vs speed
%   4. power_factor_vs_speed.png  - cos(phi) vs speed
%   5. efficiency_vs_speed.png    - Electromagnetic and shaft efficiencies vs speed
%   6. vf_scalar_family.png       - Scalar V/f control family (100%, 75%, 50%, 25%)
%
% Adheres to ADR-001 (Consolidated Lab Parameters), ADR-003 (Pure Vectorization),
% and figure-production skill standards.

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - INDUCTION MOTOR STEADY-STATE SWEEPS & V/f CONTROL   \n');
    fprintf('  Task 1.2: Full-Speed Characteristics & Scalar V/f Curve Family   \n');
    fprintf('====================================================================\n\n');

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

    %% 2. Output Directories Configuration
    script_dir = fileparts(mfilename('fullpath'));
    fig_dir = fullfile(script_dir, '..', '..', 'out', 'figures');
    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir);
    end

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

    %% 4. Publication-Quality Figures Generation
    set(groot, 'defaultAxesFontSize', 11);
    set(groot, 'defaultAxesFontName', 'Helvetica');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultLegendInterpreter', 'latex');

    % -------------------------------------------------------------
    % Figure 1: Torque vs. Speed (T x n)
    % -------------------------------------------------------------
    f1 = figure('Name', 'Torque vs Speed', 'Visible', 'off', 'Position', [100, 100, 850, 540]);
    plot(n_vec, T_em_vec, 'b-', 'LineWidth', 2.0, 'DisplayName', 'Conjugado Eletromagn\''etico $T_{em}$');
    hold on;
    plot(n_vec, T_shaft_vec, 'r--', 'LineWidth', 1.8, 'DisplayName', 'Conjugado \''Util no Eixo $T_{shaft}$');
    % Mark nominal operating points
    plot(n_nom, T_em_nom_pt, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 7, ...
        'DisplayName', sprintf('Ponto Nominal $T_{em} = %.2f$ N$\\cdot$m', T_em_nom_pt));
    plot(n_nom, T_shaft_nom_pt, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7, ...
        'DisplayName', sprintf('Ponto Nominal $T_{shaft} = %.2f$ N$\\cdot$m', T_shaft_nom_pt));
    plot(n_nom, T_nom_ref, 'ks', 'MarkerFaceColor', 'y', 'MarkerSize', 8, ...
        'DisplayName', sprintf('Refer\\^{e}ncia Placa $T_n = %.2f$ N$\\cdot$m', T_nom_ref));
    % Mark breakdown torque
    plot(n_at_Tmax, T_max, 'kp', 'MarkerFaceColor', 'm', 'MarkerSize', 11, ...
        'DisplayName', sprintf('Torque M\''aximo $T_{max} = %.2f$ N$\\cdot$m ($%.0f$ rpm)', T_max, n_at_Tmax));
    % Mark starting torque
    plot(0, T_em_vec(1), 'kd', 'MarkerFaceColor', 'c', 'MarkerSize', 8, ...
        'DisplayName', sprintf('Partida $T_{part} = %.2f$ N$\\cdot$m', T_em_vec(1)));
    grid on; grid minor; box on;
    xlabel('Velocidade Mec\^{a}nica $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('Conjugado (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 12);
    title('Curva Caracter\''istica Conjugado $\times$ Velocidade ($220\ \mathrm{V},\ 60\ \mathrm{Hz}$)', ...
          'Interpreter', 'latex', 'FontSize', 13);
    xlim([0, 1850]);
    ylim([0, 70]);
    legend('Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 9.5);
    p1 = fullfile(fig_dir, 'torque_vs_speed.png');
    exportgraphics(f1, p1, 'Resolution', 300);
    close(f1);
    fprintf('[OK] Generated: %s\n', p1);

    % -------------------------------------------------------------
    % Figure 2: Current vs. Speed (Is x n)
    % -------------------------------------------------------------
    f2 = figure('Name', 'Current vs Speed', 'Visible', 'off', 'Position', [100, 100, 850, 540]);
    plot(n_vec, I1_line_vec, 'r-', 'LineWidth', 2.0, 'DisplayName', 'Corrente de Linha $I_{line}$ (RMS)');
    hold on;
    plot(n_vec, abs(I1_ph_vec), 'b--', 'LineWidth', 1.8, 'DisplayName', 'Corrente de Fase $I_{\phi}$ (RMS)');
    plot(n_nom, I_line_nom_pt, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7, ...
        'DisplayName', sprintf('Nominal Calculado $I_{line} = %.2f$ A', I_line_nom_pt));
    plot(n_nom, I_nom_A, 'ks', 'MarkerFaceColor', 'y', 'MarkerSize', 8, ...
        'DisplayName', sprintf('Corrente Nominal de Placa $I_n = %.1f$ A', I_nom_A));
    plot(0, I1_line_vec(1), 'kd', 'MarkerFaceColor', 'm', 'MarkerSize', 8, ...
        'DisplayName', sprintf('Corrente de Partida $I_{part} = %.2f$ A', I1_line_vec(1)));
    grid on; grid minor; box on;
    xlabel('Velocidade Mec\^{a}nica $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('Corrente Estat\''orica RMS (A)', 'Interpreter', 'latex', 'FontSize', 12);
    title('Corrente Estat\''orica $\times$ Velocidade ($220\ \mathrm{V},\ 60\ \mathrm{Hz}$)', ...
          'Interpreter', 'latex', 'FontSize', 13);
    xlim([0, 1850]);
    ylim([0, max(I1_line_vec) * 1.15]);
    legend('Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 10);
    p2 = fullfile(fig_dir, 'current_vs_speed.png');
    exportgraphics(f2, p2, 'Resolution', 300);
    close(f2);
    fprintf('[OK] Generated: %s\n', p2);

    % -------------------------------------------------------------
    % Figure 3: Active Power vs. Speed (Pa x n)
    % -------------------------------------------------------------
    f3 = figure('Name', 'Power vs Speed', 'Visible', 'off', 'Position', [100, 100, 850, 540]);
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
    p3 = fullfile(fig_dir, 'power_vs_speed.png');
    exportgraphics(f3, p3, 'Resolution', 300);
    close(f3);
    fprintf('[OK] Generated: %s\n', p3);

    % -------------------------------------------------------------
    % Figure 4: Power Factor vs. Speed (cos phi x n)
    % -------------------------------------------------------------
    f4 = figure('Name', 'Power Factor vs Speed', 'Visible', 'off', 'Position', [100, 100, 850, 540]);
    plot(n_vec, cos_phi_vec, 'k-', 'LineWidth', 2.0, 'DisplayName', 'Fator de Pot\^{e}ncia $\cos\phi$');
    hold on;
    plot(n_nom, cos_phi_nom_pt, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8, ...
        'DisplayName', sprintf('Nominal Calculado $\\cos\\phi = %.4f$', cos_phi_nom_pt));
    plot(n_nom, pf_plate, 'bs', 'MarkerFaceColor', 'y', 'MarkerSize', 8, ...
        'DisplayName', sprintf('Fator de Pot\\^{e}ncia de Placa $\\cos\\phi = %.2f$', pf_plate));
    grid on; grid minor; box on;
    xlabel('Velocidade Mec\^{a}nica $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('Fator de Pot\^{e}ncia $\cos\phi$ (-)', 'Interpreter', 'latex', 'FontSize', 12);
    title('Fator de Pot\^{e}ncia $\times$ Velocidade ($220\ \mathrm{V},\ 60\ \mathrm{Hz}$)', ...
          'Interpreter', 'latex', 'FontSize', 13);
    xlim([0, 1850]);
    ylim([0, 1.05]);
    legend('Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 10);
    p4 = fullfile(fig_dir, 'power_factor_vs_speed.png');
    exportgraphics(f4, p4, 'Resolution', 300);
    close(f4);
    fprintf('[OK] Generated: %s\n', p4);

    % -------------------------------------------------------------
    % Figure 5: Efficiency vs. Speed (eta x n)
    % -------------------------------------------------------------
    f5 = figure('Name', 'Efficiency vs Speed', 'Visible', 'off', 'Position', [100, 100, 850, 540]);
    plot(n_vec, eta_em_vec .* 100, 'b-', 'LineWidth', 2.0, ...
        'DisplayName', 'Rendimento Eletromagn\''etico $\eta_{em} = P_{em}/P_{elec}$');
    hold on;
    plot(n_vec, eta_shaft_vec .* 100, 'r--', 'LineWidth', 2.0, ...
        'DisplayName', 'Rendimento \''Util no Eixo $\eta_{shaft} = P_{shaft}/P_{elec}$');
    plot(n_nom, eta_em_nom_pt * 100, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 7, ...
        'DisplayName', sprintf('Nominal $\\eta_{em} = %.2f\\,\\%%$', eta_em_nom_pt*100));
    plot(n_nom, eta_shaft_nom_pt * 100, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7, ...
        'DisplayName', sprintf('Nominal $\\eta_{shaft} = %.2f\\,\\%%$', eta_shaft_nom_pt*100));
    plot(n_nom, eta_plate * 100, 'ks', 'MarkerFaceColor', 'y', 'MarkerSize', 8, ...
        'DisplayName', sprintf('Rendimento de Placa $\\eta_{nom} = %.1f\\,\\%%$', eta_plate*100));
    grid on; grid minor; box on;
    xlabel('Velocidade Mec\^{a}nica $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('Rendimento (\%)', 'Interpreter', 'latex', 'FontSize', 12);
    title('Rendimento $\times$ Velocidade ($220\ \mathrm{V},\ 60\ \mathrm{Hz}$)', ...
          'Interpreter', 'latex', 'FontSize', 13);
    xlim([0, 1850]);
    ylim([0, 105]);
    legend('Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 9.5);
    p5 = fullfile(fig_dir, 'efficiency_vs_speed.png');
    exportgraphics(f5, p5, 'Resolution', 300);
    close(f5);
    fprintf('[OK] Generated: %s\n', p5);

    % -------------------------------------------------------------
    % Figure 6: Scalar V/f Family Curves (100%, 75%, 50%, 25%)
    % -------------------------------------------------------------
    f6 = figure('Name', 'Scalar V/f Control Family', 'Visible', 'off', 'Position', [100, 100, 880, 560]);
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
    p6 = fullfile(fig_dir, 'vf_scalar_family.png');
    exportgraphics(f6, p6, 'Resolution', 300);
    close(f6);
    fprintf('[OK] Generated: %s\n', p6);

    %% 5. Package Return Structure
    curves.nominal_sweep.n_vec       = n_vec;
    curves.nominal_sweep.s_vec       = s_vec;
    curves.nominal_sweep.T_em        = T_em_vec;
    curves.nominal_sweep.T_shaft     = T_shaft_vec;
    curves.nominal_sweep.I1_line     = I1_line_vec;
    curves.nominal_sweep.I1_ph       = abs(I1_ph_vec);
    curves.nominal_sweep.P_elec      = P_elec_vec;
    curves.nominal_sweep.Q_elec      = Q_elec_vec;
    curves.nominal_sweep.P_ag        = P_ag_vec;
    curves.nominal_sweep.P_em        = P_em_vec;
    curves.nominal_sweep.P_shaft     = P_shaft_vec;
    curves.nominal_sweep.cos_phi     = cos_phi_vec;
    curves.nominal_sweep.eta_em      = eta_em_vec;
    curves.nominal_sweep.eta_shaft   = eta_shaft_vec;
    curves.nominal_sweep.T_max       = T_max;
    curves.nominal_sweep.s_max       = s_max;
    curves.nominal_sweep.n_at_Tmax   = n_at_Tmax;
    curves.vf_family                 = vf_data;

    fprintf('\n[OK] All 6 publication-quality figures successfully generated in %s\n', fig_dir);

end
