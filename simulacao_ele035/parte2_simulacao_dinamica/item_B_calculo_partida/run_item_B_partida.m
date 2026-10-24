%% =========================================================================
%%  UFMG ELE035 - Parte 2, Item B: Corrente de partida direta (s = 1)
%%  Origem: matlab/simulink/run_sim_harness.m (secao analitica preservada)
%% =========================================================================
clear; clc;
this_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(this_dir, '..', 'item_A_modelo_simscape'));

%% 1. Parametros do motor (mapeamento Y-Delta no item A)
params = setup_parametros_Y();

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

%% 3. Exportacao dos resultados
res = struct('s',1.0,'I_line_start_A',I_line_start,'I_ph_start_A',I_ph_start,'T_start_Nm',T_start,'P_ag_start_W',P_ag_start,'Zin_real_Ohm',real(Zin_start),'Zin_imag_Ohm',imag(Zin_start));
fid = fopen(fullfile(this_dir,'resultados_partida.json'),'w'); fwrite(fid, jsonencode(res,'PrettyPrint',true),'char'); fclose(fid);
fprintf('[OK] resultados_partida.json salvo.\n');
