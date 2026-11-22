function p = parametros_motor()
% PARAMETROS_MOTOR
% Single canonical source of motor nameplate, equivalent-circuit, and
% mechanical bench parameters for the UFMG ELE035 induction motor project.
%
% Machine: WEG 3~ 100L, 3.7 kW (5 cv), 220 V (Delta), 4 poles, 60 Hz.
%
% Ground-truth laboratory sources:
%   - utils/data/01_Ensaio_CC.csv
%   - utils/data/02_Ensaio_Vazio.csv
%   - utils/data/03_Rotor_Bloqueado.csv
%   - utils/data/04_Mecanicos.csv        (B = 0.003651 N.m.s/rad, J = 0.0555 kg.m^2)
%   - utils/data/05_Resumo_Circuito.csv  (R1, R2', X1, X2', Xm, L1, L2', Lm)
%   - utils/data/07_dados_de_placa.csv   (WEG nameplate ratings)
%
% Output:
%   p - struct containing nameplate, Delta equivalent-circuit, Star-Delta
%       Wye-mapped (Y) Simulink SPS parameters, and mechanical constants
%       in base SI units.

    %% 1. Nameplate Ratings (utils/data/07_dados_de_placa.csv)
    p.V_LL_nom  = 220.0;          % Rated line-to-line RMS voltage [V]
    p.f_nom     = 60.0;           % Rated electrical frequency [Hz]
    p.poles     = 4;              % Number of stator poles [-]
    p.p_pairs   = p.poles / 2;    % Number of pole pairs [-]
    p.P_nom_W   = 3700.0;         % Rated shaft mechanical power [W] (5 cv)
    p.I_nom_A   = 14.0;           % Rated line current in Delta [A RMS]
    p.n_nom     = 1715.0;         % Rated rotor speed [rpm]
    p.pf_plate  = 0.81;           % Nameplate power factor [-]
    p.eta_plate = 0.855;          % Nameplate efficiency [-]

    %% 2. Derived Synchronous & Nominal Kinematic Quantities
    p.omega_e   = 2 * pi * p.f_nom;              % Electrical angular frequency [rad/s]
    p.omega_s   = p.omega_e / p.p_pairs;         % Synchronous mechanical speed [rad/s]
    p.n_s       = (120 * p.f_nom) / p.poles;     % Synchronous mechanical speed [rpm]
    p.s_nom     = (p.n_s - p.n_nom) / p.n_s;     % Nominal operating slip [-]
    p.omega_nom = (1 - p.s_nom) * p.omega_s;     % Nominal rotor mechanical speed [rad/s]
    p.T_nom_ref = p.P_nom_W / p.omega_nom;       % Nameplate shaft torque [N.m]

    %% 3. Equivalent Circuit Parameters - Per-Phase Delta (utils/data/05_Resumo_Circuito.csv)
    p.R1 = 1.189;                 % Stator resistance per phase (Delta) [Ohm]
    p.R2 = 1.180;                 % Referred rotor resistance per phase (Delta) [Ohm]
    p.L1 = 5.725e-3;              % Stator leakage inductance (Delta) [H]
    p.L2 = 8.420e-3;              % Referred rotor leakage inductance (Delta) [H]
    p.Lm = 131.571e-3;            % Magnetizing inductance (Delta) [H]

    % Reactances at nominal frequency (60 Hz)
    p.X1 = p.omega_e * p.L1;      % Stator leakage reactance (Delta) [Ohm]
    p.X2 = p.omega_e * p.L2;      % Referred rotor leakage reactance (Delta) [Ohm]
    p.Xm = p.omega_e * p.Lm;      % Magnetizing reactance (Delta) [Ohm]

    %% 4. Star-Delta Equivalent Parameters (Wye-Mapped for Simulink SPS)
    % Z_Y = Z_Delta / 3 preserves terminal line voltage & power
    p.R1_Y = p.R1 / 3;            % Stator resistance per phase (Wye) [Ohm]
    p.R2_Y = p.R2 / 3;            % Referred rotor resistance per phase (Wye) [Ohm]
    p.L1_Y = p.L1 / 3;            % Stator leakage inductance (Wye) [H]
    p.L2_Y = p.L2 / 3;            % Referred rotor leakage inductance (Wye) [H]
    p.Lm_Y = p.Lm / 3;            % Magnetizing inductance (Wye) [H]
    p.X1_Y = p.X1 / 3;            % Stator leakage reactance (Wye) [Ohm]
    p.X2_Y = p.X2 / 3;            % Referred rotor leakage reactance (Wye) [Ohm]
    p.Xm_Y = p.Xm / 3;            % Magnetizing reactance (Wye) [Ohm]

    %% 5. Mechanical Parameters (utils/data/04_Mecanicos.csv)
    % P_rot = 129.568 W at n0 = 1799 rpm (omega0 = 188.391 rad/s)
    % B = P_rot / omega0^2 = 0.003651 N.m.s/rad
    % J = B * Delta_t (rundown Delta_t = 15.210 s) = 0.0555 kg.m^2
    p.B = 0.003651;               % Viscous friction coefficient [N.m.s/rad]
    p.J = 0.0555;                 % Equivalent rotor moment of inertia [kg.m^2]
end
