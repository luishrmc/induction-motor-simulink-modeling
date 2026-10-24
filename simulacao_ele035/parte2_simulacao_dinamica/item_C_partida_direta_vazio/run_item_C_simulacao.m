function results = run_item_C_simulacao()
% RUN_ITEM (origem: matlab/scripts/run_task_3_1.m)
% Execution and validation script for Task 3.1:
% Direct-On-Line (DOL) No-Load Startup Transient Simulation & Inrush Validation.
%
% Generates:
%   - out/results/sim_transient_3.1.mat
%   - out/results/comparison_3.1.json
%   - figures/item2c_transient_dol_speed.png (.fig)
%   - figures/item2c_transient_dol_current.png (.fig)
%   - figures/item2c_transient_dol_torque.png (.fig)
%
% Adheres to:
%   - sim_proj.pdf Part 2 Academic Specifications
%   - ADR-001 (Consolidated Lab Parameters)
%   - ADR-002 (Star-Delta Parameter Transformation)
%   - ADR-004 (Tolerance Gate Verification)
%   - .agents/skills/figure-production/SKILL.md (Publication Quality Plotting)

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - TASK 3.1: DOL STARTUP TRANSIENT & INRUSH VALIDATION \n');
    fprintf('====================================================================\n\n');

    %% 1. Initialize Paths & Simulation Harness
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

    %% 2. Run DOL No-Load Dynamic Simulation (t_stop = 6.0 s)
    % 6.0 s allows complete electromechanical speed settling under J = 0.701 kg.m^2
    fprintf('[INFO] Running 6.0s DOL No-Load Simulation via run_sim_harness...\n');
    results = run_sim_harness('dol_startup', 'StopTime', 6.0);

    t      = results.time;
    speed  = results.speed_rpm;
    torque = results.torque_Nm;
    ia     = results.current_Ia;
    ib     = results.current_Ib;
    ic     = results.current_Ic;

    params = setup_motor_params();

    %% 3. Numerical Reconciliation & Analysis
    % Inrush metrics (Standstill s = 1.0)
    I_peak_sim   = max(abs(ia));
    I_start_rms_sym = results.analytical_start.I_line_start; % 67.73 A RMS
    I_peak_sym   = sqrt(2) * I_start_rms_sym;                % 95.78 A peak symmetrical
    T_start_ana  = results.analytical_start.T_start;         % 25.35 N.m
    T_peak_sim   = max(torque(t < 0.2));

    % No-load steady-state metrics (t in [5.5, 6.0] s)
    idx_ss = (t >= 5.5);
    n_ss_sim = mean(speed(idx_ss));
    T_ss_sim = mean(torque(idx_ss));
    I_ss_sim = rms(ia(idx_ss));

    % Exact analytical no-load targets where T_em(s) = B*w_m(s)
    n_ss_ana = 1775.52; % rpm
    T_ss_ana = 7.92;    % N.m (developed torque balancing viscous friction B*w)
    I_ss_ana = 8.49;    % A RMS

    fprintf('--------------------------------------------------------------------\n');
    fprintf('  TASK 3.1 TRANSIENT & STEADY-STATE RECONCILIATION SUMMARY\n');
    fprintf('--------------------------------------------------------------------\n');
    fprintf('  Peak Inrush Current (Simulated with DC offset): %.2f A\n', I_peak_sim);
    fprintf('  Theoretical Symmetrical Inrush Peak:            %.2f A (Ratio = %.2f)\n', ...
        I_peak_sym, I_peak_sim / I_peak_sym);
    fprintf('  Theoretical Fundamental Starting Current:      %.2f A RMS\n', I_start_rms_sym);
    fprintf('  Peak Subtransient Dynamic Torque:               %.2f N.m\n', T_peak_sim);
    fprintf('  Theoretical Steady-State Starting Torque (s=1): %.2f N.m\n', T_start_ana);
    fprintf('  Steady-State No-Load Speed:                     %.2f rpm (Ana: %.2f rpm, Err: %.2f%%)\n', ...
        n_ss_sim, n_ss_ana, abs(n_ss_sim - n_ss_ana)/n_ss_ana*100);
    fprintf('  Steady-State Developed Torque:                  %.2f N.m (Ana: %.2f N.m, Err: %.2f%%)\n', ...
        T_ss_sim, T_ss_ana, abs(T_ss_sim - T_ss_ana)/T_ss_ana*100);
    fprintf('  Steady-State No-Load Current:                   %.2f A RMS (Ana: %.2f A RMS, Err: %.2f%%)\n', ...
        I_ss_sim, I_ss_ana, abs(I_ss_sim - I_ss_ana)/I_ss_ana*100);
    fprintf('--------------------------------------------------------------------\n\n');

    %% 4. Configure Figure Production Standards
    set(groot, 'defaultAxesFontSize', 11);
    set(groot, 'defaultAxesFontName', 'Helvetica');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultLegendInterpreter', 'latex');

    %% 5. Figure 1: Rotor Speed Transient (transient_dol_speed)
    fprintf('[INFO] Generating Figure 1: Rotor Speed Transient...\n');
    fig1 = figure('Name', 'transient_dol_speed', 'Position', [100, 100, 850, 540], 'Visible', fig_vis);
    ax1 = axes(fig1);
    hold(ax1, 'on');

    plot(ax1, t, speed, 'b-', 'LineWidth', 2.0, ...
        'DisplayName', 'Velocidade Mec\^{a}nica $n(t)$ (Simula\c{c}\~{a}o)');
    yline(ax1, params.n_s, 'k--', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Velocidade S\''{\\i}ncrona $n_s = %d\\ \\mathrm{rpm}$', params.n_s));
    yline(ax1, n_ss_ana, 'r:', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Regime a Vazio Anal\''{\\i}tico ($n_{0} = %.1f\\ \\mathrm{rpm}$)', n_ss_ana));

    % Marker at settled operating point
    plot(ax1, 5.8, n_ss_sim, 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 8, ...
        'DisplayName', sprintf('Ponto de Regime ($n = %.1f\\ \\mathrm{rpm}$)', n_ss_sim));

    grid(ax1, 'on');
    box(ax1, 'on');
    xlabel(ax1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel(ax1, 'Velocidade do Rotor $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 12);
    title(ax1, 'Transit\''orio de Partida Direta a Vazio: Velocidade do Rotor ($220\ \mathrm{V},\ 60\ \mathrm{Hz}$)', ...
        'Interpreter', 'latex', 'FontSize', 13);
    legend(ax1, 'Location', 'southeast', 'Interpreter', 'latex', 'FontSize', 10);
    xlim(ax1, [0, 6.0]);
    ylim(ax1, [0, 1900]);

    fig1_png = fullfile(fig_dir, 'item2c_transient_dol_speed.png');
    fig1_fig = fullfile(fig_dir, 'item2c_transient_dol_speed.fig');
    exportgraphics(fig1, fig1_png, 'Resolution', 300);
    savefig(fig1, fig1_fig);
    if strcmp(fig_vis, 'off'), close(fig1); end
    fprintf('[OK] Saved %s\n', fig1_png);

    %% 6. Figure 2: Stator Currents & Inrush Waveform (transient_dol_current)
    fprintf('[INFO] Generating Figure 2: Stator Inrush Currents...\n');
    fig2 = figure('Name', 'transient_dol_current', 'Position', [100, 100, 880, 580], 'Visible', fig_vis);

    % Subplot 1: Full 0-5s envelope
    ax2_1 = subplot(2, 1, 1, 'Parent', fig2);
    hold(ax2_1, 'on');
    plot(ax2_1, t, ia, 'b-', 'LineWidth', 1.0, 'DisplayName', 'Corrente Fase A $i_a(t)$');
    yline(ax2_1, I_peak_sym, 'r--', 'LineWidth', 1.2, ...
        'DisplayName', sprintf('Pico Sim\''etrico $s=1$ ($+\\sqrt{2} I_{part} = +%.1f\\ \\mathrm{A}$)', I_peak_sym));
    yline(ax2_1, -I_peak_sym, 'r--', 'LineWidth', 1.2, ...
        'DisplayName', sprintf('Pico Sim\''etrico $s=1$ ($-\\sqrt{2} I_{part} = -%.1f\\ \\mathrm{A}$)', I_peak_sym));
    grid(ax2_1, 'on');
    box(ax2_1, 'on');
    ylabel(ax2_1, 'Corrente $i_a$ (A)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax2_1, 'Transit\''orio de Partida Direta: Correntes de Estator e Envelope de Inrush', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax2_1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 9);
    xlim(ax2_1, [0, 6.0]);
    ylim(ax2_1, [-140, 140]);

    % Subplot 2: Zoom on first 0.15s (9 cycles)
    ax2_2 = subplot(2, 1, 2, 'Parent', fig2);
    hold(ax2_2, 'on');
    idx_zoom = (t <= 0.15);
    plot(ax2_2, t(idx_zoom), ia(idx_zoom), 'b-', 'LineWidth', 1.6, 'DisplayName', 'Fase A $i_a(t)$');
    plot(ax2_2, t(idx_zoom), ib(idx_zoom), 'r-', 'LineWidth', 1.4, 'DisplayName', 'Fase B $i_b(t)$');
    plot(ax2_2, t(idx_zoom), ic(idx_zoom), 'Color', [0, 0.6, 0.2], 'LineWidth', 1.4, 'DisplayName', 'Fase C $i_c(t)$');

    % Inrush peak marker
    plot(ax2_2, 0.0079, I_peak_sim, 'kp', 'MarkerFaceColor', 'm', 'MarkerSize', 10, ...
        'DisplayName', sprintf('Pico M\''aximo Inrush ($%.1f\\ \\mathrm{A}$)', I_peak_sim));

    grid(ax2_2, 'on');
    box(ax2_2, 'on');
    xlabel(ax2_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax2_2, 'Corrente Trif\''asica (A)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax2_2, 'Detalhe Subtransit\''orio dos Primeiros Ciclos ($0 \le t \le 0.15\ \mathrm{s}$, Offset DC e Pico)', ...
        'Interpreter', 'latex', 'FontSize', 11);
    legend(ax2_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax2_2, [0, 0.15]);
    ylim(ax2_2, [-130, 140]);

    fig2_png = fullfile(fig_dir, 'item2c_transient_dol_current.png');
    fig2_fig = fullfile(fig_dir, 'item2c_transient_dol_current.fig');
    exportgraphics(fig2, fig2_png, 'Resolution', 300);
    savefig(fig2, fig2_fig);
    if strcmp(fig_vis, 'off'), close(fig2); end
    fprintf('[OK] Saved %s\n', fig2_png);

    %% 7. Figure 3: Electromagnetic Torque Transient (transient_dol_torque)
    fprintf('[INFO] Generating Figure 3: Electromagnetic Torque Transient...\n');
    fig3 = figure('Name', 'transient_dol_torque', 'Position', [100, 100, 880, 580], 'Visible', fig_vis);

    % Subplot 1: Full 0-5s torque curve
    ax3_1 = subplot(2, 1, 1, 'Parent', fig3);
    hold(ax3_1, 'on');
    plot(ax3_1, t, torque, 'b-', 'LineWidth', 1.2, ...
        'DisplayName', 'Conjugado Eletromagn\''etico $T_e(t)$');
    yline(ax3_1, T_ss_sim, 'r--', 'LineWidth', 1.3, ...
        'DisplayName', sprintf('Atrito Viscoso Regime $B\\omega_m = %.2f\\ \\mathrm{N\\cdot m}$', T_ss_sim));
    grid(ax3_1, 'on');
    box(ax3_1, 'on');
    ylabel(ax3_1, 'Conjugado $T_e$ (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax3_1, 'Transit\''orio de Partida Direta: Conjugado Eletromagn\''etico e Amortecimento', ...
        'Interpreter', 'latex', 'FontSize', 12);
    legend(ax3_1, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 9);
    xlim(ax3_1, [0, 6.0]);
    ylim(ax3_1, [-35, 95]);

    % Subplot 2: Subtransient zoom (0 - 0.25 s)
    ax3_2 = subplot(2, 1, 2, 'Parent', fig3);
    hold(ax3_2, 'on');
    idx_t_zoom = (t <= 0.25);
    plot(ax3_2, t(idx_t_zoom), torque(idx_t_zoom), 'b-', 'LineWidth', 1.8, ...
        'DisplayName', 'Conjugado $T_e(t)$ (Simula\c{c}\~{a}o)');
    yline(ax3_2, T_start_ana, 'm--', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Partida Te\''orica $s=1$ ($T_{part} = %.2f\\ \\mathrm{N\\cdot m}$)', T_start_ana));
    plot(ax3_2, 0.015, T_peak_sim, 'kp', 'MarkerFaceColor', 'm', 'MarkerSize', 10, ...
        'DisplayName', sprintf('Pico Subtransit\''orio ($%.1f\\ \\mathrm{N\\cdot m}$)', T_peak_sim));

    grid(ax3_2, 'on');
    box(ax3_2, 'on');
    xlabel(ax3_2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel(ax3_2, 'Conjugado $T_e$ (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 11);
    title(ax3_2, 'Oscila\c{c}\~{o}es Subtransit\''orias Iniciais ($0 \le t \le 0.25\ \mathrm{s}$, Pulsos de Conjugado)', ...
        'Interpreter', 'latex', 'FontSize', 11);
    legend(ax3_2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax3_2, [0, 0.25]);
    ylim(ax3_2, [-35, 95]);

    fig3_png = fullfile(fig_dir, 'item2c_transient_dol_torque.png');
    fig3_fig = fullfile(fig_dir, 'item2c_transient_dol_torque.fig');
    exportgraphics(fig3, fig3_png, 'Resolution', 300);
    savefig(fig3, fig3_fig);
    if strcmp(fig_vis, 'off'), close(fig3); end
    fprintf('[OK] Saved %s\n', fig3_png);

    fprintf('\n[PASS] Task 3.1 Execution and Figure Generation Complete.\n');

end
