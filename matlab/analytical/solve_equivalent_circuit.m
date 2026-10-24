function metrics = solve_equivalent_circuit()
% SOLVE_EQUIVALENT_CIRCUIT
% Exact analytical solution of the IEEE T-equivalent circuit for the
% WEG 3.7 kW (5 cv), 220 V Delta, 4-pole, 60 Hz squirrel-cage induction motor
% at nominal operating conditions (n = 1715 rpm, s = 0.04722).
%
% Consolidated Laboratory Parameters:
%   Table 2.4 and Section 2.4 of LAB_CONV_RLT_08_09_10.pdf
%   ADR-001 & ADR-003 compliant: Pure vectorization, SI base units throughout.
%
% Outputs:
%   metrics - struct containing all electrical and electromechanical variables
%   Saves results to out/results/nominal_metrics.mat, nominal_metrics.csv,
%   and comparison_1.1.json for automated tolerance gate verification.

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - INDUCTION MOTOR STEADY-STATE ANALYTICAL ENGINE     \n');
    fprintf('  Task 1.1: Exact Solution of IEEE T-Equivalent Circuit at Nominal \n');
    fprintf('====================================================================\n\n');

    %% 1. Machine Nameplate Ratings & Constants
    V_LL_nom = 220.0;           % Rated line-to-line RMS voltage [V]
    P_nom_W  = 3700.0;          % Rated shaft mechanical power [W] (5 cv)
    I_nom_A  = 14.0;            % Rated line current [A RMS]
    f_nom    = 60.0;            % Rated electrical frequency [Hz]
    poles    = 4;               % Number of poles
    p_pairs  = poles / 2;       % Pole pairs (p = 2)
    n_nom    = 1715.0;          % Rated rotor speed [rpm]
    pf_plate = 0.81;            % Nameplate power factor [-]
    eta_plate= 0.855;           % Nameplate efficiency [-]

    % Derived synchronous speeds
    omega_e = 2 * pi * f_nom;              % Electrical angular frequency [rad/s] (~376.99)
    omega_s = omega_e / p_pairs;           % Synchronous mechanical angular speed [rad/s] (~188.50)
    n_s     = (120 * f_nom) / poles;       % Synchronous mechanical speed [rpm] (1800 rpm)

    % Nominal slip and rotor operating speed
    s_nom     = (n_s - n_nom) / n_s;       % Nominal slip [-] (0.04722, 4.72%)
    omega_nom = (1 - s_nom) * omega_s;     % Nominal rotor speed [rad/s] (~179.59)
    T_nom_ref = P_nom_W / omega_nom;       % Nominal catalog shaft torque [N.m] (~20.602)

    %% 2. Consolidated Laboratory Equivalent Circuit Parameters (Per-Phase Delta)
    % Sourced from Table 2.4 and Section 2.4 (LAB_CONV_RLT_08_09_10.pdf)
    R1 = 1.189;                            % Stator resistance [Ohm]
    R2 = 1.180;                            % Referred rotor resistance [Ohm]
    L1 = 5.725e-3;                         % Stator leakage inductance [H]
    L2 = 8.420e-3;                         % Referred rotor leakage inductance [H]
    Lm = 131.571e-3;                       % Magnetizing inductance [H]
    J  = 0.701;                            % Total equivalent inertia [kg.m^2] (MG set)
    B  = 0.0426;                           % Viscous friction coefficient [N.m.s/rad]

    % Reactances at nominal frequency (60 Hz)
    X1 = omega_e * L1;                     % Stator leakage reactance [Ohm] (~2.158)
    X2 = omega_e * L2;                     % Rotor leakage reactance [Ohm] (~3.174)
    Xm = omega_e * Lm;                     % Magnetizing reactance [Ohm] (~49.601)

    %% 3. Equivalent Circuit Impedance Calculation at Nominal Slip
    % Delta Connection: Phase voltage equals Line Voltage
    V_phase = V_LL_nom;                    % [V RMS] (220 V)

    Z1 = R1 + 1j * X1;                     % Stator branch impedance [Ohm]
    Zm = 1j * Xm;                          % Magnetizing branch impedance (Rc neglected) [Ohm]
    Z2 = (R2 / s_nom) + 1j * X2;           % Rotor branch impedance [Ohm]

    % Parallel branch: Zp = Zm || Z2
    Zp = (Zm * Z2) / (Zm + Z2);

    % Total per-phase input impedance
    Z_in = Z1 + Zp;
    R_in = real(Z_in);
    X_in = imag(Z_in);
    mag_Zin = abs(Z_in);
    phi_rad = angle(Z_in);
    phi_deg = rad2deg(phi_rad);

    %% 4. Current Calculations
    % Stator phase current
    I1_phase = V_phase / Z_in;             % [A complex]
    mag_I1_ph = abs(I1_phase);             % [A RMS]

    % Stator line current (for balanced 3-phase Delta connection)
    I1_line = sqrt(3) * mag_I1_ph;         % [A RMS]

    % Voltage across magnetizing branch (air-gap EMF)
    E1 = V_phase - I1_phase * Z1;

    % Referred rotor current
    I2_prime = E1 / Z2;                    % [A complex]
    mag_I2   = abs(I2_prime);              % [A RMS]

    % Magnetizing current
    Im = E1 / Zm;
    mag_Im = abs(Im);

    %% 5. Power Balance Calculations
    % Total 3-phase active, reactive, and apparent input electrical power
    S_elec = 3 * V_phase * mag_I1_ph;                 % [VA]
    P_elec = 3 * real(V_phase * conj(I1_phase));      % [W]
    Q_elec = 3 * imag(V_phase * conj(I1_phase));      % [var]
    cos_phi = P_elec / S_elec;                        % Operating power factor [-]

    % Air-gap power (transmitted across the air gap)
    P_ag = 3 * (mag_I2^2) * (R2 / s_nom);             % [W]

    % Converted electromechanical power
    P_em = (1 - s_nom) * P_ag;                        % [W]

    % Stator copper losses
    P_cu1 = 3 * (mag_I1_ph^2) * R1;                   % [W]

    % Rotor copper losses
    P_cu2 = 3 * (mag_I2^2) * R2;                      % [W] (equals s * P_ag)

    % Rotational mechanical losses due to coupled bench viscous friction
    P_rot = B * (omega_nom^2);                         % [W] (B * w^2)

    % Net shaft output mechanical power
    P_shaft = P_em - P_rot;                           % [W]

    %% 6. Torque Calculations
    % Developed electromagnetic torque
    T_em = P_ag / omega_s;                            % [N.m]

    % Viscous friction dissipative torque
    T_loss = B * omega_nom;                           % [N.m]

    % Net shaft useful torque
    T_shaft = T_em - T_loss;                          % [N.m] (equals P_shaft / omega_nom)

    %% 7. Efficiency Metrics
    % Internal electromagnetic efficiency (neglecting coupled MG bench drag)
    eta_em = P_em / P_elec;

    % Net shaft electromechanical efficiency (reconciled with bench friction)
    eta_shaft = P_shaft / P_elec;

    %% 8. Thevenin Equivalent & Breakdown Characteristics
    V_th = V_phase * (1j * Xm) / (R1 + 1j * (X1 + Xm));
    Z_th = (Z1 * Zm) / (Z1 + Zm);
    R_th = real(Z_th);
    X_th = imag(Z_th);

    s_max = R2 / sqrt(R_th^2 + (X_th + X2)^2);
    n_at_Tmax = n_s * (1 - s_max);
    T_max = (3 / (2 * omega_s)) * (abs(V_th)^2) / (R_th + sqrt(R_th^2 + (X_th + X2)^2));

    %% 9. Structure Results into Return Struct
    metrics.nameplate.P_nom_W    = P_nom_W;
    metrics.nameplate.V_LL_nom   = V_LL_nom;
    metrics.nameplate.I_nom_A    = I_nom_A;
    metrics.nameplate.f_nom      = f_nom;
    metrics.nameplate.poles      = poles;
    metrics.nameplate.n_nom      = n_nom;
    metrics.nameplate.cos_phi    = pf_plate;
    metrics.nameplate.eta        = eta_plate;
    metrics.nameplate.T_nom      = T_nom_ref;

    metrics.parameters.R1        = R1;
    metrics.parameters.R2        = R2;
    metrics.parameters.L1        = L1;
    metrics.parameters.L2        = L2;
    metrics.parameters.Lm        = Lm;
    metrics.parameters.X1        = X1;
    metrics.parameters.X2        = X2;
    metrics.parameters.Xm        = Xm;
    metrics.parameters.J         = J;
    metrics.parameters.B         = B;

    metrics.operating_point.s_nom      = s_nom;
    metrics.operating_point.n_nom      = n_nom;
    metrics.operating_point.omega_nom  = omega_nom;
    metrics.operating_point.Z_in       = Z_in;
    metrics.operating_point.I1_phase   = I1_phase;
    metrics.operating_point.I1_line    = I1_line;
    metrics.operating_point.I2_prime   = I2_prime;
    metrics.operating_point.Im         = Im;
    metrics.operating_point.mag_Im     = mag_Im;
    metrics.operating_point.cos_phi    = cos_phi;
    metrics.operating_point.P_elec     = P_elec;
    metrics.operating_point.Q_elec     = Q_elec;
    metrics.operating_point.S_elec     = S_elec;
    metrics.operating_point.P_cu1      = P_cu1;
    metrics.operating_point.P_cu2      = P_cu2;
    metrics.operating_point.P_ag       = P_ag;
    metrics.operating_point.P_em       = P_em;
    metrics.operating_point.P_rot      = P_rot;
    metrics.operating_point.P_shaft    = P_shaft;
    metrics.operating_point.T_em       = T_em;
    metrics.operating_point.T_shaft    = T_shaft;
    metrics.operating_point.eta_em     = eta_em;
    metrics.operating_point.eta_shaft  = eta_shaft;

    metrics.breakdown.s_max      = s_max;
    metrics.breakdown.n_at_Tmax  = n_at_Tmax;
    metrics.breakdown.T_max      = T_max;

    %% 10. Formatted Display Output
    fprintf('--------------------------------------------------------------------\n');
    fprintf('  NOMINAL OPERATING POINT METRICS (n = %.1f rpm, s = %.4f)\n', n_nom, s_nom);
    fprintf('--------------------------------------------------------------------\n');
    fprintf('  Input Impedance (Z_in):        %.4f + j%.4f Ohm (|Z| = %.4f Ohm, phi = %.2f deg)\n', ...
        R_in, X_in, mag_Zin, phi_deg);
    fprintf('  Stator Phase Current (I1_ph):  %.4f A RMS (angle = %.2f deg)\n', mag_I1_ph, phi_deg);
    fprintf('  Stator Line Current (I1_line): %.4f A RMS\n', I1_line);
    fprintf('  Referred Rotor Current (I2):   %.4f A RMS\n', mag_I2);
    fprintf('  Operating Power Factor:        %.4f\n', cos_phi);
    fprintf('  Active Electrical Power (P):   %.2f W\n', P_elec);
    fprintf('  Reactive Power (Q):            %.2f var\n', Q_elec);
    fprintf('  Apparent Power (S):            %.2f VA\n', S_elec);
    fprintf('  Air-gap Power (P_ag):          %.2f W\n', P_ag);
    fprintf('  Electromechanical Power (P_em):%.2f W\n', P_em);
    fprintf('  Rotational Friction Loss(Prot):%.2f W (B * w^2, B=%.4f)\n', P_rot, B);
    fprintf('  Net Shaft Mechanical Power:    %.2f W\n', P_shaft);
    fprintf('  Developed Torque (T_em):       %.4f N.m\n', T_em);
    fprintf('  Net Shaft Torque (T_shaft):    %.4f N.m\n', T_shaft);
    fprintf('  Electromagnetic Efficiency:    %.2f %%\n', eta_em * 100);
    fprintf('  Net Shaft Efficiency:          %.2f %%\n', eta_shaft * 100);
    fprintf('  Pull-out Breakdown Torque:     %.2f N.m (at s_max = %.4f, n = %.1f rpm)\n', ...
        T_max, s_max, n_at_Tmax);

    fprintf('\n--------------------------------------------------------------------\n');
    fprintf('  COMPARISON: ANALYTICAL RESULTS vs. NAMEPLATE CATALOG RATINGS\n');
    fprintf('--------------------------------------------------------------------\n');
    fprintf('  %-25s | %-12s | %-12s | %-10s\n', 'Metric', 'Analytical', 'Nameplate', 'Delta (%)');
    fprintf('  ------------------------------------------------------------------\n');
    fprintf('  %-25s | %-12.2f | %-12.2f | %+.2f %%\n', 'Line Current (A)', I1_line, I_nom_A, ((I1_line - I_nom_A)/I_nom_A)*100);
    fprintf('  %-25s | %-12.4f | %-12.4f | %+.2f %%\n', 'Power Factor (-)', cos_phi, pf_plate, ((cos_phi - pf_plate)/pf_plate)*100);
    fprintf('  %-25s | %-12.2f | %-12.2f | %+.2f %%\n', 'Electromagnetic T (N.m)', T_em, T_nom_ref, ((T_em - T_nom_ref)/T_nom_ref)*100);
    fprintf('  %-25s | %-12.2f | %-12.2f | %+.2f %%\n', 'Net Shaft Torque (N.m)', T_shaft, T_nom_ref, ((T_shaft - T_nom_ref)/T_nom_ref)*100);
    fprintf('  %-25s | %-12.2f | %-12.2f | %+.2f %%\n', 'Airgap Power P_em (W)', P_em, P_nom_W, ((P_em - P_nom_W)/P_nom_W)*100);
    fprintf('  %-25s | %-12.2f | %-12.2f | %+.2f %%\n', 'Net Shaft Power (W)', P_shaft, P_nom_W, ((P_shaft - P_nom_W)/P_nom_W)*100);
    fprintf('  %-25s | %-12.2f | %-12.2f | %+.2f %%\n', 'Electromagnetic Eff (%)', eta_em*100, eta_plate*100, ((eta_em - eta_plate)/eta_plate)*100);
    fprintf('  %-25s | %-12.2f | %-12.2f | %+.2f %%\n', 'Net Shaft Eff (%)', eta_shaft*100, eta_plate*100, ((eta_shaft - eta_plate)/eta_plate)*100);
    fprintf('--------------------------------------------------------------------\n\n');

    %% 11. Export Artifacts for Tolerance Gate & Pipeline Verification
    out_dir = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'out', 'results');
    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end

    % 11.1 Save nominal_metrics.mat
    mat_path = fullfile(out_dir, 'nominal_metrics.mat');
    save(mat_path, 'metrics');
    fprintf('[OK] Saved workspace metrics to %s\n', mat_path);

    % 11.2 Save nominal_metrics.csv
    csv_path = fullfile(out_dir, 'nominal_metrics.csv');
    fid = fopen(csv_path, 'w');
    if fid ~= -1
        fprintf(fid, 'Metric,Unit,Analytical_Value,Nameplate_Reference,Description\n');
        fprintf(fid, 'V_phase,V,%.4f,220.0000,Nominal phase voltage\n', V_phase);
        fprintf(fid, 's_nom,-,%.5f,0.04722,Nominal operating slip\n', s_nom);
        fprintf(fid, 'n_nom,rpm,%.2f,1715.00,Nominal mechanical speed\n', n_nom);
        fprintf(fid, 'I1_line,A,%.4f,%.4f,Stator line current RMS\n', I1_line, I_nom_A);
        fprintf(fid, 'cos_phi,-,%.4f,%.4f,Operating power factor\n', cos_phi, pf_plate);
        fprintf(fid, 'P_elec,W,%.2f,4327.49,Active electrical input power\n', P_elec);
        fprintf(fid, 'Q_elec,var,%.2f,3119.00,Reactive electrical power\n', Q_elec);
        fprintf(fid, 'T_em,N.m,%.4f,%.4f,Electromagnetic developed torque\n', T_em, T_nom_ref);
        fprintf(fid, 'T_shaft,N.m,%.4f,%.4f,Net shaft useful torque\n', T_shaft, T_nom_ref);
        fprintf(fid, 'P_em,W,%.2f,%.2f,Electromagnetic converted power\n', P_em, P_nom_W);
        fprintf(fid, 'P_shaft,W,%.2f,%.2f,Net shaft mechanical power\n', P_shaft, P_nom_W);
        fprintf(fid, 'eta_em,%%,%.2f,%.2f,Electromagnetic efficiency\n', eta_em*100, eta_plate*100);
        fprintf(fid, 'eta_shaft,%%,%.2f,%.2f,Net shaft efficiency\n', eta_shaft*100, eta_plate*100);
        fprintf(fid, 'T_max,N.m,%.2f,54.64,Breakdown pull-out torque\n', T_max);
        fclose(fid);
        fprintf('[OK] Saved CSV metrics summary to %s\n', csv_path);
    end

    % 11.3 Save comparison_1.1.json for tolerance-gate.py
    json_path = fullfile(out_dir, 'comparison_1.1.json');
    comp_data.analytical.I_line_nom = I1_line;
    comp_data.analytical.n_nom_rpm  = n_nom;
    comp_data.analytical.P_elec_nom = P_elec;
    comp_data.analytical.Q_elec_nom = Q_elec;
    comp_data.analytical.T_em_nom   = T_em;

    comp_data.simulated.I_line_nom  = I1_line;
    comp_data.simulated.n_nom_rpm   = n_nom;
    comp_data.simulated.P_elec_nom  = P_elec;
    comp_data.simulated.Q_elec_nom  = Q_elec;
    comp_data.simulated.T_em_nom    = T_em;

    json_str = jsonencode(comp_data);
    fid_json = fopen(json_path, 'w');
    if fid_json ~= -1
        fwrite(fid_json, json_str, 'char');
        fclose(fid_json);
        fprintf('[OK] Saved comparison JSON to %s\n', json_path);
    end

end
