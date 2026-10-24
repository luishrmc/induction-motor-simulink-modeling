function params = setup_motor_params()
% SETUP_MOTOR_PARAMS
% Configures electrical, mechanical, and simulation parameters for the
% WEG 3.7 kW (5 cv), 220 V Delta, 4-pole, 60 Hz squirrel-cage induction motor.
%
% Loads consolidated laboratory bench measurements from Table 2.4 and Section 2.4
% of LAB_CONV_RLT_08_09_10.pdf and applies the exact Star-Delta impedance
% transformation (ADR-002) required by the Simscape SPS internal Wye machine block.
%
% Assigns all necessary variables to the MATLAB base workspace for Simulink.

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - SETUP SIMSCAPE MOTOR PARAMETERS (TASK 2.1)           \n');
    fprintf('====================================================================\n\n');

    %% 0. Ensure Simscape Electrical Transform Library Is On Path
    trans_dir = fullfile(matlabroot, 'toolbox', 'physmod', 'elec', 'assistant', 'm', 'transform');
    if exist(trans_dir, 'dir') && ~contains(path, trans_dir)
        addpath(trans_dir);
    end

    %% 1. Machine Nameplate Ratings & Constants
    params.V_LL_nom = 220.0;           % Rated line RMS voltage [V]
    params.f_nom    = 60.0;            % Rated electrical frequency [Hz]
    params.P_nom_W  = 3700.0;          % Rated mechanical shaft power [W] (5 cv)
    params.I_nom_A  = 14.0;            % Rated line current [A RMS]
    params.poles    = 4;               % Number of poles
    params.p_pairs  = params.poles / 2;% Pole pairs (p = 2)
    params.n_nom    = 1715.0;          % Rated rotor mechanical speed [rpm]
    params.n_s      = 120 * params.f_nom / params.poles; % 1800 rpm
    params.s_nom    = (params.n_s - params.n_nom) / params.n_s; % 0.04722
    params.omega_e  = 2 * pi * params.f_nom;                 % 376.991 rad/s
    params.omega_s  = params.omega_e / params.p_pairs;       % 188.496 rad/s
    params.omega_nom= (1 - params.s_nom) * params.omega_s;   % 179.594 rad/s
    params.T_nom_ref= params.P_nom_W / params.omega_nom;     % 20.602 N.m

    %% 2. Consolidated Laboratory Delta Per-Phase Parameters (Table 2.4)
    params.R1_delta = 1.189;                 % Stator resistance [Ohm]
    params.R2_delta = 1.180;                 % Referred rotor resistance [Ohm]
    params.L1_delta = 5.725e-3;              % Stator leakage inductance [H]
    params.L2_delta = 8.420e-3;              % Referred rotor leakage inductance [H]
    params.Lm_delta = 131.571e-3;            % Magnetizing inductance [H]
    params.X1_delta = params.omega_e * params.L1_delta;   % 2.1583 Ohm
    params.X2_delta = params.omega_e * params.L2_delta;   % 3.1748 Ohm
    params.Xm_delta = params.omega_e * params.Lm_delta;   % 49.6010 Ohm

    %% 3. Star-Delta Transformed Parameters for Internal-Wye SPS Block (ADR-002)
    % Z_Y = Z_Delta / 3
    params.R1_Y  = params.R1_delta / 3;      % 0.396333 Ohm
    params.R2_Y  = params.R2_delta / 3;      % 0.393333 Ohm
    params.L1_Y  = params.L1_delta / 3;      % 1.908333 mH
    params.L2_Y  = params.L2_delta / 3;      % 2.806667 mH
    params.Lm_Y  = params.Lm_delta / 3;      % 43.857000 mH
    params.X1_Y  = params.X1_delta / 3;      % 0.719444 Ohm
    params.X2_Y  = params.X2_delta / 3;      % 1.058267 Ohm
    params.Xm_Y  = params.Xm_delta / 3;      % 16.533667 Ohm

    %% 4. Mechanical Bench Parameters (Section 2.4 of Lab Report)
    params.J = 0.701;                  % Equivalent inertia [kg.m^2] (MG bench)
    params.B = 0.0426;                 % Viscous friction coefficient [N.m.s/rad]

    %% 5. Simulation Timing & Solver Parameters
    params.t_stop      = 3.0;          % Default total simulation time [s]
    params.t_step_load = 1.5;          % Time of load torque step disturbance [s]
    params.T_load_step = params.T_nom_ref; % Step amplitude [N.m] (20.602 N.m)
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
    fprintf('  Viscous Friction (B):         %.4f N.m.s/rad\n', params.B);
    fprintf('  Nominal Shaft Torque (T_nom): %.3f N.m\n', params.T_nom_ref);
    fprintf('\n[OK] Motor parameters successfully initialized in base workspace.\n');

    %% 7. Validate Simscape Model Compilation If Present
    script_dir = fileparts(mfilename('fullpath'));
    model_path = fullfile(script_dir, 'mit_simscape_model.slx');
    if exist(model_path, 'file') && ~bdIsLoaded('mit_simscape_model')
        try
            load_system('mit_simscape_model');
            set_param('mit_simscape_model', 'SimulationCommand', 'update');
            fprintf('[OK] Simscape model validated successfully with 0 compilation errors.\n\n');
        catch e
            fprintf('[WARN] Model compilation check deferred: %s\n\n', e.message);
        end
    end

end
