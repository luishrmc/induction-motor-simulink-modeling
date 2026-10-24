function results = run_item_D_simulacao()
% RUN_ITEM (origem: matlab/scripts/run_task_3_2.m)
% Execution, validation, and visualization script for Task 3.2:
% Simulation of Step Nominal Load Torque Disturbance & Convergence Audit.
%
% Scenario:
%   - Standstill start at t = 0 s (w0 = 0, n0 = 0) with zero load (T_L = 0).
%   - Motor accelerates under J = 0.701 kg.m^2 to no-load steady state (~1775 rpm).
%   - At t = 5.0 s, full nominal load torque step disturbance is applied (T_L = +20.602 N.m).
%   - Motor decelerates and converges to loaded steady state (~1700 rpm) by t = 8.0 s.
%
% Deliverables:
%   - out/results/sim_transient_3.2.mat
%   - out/results/comparison_3.2.json
%   - figures/item2d_step_load_speed.png (+ .fig)
%   - figures/item2d_step_load_current.png (+ .fig)
%   - figures/item2d_step_load_powers.png (+ .fig)
%   - figures/item2d_step_load_torque.png (+ .fig)
%
% Adheres to:
%   - sim_proj.pdf Part 2 Academic Specifications
%   - ADR-001 (Consolidated Lab Parameters)
%   - ADR-002 (Star-Delta Parameter Transformation)
%   - ADR-004 (Tolerance Gate Verification <= 2.0%)
%   - .agents/skills/figure-production/SKILL.md (Publication Quality Plotting)

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - TASK 3.2: STEP NOMINAL LOAD TORQUE & CONVERGENCE    \n');
    fprintf('====================================================================\n\n');

    %% 1. Initialize Paths & Output Directories
    proj_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
    addpath(genpath(fullfile(proj_root, 'matlab')));

    fig_dir = fullfile(fileparts(mfilename('fullpath')), 'figures');
    res_dir = fullfile(proj_root, 'out', 'results');
    if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
    fig_vis = 'off';
    if feature('ShowFigureWindows') && ~strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
        fig_vis = 'on';   % sessao interativa (MATLAB GUI)
    end
    if ~exist(res_dir, 'dir'), mkdir(res_dir); end

    %% 2. Run / Load Dynamic Simulation (t_stop = 8.0 s, t_step = 5.0 s)
    % 8.0 s ensures complete electromechanical settlement before and after step
    mat_step = fullfile(res_dir, 'sim_transient_nominal_step.mat');
    if exist(mat_step, 'file')
        fprintf('[INFO] Found existing simulation telemetry in %s. Loading...\n', mat_step);
        tmp = load(mat_step);
        results = tmp.results;
    else
        fprintf('[INFO] Executing Simscape simulation harness for nominal_step...\n');
        results = run_sim_harness('nominal_step', 'StepTime', 5.0, 'StopTime', 8.0);
    end

    t          = results.time;
    speed_rpm  = results.speed_rpm;
    torque_Nm  = results.torque_Nm;
    current_Ia = results.current_Ia;
    current_Ib = results.current_Ib;
    current_Ic = results.current_Ic;
    p_inst     = results.p_inst;
    q_inst     = results.q_inst;

    t_step_val = results.t_step;
    T_step_val = results.T_step_val;

    %% 3. Calculate Exact Analytical Operating Points
    % Parameters (Table 2.4 and Section 2.4)
    V_LL_nom = 220.0;
    f_nom    = 60.0;
    omega_s  = 2 * pi * f_nom / 2; % 188.4956 rad/s (4 poles)
    n_s      = 1800.0;
    R1       = 1.189;
    R2_prime = 1.180;
    X1       = 2.158;
    X2_prime = 3.174;
    Xm       = 49.601;
    B        = 0.0426;

    % Analytical function for developed torque as a function of slip
    Z1 = R1 + 1j*X1;
    calc_Tem = @(s) 3 * (V_LL_nom / abs(Z1 + (1j*Xm * (R2_prime./s + 1j*X2_prime)) ./ (1j*Xm + R2_prime./s + 1j*X2_prime)))^2 ...
                    * real((1j*Xm * (R2_prime./s + 1j*X2_prime)) ./ (1j*Xm + R2_prime./s + 1j*X2_prime) - 1j*X1) / omega_s;

    % Precise T_em formula using standard IEEE T-circuit:
    calc_Tem_exact = @(s) (3 / omega_s) * ...
        (abs( (1j*Xm ./ (R1 + 1j*(X1 + Xm))) * V_LL_nom )^2 * (R2_prime./s)) ./ ...
        ( (real( (1j*Xm * (R1 + 1j*X1)) / (R1 + 1j*(X1 + Xm)) ) + R2_prime./s).^2 + ...
          (imag( (1j*Xm * (R1 + 1j*X1)) / (R1 + 1j*(X1 + Xm)) ) + X2_prime).^2 );

    % Exact steady-state equilibrium at loaded condition: T_em(s) = T_L + B*omega_s*(1-s)
    obj_fun_load = @(s) calc_Tem_exact(s) - (T_step_val + B * omega_s * (1 - s));
    s_loaded_ana = fzero(obj_fun_load, 0.05);
    n_loaded_ana = n_s * (1 - s_loaded_ana);
    omega_m_loaded_ana = omega_s * (1 - s_loaded_ana);
    T_em_loaded_ana = calc_Tem_exact(s_loaded_ana);

    % Analytical impedance and electrical powers at loaded slip
    Z2_loaded = R2_prime / s_loaded_ana + 1j*X2_prime;
    Zp_loaded = (1j*Xm * Z2_loaded) / (1j*Xm + Z2_loaded);
    Zin_loaded = Z1 + Zp_loaded;
    I_ph_loaded_ana = V_LL_nom / abs(Zin_loaded);
    I_line_loaded_ana = sqrt(3) * I_ph_loaded_ana;
    phi_loaded_ana = angle(Zin_loaded);
    P_elec_loaded_ana = sqrt(3) * V_LL_nom * I_line_loaded_ana * cos(phi_loaded_ana);
    Q_elec_loaded_ana = sqrt(3) * V_LL_nom * I_line_loaded_ana * sin(phi_loaded_ana);

    % Pre-step no-load operating point
    obj_fun_noload = @(s) calc_Tem_exact(s) - B * omega_s * (1 - s);
    s_noload_ana = fzero(obj_fun_noload, 0.01);
    n_noload_ana = n_s * (1 - s_noload_ana);
    T_em_noload_ana = calc_Tem_exact(s_noload_ana);
    Z2_noload = R2_prime / s_noload_ana + 1j*X2_prime;
    Zp_noload = (1j*Xm * Z2_noload) / (1j*Xm + Z2_noload);
    Zin_noload = Z1 + Zp_noload;
    I_line_noload_ana = sqrt(3) * (V_LL_nom / abs(Zin_noload));
    phi_noload_ana = angle(Zin_noload);
    P_elec_noload_ana = sqrt(3) * V_LL_nom * I_line_noload_ana * cos(phi_noload_ana);
    Q_elec_noload_ana = sqrt(3) * V_LL_nom * I_line_noload_ana * sin(phi_noload_ana);

    %% 4. Extract Simulation Steady-State Metrics
    % Pre-step no-load window: 4.8 to 5.0 s
    idx_pre = (t >= 4.8 & t <= 5.0);
    n_noload_sim   = mean(speed_rpm(idx_pre));
    T_em_noload_sim= mean(torque_Nm(idx_pre));
    I_line_noload_sim = rms(current_Ia(idx_pre));
    P_noload_sim   = mean(p_inst(idx_pre));
    Q_noload_sim   = abs(mean(q_inst(idx_pre)));

    % Post-step loaded window: 7.8 to 8.0 s
    idx_post = (t >= 7.8 & t <= 8.0);
    n_loaded_sim   = mean(speed_rpm(idx_post));
    T_em_loaded_sim= mean(torque_Nm(idx_post));
    I_line_loaded_sim = rms(current_Ia(idx_post));
    P_loaded_sim   = mean(p_inst(idx_post));
    Q_loaded_sim   = abs(mean(q_inst(idx_post)));

    % Relative errors for loaded steady-state convergence
    err_n = abs(n_loaded_sim - n_loaded_ana) / n_loaded_ana * 100;
    err_T = abs(T_em_loaded_sim - T_em_loaded_ana) / T_em_loaded_ana * 100;
    err_I = abs(I_line_loaded_sim - I_line_loaded_ana) / I_line_loaded_ana * 100;
    err_P = abs(P_loaded_sim - P_elec_loaded_ana) / P_elec_loaded_ana * 100;
    err_Q = abs(Q_loaded_sim - Q_elec_loaded_ana) / Q_elec_loaded_ana * 100;

    fprintf('--------------------------------------------------------------------\n');
    fprintf('  TASK 3.2 STEADY-STATE CONVERGENCE AUDIT (LOADED OPERATION)\n');
    fprintf('--------------------------------------------------------------------\n');
    fprintf('  Metric           | Analytical   | Simulated    | Relative Error   \n');
    fprintf('  ------------------------------------------------------------------\n');
    fprintf('  Rotor Speed:     | %8.2f rpm | %8.2f rpm | %6.3f %% (tol 2.0%%)\n', n_loaded_ana, n_loaded_sim, err_n);
    fprintf('  Dev. Torque:     | %8.3f N.m | %8.3f N.m | %6.3f %% (tol 2.0%%)\n', T_em_loaded_ana, T_em_loaded_sim, err_T);
    fprintf('  Line Current:    | %8.3f A   | %8.3f A   | %6.3f %% (tol 2.0%%)\n', I_line_loaded_ana, I_line_loaded_sim, err_I);
    fprintf('  Active Power:    | %8.2f W   | %8.2f W   | %6.3f %% (tol 2.0%%)\n', P_elec_loaded_ana, P_loaded_sim, err_P);
    fprintf('  Reactive Power:  | %8.2f var | %8.2f var | %6.3f %% (tol 2.0%%)\n', Q_elec_loaded_ana, Q_loaded_sim, err_Q);
    fprintf('--------------------------------------------------------------------\n\n');

    %% 5. Export Deliverable Artifacts (MAT & JSON)
    mat_path = fullfile(res_dir, 'sim_transient_3.2.mat');
    save(mat_path, 'results', 'n_loaded_ana', 'T_em_loaded_ana', 'I_line_loaded_ana', ...
                   'P_elec_loaded_ana', 'Q_elec_loaded_ana', 'n_loaded_sim', ...
                   'T_em_loaded_sim', 'I_line_loaded_sim', 'P_loaded_sim', 'Q_loaded_sim');

    json_path = fullfile(res_dir, 'comparison_3.2.json');
    comp_data.analytical.n_nom_rpm  = n_loaded_ana;
    comp_data.analytical.T_em_nom   = T_em_loaded_ana;
    comp_data.analytical.I_line_nom = I_line_loaded_ana;
    comp_data.analytical.P_elec_nom = P_elec_loaded_ana;
    comp_data.analytical.Q_elec_nom = Q_elec_loaded_ana;

    comp_data.simulated.n_nom_rpm   = n_loaded_sim;
    comp_data.simulated.T_em_nom    = T_em_loaded_sim;
    comp_data.simulated.I_line_nom  = I_line_loaded_sim;
    comp_data.simulated.P_elec_nom  = P_loaded_sim;
    comp_data.simulated.Q_elec_nom  = Q_loaded_sim;

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

    %% Figure 1: Rotor Speed Droop Transient
    fprintf('[INFO] Generating Figure 1: Rotor Speed Transient...\n');
    fig1 = figure('Name', 'step_load_speed', 'Color', 'w', 'Position', [100, 100, 880, 580], 'Visible', fig_vis);
    
    % Subplot 1: Full Electromechanical Acceleration & Droop
    ax1_1 = subplot(2, 1, 1, 'Parent', fig1);
    hold(ax1_1, 'on');
    plot(ax1_1, t, speed_rpm, 'b-', 'LineWidth', 1.8, 'DisplayName', 'Velocidade $n(t)$ (Simula\c{c}\~{a}o)');
    yline(ax1_1, n_s, 'k--', 'LineWidth', 1.2, 'DisplayName', sprintf('Velocidade S\\''incrona ($n_s = %d~\\mathrm{rpm}$)', n_s));
    yline(ax1_1, n_noload_ana, 'g-.', 'LineWidth', 1.4, ...
        'DisplayName', sprintf('Regime a Vazio ($n_0 = %.1f~\\mathrm{rpm}$)', n_noload_ana));
    yline(ax1_1, n_loaded_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Regime com Carga ($n_{ss} = %.1f~\\mathrm{rpm}$)', n_loaded_ana));
    xline(ax1_1, t_step_val, 'm:', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Degrau de Carga ($t = %.1f~\\mathrm{s},\\ T_L = %.2f~\\mathrm{N\\cdot m}$)', t_step_val, T_step_val));
    grid(ax1_1, 'on'); box(ax1_1, 'on');
    xlabel(ax1_1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax1_1, 'Velocidade $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax1_1, 'Transit\''orio de Velocidade: Partida a Vazio e Degrau de Torque Nominal ($T_L = 20.60~\mathrm{N\cdot m}$)', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax1_1, 'Location', 'southeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax1_1, [0, 8.0]);
    ylim(ax1_1, [0, 1950]);

    % Subplot 2: Zoom on Step Disturbance & Recovery
    ax1_2 = subplot(2, 1, 2, 'Parent', fig1);
    hold(ax1_2, 'on');
    idx_zoom = (t >= 4.8 & t <= 7.0);
    plot(ax1_2, t(idx_zoom), speed_rpm(idx_zoom), 'b-', 'LineWidth', 2.0, 'DisplayName', 'Velocidade $n(t)$');
    yline(ax1_2, n_noload_ana, 'g-.', 'LineWidth', 1.4, 'DisplayName', sprintf('Pr\\''e-Degrau a Vazio ($%.1f~\\mathrm{rpm}$)', n_noload_ana));
    yline(ax1_2, n_loaded_ana, 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('Converg\\^{e}ncia sob Carga ($%.1f~\\mathrm{rpm}$)', n_loaded_ana));
    xline(ax1_2, t_step_val, 'm:', 'LineWidth', 1.5, 'DisplayName', 'Instante do Degrau ($t = 5.0~\mathrm{s}$)');
    plot(ax1_2, 7.9, n_loaded_sim, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 7, ...
        'DisplayName', sprintf('Ponto Estacion\\''ario ($%.1f~\\mathrm{rpm}$)', n_loaded_sim));
    grid(ax1_2, 'on'); box(ax1_2, 'on');
    xlabel(ax1_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax1_2, 'Velocidade $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax1_2, 'Detalhe da Transi\c{c}\~{a}o Din\^{a}mica do Degrau de Carga ($4.8 \le t \le 7.0~\mathrm{s}$)', ...
        'Interpreter', 'latex', 'FontSize', 11);
    legend(ax1_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax1_2, [4.8, 7.0]);
    ylim(ax1_2, [1680, 1790]);

    fig1_png = fullfile(fig_dir, 'item2d_step_load_speed.png');
    fig1_fig = fullfile(fig_dir, 'item2d_step_load_speed.fig');
    exportgraphics(fig1, fig1_png, 'Resolution', 300);
    savefig(fig1, fig1_fig);
    if strcmp(fig_vis, 'off'), close(fig1); end
    fprintf('[OK] Saved %s\n', fig1_png);

    %% Figure 2: Stator Line Current Transition
    fprintf('[INFO] Generating Figure 2: Stator Current Transient...\n');
    fig2 = figure('Name', 'step_load_current', 'Color', 'w', 'Position', [100, 100, 880, 580], 'Visible', fig_vis);
    
    % Subplot 1: Full Current Envelope
    ax2_1 = subplot(2, 1, 1, 'Parent', fig2);
    hold(ax2_1, 'on');
    plot(ax2_1, t, current_Ia, 'Color', [0.75, 0.75, 0.85], 'LineWidth', 0.8, 'DisplayName', 'Corrente Instant\^{a}nea $i_{as}(t)$');
    xline(ax2_1, t_step_val, 'm:', 'LineWidth', 1.5, 'DisplayName', 'Degrau de Carga ($t = 5.0~\mathrm{s}$)');
    yline(ax2_1, sqrt(2)*I_line_noload_ana, 'g-.', 'LineWidth', 1.3, ...
        'DisplayName', sprintf('Pico a Vazio ($\\pm %.1f~\\mathrm{A}$)', sqrt(2)*I_line_noload_ana));
    yline(ax2_1, -sqrt(2)*I_line_noload_ana, 'g-.', 'LineWidth', 1.3, 'HandleVisibility', 'off');
    yline(ax2_1, sqrt(2)*I_line_loaded_ana, 'r--', 'LineWidth', 1.4, ...
        'DisplayName', sprintf('Pico com Carga ($\\pm %.1f~\\mathrm{A},\\ I_{rms} = %.2f~\\mathrm{A}$)', ...
        sqrt(2)*I_line_loaded_ana, I_line_loaded_ana));
    yline(ax2_1, -sqrt(2)*I_line_loaded_ana, 'r--', 'LineWidth', 1.4, 'HandleVisibility', 'off');
    grid(ax2_1, 'on'); box(ax2_1, 'on');
    xlabel(ax2_1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax2_1, 'Corrente de Linha $i_{as}$ (A)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax2_1, 'Evolu\c{c}\~{a}o da Corrente Estat\''orica: Partida Direta, Regime a Vazio e Degrau de Carga', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax2_1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax2_1, [0, 8.0]);
    ylim(ax2_1, [-140, 140]);

    % Subplot 2: Zoom on 3-Phase Current Expansion at Step Transition
    ax2_2 = subplot(2, 1, 2, 'Parent', fig2);
    hold(ax2_2, 'on');
    idx_cur_zoom = (t >= 4.90 & t <= 5.25);
    plot(ax2_2, t(idx_cur_zoom), current_Ia(idx_cur_zoom), 'b-', 'LineWidth', 1.4, 'DisplayName', 'Fase A ($i_{as}$)');
    plot(ax2_2, t(idx_cur_zoom), current_Ib(idx_cur_zoom), 'r--', 'LineWidth', 1.4, 'DisplayName', 'Fase B ($i_{bs}$)');
    plot(ax2_2, t(idx_cur_zoom), current_Ic(idx_cur_zoom), 'Color', [0, 0.6, 0.2], 'LineWidth', 1.4, 'DisplayName', 'Fase C ($i_{cs}$)');
    xline(ax2_2, t_step_val, 'm:', 'LineWidth', 1.8, 'DisplayName', 'Instante do Degrau ($t = 5.0~\mathrm{s}$)');
    grid(ax2_2, 'on'); box(ax2_2, 'on');
    xlabel(ax2_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax2_2, 'Correntes Trif\''asicas (A)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax2_2, 'Expans\~{a}o Trif\''asica das Correntes no Degrau de Carga ($4.90 \le t \le 5.25~\mathrm{s}$)', ...
        'Interpreter', 'latex', 'FontSize', 11);
    legend(ax2_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax2_2, [4.90, 5.25]);
    ylim(ax2_2, [-35, 35]);

    fig2_png = fullfile(fig_dir, 'item2d_step_load_current.png');
    fig2_fig = fullfile(fig_dir, 'item2d_step_load_current.fig');
    exportgraphics(fig2, fig2_png, 'Resolution', 300);
    savefig(fig2, fig2_fig);
    if strcmp(fig_vis, 'off'), close(fig2); end
    fprintf('[OK] Saved %s\n', fig2_png);

    %% Figure 3: Active and Reactive Electrical Powers
    fprintf('[INFO] Generating Figure 3: Active and Reactive Powers...\n');
    fig3 = figure('Name', 'step_load_powers', 'Color', 'w', 'Position', [100, 100, 880, 580], 'Visible', fig_vis);
    
    % Subplot 1: Active Electrical Power P(t)
    ax3_1 = subplot(2, 1, 1, 'Parent', fig3);
    hold(ax3_1, 'on');
    % Compute moving average of instantaneous power to highlight fundamental active power
    window_sz = round( (1/60) / (t(2)-t(1)) ); % 1 electrical cycle window
    p_filt = movmean(p_inst, window_sz);
    plot(ax3_1, t, p_filt, 'b-', 'LineWidth', 1.8, 'DisplayName', 'Pot\^{e}ncia Ativa M\''edia $P(t)$');
    yline(ax3_1, P_elec_noload_ana, 'g-.', 'LineWidth', 1.4, ...
        'DisplayName', sprintf('Regime a Vazio ($P_0 = %.1f~\\mathrm{W}$)', P_elec_noload_ana));
    yline(ax3_1, P_elec_loaded_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Regime sob Carga ($P_{ss} = %.1f~\\mathrm{W}$)', P_elec_loaded_ana));
    xline(ax3_1, t_step_val, 'm:', 'LineWidth', 1.5, 'DisplayName', 'Degrau de Carga ($t = 5.0~\mathrm{s}$)');
    grid(ax3_1, 'on'); box(ax3_1, 'on');
    xlabel(ax3_1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax3_1, 'Pot\^{e}ncia Ativa $P$ (W)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax3_1, 'Pot\^{e}ncia Ativa Trif\''asica Absorvida da Rede ($P(t)$)', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax3_1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax3_1, [0, 8.0]);
    ylim(ax3_1, [-500, 14000]);

    % Subplot 2: Reactive Electrical Power Q(t)
    ax3_2 = subplot(2, 1, 2, 'Parent', fig3);
    hold(ax3_2, 'on');
    q_filt = movmean(abs(q_inst), window_sz);
    plot(ax3_2, t, q_filt, 'Color', [0.85, 0.35, 0.0], 'LineWidth', 1.8, 'DisplayName', 'Pot\^{e}ncia Reativa M\''edia $Q(t)$');
    yline(ax3_2, Q_elec_noload_ana, 'g-.', 'LineWidth', 1.4, ...
        'DisplayName', sprintf('Regime a Vazio ($Q_0 = %.1f~\\mathrm{var}$)', Q_elec_noload_ana));
    yline(ax3_2, Q_elec_loaded_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Regime sob Carga ($Q_{ss} = %.1f~\\mathrm{var}$)', Q_elec_loaded_ana));
    xline(ax3_2, t_step_val, 'm:', 'LineWidth', 1.5, 'DisplayName', 'Degrau de Carga ($t = 5.0~\mathrm{s}$)');
    grid(ax3_2, 'on'); box(ax3_2, 'on');
    xlabel(ax3_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax3_2, 'Pot\^{e}ncia Reativa $Q$ (var)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax3_2, 'Pot\^{e}ncia Reativa Trif\''asica de Magnetiza\c{c}\~{a}o ($Q(t)$)', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax3_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax3_2, [0, 8.0]);
    ylim(ax3_2, [0, 18000]);

    fig3_png = fullfile(fig_dir, 'item2d_step_load_powers.png');
    fig3_fig = fullfile(fig_dir, 'item2d_step_load_powers.fig');
    exportgraphics(fig3, fig3_png, 'Resolution', 300);
    savefig(fig3, fig3_fig);
    if strcmp(fig_vis, 'off'), close(fig3); end
    fprintf('[OK] Saved %s\n', fig3_png);

    %% Figure 4: Electromagnetic Torque & Load Equilibrium
    fprintf('[INFO] Generating Figure 4: Torque Response & Equilibrium...\n');
    fig4 = figure('Name', 'step_load_torque', 'Color', 'w', 'Position', [100, 100, 880, 580], 'Visible', fig_vis);
    
    % Subplot 1: Full Torque Transient
    ax4_1 = subplot(2, 1, 1, 'Parent', fig4);
    hold(ax4_1, 'on');
    plot(ax4_1, t, torque_Nm, 'b-', 'LineWidth', 1.6, 'DisplayName', 'Conjugado Eletromagn\''etico $T_e(t)$');
    yline(ax4_1, T_em_noload_ana, 'g-.', 'LineWidth', 1.4, ...
        'DisplayName', sprintf('Equil\\''ibrio a Vazio ($T_e = B\\omega_m = %.2f~\\mathrm{N\\cdot m}$)', T_em_noload_ana));
    yline(ax4_1, T_em_loaded_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Equil\\''ibrio com Carga ($T_e = T_L + B\\omega_m = %.2f~\\mathrm{N\\cdot m}$)', T_em_loaded_ana));
    xline(ax4_1, t_step_val, 'm:', 'LineWidth', 1.5, 'DisplayName', 'Degrau de Carga ($t = 5.0~\mathrm{s}$)');
    grid(ax4_1, 'on'); box(ax4_1, 'on');
    xlabel(ax4_1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax4_1, 'Conjugado $T_e$ (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax4_1, 'Conjugado Eletromagn\''etico: Partida Direta, Acomoda\c{c}\~{a}o a Vazio e Resposta ao Degrau', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax4_1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax4_1, [0, 8.0]);
    ylim(ax4_1, [-35, 95]);

    % Subplot 2: Zoom on Step Disturbance & Mechanical Balance
    ax4_2 = subplot(2, 1, 2, 'Parent', fig4);
    hold(ax4_2, 'on');
    idx_tq_zoom = (t >= 4.8 & t <= 6.8);
    t_z = t(idx_tq_zoom);
    % Reconstruct opposing load profile
    TL_prof = zeros(size(t_z));
    TL_prof(t_z >= t_step_val) = T_step_val;
    T_opp_prof = TL_prof + B * (speed_rpm(idx_tq_zoom) * 2 * pi / 60);

    plot(ax4_2, t_z, torque_Nm(idx_tq_zoom), 'b-', 'LineWidth', 2.0, 'DisplayName', 'Conjugado Desenvolvido $T_e(t)$');
    plot(ax4_2, t_z, T_opp_prof, 'k--', 'LineWidth', 1.6, 'DisplayName', 'Oposi\c{c}\~{a}o Mec\^{a}nica Total ($T_L + B\omega_m$)');
    plot(ax4_2, t_z, TL_prof, 'm-.', 'LineWidth', 1.4, 'DisplayName', 'Carga Externa Aplicada ($T_L$)');
    yline(ax4_2, T_em_loaded_ana, 'r:', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Valor Te\\''orico Final ($%.2f~\\mathrm{N\\cdot m}$)', T_em_loaded_ana));
    plot(ax4_2, 6.7, T_em_loaded_sim, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 7, ...
        'DisplayName', sprintf('Ponto Estacion\\''ario ($%.2f~\\mathrm{N\\cdot m}$)', T_em_loaded_sim));

    grid(ax4_2, 'on'); box(ax4_2, 'on');
    xlabel(ax4_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax4_2, 'Conjugado (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax4_2, 'Equil\''ibrio Eletromec\^{a}nico no Degrau de Carga ($T_e = T_L + B\omega_m$)', ...
        'Interpreter', 'latex', 'FontSize', 11);
    legend(ax4_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax4_2, [4.8, 6.8]);
    ylim(ax4_2, [0, 36]);

    fig4_png = fullfile(fig_dir, 'item2d_step_load_torque.png');
    fig4_fig = fullfile(fig_dir, 'item2d_step_load_torque.fig');
    exportgraphics(fig4, fig4_png, 'Resolution', 300);
    savefig(fig4, fig4_fig);
    if strcmp(fig_vis, 'off'), close(fig4); end
    fprintf('[OK] Saved %s\n', fig4_png);

    fprintf('\n[PASS] Task 3.2 Execution and Figure Generation Complete.\n');

end
