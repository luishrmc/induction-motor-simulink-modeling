function results = run_sim_harness(scenario_name, varargin)
% RUN_SIM_HARNESS
% Automated batch simulation harness and scenario dispatcher for the WEG 3.7 kW
% Simscape Specialized Power Systems induction motor dynamic model.
%
% Tasks Addressed:
%   - Task 2.2: Analytical locked-rotor starting calculation (s = 1.0) and
%               harness setup.
%   - Task 3.1: DOL startup transient test (s = 1.0 comparison at no-load).
%   - Task 3.2: Nominal load torque step disturbance (TL = 0 -> +T_nom).
%   - Task 3.3: Regenerative braking / generator quadrant (TL = -T_nom).
%
% Syntax:
%   results = run_sim_harness()                   % Runs default nominal step (t = 3.0 s)
%   results = run_sim_harness('dol_startup')       % Runs no-load DOL startup (t = 2.0 s)
%   results = run_sim_harness('nominal_step')      % Runs rated step disturbance (t = 3.0 s)
%   results = run_sim_harness('regenerative')      % Runs regenerative braking (t = 3.0 s)
%
% Outputs:
%   results - Struct containing time-series telemetry, analytical s=1 baseline,
%             and steady-state convergence metrics.
%   Saves artifacts to out/results/sim_transient.mat and scenario-specific .mat files.
%
% Adheres to:
%   - ADR-001 (Consolidated Lab Parameters)
%   - ADR-002 (Star-Delta Transformation)
%   - ADR-004 (Tolerance Gate Verification)
%   - ADR-005 (Headless Batch Execution)

    if nargin < 1 || isempty(scenario_name)
        task_env = getenv('TASK_ID');
        if strcmp(task_env, '3.1')
            scenario_name = 'dol_startup';
        elseif strcmp(task_env, '3.2')
            scenario_name = 'nominal_step';
        elseif strcmp(task_env, '3.3')
            scenario_name = 'regenerative';
        else
            scenario_name = 'nominal_step';
        end
    end

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - SIMSCAPE SIMULATION HARNESS & SCENARIO DISPATCHER   \n');
    fprintf('  Active Scenario: %s\n', scenario_name);
    fprintf('====================================================================\n\n');

    %% 1. Initialize Machine & Simulation Parameters in Base Workspace
    params = setup_motor_params();
    model_name = 'mit_simscape_model';

    %% 2. Exact Analytical Locked-Rotor Starting Calculation (s = 1.0)
    fprintf('--------------------------------------------------------------------\n');
    fprintf('  ANALYTICAL LOCKED-ROTOR CALCULATION (s = 1.0, Standstill)\n');
    fprintf('--------------------------------------------------------------------\n');

    V_ph = params.V_LL_nom;                          % Delta connection: V_ph = 220 V
    Z1   = params.R1_delta + 1j * params.X1_delta;   % Stator impedance [Ohm]
    Z2   = params.R2_delta + 1j * params.X2_delta;   % Rotor impedance at s=1 [Ohm]
    Zm   = 1j * params.Xm_delta;                     % Magnetizing branch [Ohm]

    % Parallel branch at s = 1.0
    Zp_start  = (Zm * Z2) / (Zm + Z2);
    Zin_start = Z1 + Zp_start;
    R_in_start= real(Zin_start);
    X_in_start= imag(Zin_start);
    mag_Zin   = abs(Zin_start);

    % Starting currents (s = 1.0)
    I_ph_start   = V_ph / mag_Zin;
    I_line_start = sqrt(3) * I_ph_start;             % ~67.73 A RMS

    % Air-gap power and starting torque at s = 1.0
    I1_ph_vec_start = V_ph / Zin_start;
    E1_start        = V_ph - I1_ph_vec_start * Z1;
    I2_start        = E1_start / Z2;
    P_ag_start      = 3 * (abs(I2_start)^2) * params.R2_delta;
    T_start         = P_ag_start / params.omega_s;   % ~25.36 N.m

    fprintf('  Input Impedance Z_in(s=1):     %.4f + j%.4f Ohm (|Z| = %.4f Ohm)\n', ...
        R_in_start, X_in_start, mag_Zin);
    fprintf('  Phase Starting Current (RMS):  %.2f A\n', I_ph_start);
    fprintf('  Line Starting Current (RMS):   %.2f A (Theoretical s=1)\n', I_line_start);
    fprintf('  Air-gap Starting Power (P_ag): %.2f W\n', P_ag_start);
    fprintf('  Starting Torque (T_start):     %.2f N.m (Theoretical s=1)\n', T_start);
    fprintf('--------------------------------------------------------------------\n\n');

    % Store analytical baseline
    analytical_start.s            = 1.0;
    analytical_start.Z_in         = Zin_start;
    analytical_start.I_ph_start   = I_ph_start;
    analytical_start.I_line_start = I_line_start;
    analytical_start.P_ag_start   = P_ag_start;
    analytical_start.T_start      = T_start;

    %% 3. Dispatch Scenario Parameters
    switch lower(scenario_name)
        case 'dol_startup'
            % Task 3.1: DOL startup at no-load (T_L = 0)
            t_stop_sim   = 6.0;                      % Full electromechanical speed settling
            t_step_sim   = 3.0;                      % Transition time (irrelevant since amplitude is 0)
            T_step_after = 0.0;                      % No load torque applied
            scenario_desc= 'DOL Startup at No Load (T_L = 0)';

        case 'nominal_step'
            % Task 3.2: Startup at no load, nominal load step disturbance
            t_stop_sim   = 8.0;                      % Full electromechanical settling before and after step
            t_step_sim   = 5.0;                      % Step applied after full no-load settling (>4.5s)
            T_step_after = params.T_nom_ref;         % Step to +20.602 N.m
            scenario_desc= sprintf('Nominal Load Torque Step Disturbance (0 -> +%.2f N.m at t=%.1fs)', ...
                T_step_after, t_step_sim);

        case {'regenerative', 'regenerative_braking'}
            % Task 3.3: Step to negative load torque (generator prime mover)
            t_stop_sim   = 3.0;
            t_step_sim   = 1.5;
            T_step_after = -params.T_nom_ref;        % Step to -20.602 N.m (generates power)
            scenario_desc= sprintf('Regenerative Braking / Generator Step (0 -> -%.2f N.m at t=%.1fs)', ...
                abs(T_step_after), t_step_sim);

        otherwise
            error('Unknown scenario: %s. Valid: dol_startup, nominal_step, regenerative', scenario_name);
    end

    % Optional override of stop time and step time via varargin
    p = inputParser;
    addParameter(p, 'StopTime', [], @isnumeric);
    addParameter(p, 'StepTime', [], @isnumeric);
    parse(p, varargin{:});
    if ~isempty(p.Results.StopTime)
        t_stop_sim = p.Results.StopTime;
    end
    if ~isempty(p.Results.StepTime)
        t_step_sim = p.Results.StepTime;
    end

    fprintf('[INFO] Configuring scenario: %s\n', scenario_desc);

    % Update model parameters
    if ~bdIsLoaded(model_name)
        load_system(model_name);
    end

    step_blk = [model_name, '/Load_Torque_Step'];
    set_param(step_blk, 'Time', num2str(t_step_sim));
    set_param(step_blk, 'Before', '0');
    set_param(step_blk, 'After', num2str(T_step_after));
    set_param(model_name, 'StopTime', num2str(t_stop_sim));

    %% 4. Execute Dynamic Time-Domain Simulation
    fprintf('[INFO] Executing Simscape dynamic simulation (StopTime = %.1f s)...\n', t_stop_sim);
    t_start_sim = tic;
    simOut = sim(model_name, 'StopTime', num2str(t_stop_sim));
    elapsed_sim = toc(t_start_sim);
    fprintf('[OK] Simulation completed in %.2f seconds.\n\n', elapsed_sim);

    %% 5. Extract Signal Telemetry
    tout       = simOut.tout;
    speed_rpm  = simOut.sim_speed_rpm.Data;
    torque_Nm  = simOut.sim_torque_Nm.Data;
    current_Ia = simOut.sim_current_Ia.Data;
    current_Ib = simOut.sim_current_Ib.Data;
    current_Ic = simOut.sim_current_Ic.Data;

    % Compute envelope and instantaneous line current magnitude
    I_peak_transient = max(abs(current_Ia));
    I_start_sim_rms  = I_peak_transient / sqrt(2);   % Fundamental equivalent RMS

    % Compute starting torque peak
    T_peak_sim = max(torque_Nm(tout < 0.2));

    % Extract steady-state metrics at the end of the simulation horizon
    idx_ss = (tout >= (t_stop_sim - 0.2));
    ss_speed_rpm = mean(speed_rpm(idx_ss));
    ss_torque_Nm = mean(torque_Nm(idx_ss));
    ss_Ia_rms    = rms(current_Ia(idx_ss));

    % Compute instantaneous active and reactive powers via Clarke transform
    V_LL_rms = params.V_LL_nom;
    omega_e  = 2 * pi * params.f_nom;
    V_m_ph   = sqrt(2) * (V_LL_rms / sqrt(3));
    Va_sin   = V_m_ph * sin(omega_e * tout);
    Vb_sin   = V_m_ph * sin(omega_e * tout - 2*pi/3);
    Vc_sin   = V_m_ph * sin(omega_e * tout + 2*pi/3);

    valpha   = sqrt(2/3) * (Va_sin - 0.5*Vb_sin - 0.5*Vc_sin);
    vbeta    = sqrt(2/3) * (sqrt(3)/2 * Vb_sin - sqrt(3)/2 * Vc_sin);
    ialpha   = sqrt(2/3) * (current_Ia - 0.5*current_Ib - 0.5*current_Ic);
    ibeta    = sqrt(2/3) * (sqrt(3)/2 * current_Ib - sqrt(3)/2 * current_Ic);

    p_inst   = valpha .* ialpha + vbeta .* ibeta;
    q_inst   = vbeta .* ialpha - valpha .* ibeta;

    ss_P_W   = mean(p_inst(idx_ss));
    ss_Q_var = abs(mean(q_inst(idx_ss)));

    fprintf('--------------------------------------------------------------------\n');
    fprintf('  DYNAMIC SIMULATION TELEMETRY SUMMARY\n');
    fprintf('--------------------------------------------------------------------\n');
    fprintf('  Simulated Peak Inrush Current: %.2f A (%.2f A RMS equivalent)\n', ...
        I_peak_transient, I_start_sim_rms);
    fprintf('  Theoretical Starting Current:  %.2f A RMS (Delta = %+.2f %%)\n', ...
        I_line_start, ((I_start_sim_rms - I_line_start)/I_line_start)*100);
    fprintf('  Simulated Peak Dynamic Torque: %.2f N.m\n', T_peak_sim);
    fprintf('  Theoretical Starting Torque:   %.2f N.m (s = 1.0 steady-state)\n', T_start);
    fprintf('  Steady-State Speed:            %.1f rpm\n', ss_speed_rpm);
    fprintf('  Steady-State Developed Torque: %.2f N.m\n', ss_torque_Nm);
    fprintf('  Steady-State Line Current:     %.2f A RMS\n', ss_Ia_rms);
    fprintf('  Steady-State Active Power:     %.2f W\n', ss_P_W);
    fprintf('  Steady-State Reactive Power:   %.2f var\n', ss_Q_var);
    fprintf('--------------------------------------------------------------------\n\n');

    %% 6. Package Results Structure
    results.scenario           = scenario_name;
    results.scenario_desc      = scenario_desc;
    results.t_stop             = t_stop_sim;
    results.t_step             = t_step_sim;
    results.T_step_val         = T_step_after;
    results.time               = tout;
    results.speed_rpm          = speed_rpm;
    results.torque_Nm          = torque_Nm;
    results.current_Ia         = current_Ia;
    results.current_Ib         = current_Ib;
    results.current_Ic         = current_Ic;
    results.p_inst             = p_inst;
    results.q_inst             = q_inst;
    results.analytical_start   = analytical_start;
    results.telemetry.I_peak   = I_peak_transient;
    results.telemetry.I_rms_sim= I_start_sim_rms;
    results.telemetry.T_peak   = T_peak_sim;
    results.telemetry.ss_speed = ss_speed_rpm;
    results.telemetry.ss_torque= ss_torque_Nm;
    results.telemetry.ss_current=ss_Ia_rms;
    results.telemetry.ss_P_W   = ss_P_W;
    results.telemetry.ss_Q_var = ss_Q_var;

    %% 7. Export Baseline Artifacts to out/results/
    out_dir = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'out', 'results');
    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end

    % Standard generic output checked by simulink-gate.py
    mat_path = fullfile(out_dir, 'sim_transient.mat');
    save(mat_path, 'results');
    fprintf('[OK] Saved primary telemetry artifact to %s\n', mat_path);

    % Task-specific output
    task_mat = fullfile(out_dir, sprintf('sim_transient_%s.mat', scenario_name));
    save(task_mat, 'results');
    fprintf('[OK] Saved scenario telemetry artifact to %s\n', task_mat);

    % Also save comparison JSON for tolerance gate
    if strcmp(scenario_name, 'dol_startup')
        % Task 3.1 specific artifacts
        mat_31 = fullfile(out_dir, 'sim_transient_3.1.mat');
        save(mat_31, 'results');
        
        json_31 = fullfile(out_dir, 'comparison_3.1.json');
        comp_data.analytical.n_noload_rpm     = 1775.52;
        comp_data.analytical.I_line_noload    = 8.49;
        comp_data.analytical.T_em_noload      = 7.92;
        comp_data.simulated.n_noload_rpm      = ss_speed_rpm;
        comp_data.simulated.I_line_noload     = ss_Ia_rms;
        comp_data.simulated.T_em_noload       = ss_torque_Nm;

        fid = fopen(json_31, 'w');
        if fid ~= -1
            fwrite(fid, jsonencode(comp_data), 'char');
            fclose(fid);
            fprintf('[OK] Saved comparison JSON to %s\n\n', json_31);
        end
    elseif strcmp(scenario_name, 'nominal_step')
        % Task 3.2 specific artifacts
        mat_32 = fullfile(out_dir, 'sim_transient_3.2.mat');
        save(mat_32, 'results');

        json_32 = fullfile(out_dir, 'comparison_3.2.json');
        % Analytical metrics for T_L = 20.602 N.m
        comp_data.analytical.n_nom_rpm     = 1700.4;
        comp_data.analytical.T_em_nom      = 28.188;
        comp_data.analytical.I_line_nom    = 18.193;
        comp_data.analytical.P_elec_nom    = 5753.53;
        comp_data.analytical.Q_elec_nom    = 3867.56;

        comp_data.simulated.n_nom_rpm      = ss_speed_rpm;
        comp_data.simulated.T_em_nom       = ss_torque_Nm;
        comp_data.simulated.I_line_nom     = ss_Ia_rms;
        comp_data.simulated.P_elec_nom     = ss_P_W;
        comp_data.simulated.Q_elec_nom     = ss_Q_var;

        fid = fopen(json_32, 'w');
        if fid ~= -1
            fwrite(fid, jsonencode(comp_data), 'char');
            fclose(fid);
            fprintf('[OK] Saved comparison JSON to %s\n\n', json_32);
        end
    else
        json_path = fullfile(out_dir, 'comparison_2.2.json');
        comp_data.analytical.I_start_line = I_line_start;
        comp_data.analytical.T_start      = T_start;
        comp_data.simulated.I_start_line  = I_start_sim_rms;
        comp_data.simulated.T_start_peak  = T_peak_sim;
        comp_data.simulated.ss_speed_rpm  = ss_speed_rpm;
        comp_data.simulated.ss_torque_Nm  = ss_torque_Nm;

        fid = fopen(json_path, 'w');
        if fid ~= -1
            fwrite(fid, jsonencode(comp_data), 'char');
            fclose(fid);
            fprintf('[OK] Saved comparison JSON to %s\n\n', json_path);
        end
    end

    fprintf('[PASS] Simulation Harness execution complete (%s).\n', scenario_name);

end
