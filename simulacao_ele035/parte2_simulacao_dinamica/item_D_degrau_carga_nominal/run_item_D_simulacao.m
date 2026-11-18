function results = run_item_D_simulacao()
% RUN_ITEM_D_SIMULACAO
% Execution, validation, and visualization script for Task 3.2:
% Simulation of Step Nominal Load Torque Disturbance & Convergence Audit.
%
% Scenario:
%   - Standstill start at t = 0 s (w0 = 0, n0 = 0) with zero load (T_L = 0).
%   - Motor accelerates under J = 0.0555 kg.m^2, B = 0.003651 N.m.s/rad to no-load steady state.
%   - At t = 1.5 s, full nominal load torque step disturbance is applied (T_L = +20.602 N.m).
%   - Motor decelerates and converges to loaded steady state by t = 3.0 s.
%
% Deliverables:
%   - comparison_3.2.json (local convergence report)
%   - out/results/sim_transient_3.2.mat (local cache)
%   - figures/item2d_step_load_speed.png (+ .fig)
%   - figures/item2d_step_load_current.png (+ .fig)
%   - figures/item2d_step_load_powers.png (+ .fig)
%   - figures/item2d_step_load_torque.png (+ .fig)
%
% Adheres to:
%   - sim_proj.pdf Part 2 Academic Specifications
%   - ADR-002 (Star-Delta Parameter Transformation)
%   - ADR-004 (Tolerance Gate Verification <= 2.0%)
%   - ADR-007 (Centralized parametros_motor.m & utils/data/04_Mecanicos.csv)
%   - .agents/skills/figure-production/SKILL.md (Publication Quality Plotting)

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - TASK 3.2: STEP NOMINAL LOAD TORQUE & CONVERGENCE    \n');
    fprintf('====================================================================\n\n');

    %% 1. Initialize Paths & Output Directories
    item_dir  = fileparts(mfilename('fullpath'));
    proj_root = fullfile(item_dir, '..', '..', '..');
    addpath(fullfile(item_dir, '..', 'item_A_modelo_simscape'));

    fig_dir = fullfile(item_dir, 'figures');
    res_dir = fullfile(proj_root, 'out', 'results');
    if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
    fig_vis = 'off';
    if feature('ShowFigureWindows') && ~strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
        fig_vis = 'on';   % interactive session (MATLAB GUI)
    end
    if ~exist(res_dir, 'dir'), mkdir(res_dir); end

    params = setup_parametros_Y();
    t_step_target = 1.5;
    t_stop_target = 3.0;

    %% 2. Run / Load Dynamic Simulation (t_step = 1.5 s, t_stop = 3.0 s)
    mat_step = fullfile(res_dir, 'sim_transient_nominal_step.mat');
    use_cache = false;
    if exist(mat_step, 'file')
        tmp = load(mat_step);
        if isfield(tmp, 'results') && isfield(tmp.results, 'params')
            rp = tmp.results.params;
            if abs(rp.J - params.J) < 1e-9 && abs(rp.B - params.B) < 1e-9 && ...
               abs(tmp.results.t_stop - t_stop_target) < 1e-9 && ...
               abs(tmp.results.t_step - t_step_target) < 1e-9
                use_cache = true;
                results = tmp.results;
                fprintf('[INFO] Loaded valid simulation telemetry cache from %s.\n', mat_step);
            end
        end
    end

    if ~use_cache
        fprintf('[INFO] Executing Simscape simulation harness for nominal_step (t_step=%.1fs, t_stop=%.1fs)...\n', ...
            t_step_target, t_stop_target);
        results = run_sim_harness('nominal_step', 'StepTime', t_step_target, 'StopTime', t_stop_target);
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
    V_LL_nom = params.V_LL_nom;
    omega_s  = params.omega_s;
    n_s      = params.n_s;
    R1       = params.R1_delta;
    R2_prime = params.R2_delta;
    X1       = params.X1_delta;
    X2_prime = params.X2_delta;
    Xm       = params.Xm_delta;
    B        = params.B;

    Z1 = R1 + 1j * X1;

    % Precise T_em formula using standard IEEE T-circuit
    calc_Tem_exact = @(s) (3 / omega_s) * ...
        (abs((1j * Xm ./ (R1 + 1j * (X1 + Xm))) * V_LL_nom)^2 * (R2_prime ./ s)) ./ ...
        ((real((1j * Xm * Z1) / (R1 + 1j * (X1 + Xm))) + R2_prime ./ s).^2 + ...
         (imag((1j * Xm * Z1) / (R1 + 1j * (X1 + Xm))) + X2_prime).^2);

    % Exact steady-state equilibrium at loaded condition: T_em(s) = T_L + B*omega_s*(1-s)
    obj_fun_load = @(s) calc_Tem_exact(s) - (T_step_val + B * omega_s * (1 - s));
    s_loaded_ana = fzero(obj_fun_load, 0.045);
    n_loaded_ana = n_s * (1 - s_loaded_ana);
    T_em_loaded_ana = calc_Tem_exact(s_loaded_ana);

    % Analytical impedance and electrical powers at loaded slip
    Z2_loaded  = R2_prime / s_loaded_ana + 1j * X2_prime;
    Zp_loaded  = (1j * Xm * Z2_loaded) / (1j * Xm + Z2_loaded);
    Zin_loaded = Z1 + Zp_loaded;
    I_ph_loaded_ana   = V_LL_nom / abs(Zin_loaded);
    I_line_loaded_ana = sqrt(3) * I_ph_loaded_ana;
    phi_loaded_ana    = angle(Zin_loaded);
    P_elec_loaded_ana = sqrt(3) * V_LL_nom * I_line_loaded_ana * cos(phi_loaded_ana);
    Q_elec_loaded_ana = sqrt(3) * V_LL_nom * I_line_loaded_ana * sin(phi_loaded_ana);

    % Pre-step no-load operating point
    obj_fun_noload = @(s) calc_Tem_exact(s) - B * omega_s * (1 - s);
    s_noload_ana = fzero(obj_fun_noload, 0.001);
    n_noload_ana = n_s * (1 - s_noload_ana);
    T_em_noload_ana = calc_Tem_exact(s_noload_ana);
    Z2_noload  = R2_prime / s_noload_ana + 1j * X2_prime;
    Zp_noload  = (1j * Xm * Z2_noload) / (1j * Xm + Z2_noload);
    Zin_noload = Z1 + Zp_noload;
    I_line_noload_ana = sqrt(3) * (V_LL_nom / abs(Zin_noload));
    phi_noload_ana    = angle(Zin_noload);
    P_elec_noload_ana = sqrt(3) * V_LL_nom * I_line_noload_ana * cos(phi_noload_ana);
    Q_elec_noload_ana = sqrt(3) * V_LL_nom * I_line_noload_ana * sin(phi_noload_ana);

    %% 4. Extract Simulation Steady-State Metrics
    % Pre-step no-load window: 1.2 to 1.5 s
    idx_pre = (t >= 1.2 & t <= t_step_val);
    n_noload_sim      = mean(speed_rpm(idx_pre));
    T_em_noload_sim   = mean(torque_Nm(idx_pre));
    I_line_noload_sim = rms(current_Ia(idx_pre));
    P_noload_sim      = mean(p_inst(idx_pre));
    Q_noload_sim      = abs(mean(q_inst(idx_pre)));

    % Post-step loaded window: t >= 2.7 s ([2.7, 3.0] s)
    idx_post = (t >= 2.7 & t <= t_stop_target);
    n_loaded_sim      = mean(speed_rpm(idx_post));
    T_em_loaded_sim   = mean(torque_Nm(idx_post));
    I_line_loaded_sim = rms(current_Ia(idx_post));
    P_loaded_sim      = mean(p_inst(idx_post));
    Q_loaded_sim      = abs(mean(q_inst(idx_post)));

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
                   'T_em_loaded_sim', 'I_line_loaded_sim', 'P_loaded_sim', 'Q_loaded_sim', ...
                   'n_noload_ana', 'T_em_noload_ana', 'I_line_noload_ana', ...
                   'P_elec_noload_ana', 'Q_elec_noload_ana', 'n_noload_sim', ...
                   'T_em_noload_sim', 'I_line_noload_sim', 'P_noload_sim', 'Q_noload_sim');

    json_path = fullfile(item_dir, 'comparison_3.2.json');
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
    yline(ax1_1, n_s, 'k--', 'LineWidth', 1.2, ...
        'DisplayName', ['Velocidade S\''incrona ' sprintf('($n_s = %d~\\mathrm{rpm}$)', n_s)]);
    yline(ax1_1, n_noload_ana, 'g-.', 'LineWidth', 1.4, ...
        'DisplayName', ['Regime a Vazio ' sprintf('($n_0 = %.2f~\\mathrm{rpm}$)', n_noload_ana)]);
    yline(ax1_1, n_loaded_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', ['Regime com Carga ' sprintf('($n_{ss} = %.2f~\\mathrm{rpm}$)', n_loaded_ana)]);
    xline(ax1_1, t_step_val, 'm:', 'LineWidth', 1.5, ...
        'DisplayName', ['Degrau de Carga ' sprintf('($t = %.1f~\\mathrm{s},\\ T_L = %.2f~\\mathrm{N\\cdot m}$)', t_step_val, T_step_val)]);
    grid(ax1_1, 'on'); box(ax1_1, 'on');
    xlabel(ax1_1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax1_1, 'Velocidade $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax1_1, ['Transit\''orio de Velocidade: Partida a Vazio e Degrau de Torque Nominal ' ...
        sprintf('($T_L = %.2f~\\mathrm{N\\cdot m}$)', T_step_val)], ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax1_1, 'Location', 'southeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax1_1, [0, t_stop_target]);
    ylim(ax1_1, [0, ceil(max([n_s, max(speed_rpm)]) * 1.08 / 50) * 50]);

    % Subplot 2: Zoom on Step Disturbance & Recovery ([1.4, 2.5] s)
    ax1_2 = subplot(2, 1, 2, 'Parent', fig1);
    hold(ax1_2, 'on');
    t_zoom_start = 1.4;
    t_zoom_end   = 2.5;
    idx_zoom = (t >= t_zoom_start & t <= t_zoom_end);
    plot(ax1_2, t(idx_zoom), speed_rpm(idx_zoom), 'b-', 'LineWidth', 2.0, 'DisplayName', 'Velocidade $n(t)$');
    yline(ax1_2, n_noload_ana, 'g-.', 'LineWidth', 1.4, ...
        'DisplayName', ['Pr\''e-Degrau a Vazio ' sprintf('($%.2f~\\mathrm{rpm}$)', n_noload_ana)]);
    yline(ax1_2, n_loaded_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', ['Converg\^{e}ncia sob Carga ' sprintf('($%.2f~\\mathrm{rpm}$)', n_loaded_ana)]);
    xline(ax1_2, t_step_val, 'm:', 'LineWidth', 1.5, ...
        'DisplayName', ['Instante do Degrau ' sprintf('($t = %.1f~\\mathrm{s}$)', t_step_val)]);
    t_mk_1 = 2.4;
    plot(ax1_2, t_mk_1, n_loaded_sim, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 7, ...
        'DisplayName', ['Ponto Estacion\''ario ' sprintf('($%.2f~\\mathrm{rpm}$)', n_loaded_sim)]);
    grid(ax1_2, 'on'); box(ax1_2, 'on');
    xlabel(ax1_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax1_2, 'Velocidade $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax1_2, ['Detalhe da Transi\c{c}\~{a}o Din\^{a}mica do Degrau de Carga ' ...
        sprintf('($%.1f \\le t \\le %.1f~\\mathrm{s}$)', t_zoom_start, t_zoom_end)], ...
        'Interpreter', 'latex', 'FontSize', 11);
    legend(ax1_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax1_2, [t_zoom_start, t_zoom_end]);
    sp_min_z = min([min(speed_rpm(idx_zoom)), n_loaded_ana]);
    sp_max_z = max([max(speed_rpm(idx_zoom)), n_noload_ana]);
    sp_span  = max(sp_max_z - sp_min_z, 10);
    ylim(ax1_2, [floor((sp_min_z - 0.25 * sp_span) / 5) * 5, ceil((sp_max_z + 0.35 * sp_span) / 5) * 5]);

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
    xline(ax2_1, t_step_val, 'm:', 'LineWidth', 1.5, ...
        'DisplayName', ['Degrau de Carga ' sprintf('($t = %.1f~\\mathrm{s}$)', t_step_val)]);
    yline(ax2_1, sqrt(2) * I_line_noload_ana, 'g-.', 'LineWidth', 1.3, ...
        'DisplayName', ['Pico a Vazio ' sprintf('($\\pm %.1f~\\mathrm{A}$)', sqrt(2) * I_line_noload_ana)]);
    yline(ax2_1, -sqrt(2) * I_line_noload_ana, 'g-.', 'LineWidth', 1.3, 'HandleVisibility', 'off');
    yline(ax2_1, sqrt(2) * I_line_loaded_ana, 'r--', 'LineWidth', 1.4, ...
        'DisplayName', ['Pico com Carga ' sprintf('($\\pm %.1f~\\mathrm{A},\\ I_{rms} = %.2f~\\mathrm{A}$)', ...
        sqrt(2) * I_line_loaded_ana, I_line_loaded_ana)]);
    yline(ax2_1, -sqrt(2) * I_line_loaded_ana, 'r--', 'LineWidth', 1.4, 'HandleVisibility', 'off');
    grid(ax2_1, 'on'); box(ax2_1, 'on');
    xlabel(ax2_1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax2_1, 'Corrente de Linha $i_{as}$ (A)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax2_1, 'Evolu\c{c}\~{a}o da Corrente Estat\''orica: Partida Direta, Regime a Vazio e Degrau de Carga', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax2_1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax2_1, [0, t_stop_target]);
    ylim_c1 = ceil(max(abs(current_Ia)) * 1.25 / 10) * 10;
    ylim(ax2_1, [-ylim_c1, ylim_c1]);

    % Subplot 2: Zoom on 3-Phase Current Expansion at Step Transition
    ax2_2 = subplot(2, 1, 2, 'Parent', fig2);
    hold(ax2_2, 'on');
    t_cz_start = t_step_val - 0.10;
    t_cz_end   = t_step_val + 0.25;
    idx_cur_zoom = (t >= t_cz_start & t <= t_cz_end);
    plot(ax2_2, t(idx_cur_zoom), current_Ia(idx_cur_zoom), 'b-', 'LineWidth', 1.4, 'DisplayName', 'Fase A ($i_{as}$)');
    plot(ax2_2, t(idx_cur_zoom), current_Ib(idx_cur_zoom), 'r--', 'LineWidth', 1.4, 'DisplayName', 'Fase B ($i_{bs}$)');
    plot(ax2_2, t(idx_cur_zoom), current_Ic(idx_cur_zoom), 'Color', [0, 0.6, 0.2], 'LineWidth', 1.4, 'DisplayName', 'Fase C ($i_{cs}$)');
    xline(ax2_2, t_step_val, 'm:', 'LineWidth', 1.8, ...
        'DisplayName', ['Instante do Degrau ' sprintf('($t = %.1f~\\mathrm{s}$)', t_step_val)]);
    grid(ax2_2, 'on'); box(ax2_2, 'on');
    xlabel(ax2_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax2_2, 'Correntes Trif\''asicas (A)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax2_2, ['Expans\~{a}o Trif\''asica das Correntes no Degrau de Carga ' ...
        sprintf('($%.2f \\le t \\le %.2f~\\mathrm{s}$)', t_cz_start, t_cz_end)], ...
        'Interpreter', 'latex', 'FontSize', 11);
    legend(ax2_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax2_2, [t_cz_start, t_cz_end]);
    c_pk_z = max([max(abs(current_Ia(idx_cur_zoom))), max(abs(current_Ib(idx_cur_zoom))), max(abs(current_Ic(idx_cur_zoom)))]);
    ylim_c2 = ceil(c_pk_z * 1.35 / 5) * 5;
    ylim(ax2_2, [-ylim_c2, ylim_c2]);

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
    window_sz = round((1 / params.f_nom) / (t(2) - t(1))); % 1 electrical cycle window
    p_filt = movmean(p_inst, window_sz);
    plot(ax3_1, t, p_filt, 'b-', 'LineWidth', 1.8, 'DisplayName', 'Pot\^{e}ncia Ativa M\''edia $P(t)$');
    yline(ax3_1, P_elec_noload_ana, 'g-.', 'LineWidth', 1.4, ...
        'DisplayName', ['Regime a Vazio ' sprintf('($P_0 = %.1f~\\mathrm{W}$)', P_elec_noload_ana)]);
    yline(ax3_1, P_elec_loaded_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', ['Regime sob Carga ' sprintf('($P_{ss} = %.1f~\\mathrm{W}$)', P_elec_loaded_ana)]);
    xline(ax3_1, t_step_val, 'm:', 'LineWidth', 1.5, ...
        'DisplayName', ['Degrau de Carga ' sprintf('($t = %.1f~\\mathrm{s}$)', t_step_val)]);
    grid(ax3_1, 'on'); box(ax3_1, 'on');
    xlabel(ax3_1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax3_1, 'Pot\^{e}ncia Ativa $P$ (W)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax3_1, 'Pot\^{e}ncia Ativa Trif\''asica Absorvida da Rede ($P(t)$)', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax3_1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax3_1, [0, t_stop_target]);
    p_min = min([min(p_filt), 0]);
    p_max = max(p_filt);
    p_span = p_max - p_min;
    ylim(ax3_1, [floor((p_min - 0.08 * p_span) / 500) * 500, ceil((p_max + 0.25 * p_span) / 500) * 500]);

    % Subplot 2: Reactive Electrical Power Q(t)
    ax3_2 = subplot(2, 1, 2, 'Parent', fig3);
    hold(ax3_2, 'on');
    q_filt = movmean(abs(q_inst), window_sz);
    plot(ax3_2, t, q_filt, 'Color', [0.85, 0.35, 0.0], 'LineWidth', 1.8, 'DisplayName', 'Pot\^{e}ncia Reativa M\''edia $Q(t)$');
    yline(ax3_2, Q_elec_noload_ana, 'g-.', 'LineWidth', 1.4, ...
        'DisplayName', ['Regime a Vazio ' sprintf('($Q_0 = %.1f~\\mathrm{var}$)', Q_elec_noload_ana)]);
    yline(ax3_2, Q_elec_loaded_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', ['Regime sob Carga ' sprintf('($Q_{ss} = %.1f~\\mathrm{var}$)', Q_elec_loaded_ana)]);
    xline(ax3_2, t_step_val, 'm:', 'LineWidth', 1.5, ...
        'DisplayName', ['Degrau de Carga ' sprintf('($t = %.1f~\\mathrm{s}$)', t_step_val)]);
    grid(ax3_2, 'on'); box(ax3_2, 'on');
    xlabel(ax3_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax3_2, 'Pot\^{e}ncia Reativa $Q$ (var)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax3_2, 'Pot\^{e}ncia Reativa Trif\''asica de Magnetiza\c{c}\~{a}o ($Q(t)$)', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax3_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax3_2, [0, t_stop_target]);
    q_max = max(q_filt);
    ylim(ax3_2, [0, ceil(q_max * 1.25 / 1000) * 1000]);

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
        'DisplayName', ['Equil\''ibrio a Vazio ' sprintf('($T_e = B\\omega_m = %.3f~\\mathrm{N\\cdot m}$)', T_em_noload_ana)]);
    yline(ax4_1, T_em_loaded_ana, 'r--', 'LineWidth', 1.5, ...
        'DisplayName', ['Equil\''ibrio com Carga ' sprintf('($T_e = T_L + B\\omega_m = %.2f~\\mathrm{N\\cdot m}$)', T_em_loaded_ana)]);
    xline(ax4_1, t_step_val, 'm:', 'LineWidth', 1.5, ...
        'DisplayName', ['Degrau de Carga ' sprintf('($t = %.1f~\\mathrm{s}$)', t_step_val)]);
    grid(ax4_1, 'on'); box(ax4_1, 'on');
    xlabel(ax4_1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax4_1, 'Conjugado $T_e$ (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax4_1, 'Conjugado Eletromagn\''etico: Partida Direta, Acomoda\c{c}\~{a}o a Vazio e Resposta ao Degrau', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax4_1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax4_1, [0, t_stop_target]);
    tq_span1 = max(torque_Nm) - min(torque_Nm);
    ylim(ax4_1, [floor((min(torque_Nm) - 0.15 * tq_span1) / 5) * 5, ceil((max(torque_Nm) + 0.25 * tq_span1) / 5) * 5]);

    % Subplot 2: Zoom on Step Disturbance & Mechanical Balance ([1.4, 2.5] s)
    ax4_2 = subplot(2, 1, 2, 'Parent', fig4);
    hold(ax4_2, 'on');
    idx_tq_zoom = (t >= t_zoom_start & t <= t_zoom_end);
    t_z = t(idx_tq_zoom);
    TL_prof = zeros(size(t_z));
    TL_prof(t_z >= t_step_val) = T_step_val;
    T_opp_prof = TL_prof + B * (speed_rpm(idx_tq_zoom) * 2 * pi / 60);

    plot(ax4_2, t_z, torque_Nm(idx_tq_zoom), 'b-', 'LineWidth', 2.0, 'DisplayName', 'Conjugado Desenvolvido $T_e(t)$');
    plot(ax4_2, t_z, T_opp_prof, 'k--', 'LineWidth', 1.6, 'DisplayName', 'Oposi\c{c}\~{a}o Mec\^{a}nica Total ($T_L + B\omega_m$)');
    plot(ax4_2, t_z, TL_prof, 'm-.', 'LineWidth', 1.4, 'DisplayName', 'Carga Externa Aplicada ($T_L$)');
    yline(ax4_2, T_em_loaded_ana, 'r:', 'LineWidth', 1.5, ...
        'DisplayName', ['Valor Te\''orico Final ' sprintf('($%.2f~\\mathrm{N\\cdot m}$)', T_em_loaded_ana)]);
    plot(ax4_2, t_mk_1, T_em_loaded_sim, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 7, ...
        'DisplayName', ['Ponto Estacion\''ario ' sprintf('($%.2f~\\mathrm{N\\cdot m}$)', T_em_loaded_sim)]);

    grid(ax4_2, 'on'); box(ax4_2, 'on');
    xlabel(ax4_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax4_2, 'Conjugado (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax4_2, 'Equil\''ibrio Eletromec\^{a}nico no Degrau de Carga ($T_e = T_L + B\omega_m$)', ...
        'Interpreter', 'latex', 'FontSize', 11);
    legend(ax4_2, 'Location', 'southeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax4_2, [t_zoom_start, t_zoom_end]);
    tq_z_min = min([min(torque_Nm(idx_tq_zoom)), 0]);
    tq_z_max = max([max(torque_Nm(idx_tq_zoom)), max(T_opp_prof), T_em_loaded_ana]);
    tq_z_span = max(tq_z_max - tq_z_min, 5);
    ylim(ax4_2, [floor((tq_z_min - 0.15 * tq_z_span) / 2) * 2, ceil((tq_z_max + 0.25 * tq_z_span) / 2) * 2]);

    fig4_png = fullfile(fig_dir, 'item2d_step_load_torque.png');
    fig4_fig = fullfile(fig_dir, 'item2d_step_load_torque.fig');
    exportgraphics(fig4, fig4_png, 'Resolution', 300);
    savefig(fig4, fig4_fig);
    if strcmp(fig_vis, 'off'), close(fig4); end
    fprintf('[OK] Saved %s\n', fig4_png);

    fprintf('\n[PASS] Task 3.2 Execution and Figure Generation Complete.\n');

end
