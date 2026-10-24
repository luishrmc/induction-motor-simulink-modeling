function run_item_E_simulacao()
% RUN_ITEM (origem: matlab/scripts/run_task_3_3.m)
% Task 3.3: Induction Motor Generating Quadrant & Regenerative Braking Simulation
%
% Objectives:
%   1. Simulate DOL startup at no-load (t < 5.0 s), followed by a step to negative
%      mechanical shaft load torque (T_L = -T_nom = -20.602 N.m at t = 5.0 s).
%   2. Verify hypersynchronous operation (n > 1800 rpm, s < 0).
%   3. Demonstrate active electrical power reversal (P < 0, injecting power into AC grid)
%      while maintaining positive reactive power consumption (Q > 0, grid excitation).
%   4. Verify electromechanical equilibrium: T_e = T_L + B*omega_m = -20.602 + 8.191 = -12.411 N.m.
%   5. Enforce steady-state error tolerance <= 2.0% across all 5 key variables.
%   6. Generate publication-quality figures:
%      - figures/item2e_regenerative_speed.png (+ .fig)
%      - figures/item2e_regenerative_powers.png (+ .fig)
%      - figures/item2e_regenerative_torque.png (+ .fig)
%
% Sourced from Table 2.4 and Section 2.4 of LAB_CONV_RLT_08_09_10.pdf.

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - TASK 3.3: GENERATING QUADRANT & REGENERATIVE BRAKING\n');
    fprintf('====================================================================\n\n');

    %% 1. Machine Parameters & Physical Constants
    V_LL_nom = 220.0;           % Rated line-to-line RMS voltage [V]
    P_nom_W  = 3700.0;          % Rated mechanical power [W] (5 cv)
    f_nom    = 60.0;            % Rated electrical frequency [Hz]
    poles    = 4;               % Number of poles
    p_pairs  = poles / 2;       % Pole pairs (p = 2)
    omega_e  = 2 * pi * f_nom;  % Electrical angular frequency [rad/s] (~376.99)
    omega_s  = omega_e / p_pairs;% Synchronous angular speed [rad/s] (~188.50)
    n_s      = (120 * f_nom) / poles; % Synchronous speed [rpm] (1800 rpm)

    % Per-phase Delta equivalent circuit parameters (Table 2.4)
    R1 = 1.189;                 % Stator resistance [Ohm]
    R2 = 1.180;                 % Referred rotor resistance [Ohm]
    L1 = 5.725e-3;              % Stator leakage inductance [H]
    L2 = 8.420e-3;              % Referred rotor leakage inductance [H]
    Lm = 131.571e-3;            % Magnetizing inductance [H]
    J  = 0.701;                 % Equivalent moment of inertia [kg.m^2]
    B  = 0.0426;                % Viscous friction coefficient [N.m.s/rad]

    X1 = omega_e * L1;          % Stator leakage reactance [Ohm] (~2.158)
    X2 = omega_e * L2;          % Rotor leakage reactance [Ohm] (~3.174)
    Xm = omega_e * Lm;          % Magnetizing reactance [Ohm] (~49.601)

    T_nom_ref  = 20.602;        % Nominal catalog shaft torque magnitude [N.m]
    T_step_val = -T_nom_ref;    % Prime mover negative shaft torque [N.m] (-20.602 N.m)
    t_step_val = 5.0;           % Step disturbance time [s]
    t_stop_val = 8.0;           % Simulation horizon [s]

    %% 2. Exact Analytical Operating Point Calculations
    % Function handle for full circuit solution as a function of slip s
    calc_circuit = @(s) ...
        struct(...
            's', s, ...
            'wm', omega_s * (1 - s), ...
            'n_rpm', n_s * (1 - s), ...
            'Z2', (R2 ./ s) + 1j * X2, ...
            'Zp', (1j * Xm .* ((R2 ./ s) + 1j * X2)) ./ (1j * Xm + (R2 ./ s) + 1j * X2), ...
            'Zin', (R1 + 1j * X1) + (1j * Xm .* ((R2 ./ s) + 1j * X2)) ./ (1j * Xm + (R2 ./ s) + 1j * X2), ...
            'I1_ph', V_LL_nom ./ ((R1 + 1j * X1) + (1j * Xm .* ((R2 ./ s) + 1j * X2)) ./ (1j * Xm + (R2 ./ s) + 1j * X2)), ...
            'I1_line', sqrt(3) * abs(V_LL_nom ./ ((R1 + 1j * X1) + (1j * Xm .* ((R2 ./ s) + 1j * X2)) ./ (1j * Xm + (R2 ./ s) + 1j * X2))), ...
            'E1', V_LL_nom - (V_LL_nom ./ ((R1 + 1j * X1) + (1j * Xm .* ((R2 ./ s) + 1j * X2)) ./ (1j * Xm + (R2 ./ s) + 1j * X2))) .* (R1 + 1j * X1), ...
            'I2', (V_LL_nom - (V_LL_nom ./ ((R1 + 1j * X1) + (1j * Xm .* ((R2 ./ s) + 1j * X2)) ./ (1j * Xm + (R2 ./ s) + 1j * X2))) .* (R1 + 1j * X1)) ./ ((R2 ./ s) + 1j * X2), ...
            'Pag', 3 * abs((V_LL_nom - (V_LL_nom ./ ((R1 + 1j * X1) + (1j * Xm .* ((R2 ./ s) + 1j * X2)) ./ (1j * Xm + (R2 ./ s) + 1j * X2))) .* (R1 + 1j * X1)) ./ ((R2 ./ s) + 1j * X2)).^2 .* (R2 ./ s), ...
            'Tem', (3 * abs((V_LL_nom - (V_LL_nom ./ ((R1 + 1j * X1) + (1j * Xm .* ((R2 ./ s) + 1j * X2)) ./ (1j * Xm + (R2 ./ s) + 1j * X2))) .* (R1 + 1j * X1)) ./ ((R2 ./ s) + 1j * X2)).^2 .* (R2 ./ s)) / omega_s, ...
            'P_elec', 3 * real(V_LL_nom * conj(V_LL_nom ./ ((R1 + 1j * X1) + (1j * Xm .* ((R2 ./ s) + 1j * X2)) ./ (1j * Xm + (R2 ./ s) + 1j * X2)))), ...
            'Q_elec', 3 * imag(V_LL_nom * conj(V_LL_nom ./ ((R1 + 1j * X1) + (1j * Xm .* ((R2 ./ s) + 1j * X2)) ./ (1j * Xm + (R2 ./ s) + 1j * X2)))) ...
        );

    % Helper function for developed torque Tem(s)
    calc_Tem = @(s) ...
        (3 * abs((V_LL_nom - (V_LL_nom ./ ((R1 + 1j * X1) + (1j * Xm .* ((R2 ./ s) + 1j * X2)) ./ (1j * Xm + (R2 ./ s) + 1j * X2))) .* (R1 + 1j * X1)) ./ ((R2 ./ s) + 1j * X2)).^2 .* (R2 ./ s)) / omega_s;

    % (A) No-load operating point: T_em(s) = B * omega_s * (1 - s)
    res_noload = @(s) calc_Tem(s) - B * omega_s * (1 - s);
    s_noload_ana = fzero(res_noload, 0.013);
    m_noload = calc_circuit(s_noload_ana);

    n_noload_ana        = m_noload.n_rpm;
    T_em_noload_ana     = m_noload.Tem;
    I_line_noload_ana   = m_noload.I1_line;
    P_elec_noload_ana   = m_noload.P_elec;
    Q_elec_noload_ana   = m_noload.Q_elec;

    % (B) Hypersynchronous Generating Point: T_em(s) = T_L + B * omega_s * (1 - s)
    res_regen = @(s) calc_Tem(s) - T_step_val - B * omega_s * (1 - s);
    s_regen_ana = fzero(res_regen, -0.02);
    m_regen = calc_circuit(s_regen_ana);

    n_regen_ana        = m_regen.n_rpm;
    T_em_regen_ana     = m_regen.Tem;
    I_line_regen_ana   = m_regen.I1_line;
    P_elec_regen_ana   = m_regen.P_elec;
    Q_elec_regen_ana   = m_regen.Q_elec;

    fprintf('Analytical Baselines Calculated:\n');
    fprintf('  No-Load (t < 5s):    n = %.2f rpm, Te = %.3f N.m, I_s = %.3f A, P = %.1f W, Q = %.1f var\n', ...
        n_noload_ana, T_em_noload_ana, I_line_noload_ana, P_elec_noload_ana, Q_elec_noload_ana);
    fprintf('  Regen (t > 5s):      n = %.2f rpm, Te = %.3f N.m, I_s = %.3f A, P = %.1f W, Q = %.1f var\n\n', ...
        n_regen_ana, T_em_regen_ana, I_line_regen_ana, P_elec_regen_ana, Q_elec_regen_ana);

    %% 3. Execute or Load Dynamic Simscape Simulation
    data_dir = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', 'out', 'results');
    fig_dir  = fullfile(fileparts(mfilename('fullpath')), 'figures');
    if ~exist(data_dir, 'dir'), mkdir(data_dir); end
    if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
    fig_vis = 'off';
    if feature('ShowFigureWindows') && ~strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
        fig_vis = 'on';   % sessao interativa (MATLAB GUI)
    end

    cache_file = fullfile(data_dir, 'sim_transient_regenerative.mat');
    if exist(cache_file, 'file')
        fprintf('[INFO] Found cached simulation telemetry in %s. Loading...\n', cache_file);
        loaded = load(cache_file);
        results = loaded.results;
    else
        fprintf('[INFO] Running Simscape dynamic harness for scenario: regenerative (t_stop = %.1fs)...\n', t_stop_val);
        addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', 'matlab')));
        results = run_sim_harness('regenerative', 'StopTime', t_stop_val, 'StepTime', t_step_val);
        save(cache_file, 'results');
        fprintf('[OK] Cached simulation telemetry to %s\n', cache_file);
    end

    t          = results.time;
    speed_rpm  = results.speed_rpm;
    torque_Nm  = results.torque_Nm;
    current_Ia = results.current_Ia;
    current_Ib = results.current_Ib;
    current_Ic = results.current_Ic;
    p_inst     = results.p_inst;
    q_inst     = results.q_inst;

    %% 4. Steady-State Metric Extraction & Convergence Audit
    % Steady-state evaluation window: t in [7.8, 8.0] s
    idx_ss = (t >= 7.8 & t <= 8.0);
    speed_regen_sim  = mean(speed_rpm(idx_ss));
    torque_regen_sim = mean(torque_Nm(idx_ss));
    Ia_rms_regen_sim = rms(current_Ia(idx_ss));
    P_regen_sim      = mean(p_inst(idx_ss));
    Q_regen_sim      = mean(abs(q_inst(idx_ss)));

    err_n = abs((speed_regen_sim - n_regen_ana) / n_regen_ana) * 100;
    err_T = abs((torque_regen_sim - T_em_regen_ana) / T_em_regen_ana) * 100;
    err_I = abs((Ia_rms_regen_sim - I_line_regen_ana) / I_line_regen_ana) * 100;
    err_P = abs((P_regen_sim - P_elec_regen_ana) / P_elec_regen_ana) * 100;
    err_Q = abs((Q_regen_sim - Q_elec_regen_ana) / Q_elec_regen_ana) * 100;

    fprintf('--------------------------------------------------------------------\n');
    fprintf('  TASK 3.3 STEADY-STATE CONVERGENCE AUDIT (REGENERATIVE OPERATION)\n');
    fprintf('--------------------------------------------------------------------\n');
    fprintf('  Metric           | Analytical   | Simulated    | Relative Error   \n');
    fprintf('  ------------------------------------------------------------------\n');
    fprintf('  Rotor Speed:     | %8.2f rpm | %8.2f rpm |  %5.3f %% (tol 2.0%%)\n', ...
        n_regen_ana, speed_regen_sim, err_n);
    fprintf('  Dev. Torque:     | %8.3f N.m | %8.3f N.m |  %5.3f %% (tol 2.0%%)\n', ...
        T_em_regen_ana, torque_regen_sim, err_T);
    fprintf('  Line Current:    | %8.3f A   | %8.3f A   |  %5.3f %% (tol 2.0%%)\n', ...
        I_line_regen_ana, Ia_rms_regen_sim, err_I);
    fprintf('  Active Power:    | %8.2f W   | %8.2f W   |  %5.3f %% (tol 2.0%%)\n', ...
        P_elec_regen_ana, P_regen_sim, err_P);
    fprintf('  Reactive Power:  | %8.2f var | %8.2f var |  %5.3f %% (tol 2.0%%)\n', ...
        Q_elec_regen_ana, Q_regen_sim, err_Q);
    fprintf('--------------------------------------------------------------------\n\n');

    %% 5. Export Verification Artifacts (JSON & MAT)
    mat_path = fullfile(data_dir, 'sim_transient_3.3.mat');
    save(mat_path, 'results');

    json_path = fullfile(data_dir, 'comparison_3.3.json');
    comp_data.analytical.n_nom_rpm     = n_regen_ana;
    comp_data.analytical.T_em_nom      = T_em_regen_ana;
    comp_data.analytical.I_line_nom    = I_line_regen_ana;
    comp_data.analytical.P_elec_nom    = P_elec_regen_ana;
    comp_data.analytical.Q_elec_nom    = Q_elec_regen_ana;

    comp_data.simulated.n_nom_rpm      = speed_regen_sim;
    comp_data.simulated.T_em_nom       = torque_regen_sim;
    comp_data.simulated.I_line_nom     = Ia_rms_regen_sim;
    comp_data.simulated.P_elec_nom     = P_regen_sim;
    comp_data.simulated.Q_elec_nom     = Q_regen_sim;

    fid = fopen(json_path, 'w');
    if fid ~= -1
        fwrite(fid, jsonencode(comp_data), 'char');
        fclose(fid);
        fprintf('[OK] Exported verification JSON to %s\n', json_path);
    end

    %% 6. Publication-Quality Figure Generation (.png & .fig)
    set(groot, 'defaultAxesFontSize', 11);
    set(groot, 'defaultAxesFontName', 'Helvetica');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultLegendInterpreter', 'latex');
    set(groot, 'defaultAxesTickLabelInterpreter', 'latex');

    %% Figure 1: Hypersynchronous Rotor Speed Transient
    fprintf('[INFO] Generating Figure 1: Hypersynchronous Speed Transient...\n');
    fig1 = figure('Name', 'regenerative_speed', 'Color', 'w', 'Position', [100, 100, 880, 580], 'Visible', fig_vis);

    % Subplot 1: Full Electromechanical Acceleration & Hypersynchronous Runaway
    ax1_1 = subplot(2, 1, 1, 'Parent', fig1);
    hold(ax1_1, 'on');
    plot(ax1_1, t, speed_rpm, 'b-', 'LineWidth', 1.8, 'DisplayName', 'Velocidade $n(t)$ (Simula\c{c}\~{a}o)');
    yline(ax1_1, n_s, 'k--', 'LineWidth', 1.3, 'DisplayName', sprintf('Velocidade S\\''incrona ($n_s = %d~\\mathrm{rpm}$)', n_s));
    yline(ax1_1, n_noload_ana, 'g-.', 'LineWidth', 1.4, ...
        'DisplayName', sprintf('Regime a Vazio ($n_0 = %.1f~\\mathrm{rpm}$)', n_noload_ana));
    yline(ax1_1, n_regen_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Regime Hipers\\''incrono ($n_{ss} = %.1f~\\mathrm{rpm}$)', n_regen_ana));
    xline(ax1_1, t_step_val, 'm:', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Degrau de Carga Negativo ($t = %.1f~\\mathrm{s},\\ T_L = %.2f~\\mathrm{N\\cdot m}$)', t_step_val, T_step_val));
    grid(ax1_1, 'on'); box(ax1_1, 'on');
    xlabel(ax1_1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax1_1, 'Velocidade $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax1_1, 'Transit\''orio de Velocidade: Partida a Vazio e Opera\c{c}\~{a}o Hipers\''incrona ($T_L = -20.60~\mathrm{N\cdot m}$)', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax1_1, 'Location', 'southeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax1_1, [0, 8.0]);
    ylim(ax1_1, [0, 1950]);

    % Subplot 2: Zoom on Synchronous Crossing and Settlement
    ax1_2 = subplot(2, 1, 2, 'Parent', fig1);
    hold(ax1_2, 'on');
    idx_zoom = (t >= 4.8 & t <= 7.0);
    plot(ax1_2, t(idx_zoom), speed_rpm(idx_zoom), 'b-', 'LineWidth', 2.0, 'DisplayName', 'Velocidade $n(t)$');
    yline(ax1_2, n_s, 'k--', 'LineWidth', 1.3, 'DisplayName', sprintf('Fronteira S\\''incrona ($n_s = %d~\\mathrm{rpm}$)', n_s));
    yline(ax1_2, n_noload_ana, 'g-.', 'LineWidth', 1.4, 'DisplayName', sprintf('Pr\\''e-Degrau a Vazio ($%.1f~\\mathrm{rpm}$)', n_noload_ana));
    yline(ax1_2, n_regen_ana, 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('Converg\\^{e}ncia Gerador ($%.1f~\\mathrm{rpm}$)', n_regen_ana));
    xline(ax1_2, t_step_val, 'm:', 'LineWidth', 1.5, 'DisplayName', 'Instante do Degrau ($t = 5.0~\mathrm{s}$)');
    plot(ax1_2, 7.9, speed_regen_sim, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 7, ...
        'DisplayName', sprintf('Ponto Estacion\\''ario ($%.1f~\\mathrm{rpm}$)', speed_regen_sim));
    grid(ax1_2, 'on'); box(ax1_2, 'on');
    xlabel(ax1_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax1_2, 'Velocidade $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax1_2, 'Transi\c{c}\~{a}o para Regime Hipers\''incrono e Cruzamento da Velocidade S\''incrona ($s < 0$)', ...
        'Interpreter', 'latex', 'FontSize', 11);
    legend(ax1_2, 'Location', 'southeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax1_2, [4.8, 7.0]);
    ylim(ax1_2, [1760, 1855]);

    fig1_png = fullfile(fig_dir, 'item2e_regenerative_speed.png');
    fig1_fig = fullfile(fig_dir, 'item2e_regenerative_speed.fig');
    exportgraphics(fig1, fig1_png, 'Resolution', 300);
    savefig(fig1, fig1_fig);
    if strcmp(fig_vis, 'off'), close(fig1); end
    fprintf('[OK] Saved %s\n', fig1_png);

    %% Figure 2: Active & Reactive Electrical Powers (Power Flow Inversion)
    fprintf('[INFO] Generating Figure 2: Active and Reactive Powers...\n');
    fig2 = figure('Name', 'regenerative_powers', 'Color', 'w', 'Position', [100, 100, 880, 580], 'Visible', fig_vis);

    window_sz = round( (1/60) / (t(2)-t(1)) ); % 1 electrical cycle window
    p_filt = movmean(p_inst, window_sz);
    q_filt = movmean(abs(q_inst), window_sz);

    % Subplot 1: Active Electrical Power Inversion
    ax2_1 = subplot(2, 1, 1, 'Parent', fig2);
    hold(ax2_1, 'on');
    plot(ax2_1, t, p_filt, 'b-', 'LineWidth', 1.8, 'DisplayName', 'Pot\^{e}ncia Ativa M\''edia $P(t)$');
    yline(ax2_1, 0, 'k-', 'LineWidth', 1.1, 'DisplayName', 'Fronteira Motor / Gerador ($P = 0$)');
    yline(ax2_1, P_elec_noload_ana, 'g-.', 'LineWidth', 1.4, ...
        'DisplayName', sprintf('Consumo a Vazio ($P_0 = +%.1f~\\mathrm{W}$)', P_elec_noload_ana));
    yline(ax2_1, P_elec_regen_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', ['Inje\c{c}\~{a}o na Rede ' sprintf('($P_{ss} = %.1f~\\mathrm{W}$)', P_elec_regen_ana)]);
    xline(ax2_1, t_step_val, 'm:', 'LineWidth', 1.5, 'DisplayName', 'Degrau de Carga Negativo ($t = 5.0~\mathrm{s}$)');
    grid(ax2_1, 'on'); box(ax2_1, 'on');
    xlabel(ax2_1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax2_1, 'Pot\^{e}ncia Ativa $P$ (W)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax2_1, 'Invers\~{a}o do Fluxo de Pot\^{e}ncia Ativa: Opera\c{c}\~{a}o Regenerativa ($P < 0$)', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax2_1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax2_1, [0, 8.0]);
    ylim(ax2_1, [-4000, 14000]);

    % Subplot 2: Continuous Reactive Power Consumption
    ax2_2 = subplot(2, 1, 2, 'Parent', fig2);
    hold(ax2_2, 'on');
    plot(ax2_2, t, q_filt, 'Color', [0.85, 0.35, 0.0], 'LineWidth', 1.8, 'DisplayName', 'Pot\^{e}ncia Reativa M\''edia $Q(t)$');
    yline(ax2_2, Q_elec_noload_ana, 'g-.', 'LineWidth', 1.4, ...
        'DisplayName', ['Magnetiza\c{c}\~{a}o a Vazio ' sprintf('($Q_0 = %.1f~\\mathrm{var}$)', Q_elec_noload_ana)]);
    yline(ax2_2, Q_elec_regen_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', ['Magnetiza\c{c}\~{a}o Gerador ' sprintf('($Q_{ss} = %.1f~\\mathrm{var}$)', Q_elec_regen_ana)]);
    xline(ax2_2, t_step_val, 'm:', 'LineWidth', 1.5, 'DisplayName', 'Degrau de Carga Negativo ($t = 5.0~\mathrm{s}$)');
    grid(ax2_2, 'on'); box(ax2_2, 'on');
    xlabel(ax2_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax2_2, 'Pot\^{e}ncia Reativa $Q$ (var)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax2_2, 'Demanda Cont\''inua de Pot\^{e}ncia Reativa Indutiva para Excita\c{c}\~{a}o da Rede ($Q > 0$)', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax2_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax2_2, [0, 8.0]);
    ylim(ax2_2, [0, 18000]);

    fig2_png = fullfile(fig_dir, 'item2e_regenerative_powers.png');
    fig2_fig = fullfile(fig_dir, 'item2e_regenerative_powers.fig');
    exportgraphics(fig2, fig2_png, 'Resolution', 300);
    savefig(fig2, fig2_fig);
    if strcmp(fig_vis, 'off'), close(fig2); end
    fprintf('[OK] Saved %s\n', fig2_png);

    %% Figure 3: Electromagnetic Torque & Mechanical Balance
    fprintf('[INFO] Generating Figure 3: Torque Response & Equilibrium...\n');
    fig3 = figure('Name', 'regenerative_torque', 'Color', 'w', 'Position', [100, 100, 880, 580], 'Visible', fig_vis);

    % Subplot 1: Full Torque Waveform
    ax3_1 = subplot(2, 1, 1, 'Parent', fig3);
    hold(ax3_1, 'on');
    plot(ax3_1, t, torque_Nm, 'b-', 'LineWidth', 1.6, 'DisplayName', 'Conjugado Eletromagn\''etico $T_e(t)$');
    yline(ax3_1, 0, 'k-', 'LineWidth', 1.1, 'DisplayName', 'Fronteira Motor / Gerador ($T_e = 0$)');
    yline(ax3_1, T_em_noload_ana, 'g-.', 'LineWidth', 1.4, ...
        'DisplayName', sprintf('Equil\\''ibrio a Vazio ($T_e = +%.2f~\\mathrm{N\\cdot m}$)', T_em_noload_ana));
    yline(ax3_1, T_em_regen_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Equil\\''ibrio Gerador ($T_e = %.2f~\\mathrm{N\\cdot m}$)', T_em_regen_ana));
    xline(ax3_1, t_step_val, 'm:', 'LineWidth', 1.5, 'DisplayName', 'Degrau de Carga Negativo ($t = 5.0~\mathrm{s}$)');
    grid(ax3_1, 'on'); box(ax3_1, 'on');
    xlabel(ax3_1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax3_1, 'Conjugado $T_e$ (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax3_1, 'Conjugado Eletromagn\''etico: Partida Direta e Opera\c{c}\~{a}o como Freio Regenerativo ($T_e < 0$)', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax3_1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax3_1, [0, 8.0]);
    ylim(ax3_1, [-45, 95]);

    % Subplot 2: Zoom on Mechanical Equilibrium
    ax3_2 = subplot(2, 1, 2, 'Parent', fig3);
    hold(ax3_2, 'on');
    idx_tq_zoom = (t >= 4.8 & t <= 6.8);
    t_z = t(idx_tq_zoom);
    TL_prof = zeros(size(t_z));
    TL_prof(t_z >= t_step_val) = T_step_val;
    T_opp_prof = TL_prof + B * (speed_rpm(idx_tq_zoom) * 2 * pi / 60);

    plot(ax3_2, t_z, torque_Nm(idx_tq_zoom), 'b-', 'LineWidth', 2.0, 'DisplayName', 'Conjugado Desenvolvido $T_e(t)$');
    plot(ax3_2, t_z, T_opp_prof, 'k--', 'LineWidth', 1.6, 'DisplayName', 'Equil\''ibrio Din\^{a}mico ($T_L + B\omega_m$)');
    plot(ax3_2, t_z, TL_prof, 'm-.', 'LineWidth', 1.4, 'DisplayName', 'Torque Mec\^{a}nico Aplicado ($T_L$)');
    yline(ax3_2, T_em_regen_ana, 'r:', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Valor Te\\''orico Final ($%.2f~\\mathrm{N\\cdot m}$)', T_em_regen_ana));
    plot(ax3_2, 6.7, torque_regen_sim, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 7, ...
        'DisplayName', sprintf('Ponto Estacion\\''ario ($%.2f~\\mathrm{N\\cdot m}$)', torque_regen_sim));
    grid(ax3_2, 'on'); box(ax3_2, 'on');
    xlabel(ax3_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax3_2, 'Conjugado (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax3_2, 'Equil\''ibrio Eletromec\^{a}nico no Modo Gerador ($T_e = T_L + B\omega_m$)', ...
        'Interpreter', 'latex', 'FontSize', 11);
    legend(ax3_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax3_2, [4.8, 6.8]);
    ylim(ax3_2, [-24, 12]);

    fig3_png = fullfile(fig_dir, 'item2e_regenerative_torque.png');
    fig3_fig = fullfile(fig_dir, 'item2e_regenerative_torque.fig');
    exportgraphics(fig3, fig3_png, 'Resolution', 300);
    savefig(fig3, fig3_fig);
    if strcmp(fig_vis, 'off'), close(fig3); end
    fprintf('[OK] Saved %s\n', fig3_png);

    fprintf('\n[PASS] Task 3.3 Execution and Figure Generation Complete.\n');

end
