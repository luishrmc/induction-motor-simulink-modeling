%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 1: Itens A, B e C - Dados de Placa, Torque Nominal e Ponto Nominal
% =========================================================================
%  Este script executa de forma autônoma:
%    1. Carregamento dos dados de placa da máquina WEG 3.7 kW (5 cv) e dos
%       parâmetros do circuito equivalente obtidos em laboratório (Item A).
%    2. Cálculo analítico rigoroso do torque nominal de placa Tn (Item B).
%    3. Resolução exata passo a passo do circuito equivalente IEEE em
%       rotação nominal (n = 1715 rpm, s = 0.04722), calculando correntes,
%       potências, perdas, conjugados e rendimentos (Item C).
%    4. Confronto com os dados de placa e exportação de 'nominal_metrics.csv'.
% =========================================================================

clear; clc;
fprintf('====================================================================\n');
fprintf('  UFMG ELE035 - PARTE 1: ITENS A, B e C (PONTO NOMINAL ANALÍTICO)  \n');
fprintf('====================================================================\n\n');

%% 1. Item A: Dados de Placa e Parâmetros Obtidos em Ensaio (Tabela 2.4)
% Dados nominais de catálogo (WEG 3~ 100L, 4 polos, 60 Hz)
P_nom_W    = 3700.0;             % Potência mecânica nominal de catálogo [W] (5 cv)
V_LL_nom   = 220.0;              % Tensão nominal de linha RMS [V] (Triângulo)
I_nom_placa= 14.0;               % Corrente nominal de linha RMS de catálogo [A]
f_nom      = 60.0;               % Frequência elétrica nominal da rede [Hz]
poles      = 4;                  % Número de polos da máquina
p_pairs    = poles / 2;          % Número de pares de polos (p = 2)
n_nom      = 1715.0;             % Velocidade nominal mecânica de placa [rpm]
PF_placa   = 0.810;              % Fator de potência nominal de placa
eta_placa  = 85.5;               % Rendimento nominal de placa [%]

% Constantes mecânicas da bancada acoplada (Seção 2.4 do relatório de laboratório)
J_bench    = 0.701;              % Momento de inércia equivalente [kg.m^2]
B_bench    = 0.0426;             % Coeficiente de atrito viscoso [N.m.s/rad]

% Parâmetros do circuito equivalente IEEE por fase em Triângulo (Delta)
R1         = 1.189;              % Resistência estatórica por fase [Ohm]
R2_prime   = 1.180;              % Resistência rotórica refletida por fase [Ohm]
L_l1       = 5.725e-3;           % Indutância de dispersão do estator [H] (5.725 mH)
L_l2_prime = 8.420e-3;           % Indutância de dispersão do rotor [H] (8.420 mH)
L_m        = 131.571e-3;         % Indutância de magnetização [H] (131.571 mH)

% Reatâncias a 60 Hz
omega_e    = 2 * pi * f_nom;     % Frequência angular elétrica [rad/s] (376.991 rad/s)
X1         = omega_e * L_l1;      % Reatância de dispersão do estator [Ohm] (2.1583 Ohm)
X2_prime   = omega_e * L_l2_prime;% Reatância de dispersão do rotor [Ohm] (3.1743 Ohm)
Xm         = omega_e * L_m;       % Reatância de magnetização [Ohm] (49.6013 Ohm)

fprintf('[Item A] Parâmetros consolidados do motor carregados com sucesso.\n');

%% 2. Item B: Cálculo do Torque Nominal de Placa (Tn)
% Velocidades síncrona e nominal
n_s        = 120 * f_nom / poles;% Rotação síncrona [rpm] (1800 rpm)
omega_s    = omega_e / p_pairs;  % Velocidade síncrona mecânica [rad/s] (188.496 rad/s)
omega_nom  = n_nom * (2*pi/60);  % Velocidade nominal mecânica [rad/s] (179.594 rad/s)
s_nom      = (n_s - n_nom) / n_s;% Escorregamento nominal (0.04722)

% Torque mecânico nominal útil de catálogo
Tn = P_nom_W / omega_nom;

fprintf('[Item B] Cálculo do Torque Nominal:\n');
fprintf('  Velocidade mecânica nominal:   omega_nom = %.4f rad/s (n = %.1f rpm)\n', omega_nom, n_nom);
fprintf('  Velocidade síncrona mecânica:  omega_s   = %.4f rad/s (n_s = %.1f rpm)\n', omega_s, n_s);
fprintf('  Escorregamento nominal:        s_nom     = %.5f (%.2f%%)\n', s_nom, s_nom * 100);
fprintf('  Torque Nominal de Placa:       Tn        = %.4f N.m\n\n', Tn);

%% 3. Item C: Resolução Analítica do Circuito Equivalente no Ponto Nominal
% Tensão de fase aplicada (conexão Delta: V_ph = V_LL)
V_phase = V_LL_nom;
V_ph_vec = V_phase + 0j;

% Ramo rotórico com escorregamento nominal
R2_s = R2_prime / s_nom;
Z2_vec = R2_s + 1j * X2_prime;

% Ramo magnetizante puro (desprezando Rc)
Zm_vec = 1j * Xm;

% Associação em paralelo: Zp = Zm // Z2
Zp_vec = (Zm_vec * Z2_vec) / (Zm_vec + Z2_vec);

% Impedância estatórica série
Z1_vec = R1 + 1j * X1;

% Impedância de entrada por fase
Zin_vec = Z1_vec + Zp_vec;
mag_Zin = abs(Zin_vec);
phi_rad = angle(Zin_vec);
phi_deg = phi_rad * (180 / pi);
PF_calc = cos(phi_rad);

% Corrente de fase e corrente de linha estatórica
I1_phase_vec = V_ph_vec / Zin_vec;
I1_phase_rms = abs(I1_phase_vec);
I_line_rms   = sqrt(3) * I1_phase_rms;

% Tensão interna de entreferro (E1) e corrente rotórica referida (I2_prime)
E1_vec       = V_ph_vec - I1_phase_vec * Z1_vec;
I2_prime_vec = E1_vec / Z2_vec;
I2_prime_rms = abs(I2_prime_vec);

% Potências elétricas trifásicas absorvidas
P_elec_W = 3 * V_phase * I1_phase_rms * PF_calc;
Q_elec_var = 3 * V_phase * I1_phase_rms * sin(phi_rad);
S_elec_VA  = 3 * V_phase * I1_phase_rms;

% Perdas por efeito Joule no cobre (estator e rotor)
P_cu1_W = 3 * (I1_phase_rms^2) * R1;
P_cu2_W = 3 * (I2_prime_rms^2) * R2_prime;

% Potência no entreferro (P_ag)
P_ag_W = 3 * (I2_prime_rms^2) * R2_s;

% Conversão eletromecânica interna e torque eletromagnético desenvolvido
P_em_W = (1 - s_nom) * P_ag_W;
Tem_Nm = P_ag_W / omega_s;

% Perdas mecânicas rotacionais por atrito viscoso da bancada (Seção 2.4)
T_rot_Nm = B_bench * omega_nom;
P_rot_W  = B_bench * (omega_nom^2);

% Grandezas mecânicas úteis na ponta do eixo (deduzindo arraste da bancada)
T_shaft_Nm = Tem_Nm - T_rot_Nm;
P_shaft_W  = P_em_W - P_rot_W;

% Rendimentos: eletromagnético interno vs. global com bancada acoplada
eta_em    = (P_em_W / P_elec_W) * 100;
eta_shaft = (P_shaft_W / P_elec_W) * 100;

%% 4. Apresentação dos Resultados e Confronto com Dados de Placa
fprintf('[Item C] Resultados Analíticos no Ponto Nominal (n = 1715 rpm):\n');
fprintf('  Impedância de entrada Zin:     %.4f + j%.4f Ohm (|Z| = %.4f Ohm, phi = %.2f deg)\n', ...
    real(Zin_vec), imag(Zin_vec), mag_Zin, phi_deg);
fprintf('  Corrente de linha estatórica:  I_line   = %.3f A RMS (Placa: %.1f A)\n', I_line_rms, I_nom_placa);
fprintf('  Fator de potência:             cos(phi) = %.4f (Placa: %.3f)\n', PF_calc, PF_placa);
fprintf('  Potência elétrica ativa:       P_elec   = %.2f W\n', P_elec_W);
fprintf('  Potência reativa absorvida:    Q_elec   = %.2f var\n', Q_elec_var);
fprintf('  Potência no entreferro:        P_ag     = %.2f W\n', P_ag_W);
fprintf('  Potência eletromecânica int.:  P_em     = %.2f W\n', P_em_W);
fprintf('  Conjugado eletromagnético:     Tem      = %.3f N.m\n', Tem_Nm);
fprintf('  Conjugado útil no eixo:        T_shaft  = %.3f N.m (Placa Tn: %.3f N.m)\n', T_shaft_Nm, Tn);
fprintf('  Potência útil no eixo:         P_shaft  = %.2f W (Placa Pn: %.1f W)\n', P_shaft_W, P_nom_W);
fprintf('  Rendimento eletromagnético:    eta_em   = %.2f%% (Placa: %.1f%%)\n', eta_em, eta_placa);
fprintf('  Rendimento com bancada CC:     eta_sh   = %.2f%%\n\n', eta_shaft);

%% 5. Exportação da Tabela Comparativa em CSV
out_dir = fileparts(mfilename('fullpath'));
csv_file = fullfile(out_dir, 'nominal_metrics.csv');

T = table(...
    {'Velocidade de Rotacao'; 'Conjugado Eletromagnetico Interno'; 'Conjugado Util de Eixo'; ...
     'Potencia Mecanica de Eixo'; 'Corrente de Linha Estatorica'; 'Fator de Potencia'; ...
     'Rendimento Eletromagnetico Interno'; 'Rendimento Global com Bancada'}, ...
    {'rpm'; 'N.m'; 'N.m'; 'W'; 'A RMS'; '-'; '%'; '%'}, ...
    [n_nom; Tn; Tn; P_nom_W; I_nom_placa; PF_placa; eta_placa; eta_placa], ...
    [n_nom; Tem_Nm; T_shaft_Nm; P_shaft_W; I_line_rms; PF_calc; eta_em; eta_shaft], ...
    abs([n_nom; Tem_Nm; T_shaft_Nm; P_shaft_W; I_line_rms; PF_calc; eta_em; eta_shaft] - ...
        [n_nom; Tn; Tn; P_nom_W; I_nom_placa; PF_placa; eta_placa; eta_placa]) ./ ...
        [n_nom; Tn; Tn; P_nom_W; I_nom_placa; PF_placa; eta_placa; eta_placa] * 100, ...
    'VariableNames', {'Grandeza', 'Unidade', 'Placa_Catalogo', 'Modelo_Analitico', 'Desvio_pct'});

writetable(T, csv_file);
fprintf('[OK] Tabela comparativa exportada com sucesso em: %s\n', csv_file);
