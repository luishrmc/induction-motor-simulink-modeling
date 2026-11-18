function results = run_item_C_simulacao()
% RUN_ITEM_C_SIMULACAO
% Execution and validation script for Task 3.1:
% Direct-On-Line (DOL) No-Load Startup Transient Simulation & Inrush Validation.
%
% Generates:
%   - analise_convergencia.json (local convergence report)
%   - out/results/sim_transient_dol_startup.mat (local cache)
%   - figures/item2c_transient_dol_speed.png (.fig)
%   - figures/item2c_transient_dol_current.png (.fig)
%   - figures/item2c_transient_dol_torque.png (.fig)
%
% Adheres to:
%   - sim_proj.pdf Part 2 Academic Specifications
%   - ADR-002 (Star-Delta Parameter Transformation)
%   - ADR-004 (Tolerance Gate Verification)
%   - ADR-007 (Centralized parametros_motor.m & utils/data/04_Mecanicos.csv)
%   - .agents/skills/figure-production/SKILL.md (Publication Quality Plotting)

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - TASK 3.1: DOL STARTUP TRANSIENT & INRUSH VALIDATION \n');
    fprintf('====================================================================\n\n');

    %% 1. Initialize Paths & Simulation Harness
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

    %% 2. Run DOL No-Load Dynamic Simulation (t_stop = 2.0 s)
    t_stop_val = 2.0;
    fprintf('[INFO] Running %.1fs DOL No-Load Simulation via run_sim_harness...\n', t_stop_val);
    results = run_sim_harness('dol_startup', 'StopTime', t_stop_val);

    t      = results.time;
    speed  = results.speed_rpm;
    torque = results.torque_Nm;
    ia     = results.current_Ia;
    ib     = results.current_Ib;
    ic     = results.current_Ic;
    p_inst = results.p_inst;
    q_inst = results.q_inst;

    params = setup_parametros_Y();

    %% 3. Analytical No-Load Equilibrium via fzero (IEEE T-Equivalent Circuit)
    V_ph = params.V_LL_nom;
    Z1   = params.R1_delta + 1j * params.X1_delta;
    Zm   = 1j * params.Xm_delta;

    calc_Tem = @(s) (3 / params.omega_s) * ...
        (abs((1j * params.Xm_delta ./ (params.R1_delta + 1j * (params.X1_delta + params.Xm_delta))) * V_ph)^2 .* (params.R2_delta ./ s)) ./ ...
        ((real((1j * params.Xm_delta * Z1) / (params.R1_delta + 1j * (params.X1_delta + params.Xm_delta))) + params.R2_delta ./ s).^2 + ...
         (imag((1j * params.Xm_delta * Z1) / (params.R1_delta + 1j * (params.X1_delta + params.Xm_delta))) + params.X2_delta).^2);

    obj_fun_noload = @(s) calc_Tem(s) - params.B * params.omega_s * (1 - s);
    s_noload_ana = fzero(obj_fun_noload, 0.001);
    n_ss_ana     = params.n_s * (1 - s_noload_ana);
    T_ss_ana     = calc_Tem(s_noload_ana);

    Z2_nl  = (params.R2_delta / s_noload_ana) + 1j * params.X2_delta;
    Zp_nl  = (Zm * Z2_nl) / (Zm + Z2_nl);
    Zin_nl = Z1 + Zp_nl;
    I1_ph_nl = V_ph / Zin_nl;
    I_ss_ana = sqrt(3) * abs(I1_ph_nl);
    P_ss_ana = 3 * real(V_ph * conj(I1_ph_nl));
    Q_ss_ana = 3 * imag(V_ph * conj(I1_ph_nl));

    %% 4. Numerical Reconciliation & Steady-State Extraction (t >= 1.5 s)
    % Inrush metrics (Standstill s = 1.0)
    I_peak_sim      = max(abs(ia));
    I_start_rms_sym = results.analytical_start.I_line_start;
    I_peak_sym      = sqrt(2) * I_start_rms_sym;
    T_start_ana     = results.analytical_start.T_start;
    T_peak_sim      = max(torque(t < 0.25));

    % No-load steady-state metrics (t in [1.5, 2.0] s)
    idx_ss   = (t >= 1.5);
    n_ss_sim = mean(speed(idx_ss));
    T_ss_sim = mean(torque(idx_ss));
    I_ss_sim = rms(ia(idx_ss));
    P_ss_sim = mean(p_inst(idx_ss));
    Q_ss_sim = abs(mean(q_inst(idx_ss)));

    err_n = abs(n_ss_sim - n_ss_ana) / n_ss_ana * 100;
    err_T = abs(T_ss_sim - T_ss_ana) / T_ss_ana * 100;
    err_I = abs(I_ss_sim - I_ss_ana) / I_ss_ana * 100;
    err_P = abs(P_ss_sim - P_ss_ana) / P_ss_ana * 100;
    err_Q = abs(Q_ss_sim - Q_ss_ana) / Q_ss_ana * 100;

    fprintf('--------------------------------------------------------------------\n');
    fprintf('  TASK 3.1 TRANSIENT & STEADY-STATE RECONCILIATION SUMMARY\n');
    fprintf('--------------------------------------------------------------------\n');
    fprintf('  Peak Inrush Current (Simulated with DC offset): %.2f A\n', I_peak_sim);
    fprintf('  Theoretical Symmetrical Inrush Peak:            %.2f A (Ratio = %.2f)\n', ...
        I_peak_sym, I_peak_sim / I_peak_sym);
    fprintf('  Theoretical Fundamental Starting Current:      %.2f A RMS\n', I_start_rms_sym);
    fprintf('  Peak Subtransient Dynamic Torque:               %.2f N.m\n', T_peak_sim);
    fprintf('  Theoretical Steady-State Starting Torque (s=1): %.2f N.m\n', T_start_ana);
    fprintf('  Steady-State No-Load Speed:                     %.2f rpm (Ana: %.2f rpm, Err: %.3f%%)\n', ...
        n_ss_sim, n_ss_ana, err_n);
    fprintf('  Steady-State Developed Torque:                  %.3f N.m (Ana: %.3f N.m, Err: %.3f%%)\n', ...
        T_ss_sim, T_ss_ana, err_T);
    fprintf('  Steady-State No-Load Current:                   %.3f A RMS (Ana: %.3f A RMS, Err: %.3f%%)\n', ...
        I_ss_sim, I_ss_ana, err_I);
    fprintf('  Steady-State Active Power (P_0):                %.2f W (Ana: %.2f W, Err: %.3f%%)\n', ...
        P_ss_sim, P_ss_ana, err_P);
    fprintf('  Steady-State Reactive Power (Q_0):              %.2f var (Ana: %.2f var, Err: %.3f%%)\n', ...
        Q_ss_sim, Q_ss_ana, err_Q);
    fprintf('--------------------------------------------------------------------\n\n');

    % Export analise_convergencia.json for tolerance-gate.py and simulink-gate.py
    comp_data.analytical.n_noload_rpm   = n_ss_ana;
    comp_data.analytical.I_line_noload  = I_ss_ana;
    comp_data.analytical.T_em_noload    = T_ss_ana;
    comp_data.analytical.P_elec_noload  = P_ss_ana;
    comp_data.analytical.Q_elec_noload  = Q_ss_ana;

    comp_data.simulated.n_noload_rpm    = n_ss_sim;
    comp_data.simulated.I_line_noload   = I_ss_sim;
    comp_data.simulated.T_em_noload     = T_ss_sim;
    comp_data.simulated.P_elec_noload   = P_ss_sim;
    comp_data.simulated.Q_elec_noload   = Q_ss_sim;

    json_path = fullfile(item_dir, 'analise_convergencia.json');
    fid = fopen(json_path, 'w');
    if fid ~= -1
        fwrite(fid, jsonencode(comp_data), 'char');
        fclose(fid);
        fprintf('[OK] Exported verification JSON to %s\n', json_path);
    end

    %% 5. Configure Figure Production Standards
    set(groot, 'defaultAxesFontSize', 11);
    set(groot, 'defaultAxesFontName', 'Helvetica');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultLegendInterpreter', 'latex');
    set(groot, 'defaultAxesTickLabelInterpreter', 'latex');

    %% 6. Figure 1: Rotor Speed Transient (item2c_transient_dol_speed)
    fprintf('[INFO] Generating Figure 1: Rotor Speed Transient...\n');
    fig1 = figure('Name', 'transient_dol_speed', 'Color', 'w', 'Position', [100, 100, 850, 540], 'Visible', fig_vis);
    ax1 = axes(fig1);
    hold(ax1, 'on');

    plot(ax1, t, speed, 'b-', 'LineWidth', 2.0, ...
        'DisplayName', 'Velocidade Mec\^{a}nica $n(t)$ (Simula\c{c}\~{a}o)');
    yline(ax1, params.n_s, 'k--', 'LineWidth', 1.5, ...
        'DisplayName', ['Velocidade S\''incrona ' sprintf('($n_s = %d~\\mathrm{rpm}$)', params.n_s)]);
    yline(ax1, n_ss_ana, 'r:', 'LineWidth', 1.5, ...
        'DisplayName', ['Regime a Vazio Anal\''itico ' sprintf('($n_0 = %.2f~\\mathrm{rpm}$)', n_ss_ana)]);

    t_marker_1 = 1.85;
    plot(ax1, t_marker_1, n_ss_sim, 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 8, ...
        'DisplayName', ['Ponto de Regime ' sprintf('($n = %.2f~\\mathrm{rpm}$)', n_ss_sim)]);

    grid(ax1, 'on');
    box(ax1, 'on');
    xlabel(ax1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel(ax1, 'Velocidade do Rotor $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 12);
    title(ax1, ['Transit\''orio de Partida Direta a Vazio: Velocidade do Rotor ' ...
        sprintf('($%.0f~\\mathrm{V},\\ %.0f~\\mathrm{Hz}$)', params.V_LL_nom, params.f_nom)], ...
        'Interpreter', 'latex', 'FontSize', 13);
    legend(ax1, 'Location', 'southeast', 'Interpreter', 'latex', 'FontSize', 10);
    xlim(ax1, [0, t_stop_val]);
    ylim(ax1, [0, ceil(max([params.n_s, max(speed)]) * 1.08 / 50) * 50]);

    fig1_png = fullfile(fig_dir, 'item2c_transient_dol_speed.png');
    fig1_fig = fullfile(fig_dir, 'item2c_transient_dol_speed.fig');
    exportgraphics(fig1, fig1_png, 'Resolution', 300);
    savefig(fig1, fig1_fig);
    if strcmp(fig_vis, 'off'), close(fig1); end
    fprintf('[OK] Saved %s\n', fig1_png);

    %% 7. Figure 2: Stator Currents & Inrush Waveform (item2c_transient_dol_current)
    fprintf('[INFO] Generating Figure 2: Stator Inrush Currents...\n');
    fig2 = figure('Name', 'transient_dol_current', 'Color', 'w', 'Position', [100, 100, 880, 580], 'Visible', fig_vis);

    % Subplot 1: Full 0-2s envelope
    ax2_1 = subplot(2, 1, 1, 'Parent', fig2);
    hold(ax2_1, 'on');
    plot(ax2_1, t, ia, 'b-', 'LineWidth', 1.0, 'DisplayName', 'Corrente Fase A $i_a(t)$');
    yline(ax2_1, I_peak_sym, 'r--', 'LineWidth', 1.2, ...
        'DisplayName', ['Pico Sim\''etrico $s=1$ ' sprintf('($+\\sqrt{2} I_{part} = +%.1f~\\mathrm{A}$)', I_peak_sym)]);
    yline(ax2_1, -I_peak_sym, 'r--', 'LineWidth', 1.2, ...
        'DisplayName', ['Pico Sim\''etrico $s=1$ ' sprintf('($-\\sqrt{2} I_{part} = -%.1f~\\mathrm{A}$)', I_peak_sym)]);
    grid(ax2_1, 'on');
    box(ax2_1, 'on');
    ylabel(ax2_1, 'Corrente $i_a$ (A)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax2_1, 'Transit\''orio de Partida Direta: Correntes de Estator e Envelope de Inrush', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax2_1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 9);
    xlim(ax2_1, [0, t_stop_val]);
    ylim_c1 = ceil(max([I_peak_sim, I_peak_sym]) * 1.25 / 10) * 10;
    ylim(ax2_1, [-ylim_c1, ylim_c1]);

    % Subplot 2: Zoom on first 0.15s (9 cycles)
    ax2_2 = subplot(2, 1, 2, 'Parent', fig2);
    hold(ax2_2, 'on');
    t_cur_zoom = 0.15;
    idx_zoom = (t <= t_cur_zoom);
    t_z  = t(idx_zoom);
    ia_z = ia(idx_zoom);
    ib_z = ib(idx_zoom);
    ic_z = ic(idx_zoom);

    plot(ax2_2, t_z, ia_z, 'b-', 'LineWidth', 1.6, 'DisplayName', 'Fase A $i_a(t)$');
    plot(ax2_2, t_z, ib_z, 'r-', 'LineWidth', 1.4, 'DisplayName', 'Fase B $i_b(t)$');
    plot(ax2_2, t_z, ic_z, 'Color', [0, 0.6, 0.2], 'LineWidth', 1.4, 'DisplayName', 'Fase C $i_c(t)$');

    [~, idx_ipk] = max(abs(ia_z));
    t_ipk   = t_z(idx_ipk);
    val_ipk = ia_z(idx_ipk);
    plot(ax2_2, t_ipk, val_ipk, 'kp', 'MarkerFaceColor', 'm', 'MarkerSize', 10, ...
        'DisplayName', ['Pico M\''aximo Inrush ' sprintf('($%.1f~\\mathrm{A}$)', abs(val_ipk))]);

    grid(ax2_2, 'on');
    box(ax2_2, 'on');
    xlabel(ax2_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax2_2, 'Corrente Trif\''asica (A)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax2_2, ['Detalhe Subtransit\''orio dos Primeiros Ciclos ' ...
        sprintf('($0 \\le t \\le %.2f~\\mathrm{s}$, Offset DC e Pico)', t_cur_zoom)], ...
        'Interpreter', 'latex', 'FontSize', 11);
    legend(ax2_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax2_2, [0, t_cur_zoom]);
    ylim_c2 = ceil(max([max(abs(ia_z)), max(abs(ib_z)), max(abs(ic_z))]) * 1.25 / 10) * 10;
    ylim(ax2_2, [-ylim_c2, ylim_c2]);

    fig2_png = fullfile(fig_dir, 'item2c_transient_dol_current.png');
    fig2_fig = fullfile(fig_dir, 'item2c_transient_dol_current.fig');
    exportgraphics(fig2, fig2_png, 'Resolution', 300);
    savefig(fig2, fig2_fig);
    if strcmp(fig_vis, 'off'), close(fig2); end
    fprintf('[OK] Saved %s\n', fig2_png);

    %% 8. Figure 3: Electromagnetic Torque Transient (item2c_transient_dol_torque)
    fprintf('[INFO] Generating Figure 3: Electromagnetic Torque Transient...\n');
    fig3 = figure('Name', 'transient_dol_torque', 'Color', 'w', 'Position', [100, 100, 880, 580], 'Visible', fig_vis);

    % Subplot 1: Full 0-2s torque curve
    ax3_1 = subplot(2, 1, 1, 'Parent', fig3);
    hold(ax3_1, 'on');
    plot(ax3_1, t, torque, 'b-', 'LineWidth', 1.2, ...
        'DisplayName', 'Conjugado Eletromagn\''etico $T_e(t)$');
    yline(ax3_1, T_ss_sim, 'r--', 'LineWidth', 1.3, ...
        'DisplayName', ['Atrito Viscoso Regime ' sprintf('($B\\omega_m = %.3f~\\mathrm{N\\cdot m}$)', T_ss_sim)]);
    grid(ax3_1, 'on');
    box(ax3_1, 'on');
    ylabel(ax3_1, 'Conjugado $T_e$ (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax3_1, 'Transit\''orio de Partida Direta: Conjugado Eletromagn\''etico e Amortecimento', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax3_1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 9);
    xlim(ax3_1, [0, t_stop_val]);
    tq_min1 = floor((min(torque) - 0.15 * (max(torque) - min(torque))) / 5) * 5;
    tq_max1 = ceil((max(torque) + 0.25 * (max(torque) - min(torque))) / 5) * 5;
    ylim(ax3_1, [tq_min1, tq_max1]);

    % Subplot 2: Subtransient zoom (0 - 0.25 s)
    ax3_2 = subplot(2, 1, 2, 'Parent', fig3);
    hold(ax3_2, 'on');
    t_tq_zoom = 0.25;
    idx_t_zoom = (t <= t_tq_zoom);
    t_tz  = t(idx_t_zoom);
    tq_z  = torque(idx_t_zoom);

    plot(ax3_2, t_tz, tq_z, 'b-', 'LineWidth', 1.8, ...
        'DisplayName', 'Conjugado $T_e(t)$ (Simula\c{c}\~{a}o)');
    yline(ax3_2, T_start_ana, 'm--', 'LineWidth', 1.5, ...
        'DisplayName', ['Partida Te\''orica $s=1$ ' sprintf('($T_{part} = %.2f~\\mathrm{N\\cdot m}$)', T_start_ana)]);
    [T_pk_val, idx_tpk] = max(tq_z);
    plot(ax3_2, t_tz(idx_tpk), T_pk_val, 'kp', 'MarkerFaceColor', 'm', 'MarkerSize', 10, ...
        'DisplayName', ['Pico Subtransit\''orio ' sprintf('($%.1f~\\mathrm{N\\cdot m}$)', T_pk_val)]);

    grid(ax3_2, 'on');
    box(ax3_2, 'on');
    xlabel(ax3_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax3_2, 'Conjugado $T_e$ (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax3_2, ['Oscila\c{c}\~{o}es Subtransit\''orias Iniciais ' ...
        sprintf('($0 \\le t \\le %.2f~\\mathrm{s}$, Pulsos de Conjugado)', t_tq_zoom)], ...
        'Interpreter', 'latex', 'FontSize', 11);
    legend(ax3_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax3_2, [0, t_tq_zoom]);
    tq_min2 = floor((min(tq_z) - 0.15 * (max(tq_z) - min(tq_z))) / 5) * 5;
    tq_max2 = ceil((max(tq_z) + 0.30 * (max(tq_z) - min(tq_z))) / 5) * 5;
    ylim(ax3_2, [tq_min2, tq_max2]);

    fig3_png = fullfile(fig_dir, 'item2c_transient_dol_torque.png');
    fig3_fig = fullfile(fig_dir, 'item2c_transient_dol_torque.fig');
    exportgraphics(fig3, fig3_png, 'Resolution', 300);
    savefig(fig3, fig3_fig);
    if strcmp(fig_vis, 'off'), close(fig3); end
    fprintf('[OK] Saved %s\n', fig3_png);

    fprintf('\n[PASS] Task 3.1 Execution and Figure Generation Complete.\n');

end
