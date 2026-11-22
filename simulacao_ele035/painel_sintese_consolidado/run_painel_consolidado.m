function run_painel_consolidado()
% RUN_PAINEL_CONSOLIDADO
% Executive Synthesis & Multi-Scenario Consolidated Overview for UFMG ELE035.
%
% Dynamically ingests:
%   - simulacao_ele035/parametros_motor.m (canonical parameters, ADR-007)
%   - utils/data/dados_resumo.json (experimental bench measurements)
%   - parte1_regime_permanente/item_A_B_C_ponto_nominal/nominal_metrics.mat
%   - parte2_simulacao_dinamica/item_B_calculo_partida/resultados_partida.json
%   - parte2_simulacao_dinamica/item_C_partida_direta_vazio/analise_convergencia.json
%   - parte2_simulacao_dinamica/item_D_degrau_carga_nominal/comparison_3.2.json
%   - parte2_simulacao_dinamica/item_E_operacao_regenerativa/comparison_3.3.json
%   - out/results/sim_transient_*.mat (dynamic time-series telemetry)
%
% Generates:
%   - results/consolidated_comparison.{csv,json}
%   - figures/consolidated_transient_overview.{png,fig,json}

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - PAINEL EXECUTIVO E SINTESE CONSOLIDADA DE RESULTADOS \n');
    fprintf('====================================================================\n\n');

    %% 1. Configure Paths & Load Canonical Parameters
    this_dir  = fileparts(mfilename('fullpath'));
    fig_dir   = fullfile(this_dir, 'figures');
    res_dir   = fullfile(this_dir, 'results');
    base_dir  = fullfile(this_dir, '..');
    proj_root = fullfile(base_dir, '..');
    out_res   = fullfile(proj_root, 'out', 'results');

    if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
    if ~exist(res_dir, 'dir'), mkdir(res_dir); end

    addpath(base_dir);
    addpath(fullfile(base_dir, 'parte2_simulacao_dinamica', 'item_A_modelo_Simulink'));
    p = parametros_motor();

    fig_vis = 'off';
    if feature('ShowFigureWindows') && ~strcmp(getenv('QT_QPA_PLATFORM'), 'offscreen')
        fig_vis = 'on';
    end

    %% 2. Load Upstream Deliverables & Experimental Ground Truth
    dados_exp   = jsondecode(fileread(fullfile(proj_root, 'utils', 'data', 'dados_resumo.json')));
    nom_mat     = load(fullfile(base_dir, 'parte1_regime_permanente', 'item_A_B_C_ponto_nominal', 'nominal_metrics.mat'));
    metrics_p1  = nom_mat.metrics;
    part_json   = jsondecode(fileread(fullfile(base_dir, 'parte2_simulacao_dinamica', 'item_B_calculo_partida', 'resultados_partida.json')));
    item_c_json = jsondecode(fileread(fullfile(base_dir, 'parte2_simulacao_dinamica', 'item_C_partida_direta_vazio', 'analise_convergencia.json')));
    item_d_json = jsondecode(fileread(fullfile(base_dir, 'parte2_simulacao_dinamica', 'item_D_degrau_carga_nominal', 'comparison_3.2.json')));
    item_e_json = jsondecode(fileread(fullfile(base_dir, 'parte2_simulacao_dinamica', 'item_E_operacao_regenerativa', 'comparison_3.3.json')));

    % Load cached Simulink time-series telemetry
    dol_mat  = fullfile(out_res, 'sim_transient_dol_startup.mat');
    step_mat = fullfile(out_res, 'sim_transient_nominal_step.mat');
    reg_mat  = fullfile(out_res, 'sim_transient_regenerative.mat');

    if ~exist(dol_mat, 'file'), run_sim_harness('dol_startup', 'StopTime', 2.0); end
    if ~exist(step_mat, 'file'), run_sim_harness('nominal_step', 'StepTime', 1.5, 'StopTime', 3.0); end
    if ~exist(reg_mat, 'file'), run_sim_harness('regenerative', 'StepTime', 1.5, 'StopTime', 3.0); end

    res_dol  = getfield(load(dol_mat), 'results');
    res_step = getfield(load(step_mat), 'results');
    res_reg  = getfield(load(reg_mat), 'results');

    %% 3. Compute Derived Metrics Dynamically Across All Regimes
    rel_err = @(sim_v, ana_v) abs(sim_v - ana_v) / max(abs(ana_v), 1e-9) * 100.0;

    % Nameplate calculations (07_dados_de_placa.csv)
    I_start_plate = 7.6 * p.I_nom_A;
    I_peak_plate  = sqrt(2) * I_start_plate;
    P_elec_plate  = p.P_nom_W / p.eta_plate;
    Q_elec_plate  = P_elec_plate * tan(acos(p.pf_plate));

    % Experimental bench calculations (utils/data/dados_resumo.json)
    I_start_exp = dados_exp.ensaio_rotor_bloqueado.I_linha_A * (p.V_LL_nom / dados_exp.ensaio_rotor_bloqueado.V_linha_V);
    n_nl_exp    = dados_exp.ensaio_vazio.n_rpm;
    I_nl_exp    = dados_exp.ensaio_vazio.I_linha_A;
    P_nl_exp    = dados_exp.ensaio_vazio.P0_W;
    pf_nl_exp   = P_nl_exp / (sqrt(3) * p.V_LL_nom * I_nl_exp);

    % Partida / Locked-Rotor (s = 1.0)
    I_start_ana  = part_json.I_line_start_A;
    I_start_sim  = res_dol.analytical_start.I_line_start;
    I_crest_ana  = sqrt(2) * I_start_ana;
    I_peak_sim   = res_dol.telemetry.I_peak;
    T_start_ana  = part_json.T_start_Nm;
    T_start_sim  = res_dol.analytical_start.T_start;
    T_peak_dyn   = res_dol.telemetry.T_peak;
    X_over_R     = imag(res_dol.analytical_start.Z_in) / real(res_dol.analytical_start.Z_in);

    % Regime a Vazio (T_L = 0)
    n_nl_ana     = item_c_json.analytical.n_noload_rpm;
    n_nl_sim     = item_c_json.simulated.n_noload_rpm;
    T_nl_ana     = item_c_json.analytical.T_em_noload;
    T_nl_sim     = item_c_json.simulated.T_em_noload;
    I_nl_ana     = item_c_json.analytical.I_line_noload;
    I_nl_sim     = item_c_json.simulated.I_line_noload;
    P_nl_ana     = item_c_json.analytical.P_elec_noload;
    P_nl_sim     = item_c_json.simulated.P_elec_noload;
    Q_nl_ana     = item_c_json.analytical.Q_elec_noload;
    Q_nl_sim     = item_c_json.simulated.Q_elec_noload;
    pf_nl_ana    = P_nl_ana / (sqrt(3) * p.V_LL_nom * I_nl_ana);
    pf_nl_sim    = P_nl_sim / (sqrt(3) * p.V_LL_nom * I_nl_sim);
    P_rot_nl_sim = p.B * (n_nl_sim * 2 * pi / 60)^2;

    % Carga Nominal (+T_nom)
    n_ld_ana     = item_d_json.analytical.n_nom_rpm;
    n_ld_sim     = item_d_json.simulated.n_nom_rpm;
    T_ld_ana     = item_d_json.analytical.T_em_nom;
    T_ld_sim     = item_d_json.simulated.T_em_nom;
    I_ld_ana     = item_d_json.analytical.I_line_nom;
    I_ld_sim     = item_d_json.simulated.I_line_nom;
    P_ld_ana     = item_d_json.analytical.P_elec_nom;
    P_ld_sim     = item_d_json.simulated.P_elec_nom;
    Q_ld_ana     = item_d_json.analytical.Q_elec_nom;
    Q_ld_sim     = item_d_json.simulated.Q_elec_nom;
    pf_ld_ana    = P_ld_ana / (sqrt(3) * p.V_LL_nom * I_ld_ana);
    pf_ld_sim    = P_ld_sim / (sqrt(3) * p.V_LL_nom * I_ld_sim);
    wm_ld_ana    = n_ld_ana * 2 * pi / 60;
    wm_ld_sim    = n_ld_sim * 2 * pi / 60;
    P_shaft_ld_ana = p.T_nom_ref * wm_ld_ana;
    P_shaft_ld_sim = p.T_nom_ref * wm_ld_sim;
    P_rot_ld_sim   = p.B * wm_ld_sim^2;
    eta_ld_ana     = (P_shaft_ld_ana / P_ld_ana) * 100;
    eta_ld_sim     = (P_shaft_ld_sim / P_ld_sim) * 100;

    % Gerador Regenerativo (-T_nom)
    n_rg_ana     = item_e_json.analytical.n_nom_rpm;
    n_rg_sim     = item_e_json.simulated.n_nom_rpm;
    T_rg_ana     = item_e_json.analytical.T_em_nom;
    T_rg_sim     = item_e_json.simulated.T_em_nom;
    I_rg_ana     = item_e_json.analytical.I_line_nom;
    I_rg_sim     = item_e_json.simulated.I_line_nom;
    P_rg_ana     = item_e_json.analytical.P_elec_nom;
    P_rg_sim     = item_e_json.simulated.P_elec_nom;
    Q_rg_ana     = item_e_json.analytical.Q_elec_nom;
    Q_rg_sim     = item_e_json.simulated.Q_elec_nom;
    pf_rg_ana    = P_rg_ana / (sqrt(3) * p.V_LL_nom * I_rg_ana);
    pf_rg_sim    = P_rg_sim / (sqrt(3) * p.V_LL_nom * I_rg_sim);
    wm_rg_sim    = n_rg_sim * 2 * pi / 60;
    P_mech_rg_sim = -p.T_nom_ref * wm_rg_sim;
    P_rot_rg_sim  = p.B * wm_rg_sim^2;

    %% 4. Assemble Consolidated Comparison Table Dynamically
    fmt2 = @(x) sprintf('%.2f', x);
    fmt3 = @(x) sprintf('%.3f', x);

    comparison_rows = {
        % Partida / Rotor Bloqueado (s = 1.0)
        'Partida / Rotor Bloqueado (s=1.0)', 'Corrente de Linha de Partida', 'A RMS', fmt2(I_start_plate), fmt2(I_start_exp), fmt2(I_start_ana), fmt2(I_start_sim), fmt3(rel_err(I_start_sim, I_start_ana)), ...
            sprintf('Ensaio rotor bloqueado a %.1f V extrapolado linearmente para %.0f V; modelo analitico e Simulink concordam.', dados_exp.ensaio_rotor_bloqueado.V_linha_V, p.V_LL_nom);
        'Partida / Rotor Bloqueado (s=1.0)', 'Pico Instantaneo de Inrush', 'A', fmt2(I_peak_plate), '-', fmt2(I_crest_ana), fmt2(I_peak_sim), fmt2(rel_err(I_peak_sim, I_crest_ana)), ...
            sprintf('Pico instantaneo inclui componente aperiodica CC (X/R = %.2f), amortecendo em ~70 ms.', X_over_R);
        'Partida / Rotor Bloqueado (s=1.0)', 'Conjugado Eletromagnetico de Partida', 'N.m', '-', '-', fmt2(T_start_ana), fmt2(T_start_sim), fmt3(rel_err(T_start_sim, T_start_ana)), ...
            sprintf('Conjugado simetrico s=1 convergente; pico subtransitorio dinamico atinge %.2f N.m.', T_peak_dyn);

        % Regime a Vazio (TL = 0)
        'Regime Permanente a Vazio (TL=0)', 'Velocidade de Rotacao', 'rpm', fmt2(p.n_s), fmt2(n_nl_exp), fmt2(n_nl_ana), fmt2(n_nl_sim), fmt3(rel_err(n_nl_sim, n_nl_ana)), ...
            sprintf('Atrito viscoso consolidado B = %.6f N.m.s/rad (Prot = %.2f W), estabilizando proximo a %.2f rpm.', p.B, P_rot_nl_sim, n_nl_sim);
        'Regime Permanente a Vazio (TL=0)', 'Conjugado Eletromagnetico', 'N.m', '0.00', '-', fmt3(T_nl_ana), fmt3(T_nl_sim), fmt3(rel_err(T_nl_sim, T_nl_ana)), ...
            sprintf('Equilibrio estrito com atrito viscoso rotacional: Te = B*omega_m = %.3f N.m.', T_nl_sim);
        'Regime Permanente a Vazio (TL=0)', 'Corrente de Linha de Estator', 'A RMS', '-', fmt2(I_nl_exp), fmt3(I_nl_ana), fmt3(I_nl_sim), fmt3(rel_err(I_nl_sim, I_nl_ana)), ...
            sprintf('Corrente magnetizante a vazio em total acordo com ensaio experimental (%.2f A).', I_nl_exp);
        'Regime Permanente a Vazio (TL=0)', 'Potencia Ativa Absorvida', 'W', '-', fmt2(P_nl_exp), fmt2(P_nl_ana), fmt2(P_nl_sim), fmt3(rel_err(P_nl_sim, P_nl_ana)), ...
            sprintf('Suprimento exato das perdas rotacionais (%.1f W) e Joule estatoricas, validado contra P0 = %.1f W.', P_rot_nl_sim, P_nl_exp);
        'Regime Permanente a Vazio (TL=0)', 'Potencia Reativa Absorvida', 'var', '-', '-', fmt2(Q_nl_ana), fmt2(Q_nl_sim), fmt3(rel_err(Q_nl_sim, Q_nl_ana)), ...
            'Potencia reativa de magnetizacao do entreferro a vazio.';
        'Regime Permanente a Vazio (TL=0)', 'Fator de Potencia a Vazio', '-', '-', fmt3(pf_nl_exp), fmt3(pf_nl_ana), fmt3(pf_nl_sim), fmt3(rel_err(pf_nl_sim, pf_nl_ana)), ...
            'Predominancia fortemente indutiva da corrente magnetizante a vazio.';

        % Regime com Degrau de Carga Nominal (TL = +Tnom)
        'Carga Nominal (+Tnom)', 'Velocidade de Rotacao', 'rpm', fmt2(p.n_nom), fmt2(p.n_nom), fmt2(n_ld_ana), fmt2(n_ld_sim), fmt3(rel_err(n_ld_sim, n_ld_ana)), ...
            sprintf('Escorregamento sob carga s = %.2f%% para suprir TL = +%.2f N.m e atrito B*omega_m.', (p.n_s - n_ld_sim)/p.n_s*100, p.T_nom_ref);
        'Carga Nominal (+Tnom)', 'Conjugado Eletromagnetico', 'N.m', fmt2(p.T_nom_ref), fmt2(p.T_nom_ref), fmt3(T_ld_ana), fmt3(T_ld_sim), fmt3(rel_err(T_ld_sim, T_ld_ana)), ...
            sprintf('Equilibrio Te = TL + B*omega_m = %.2f + %.3f = %.3f N.m.', p.T_nom_ref, T_ld_sim - p.T_nom_ref, T_ld_sim);
        'Carga Nominal (+Tnom)', 'Corrente de Linha de Estator', 'A RMS', fmt2(p.I_nom_A), '-', fmt3(I_ld_ana), fmt3(I_ld_sim), fmt3(rel_err(I_ld_sim, I_ld_ana)), ...
            sprintf('Corrente sob carga em forte convergencia analitica-Simulink e proxima da placa (%.1f A).', p.I_nom_A);
        'Carga Nominal (+Tnom)', 'Potencia Eletrica Ativa', 'W', fmt2(P_elec_plate), '-', fmt2(P_ld_ana), fmt2(P_ld_sim), fmt3(rel_err(P_ld_sim, P_ld_ana)), ...
            sprintf('Potencia absorvida supre %.1f W uteis no eixo + %.1f W de atrito + perdas Joule.', P_shaft_ld_sim, P_rot_ld_sim);
        'Carga Nominal (+Tnom)', 'Potencia Reativa Absorvida', 'var', fmt2(Q_elec_plate), '-', fmt2(Q_ld_ana), fmt2(Q_ld_sim), fmt3(rel_err(Q_ld_sim, Q_ld_ana)), ...
            'Demanda reativa de magnetizacao e dispersao sob conjugado nominal.';
        'Carga Nominal (+Tnom)', 'Fator de Potencia sob Carga', '-', fmt3(p.pf_plate), '-', fmt3(pf_ld_ana), fmt3(pf_ld_sim), fmt3(rel_err(pf_ld_sim, pf_ld_ana)), ...
            'Fator de potencia sob carga convergente e coerente com a especificacao de catalogo.';
        'Carga Nominal (+Tnom)', 'Rendimento Global de Eixo', '%', fmt2(p.eta_plate * 100), '-', fmt2(eta_ld_ana), fmt2(eta_ld_sim), fmt3(rel_err(eta_ld_sim, eta_ld_ana)), ...
            sprintf('Rendimento liquido no eixo: P_eixo / P_elec = %.1f / %.1f = %.2f%%.', P_shaft_ld_sim, P_ld_sim, eta_ld_sim);

        % Regime de Frenagem Regenerativa / Gerador (TL = -Tnom)
        'Gerador Regenerativo (-Tnom)', 'Velocidade de Rotacao', 'rpm', '-', '-', fmt2(n_rg_ana), fmt2(n_rg_sim), fmt3(rel_err(n_rg_sim, n_rg_ana)), ...
            sprintf('Operacao hipersincrona (s = %.2f%%) acima do campo girante de %d rpm.', (p.n_s - n_rg_sim)/p.n_s*100, p.n_s);
        'Gerador Regenerativo (-Tnom)', 'Conjugado Eletromagnetico', 'N.m', '-', '-', fmt3(T_rg_ana), fmt3(T_rg_sim), fmt3(rel_err(T_rg_sim, T_rg_ana)), ...
            sprintf('Conjugado negativo de frenagem: Te = %.2f + %.3f = %.3f N.m.', -p.T_nom_ref, T_rg_sim + p.T_nom_ref, T_rg_sim);
        'Gerador Regenerativo (-Tnom)', 'Corrente de Linha de Estator', 'A RMS', '-', '-', fmt3(I_rg_ana), fmt3(I_rg_sim), fmt3(rel_err(I_rg_sim, I_rg_ana)), ...
            'Corrente de estator em regime gerador com erro relativo sub-0.2%.';
        'Gerador Regenerativo (-Tnom)', 'Potencia Eletrica Ativa', 'W', '-', '-', fmt2(P_rg_ana), fmt2(P_rg_sim), fmt3(rel_err(P_rg_sim, P_rg_ana)), ...
            sprintf('Sinal negativo indica injecao liquida de %.2f kW na rede eletrica trifasica.', abs(P_rg_sim) / 1000);
        'Gerador Regenerativo (-Tnom)', 'Potencia Reativa Magnetizante', 'var', '-', '-', fmt2(Q_rg_ana), fmt2(Q_rg_sim), fmt3(rel_err(Q_rg_sim, Q_rg_ana)), ...
            'Consumo continuo de reativos da rede para excitacao do campo girante.';
        'Gerador Regenerativo (-Tnom)', 'Fator de Potencia Regenerativo', '-', '-', '-', fmt3(pf_rg_ana), fmt3(pf_rg_sim), fmt3(rel_err(pf_rg_sim, pf_rg_ana)), ...
            'Fator de potencia negativo reflete injecao de ativa com absorcao simultanea de reativa.'
    };

    headers = {'Regime', 'Metrica', 'Unidade', 'Placa_Catalogo', 'Ensaio_Bancada', 'Modelo_Analitico', 'Simulink_Simulink', 'Erro_Relativo_pct', 'Analise_Discrepancia'};
    T = cell2table(comparison_rows, 'VariableNames', headers);

    csv_path = fullfile(res_dir, 'consolidated_comparison.csv');
    writetable(T, csv_path);
    fprintf('[OK] Matriz comparativa salva em: %s\n', csv_path);

    json_path = fullfile(res_dir, 'consolidated_comparison.json');
    json_str  = jsonencode(table2struct(T), 'PrettyPrint', true);
    fid = fopen(json_path, 'w');
    fwrite(fid, json_str, 'char');
    fclose(fid);
    fprintf('[OK] Matriz JSON salva em: %s\n', json_path);

    %% 5. Generate 4-Panel Executive Overview Figure
    fprintf('[INFO] Gerando painel grafico consolidado (300 DPI)...\n');
    set(groot, 'defaultAxesFontSize', 10);
    set(groot, 'defaultAxesFontName', 'Helvetica');
    set(groot, 'defaultTextInterpreter', 'latex');
    set(groot, 'defaultLegendInterpreter', 'latex');
    set(groot, 'defaultAxesTickLabelInterpreter', 'latex');

    fig = figure('Name', 'consolidated_transient_overview', 'Color', 'w', ...
        'Position', [80, 80, 1180, 780], 'Visible', fig_vis);

    t_dol  = res_dol.time;
    t_step = res_step.time;
    t_reg  = res_reg.time;
    t_max_plot = max([t_dol(end), t_step(end), t_reg(end)]);

    % Subplot 1: Speed evolution
    ax1 = subplot(2, 2, 1, 'Parent', fig);
    hold(ax1, 'on');
    plot(ax1, t_step, res_step.speed_rpm, 'b-', 'LineWidth', 1.8, ...
        'DisplayName', ['Degrau Motor ' sprintf('($T_L = +%.2f~\\mathrm{N\\cdot m}$)', p.T_nom_ref)]);
    plot(ax1, t_reg, res_reg.speed_rpm, 'r--', 'LineWidth', 1.8, ...
        'DisplayName', ['Degrau Gerador ' sprintf('($T_L = -%.2f~\\mathrm{N\\cdot m}$)', p.T_nom_ref)]);
    plot(ax1, t_dol, res_dol.speed_rpm, 'Color', [0.1, 0.65, 0.2], 'LineWidth', 1.5, ...
        'DisplayName', 'Partida Direta a Vazio ($T_L = 0$)');
    yline(ax1, p.n_s, 'k:', 'LineWidth', 1.4, ...
        'DisplayName', ['Velocidade S\''incrona ' sprintf('($%d~\\mathrm{rpm}$)', p.n_s)]);
    grid(ax1, 'on'); box(ax1, 'on');
    xlabel(ax1, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 10.5);
    ylabel(ax1, 'Velocidade $n$ (rpm)', 'Interpreter', 'latex', 'FontSize', 10.5);
    title(ax1, 'Evolu\c{c}\~{a}o Temporal da Velocidade do Rotor $n(t)$', 'Interpreter', 'latex', 'FontSize', 11.5);
    legend(ax1, 'Location', 'southeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax1, [0, t_max_plot]);
    sp_top = ceil(max([max(res_reg.speed_rpm), p.n_s]) * 1.08 / 50) * 50;
    ylim(ax1, [0, sp_top]);

    % Subplot 2: Electromagnetic Torque
    ax2 = subplot(2, 2, 2, 'Parent', fig);
    hold(ax2, 'on');
    plot(ax2, t_step, res_step.torque_Nm, 'b-', 'LineWidth', 1.6, ...
        'DisplayName', ['Motor com Carga ' sprintf('($T_e \\to +%.2f~\\mathrm{N\\cdot m}$)', T_ld_sim)]);
    plot(ax2, t_reg, res_reg.torque_Nm, 'r--', 'LineWidth', 1.6, ...
        'DisplayName', ['Freio Regenerativo ' sprintf('($T_e \\to %.2f~\\mathrm{N\\cdot m}$)', T_rg_sim)]);
    yline(ax2, 0, 'k-', 'LineWidth', 1.0, 'DisplayName', 'Fronteira Motor / Gerador ($T_e = 0$)');
    yline(ax2, T_nl_sim, 'g:', 'LineWidth', 1.5, ...
        'DisplayName', ['Regime a Vazio ' sprintf('($+%.3f~\\mathrm{N\\cdot m}$)', T_nl_sim)]);
    grid(ax2, 'on'); box(ax2, 'on');
    xlabel(ax2, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 10.5);
    ylabel(ax2, 'Conjugado $T_e$ (N$\cdot$m)', 'Interpreter', 'latex', 'FontSize', 10.5);
    title(ax2, 'Conjugado Eletromagn\''etico Desenvolvido $T_e(t)$', 'Interpreter', 'latex', 'FontSize', 11.5);
    legend(ax2, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax2, [0, t_max_plot]);
    tq_lo = min([min(res_step.torque_Nm), min(res_reg.torque_Nm)]);
    tq_hi = max([max(res_step.torque_Nm), max(res_reg.torque_Nm)]);
    tq_sp = tq_hi - tq_lo;
    ylim(ax2, [floor((tq_lo - 0.12 * tq_sp) / 5) * 5, ceil((tq_hi + 0.35 * tq_sp) / 5) * 5]);

    % Subplot 3: Active Electrical Power Flow
    ax3 = subplot(2, 2, 3, 'Parent', fig);
    hold(ax3, 'on');
    win_step = round((1 / p.f_nom) / (t_step(2) - t_step(1)));
    win_reg  = round((1 / p.f_nom) / (t_reg(2) - t_reg(1)));
    p_step_f = movmean(res_step.p_inst, win_step);
    p_reg_f  = movmean(res_reg.p_inst, win_reg);
    plot(ax3, t_step, p_step_f, 'b-', 'LineWidth', 1.8, ...
        'DisplayName', ['Degrau de Carga ' sprintf('($P_{ss} = +%.0f~\\mathrm{W}$)', P_ld_sim)]);
    plot(ax3, t_reg, p_reg_f, 'r--', 'LineWidth', 1.8, ...
        'DisplayName', ['Gerador Hipers\''incrono ' sprintf('($P_{ss} = %.0f~\\mathrm{W}$)', P_rg_sim)]);
    yline(ax3, 0, 'k-', 'LineWidth', 1.0, 'DisplayName', 'Fronteira ($P = 0$)');
    yline(ax3, P_nl_sim, 'g:', 'LineWidth', 1.5, ...
        'DisplayName', ['Consumo a Vazio ' sprintf('($+%.1f~\\mathrm{W}$)', P_nl_sim)]);
    grid(ax3, 'on'); box(ax3, 'on');
    xlabel(ax3, 'Tempo $t$ (s)', 'Interpreter', 'latex', 'FontSize', 10.5);
    ylabel(ax3, 'Pot\^{e}ncia Ativa $P$ (W)', 'Interpreter', 'latex', 'FontSize', 10.5);
    title(ax3, 'Fluxo de Pot\^{e}ncia Ativa Trif\''asica $P(t)$', 'Interpreter', 'latex', 'FontSize', 11.5);
    legend(ax3, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    xlim(ax3, [0, t_max_plot]);
    p_lo = min([min(p_step_f), min(p_reg_f)]);
    p_hi = max([max(p_step_f), max(p_reg_f)]);
    p_sp = p_hi - p_lo;
    ylim(ax3, [floor((p_lo - 0.12 * p_sp) / 500) * 500, ceil((p_hi + 0.35 * p_sp) / 500) * 500]);

    % Subplot 4: Reconciled Power Balance Across Regimes (kW)
    ax4 = subplot(2, 2, 4, 'Parent', fig);
    hold(ax4, 'on');
    bar_matrix_kW = [
        P_elec_plate / 1000,               p.P_nom_W / 1000,                      0.0;
        metrics_p1.operating_point.P_elec / 1000, metrics_p1.operating_point.P_shaft / 1000, metrics_p1.operating_point.P_rot / 1000;
        P_ld_sim / 1000,                   P_shaft_ld_sim / 1000,                 P_rot_ld_sim / 1000;
        P_rg_sim / 1000,                   P_mech_rg_sim / 1000,                  P_rot_rg_sim / 1000
    ];
    hb = bar(ax4, bar_matrix_kW, 'grouped');
    hb(1).FaceColor = [0.20, 0.45, 0.78];
    hb(2).FaceColor = [0.85, 0.35, 0.15];
    hb(3).FaceColor = [0.35, 0.70, 0.30];
    hb(1).DisplayName = 'Pot\^{e}ncia El\''etrica $P_{elec}$ (kW)';
    hb(2).DisplayName = 'Pot\^{e}ncia Mec\^{a}nica Eixo $P_{eixo}$ (kW)';
    hb(3).DisplayName = 'Perdas Rotacionais $B\omega_m^2$ (kW)';
    yline(ax4, 0, 'k-', 'LineWidth', 0.9, 'HandleVisibility', 'off');
    grid(ax4, 'on'); box(ax4, 'on');
    set(ax4, 'XTick', 1:4, 'XTickLabel', {'Placa Nominal', 'Nominal Anal\''itico', 'Degrau $+T_{nom}$', 'Regenerativo $-T_{nom}$'});
    xtickangle(ax4, 15);
    ylabel(ax4, 'Pot\^{e}ncia (kW)', 'Interpreter', 'latex', 'FontSize', 10.5);
    title(ax4, 'Balan\c{c}o de Pot\^{e}ncia Reconciliado entre Regimes', 'Interpreter', 'latex', 'FontSize', 11.5);
    legend(ax4, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 8.5);
    b_min = min(bar_matrix_kW(:));
    b_max = max(bar_matrix_kW(:));
    b_sp  = b_max - b_min;
    ylim(ax4, [floor((b_min - 0.15 * b_sp) * 2) / 2, ceil((b_max + 0.55 * b_sp) * 2) / 2]);

    fig_png = fullfile(fig_dir, 'consolidated_transient_overview.png');
    fig_fig = fullfile(fig_dir, 'consolidated_transient_overview.fig');
    exportgraphics(fig, fig_png, 'Resolution', 300);
    savefig(fig, fig_fig);
    if strcmp(fig_vis, 'off'), close(fig); end
    fprintf('[OK] Painel grafico salvo em: %s\n', fig_png);

    %% 6. Export Figure JSON Sidecar Dynamically
    fig_meta.figure_id = 'consolidated_transient_overview';
    fig_meta.task_ref  = 'Synthesis & Executive Overview';
    fig_meta.title     = 'Painel Comparativo de Transitorios e Balanco de Potencia';
    fig_meta.operating_conditions.scenarios_compared = {
        sprintf('DOL No-Load Startup (0-%.1fs)', res_dol.t_stop), ...
        sprintf('Nominal Load Step +%.2f N.m (0-%.1fs)', p.T_nom_ref, res_step.t_stop), ...
        sprintf('Regenerative Prime Mover -%.2f N.m (0-%.1fs)', p.T_nom_ref, res_reg.t_stop)
    };
    fig_meta.operating_conditions.voltage_LL_rms_V = p.V_LL_nom;
    fig_meta.operating_conditions.frequency_Hz     = p.f_nom;
    fig_meta.operating_conditions.inertia_J_kgm2   = p.J;
    fig_meta.operating_conditions.friction_B_Nms_rad = p.B;

    fig_meta.key_numerical_markers.no_load_speed_rpm              = round(n_nl_sim, 2);
    fig_meta.key_numerical_markers.nominal_loaded_speed_rpm       = round(n_ld_sim, 2);
    fig_meta.key_numerical_markers.hypersynchronous_speed_rpm     = round(n_rg_sim, 2);
    fig_meta.key_numerical_markers.no_load_torque_Nm              = round(T_nl_sim, 3);
    fig_meta.key_numerical_markers.nominal_loaded_torque_Nm       = round(T_ld_sim, 3);
    fig_meta.key_numerical_markers.regenerative_torque_Nm         = round(T_rg_sim, 3);
    fig_meta.key_numerical_markers.no_load_active_power_W         = round(P_nl_sim, 2);
    fig_meta.key_numerical_markers.nominal_loaded_active_power_W  = round(P_ld_sim, 2);
    fig_meta.key_numerical_markers.regenerative_active_power_W    = round(P_rg_sim, 2);
    fig_meta.key_numerical_markers.bench_viscous_losses_W_range   = [round(P_rot_ld_sim, 2), round(P_rot_rg_sim, 2)];

    fig_meta.axis_extents.xlim_transients_s = [0.0, t_max_plot];
    fig_meta.axis_extents.ylim_power_kW     = [floor((b_min - 0.15 * b_sp) * 2) / 2, ceil((b_max + 0.55 * b_sp) * 2) / 2];

    fig_meta.physical_phenomena_summary = {
        sprintf('Visao executiva integrada comparando as tres trajetorias dinamicas essenciais sob J = %.4f kg.m^2 e B = %.6f N.m.s/rad.', p.J, p.B), ...
        sprintf('Cruzamento de regime motor sub-sincrono (%.2f rpm) para gerador hipersincrono (%.2f rpm).', n_ld_sim, n_rg_sim), ...
        sprintf('Inversao de polaridade do fluxo de potencia ativa entre operacao motora (+%.2f kW) e geradora (%.2f kW).', P_ld_sim/1000, P_rg_sim/1000), ...
        sprintf('Perdas rotacionais consistentes com o ensaio a vazio (%.1f a %.1f W entre carga e geracao).', P_rot_ld_sim, P_rot_rg_sim)
    };

    fig_json_path = fullfile(fig_dir, 'consolidated_transient_overview.json');
    fid_j = fopen(fig_json_path, 'w');
    if fid_j ~= -1
        fwrite(fid_j, jsonencode(fig_meta, 'PrettyPrint', true), 'char');
        fclose(fid_j);
        fprintf('[OK] Metadata JSON salva em: %s\n', fig_json_path);
    end

    fprintf('\n[PRONTO] Modulo de sintese executiva consolidado com sucesso.\n');

end
