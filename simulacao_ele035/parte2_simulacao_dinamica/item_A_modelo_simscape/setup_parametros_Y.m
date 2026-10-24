%% =========================================================================
%  UNIVERSIDADE FEDERAL DE MINAS GERAIS - UFMG
%  ELE035 - Laboratório de Conversão de Energia
%  Parte 2: Item A - Parametrização Simscape e Mapeamento Estrela-Triângulo
% =========================================================================
%  Este script autônomo executa:
%    1. Carregamento dos parâmetros de placa e do circuito equivalente (Delta).
%    2. Aplicação da Transformação Estrela-Triângulo (ADR-002) para o bloco
%       Asynchronous Machine SI Units do Simscape SPS:
%         R1_Y = R1/3, R2_Y = R2'/3, L1_Y = L1/3, L2_Y = L2'/3, Lm_Y = Lm/3
%    3. Definição das constantes mecânicas da bancada (J = 0.701 kg.m^2, B = 0.0426).
%    4. Exportação das variáveis para o Workspace base do MATLAB para o Simulink.
% =========================================================================

function params = setup_parametros_Y()

    fprintf('====================================================================\n');
    fprintf('  UFMG ELE035 - PARTE 2: ITEM A (PARAMETRIZAÇÃO ESTRELA-TRIÂNGULO) \n');
    fprintf('====================================================================\n\n');

    %% 1. Dados de Placa da Máquina WEG 3.7 kW (5 cv)
    params.V_LL_nom = 220.0;           % Tensão de linha nominal [V RMS] (60 Hz)
    params.f_nom    = 60.0;            % Frequência elétrica nominal [Hz]
    params.P_nom_W  = 3700.0;          % Potência mecânica nominal de catálogo [W] (5 cv)
    params.I_nom_A  = 14.0;            % Corrente nominal de linha de catálogo [A RMS]
    params.poles    = 4;               % 4 polos
    params.p_pairs  = params.poles / 2;% 2 pares de polos
    params.n_nom    = 1715.0;          % Rotação nominal [rpm]
    params.n_s      = 120 * params.f_nom / params.poles; % 1800 rpm
    params.s_nom    = (params.n_s - params.n_nom) / params.n_s; % 0.04722
    params.omega_e  = 2 * pi * params.f_nom;                 % 376.991 rad/s
    params.omega_s  = params.omega_e / params.p_pairs;       % 188.496 rad/s
    params.omega_nom= (1 - params.s_nom) * params.omega_s;   % 179.594 rad/s
    params.T_nom_ref= params.P_nom_W / params.omega_nom;     % 20.602 N.m

    %% 2. Parâmetros por Fase em Conexão Triângulo (Delta) - Ensaio de Bancada
    params.R1_delta = 1.189;                 % Resistência do estator [Ohm]
    params.R2_delta = 1.180;                 % Resistência do rotor referida [Ohm]
    params.L1_delta = 5.725e-3;              % Indutância de dispersão do estator [H]
    params.L2_delta = 8.420e-3;              % Indutância de dispersão do rotor [H]
    params.Lm_delta = 131.571e-3;            % Indutância de magnetização [H]
    params.X1_delta = params.omega_e * params.L1_delta;   % 2.1583 Ohm
    params.X2_delta = params.omega_e * params.L2_delta;   % 3.1743 Ohm
    params.Xm_delta = params.omega_e * params.Lm_delta;   % 49.6013 Ohm

    %% 3. Mapeamento Rigoroso Estrela-Triângulo para o Bloco Simscape (Y)
    % O bloco Asynchronous Machine SI Units opera internamente em Wye (Y).
    % Para equivalência terminal perfeita (mesma tensão de linha de 220 V e correntes):
    % Z_Y = Z_Delta / 3
    params.R1_Y  = params.R1_delta / 3;      % 0.396333 Ohm
    params.R2_Y  = params.R2_delta / 3;      % 0.393333 Ohm
    params.L1_Y  = params.L1_delta / 3;      % 1.908333 mH
    params.L2_Y  = params.L2_delta / 3;      % 2.806667 mH
    params.Lm_Y  = params.Lm_delta / 3;      % 43.857000 mH
    params.X1_Y  = params.X1_delta / 3;      % 0.719444 Ohm
    params.X2_Y  = params.X2_delta / 3;      % 1.058267 Ohm
    params.Xm_Y  = params.Xm_delta / 3;      % 16.533667 Ohm

    %% 4. Parâmetros Mecânicos da Bancada Acoplada (Seção 2.4 do Relatório)
    params.J = 0.701;                  % Momento de inércia total equivalente [kg.m^2]
    params.B = 0.0426;                 % Coeficiente de atrito viscoso [N.m.s/rad]

    %% 5. Configuração do Solver Numérico L-Estável
    params.T_sample    = 50e-6;        % Passo de integração discreto [s] (50 us / 20 kHz)
    params.t_stop      = 8.0;          % Tempo padrão de simulação [s]
    params.t_step_load = 5.0;          % Instante de chaveamento do degrau [s]
    params.T_load_step = params.T_nom_ref; % Amplitude nominal do degrau [N.m] (20.602 N.m)

    %% 6. Exportação para o Base Workspace do MATLAB
    fields = fieldnames(params);
    for k = 1:length(fields)
        assignin('base', fields{k}, params.(fields{k}));
    end

    fprintf('  Tensão de Alimentação (V_LL): %.1f V RMS (60 Hz)\n', params.V_LL_nom);
    fprintf('  Resistência Estatórica (R1_Y):  %.4f Ohm (Delta: %.4f Ohm)\n', params.R1_Y, params.R1_delta);
    fprintf('  Resistência Rotórica (R2_Y):   %.4f Ohm (Delta: %.4f Ohm)\n', params.R2_Y, params.R2_delta);
    fprintf('  Indutância Estatórica (L1_Y):  %.4f mH  (Delta: %.4f mH)\n', params.L1_Y * 1e3, params.L1_delta * 1e3);
    fprintf('  Indutância Rotórica (L2_Y):   %.4f mH  (Delta: %.4f mH)\n', params.L2_Y * 1e3, params.L2_delta * 1e3);
    fprintf('  Indutância Magnetização(Lm_Y): %.4f mH  (Delta: %.4f mH)\n', params.Lm_Y * 1e3, params.Lm_delta * 1e3);
    fprintf('  Momento de Inércia Total (J):  %.4f kg.m^2 (Bancada MG acoplada)\n', params.J);
    fprintf('  Atrito Viscoso da Bancada (B): %.4f N.m.s/rad\n', params.B);
    fprintf('  Torque Nominal de Placa (Tn):  %.3f N.m\n', params.T_nom_ref);
    fprintf('\n[OK] Parâmetros exportados com sucesso para o Base Workspace.\n');

end
