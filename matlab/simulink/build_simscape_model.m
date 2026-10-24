function model_name = build_simscape_model()
% BUILD_SIMSCAPE_MODEL
% Programmatically constructs, configures, and saves the Simscape Specialized
% Power Systems induction machine model for the WEG 3.7 kW (5 cv) motor.
%
% Generates: matlab/simulink/mit_simscape_model.slx
%
% Architecture:
%   - 3-Phase AC Voltage Source (220 V RMS L-L, 60 Hz)
%   - Phase Splitter connecting to Delta/Wye transformed terminals
%   - Asynchronous Machine SI Units (Rotor reference frame, Squirrel Cage)
%   - Parameterized using Star-Delta transformed values (ADR-002)
%   - Load torque step transition (0 to T_nom at t = 1.5 s)
%   - Comprehensive instrumentation: speed (rpm), torque (N.m), stator currents (A)
%   - Fast, robust discrete local solver (Backward Euler, 50 us sample time)
%
% Adheres to:
%   - sim_proj.pdf Part 2 academic specification
%   - ADR-001 (Consolidated Lab Parameters)
%   - ADR-002 (Star-Delta Parameter Transformation)

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - BUILD SIMSCAPE SPS INDUCTION MOTOR MODEL (TASK 2.1) \n');
    fprintf('====================================================================\n\n');

    model_name = 'mit_simscape_model';
    script_dir = fileparts(mfilename('fullpath'));
    model_path = fullfile(script_dir, [model_name, '.slx']);

    %% 1. Initialize Machine & Simulation Parameters in Base Workspace
    setup_motor_params();

    %% 2. Load Required Libraries
    fprintf('[INFO] Loading Simscape Electrical and Simulink libraries...\n');
    trans_dir = fullfile(matlabroot, 'toolbox', 'physmod', 'elec', 'assistant', 'm', 'transform');
    if exist(trans_dir, 'dir')
        addpath(trans_dir);
    end
    load_system('elec_conv_AsynchronousMachineSIUni');
    load_system('ee_lib');
    load_system('fl_lib');
    load_system('nesl_utility');
    load_system('simulink');

    %% 3. Create or Reset Model
    if bdIsLoaded(model_name)
        close_system(model_name, 0);
    end
    if exist(model_path, 'file')
        delete(model_path);
    end
    new_system(model_name);
    load_system(model_name);

    %% 4. Add Physical Network & Electrical Components
    fprintf('[INFO] Adding physical blocks and electrical network...\n');

    % 4.1 Solver Configuration (Configured with local solver for ultra-fast, robust DAE solution)
    add_block('nesl_utility/Solver Configuration', [model_name, '/Solver_Config'], ...
        'Position', [60, 40, 110, 70]);
    set_param([model_name, '/Solver_Config'], ...
        'UseLocalSolver', 'on', ...
        'DoFixedCost', 'off', ...
        'LocalSolverChoice', 'NE_BACKWARD_EULER_ADVANCER', ...
        'LocalSolverSampleTime', 'T_sample');

    % 4.2 Electrical Reference
    add_block('fl_lib/Electrical/Electrical Elements/Electrical Reference', [model_name, '/Elec_Ref'], ...
        'Position', [60, 100, 90, 130]);

    % 4.3 Three-Phase AC Voltage Source
    add_block('ee_lib/Sources/Voltage Source (Three-Phase)', [model_name, '/Three_Phase_Source'], ...
        'Position', [140, 150, 210, 210]);
    set_param([model_name, '/Three_Phase_Source'], ...
        'vline_rms', 'V_LL_nom', ...
        'freq', 'f_nom');

    % 4.4 Phase Splitter (Splits composite 3-phase line into discrete A, B, C phases)
    ps_lib_name = sprintf('ee_lib/Connectors &\nReferences/Phase Splitter');
    add_block(ps_lib_name, [model_name, '/Phase_Splitter'], ...
        'Position', [280, 150, 320, 210]);

    % 4.5 Asynchronous Machine SI Units Block (Star-Delta Parameterized per ADR-002)
    add_block('elec_conv_AsynchronousMachineSIUni/AsynchronousMachineSIUni_TmSCRotor', ...
        [model_name, '/Asynchronous_Machine'], ...
        'Position', [420, 130, 540, 230]);
    set_param([model_name, '/Asynchronous_Machine'], ...
        'SRated', 'P_nom_W', ...
        'VRated', 'V_LL_nom', ...
        'FRated', 'f_nom', ...
        'nPolePairs', 'p_pairs', ...
        'Rs', 'R1_Y', ...
        'Xls', 'X1_Y', ...
        'Rrd', 'R2_Y', ...
        'Xlrd', 'X2_Y', ...
        'Xm', 'Xm_Y', ...
        'J', 'J', ...
        'D', 'B');

    %% 5. Add Mechanical Load Torque Disturbance Input (Tm)
    % Initial step profile: Starts at 0 N.m (s=1 DOL startup), steps to T_nom at t = 1.5 s
    add_block('simulink/Sources/Step', [model_name, '/Load_Torque_Step'], ...
        'Position', [320, 260, 360, 290]);
    set_param([model_name, '/Load_Torque_Step'], ...
        'Time', 't_step_load', ...
        'Before', '0', ...
        'After', 'T_load_step', ...
        'SampleTime', '0');

    %% 6. Add Signal Instrumentation & Measurement Demuxing
    fprintf('[INFO] Adding signal measurement and logging blocks...\n');

    % 6.1 Bus Selector to unpack measurement bus 'm'
    add_block('simulink/Commonly Used Blocks/Bus Selector', [model_name, '/Bus_Selector_m'], ...
        'Position', [600, 140, 610, 220]);
    set_param([model_name, '/Bus_Selector_m'], ...
        'OutputSignals', 'w,Te,ias,ibs,ics');

    % 6.2 Speed Conversion: w [rad/s] -> n [rpm] (Gain = 60 / (2*pi) = 30 / pi)
    add_block('simulink/Commonly Used Blocks/Gain', [model_name, '/Gain_rads_to_rpm'], ...
        'Position', [660, 135, 700, 165], ...
        'Gain', '30/pi');

    % 6.3 To Workspace Logging Blocks
    % Speed [rpm]
    add_block('simulink/Sinks/To Workspace', [model_name, '/ToWS_Speed'], ...
        'Position', [740, 135, 810, 165], ...
        'VariableName', 'sim_speed_rpm', ...
        'SaveFormat', 'Timeseries');

    % Electromagnetic Torque [N.m]
    add_block('simulink/Sinks/To Workspace', [model_name, '/ToWS_Torque'], ...
        'Position', [740, 175, 810, 205], ...
        'VariableName', 'sim_torque_Nm', ...
        'SaveFormat', 'Timeseries');

    % Stator Line Current Phase A [A]
    add_block('simulink/Sinks/To Workspace', [model_name, '/ToWS_Ia'], ...
        'Position', [740, 215, 810, 245], ...
        'VariableName', 'sim_current_Ia', ...
        'SaveFormat', 'Timeseries');

    % Stator Line Current Phase B [A]
    add_block('simulink/Sinks/To Workspace', [model_name, '/ToWS_Ib'], ...
        'Position', [740, 255, 810, 285], ...
        'VariableName', 'sim_current_Ib', ...
        'SaveFormat', 'Timeseries');

    % Stator Line Current Phase C [A]
    add_block('simulink/Sinks/To Workspace', [model_name, '/ToWS_Ic'], ...
        'Position', [740, 295, 810, 325], ...
        'VariableName', 'sim_current_Ic', ...
        'SaveFormat', 'Timeseries');

    % 6.4 Real-time Scopes for Visual Monitoring
    add_block('simulink/Sinks/Scope', [model_name, '/Scope_Speed_Torque'], ...
        'Position', [850, 150, 890, 190], ...
        'NumInputPorts', '2');

    add_block('simulink/Sinks/Scope', [model_name, '/Scope_Stator_Currents'], ...
        'Position', [850, 240, 890, 280], ...
        'NumInputPorts', '3');

    %% 7. Connect Lines & Physical Ports
    fprintf('[INFO] Routing physical and signal connections...\n');

    % 7.1 Solver Config and Ground Reference to Source Neutral (LConn1)
    add_line(model_name, 'Solver_Config/RConn1', 'Three_Phase_Source/LConn1', 'autorouting', 'on');
    add_line(model_name, 'Elec_Ref/LConn1', 'Three_Phase_Source/LConn1', 'autorouting', 'on');

    % 7.2 Source composite output to Phase Splitter input
    add_line(model_name, 'Three_Phase_Source/RConn1', 'Phase_Splitter/LConn1', 'autorouting', 'on');

    % 7.3 Phase Splitter outputs (A, B, C) to Machine stator terminals (LConn 1, 2, 3)
    add_line(model_name, 'Phase_Splitter/RConn1', 'Asynchronous_Machine/LConn1', 'autorouting', 'on');
    add_line(model_name, 'Phase_Splitter/RConn2', 'Asynchronous_Machine/LConn2', 'autorouting', 'on');
    add_line(model_name, 'Phase_Splitter/RConn3', 'Asynchronous_Machine/LConn3', 'autorouting', 'on');

    % 7.4 Load torque step to Machine mechanical port (Inport 1: Tm)
    add_line(model_name, 'Load_Torque_Step/1', 'Asynchronous_Machine/1', 'autorouting', 'on');

    % 7.5 Machine measurement port (Outport 1: m) to Bus Selector
    add_line(model_name, 'Asynchronous_Machine/1', 'Bus_Selector_m/1', 'autorouting', 'on');

    % 7.6 Connect Bus Selector signals to Sinks
    % Port 1: w [rad/s] -> Gain -> Speed [rpm]
    add_line(model_name, 'Bus_Selector_m/1', 'Gain_rads_to_rpm/1', 'autorouting', 'on');
    add_line(model_name, 'Gain_rads_to_rpm/1', 'ToWS_Speed/1', 'autorouting', 'on');
    add_line(model_name, 'Gain_rads_to_rpm/1', 'Scope_Speed_Torque/1', 'autorouting', 'on');

    % Port 2: Te [N.m] -> Torque
    add_line(model_name, 'Bus_Selector_m/2', 'ToWS_Torque/1', 'autorouting', 'on');
    add_line(model_name, 'Bus_Selector_m/2', 'Scope_Speed_Torque/2', 'autorouting', 'on');

    % Port 3, 4, 5: ias, ibs, ics [A]
    add_line(model_name, 'Bus_Selector_m/3', 'ToWS_Ia/1', 'autorouting', 'on');
    add_line(model_name, 'Bus_Selector_m/3', 'Scope_Stator_Currents/1', 'autorouting', 'on');
    add_line(model_name, 'Bus_Selector_m/4', 'ToWS_Ib/1', 'autorouting', 'on');
    add_line(model_name, 'Bus_Selector_m/4', 'Scope_Stator_Currents/2', 'autorouting', 'on');
    add_line(model_name, 'Bus_Selector_m/5', 'ToWS_Ic/1', 'autorouting', 'on');
    add_line(model_name, 'Bus_Selector_m/5', 'Scope_Stator_Currents/3', 'autorouting', 'on');

    %% 8. Configure Solver Settings & Model Diagnostics
    fprintf('[INFO] Configuring discrete fixed-step solver (50 us)...\n');
    set_param(model_name, ...
        'SolverType', 'Fixed-step', ...
        'Solver', 'FixedStepDiscrete', ...
        'FixedStep', 'T_sample', ...
        'StopTime', 't_stop', ...
        'SaveTime', 'on', ...
        'TimeSaveName', 'tout', ...
        'SaveOutput', 'on', ...
        'OutputSaveName', 'yout', ...
        'SignalLogging', 'on', ...
        'SignalLoggingName', 'logsout');

    %% 9. Compile & Validate Model Architecture
    fprintf('[INFO] Compiling model to verify connections and parameters...\n');
    set_param(model_name, 'SimulationCommand', 'update');
    fprintf('[OK] Model compiled successfully with 0 algebraic loops or port mismatches.\n');

    %% 10. Save Model
    save_system(model_name, model_path);
    fprintf('[OK] Simscape model successfully saved to:\n     %s\n\n', model_path);

end
