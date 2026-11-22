function params = setup_parametros_Y()
% SETUP_PARAMETROS_Y
% Configures electrical, mechanical, and simulation parameters for the
% WEG 3.7 kW (5 cv), 220 V Delta, 4-pole, 60 Hz squirrel-cage induction motor.
%
% Consumes the single canonical parameter source simulacao_ele035/parametros_motor.m
% (consolidated from utils/data/01-07 CSVs, ADR-007) and maps impedances via
% the exact Star-Delta transformation (ADR-002) required by the Simulink SPS
% internal Wye machine block.
%
% Assigns all necessary variables to the MATLAB base workspace for Simulink.

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - SETUP Simulink MOTOR PARAMETERS (TASK 2.1)           \n');
    fprintf('====================================================================\n\n');

    %% 0. Ensure Simulink Electrical Transform Library & Canonical Params Are On Path
    script_dir = fileparts(mfilename('fullpath'));
    ele035_dir = fullfile(script_dir, '..', '..');
    if exist(ele035_dir, 'dir') && ~contains(path, ele035_dir)
        addpath(ele035_dir);
    end

    trans_dir = fullfile(matlabroot, 'toolbox', 'physmod', 'elec', 'assistant', 'm', 'transform');
    if exist(trans_dir, 'dir') && ~contains(path, trans_dir)
        addpath(trans_dir);
    end

    %% 1. Load Canonical Machine & Bench Parameters
    p = parametros_motor();

    params.V_LL_nom  = p.V_LL_nom;     % Rated line RMS voltage [V]
    params.f_nom     = p.f_nom;        % Rated electrical frequency [Hz]
    params.P_nom_W   = p.P_nom_W;      % Rated mechanical shaft power [W] (5 cv)
    params.I_nom_A   = p.I_nom_A;      % Rated line current [A RMS]
    params.poles     = p.poles;        % Number of poles
    params.p_pairs   = p.p_pairs;      % Pole pairs (p = 2)
    params.n_nom     = p.n_nom;        % Rated rotor mechanical speed [rpm]
    params.n_s       = p.n_s;          % Synchronous mechanical speed [rpm] (1800 rpm)
    params.s_nom     = p.s_nom;        % Nominal operating slip [-] (0.04722)
    params.omega_e   = p.omega_e;      % Electrical angular frequency [rad/s]
    params.omega_s   = p.omega_s;      % Synchronous mechanical speed [rad/s]
    params.omega_nom = p.omega_nom;    % Nominal rotor mechanical speed [rad/s]
    params.T_nom_ref = p.T_nom_ref;    % Nominal shaft torque [N.m] (20.602 N.m)
    params.pf_plate  = p.pf_plate;     % Nameplate power factor [-]
    params.eta_plate = p.eta_plate;    % Nameplate efficiency [-]

    %% 2. Delta Per-Phase Parameters (utils/data/05_Resumo_Circuito.csv)
    params.R1_delta = p.R1;            % Stator resistance [Ohm]
    params.R2_delta = p.R2;            % Referred rotor resistance [Ohm]
    params.L1_delta = p.L1;            % Stator leakage inductance [H]
    params.L2_delta = p.L2;            % Referred rotor leakage inductance [H]
    params.Lm_delta = p.Lm;            % Magnetizing inductance [H]
    params.X1_delta = p.X1;            % Stator leakage reactance [Ohm]
    params.X2_delta = p.X2;            % Rotor leakage reactance [Ohm]
    params.Xm_delta = p.Xm;            % Magnetizing reactance [Ohm]

    %% 3. Star-Delta Transformed Parameters for Internal-Wye SPS Block (ADR-002)
    % Z_Y = Z_Delta / 3
    params.R1_Y = p.R1_Y;              % 0.396333 Ohm
    params.R2_Y = p.R2_Y;              % 0.393333 Ohm
    params.L1_Y = p.L1_Y;              % 1.908333 mH
    params.L2_Y = p.L2_Y;              % 2.806667 mH
    params.Lm_Y = p.Lm_Y;              % 43.857000 mH
    params.X1_Y = p.X1_Y;              % 0.719444 Ohm
    params.X2_Y = p.X2_Y;              % 1.058267 Ohm
    params.Xm_Y = p.Xm_Y;              % 16.533667 Ohm

    %% 4. Mechanical Bench Parameters (utils/data/04_Mecanicos.csv, ADR-007)
    params.J = p.J;                    % Equivalent inertia [kg.m^2] (0.0555)
    params.B = p.B;                    % Viscous friction coefficient [N.m.s/rad] (0.003651)

    %% 5. Simulation Timing & Solver Parameters
    params.t_stop      = 3.0;          % Default total simulation time [s]
    params.t_step_load = 1.5;          % Time of load torque step disturbance [s]
    params.T_load_step = p.T_nom_ref;  % Step amplitude [N.m] (20.602 N.m)
    params.T_sample    = 50e-6;        % Discrete solver sample time [s] (50 us, 20 kHz)

    %% 6. Export Parameters to Base Workspace
    fields = fieldnames(params);
    for k = 1:length(fields)
        assignin('base', fields{k}, params.(fields{k}));
    end

    fprintf('  Rated Voltage (V_LL):        %.1f V RMS (60 Hz)\n', params.V_LL_nom);
    fprintf('  Stator Resistance (R1_Y):     %.4f Ohm (Delta: %.4f Ohm)\n', params.R1_Y, params.R1_delta);
    fprintf('  Rotor Resistance (R2_Y):      %.4f Ohm (Delta: %.4f Ohm)\n', params.R2_Y, params.R2_delta);
    fprintf('  Stator Inductance (L1_Y):     %.4f mH  (Delta: %.4f mH)\n', params.L1_Y * 1e3, params.L1_delta * 1e3);
    fprintf('  Rotor Inductance (L2_Y):      %.4f mH  (Delta: %.4f mH)\n', params.L2_Y * 1e3, params.L2_delta * 1e3);
    fprintf('  Magnetizing Inductance (Lm_Y):%.4f mH  (Delta: %.4f mH)\n', params.Lm_Y * 1e3, params.Lm_delta * 1e3);
    fprintf('  Total Inertia (J):            %.4f kg.m^2\n', params.J);
    fprintf('  Viscous Friction (B):         %.6f N.m.s/rad\n', params.B);
    fprintf('  Nominal Shaft Torque (T_nom): %.3f N.m\n', params.T_nom_ref);
    fprintf('\n[OK] Motor parameters successfully initialized in base workspace.\n');

    %% 7. Validate Simulink Model Compilation If Present
    model_path = fullfile(script_dir, 'mit_Simulink_model.slx');
    if exist(model_path, 'file') && ~bdIsLoaded('mit_Simulink_model')
        try
            load_system(model_path);
            set_param('mit_Simulink_model', 'SimulationCommand', 'update');
            fprintf('[OK] Simulink model validated successfully with 0 compilation errors.\n\n');
        catch e
            fprintf('[WARN] Model compilation check deferred: %s\n\n', e.message);
        end
    end

end
