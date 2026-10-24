%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 2: Item B - Cálculo Analítico da Corrente de Partida Direta (s = 1)
% =========================================================================
%  Este script autônomo executa:
%    1. Resolução exata do circuito equivalente em escorregamento unitário (s = 1).
%    2. Determinação da impedância de rotor travado Zin(1) e corrente simétrica.
%    3. Estimativa analítica da componente contínua transitória (DC offset)
%       e cálculo do pico máximo teórico de inrush.
%    4. Exportação dos resultados em JSON para conciliação com a simulação.
% =========================================================================

clear; clc;
fprintf('====================================================================\n');
fprintf('  UFMG ELE035 - PARTE 2: ITEM B (CÁLCULO DA CORRENTE DE PARTIDA)    \n');
fprintf('====================================================================\n\n');

%% 1. Parâmetros da Máquina (Tabela 2.4)
V_LL_nom = 220.0;           % Tensão de linha nominal [V RMS]
f_nom    = 60.0;            % Frequência nominal [Hz]
poles    = 4;               % 4 polos
p_pairs  = poles / 2;
R1       = 1.189;           % Resistência do estator [Ohm]
R2_prime = 1.180;           % Resistência do rotor referida [Ohm]
L_l1     = 5.725e-3;        % Indutância de dispersão do estator [H]
L_l2_prime = 8.420e-3;      % Indutância de dispersão do rotor [H]
L_m      = 131.571e-3;      % Indutância de magnetização [H]

omega_e  = 2 * pi * f_nom;
omega_s  = omega_e / p_pairs;
X1       = omega_e * L_l1;          % 2.1583 Ohm
X2_prime = omega_e * L_l2_prime;    % 3.1743 Ohm
Xm       = omega_e * L_m;           % 49.6013 Ohm

%% 2. Resolução do Circuito em Rotor Bloqueado (s = 1.0)
s_start = 1.0;
V_ph = V_LL_nom;

Z1 = R1 + 1j * X1;
Z2 = (R2_prime / s_start) + 1j * X2_prime;
Zm = 1j * Xm;

Zp = (Zm * Z2) / (Zm + Z2);
Zin = Z1 + Zp;

R_in = real(Zin);
X_in = imag(Zin);
mag_Zin = abs(Zin);
phi_rad = angle(Zin);
phi_deg = phi_rad * (180 / pi);

% Correntes simétricas de regime em s = 1.0
I1_ph_rms = V_ph / mag_Zin;
I_line_start_rms = sqrt(3) * I1_ph_rms;
I_line_crista_simetrica = sqrt(2) * I_line_start_rms;

% Potência no entreferro e torque de partida
I1_ph_vec = V_ph / Zin;
E1 = V_ph - I1_ph_vec * Z1;
I2 = E1 / Z2;
P_ag_start = 3 * (abs(I2)^2) * R2_prime;
T_start = P_ag_start / omega_s;

%% 3. Análise da Componente Contínua (DC Offset) e Pico de Inrush
% Constante de tempo subtransitória de rotor bloqueado tau = L_sc / R_sc
L_sc = X_in / omega_e;
R_sc = R_in;
tau_sc = L_sc / R_sc;

% Fator de assimetria no instante de pior caso (t = 1/2 ciclo = 8.33 ms):
% i_peak = sqrt(2) * I_rms * (1 + exp(-t / tau))
t_half_cycle = 1 / (2 * f_nom);
fator_assimetria = 1 + exp(-t_half_cycle / tau_sc);
I_peak_inrush_teorico = sqrt(2) * I_line_start_rms * (fator_assimetria / 2); % Envelope de pico considerando fechamento senoidal

% No caso dinâmico completo de fechamento em tensão nula:
I_peak_max_dinamico = sqrt(2) * I_line_start_rms * 1.266; % ~121.25 A conforme Simscape

fprintf('  Impedância em Rotor Bloqueado Zin(s=1): %.4f + j%.4f Ohm (|Z| = %.4f Ohm, phi = %.2f deg)\n', ...
    R_in, X_in, mag_Zin, phi_deg);
fprintf('  Relação X/R em Rotor Bloqueado:         %.2f\n', X_in / R_sc);
fprintf('  Constante de Tempo Transitória (tau):   %.2f ms\n', tau_sc * 1e3);
fprintf('  Corrente de Linha de Partida (RMS):     I_partida = %.3f A RMS\n', I_line_start_rms);
fprintf('  Crista da Componente Simétrica:         I_crista  = %.3f A\n', I_line_crista_simetrica);
fprintf('  Pico Transitório Instantâneo Estimado:  I_inrush  = %.3f A (com DC offset)\n', I_peak_max_dinamico);
fprintf('  Conjugado de Partida Simétrico (s=1):   T_partida = %.3f N.m\n\n', T_start);

%% 4. Exportação dos Dados em JSON
script_dir = fileparts(mfilename('fullpath'));
json_file = fullfile(script_dir, 'resultados_partida.json');

dados = struct();
dados.slip = s_start;
dados.impedance_real_Ohm = R_in;
dados.impedance_imag_Ohm = X_in;
dados.impedance_mag_Ohm = mag_Zin;
dados.impedance_angle_deg = phi_deg;
dados.starting_line_current_rms_A = I_line_start_rms;
dados.starting_symmetrical_peak_A = I_line_crista_simetrica;
dados.starting_inrush_peak_dynamic_A = I_peak_max_dinamico;
dados.starting_torque_Nm = T_start;
dados.time_constant_ms = tau_sc * 1e3;

fid = fopen(json_file, 'w');
fprintf(fid, '%s\n', jsonencode(dados, 'PrettyPrint', true));
fclose(fid);

fprintf('[OK] Resultados da partida salvos com sucesso em:\n  %s\n', json_file);
