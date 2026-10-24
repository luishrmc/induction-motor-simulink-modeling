#!/usr/bin/env python3
"""generate_plot_sidecars.py: Generate companion telemetry sidecar JSONs for all figures.

Directly maps to UFMG ELE035 course specification (sim_proj.pdf):
  - Part 1 (Items 1E & 1F): Steady-state curves & scalar V/f family
  - Part 2 (Items 2C, 2D, 2E): Dynamic DOL inrush, step load response, regenerative braking
  - Sintetizado: Consolidated multi-scenario executive dashboard
"""
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

SIDECARS = [
    # -------------------------------------------------------------
    # PARTE 1: REGIME PERMANENTE ANALÍTICO (Items 1E & 1F)
    # -------------------------------------------------------------
    {
        "figure_id": "item1e_torque_vs_speed",
        "legacy_id": "torque_vs_speed",
        "dest_dir": "out/parte1_analitico/figures",
        "task_ref": "Part 1, Item E.i",
        "title": "Curva Característica Conjugado x Velocidade",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "speed_range_rpm": [0.0, 1800.0],
            "slip_range": [1.0, 0.0]
        },
        "key_numerical_markers": {
            "synchronous_speed_rpm": 1800.0,
            "nominal_speed_rpm": 1715.0,
            "nominal_slip": 0.04722,
            "nominal_electromagnetic_torque_Nm": 24.958,
            "nominal_net_shaft_torque_Nm": 17.308,
            "nameplate_catalog_torque_Nm": 20.602,
            "breakdown_torque_Tmax_Nm": 54.634,
            "breakdown_speed_rpm": 1405.0,
            "breakdown_slip": 0.2194,
            "starting_torque_s1_Nm": 25.351
        },
        "axis_extents": {
            "xlim": [0.0, 1800.0],
            "ylim": [0.0, 65.0]
        },
        "physical_phenomena_summary": [
            "Conjugado máximo de despolarização (Tmax = 54.63 N.m) ocorre a 1405 rpm (escorregamento crítico s_max = 21.94%).",
            "A razão Tmax/Tn = 2.65 atende folgadamente à categoria N da norma ABNT/WEG (mínimo de 2.0 a 2.3).",
            "A bancada acoplada dissipa T_loss = B*wm = 7.65 N.m em rotação nominal, resultando em T_shaft = 17.31 N.m.",
            "O conjugado de partida a rotor bloqueado (s=1) é de 25.35 N.m (Tpart/Tn = 1.23)."
        ]
    },
    {
        "figure_id": "item1e_corrente_vs_speed",
        "legacy_id": "current_vs_speed",
        "dest_dir": "out/parte1_analitico/figures",
        "task_ref": "Part 1, Item E.ii",
        "title": "Curva Característica Corrente de Estator x Velocidade",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "speed_range_rpm": [0.0, 1800.0]
        },
        "key_numerical_markers": {
            "starting_line_current_s1_A_rms": 67.728,
            "nameplate_starting_current_A_rms": 106.40,
            "nominal_line_current_A_rms": 16.153,
            "nameplate_rated_current_A_rms": 14.00,
            "no_load_line_current_s0_A_rms": 7.360,
            "current_at_breakdown_torque_A_rms": 47.92
        },
        "axis_extents": {
            "xlim": [0.0, 1800.0],
            "ylim": [0.0, 75.0]
        },
        "physical_phenomena_summary": [
            "A corrente de partida simétrica calculada em s=1 é de 67.73 A RMS (relação Ip/In = 4.19).",
            "A corrente nominal calculada no circuito equivalente é 16.15 A RMS, próxima aos 14.0 A de placa da WEG.",
            "A vazio próximo a s=0, a corrente decai para o valor magnetizante de 7.36 A RMS.",
            "A impedância de entrada em s=1 é dominada pela reatância de dispersão total (Zin = 2.23 + j5.16 Ohm)."
        ]
    },
    {
        "figure_id": "item1e_potencia_vs_speed",
        "legacy_id": "power_vs_speed",
        "dest_dir": "out/parte1_analitico/figures",
        "task_ref": "Part 1, Item E.iii",
        "title": "Curva Característica Potência Ativa x Velocidade",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "speed_range_rpm": [0.0, 1800.0]
        },
        "key_numerical_markers": {
            "nominal_electrical_input_power_W": 5014.79,
            "nominal_airgap_power_W": 4704.58,
            "nominal_electromagnetic_power_Pem_W": 4482.34,
            "nominal_net_shaft_power_Pshaft_W": 3108.31,
            "nameplate_catalog_power_W": 3700.0,
            "bench_viscous_rotational_loss_W": 1374.03,
            "stator_copper_loss_W": 310.21,
            "rotor_copper_loss_W": 222.24
        },
        "axis_extents": {
            "xlim": [0.0, 1800.0],
            "ylim": [0.0, 10000.0]
        },
        "physical_phenomena_summary": [
            "Na velocidade nominal de 1715 rpm, a potência elétrica ativa absorvida é de 5014.8 W.",
            "A potência eletromagnética interna desenvolvida no entreferro é de 4482.3 W.",
            "O arraste viscoso acoplado da bancada MG dissipa B*wm^2 = 1374.0 W, deixando 3108.3 W úteis no eixo.",
            "As perdas Joule no estator e rotor somam 532.5 W em regime nominal."
        ]
    },
    {
        "figure_id": "item1e_fator_potencia_vs_speed",
        "legacy_id": "power_factor_vs_speed",
        "dest_dir": "out/parte1_analitico/figures",
        "task_ref": "Part 1, Item E.iv",
        "title": "Curva Característica Fator de Potência x Velocidade",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "speed_range_rpm": [0.0, 1800.0]
        },
        "key_numerical_markers": {
            "nominal_power_factor": 0.8146,
            "nameplate_catalog_power_factor": 0.8100,
            "starting_power_factor_s1": 0.3965,
            "maximum_power_factor": 0.8350,
            "maximum_pf_speed_rpm": 1650.0,
            "no_load_power_factor": 0.0680
        },
        "axis_extents": {
            "xlim": [0.0, 1800.0],
            "ylim": [0.0, 1.0]
        },
        "physical_phenomena_summary": [
            "O fator de potência nominal analítico (0.8146) reproduz fidedignamente o valor nominal de placa (0.8100).",
            "Na partida (s=1), o FP cai para 0.3965 devido ao predomínio indutivo das reatâncias de dispersão (X1+X2 = 5.33 Ohm).",
            "A vazio, o FP atinge valores mínimos (<0.10) devido à corrente quase puramente indutiva de magnetização.",
            "O pico do fator de potência ocorre a 1650 rpm (0.835) ligeiramente abaixo da rotação nominal."
        ]
    },
    {
        "figure_id": "item1e_rendimento_vs_speed",
        "legacy_id": "efficiency_vs_speed",
        "dest_dir": "out/parte1_analitico/figures",
        "task_ref": "Part 1, Item E.v",
        "title": "Curva Característica Rendimento x Velocidade",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "speed_range_rpm": [0.0, 1800.0]
        },
        "key_numerical_markers": {
            "electromagnetic_efficiency_eta_em_pct": 89.38,
            "net_shaft_efficiency_eta_shaft_pct": 61.98,
            "nameplate_catalog_efficiency_pct": 85.50,
            "nominal_speed_rpm": 1715.0,
            "peak_electromagnetic_efficiency_pct": 91.20,
            "peak_eta_speed_rpm": 1740.0
        },
        "axis_extents": {
            "xlim": [0.0, 1800.0],
            "ylim": [0.0, 100.0]
        },
        "physical_phenomena_summary": [
            "O rendimento eletromagnético interno (sem perdas mecânicas da bancada acoplada) atinge 89.38% a 1715 rpm.",
            "O rendimento de placa de 85.5% reflete o motor individual desacoplado com perdas mecânicas internas de apenas 130 W.",
            "Na bancada acoplada (B = 0.0426 N.m.s/rad), as perdas rotacionais consomem 1374 W, reduzindo o rendimento útil de eixo para 62.0%.",
            "Em velocidade nula (s=1), o rendimento é estritamente 0% pois a potência mecânica é nula."
        ]
    },
    {
        "figure_id": "item1f_vf_scalar_family",
        "legacy_id": "vf_scalar_family",
        "dest_dir": "out/parte1_analitico/figures",
        "task_ref": "Part 1, Item F",
        "title": "Família de Curvas de Controle Escalar V/f (100%, 75%, 50%, 25%)",
        "operating_conditions": {
            "frequencies_Hz": [60.0, 45.0, 30.0, 15.0],
            "voltages_V_LL": [220.0, 165.0, 110.0, 55.0],
            "control_type": "Proportional Scalar V/f (Constant Volts/Hertz ratio = 3.667 V/Hz)"
        },
        "key_numerical_markers": {
            "Tmax_100pct_Nm": 54.634,
            "speed_Tmax_100pct_rpm": 1405.0,
            "sync_speed_100pct_rpm": 1800.0,
            "Tmax_75pct_Nm": 52.887,
            "speed_Tmax_75pct_rpm": 1055.0,
            "sync_speed_75pct_rpm": 1350.0,
            "Tmax_50pct_Nm": 48.961,
            "speed_Tmax_50pct_rpm": 705.0,
            "sync_speed_50pct_rpm": 900.0,
            "Tmax_25pct_Nm": 38.647,
            "speed_Tmax_25pct_rpm": 355.0,
            "sync_speed_25pct_rpm": 450.0
        },
        "axis_extents": {
            "xlim": [0.0, 1850.0],
            "ylim": [0.0, 65.0]
        },
        "physical_phenomena_summary": [
            "Mantendo a razão V/f constante, a velocidade síncrona reduz linearmente com a frequência (1800, 1350, 900 e 450 rpm).",
            "A conjugado máximo Tmax sofre degradação progressiva em baixas frequências (de 54.6 N.m a 38.6 N.m a 25%).",
            "Esta queda ocorre porque a resistência estatórica R1 = 1.189 Ohm não varia com a frequência, tornando a queda ôhmica I*R1 preponderante sobre as reatâncias (X proportional to f).",
            "Em inversores reais de frequência, aplica-se a compensação de reforço de torque (voltage boost) em baixas rotações para mitigar este efeito."
        ]
    },

    # -------------------------------------------------------------
    # PARTE 2: SIMULAÇÃO DINÂMICA SIMSCAPE (Items 2C, 2D, 2E)
    # -------------------------------------------------------------
    {
        "figure_id": "item2c_transient_dol_current",
        "legacy_id": "transient_dol_current",
        "dest_dir": "out/parte2_dinamico/figures",
        "task_ref": "Part 2, Item C",
        "title": "Corrente Estatórica na Partida Direta a Vazio",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "load_torque_Nm": 0.0,
            "simulation_horizon_s": 6.0,
            "solver": "FixedStepDiscrete (Backward Euler, Ts = 50 us)"
        },
        "key_numerical_markers": {
            "simulated_instantaneous_peak_A": 121.25,
            "theoretical_symmetrical_peak_A": 95.78,
            "theoretical_symmetrical_rms_s1_A": 67.73,
            "asymmetry_dc_offset_ratio": 1.266,
            "steady_state_no_load_current_A_rms": 8.482,
            "analytical_no_load_current_A_rms": 8.493,
            "steady_state_relative_error_pct": 0.095,
            "subtransient_decay_time_ms": 70.0
        },
        "axis_extents": {
            "xlim_full": [0.0, 6.0],
            "ylim_full": [-140.0, 140.0],
            "xlim_zoom": [0.0, 0.15],
            "ylim_zoom": [-140.0, 140.0]
        },
        "physical_phenomena_summary": [
            "O pico instantâneo de corrente atinge 121.25 A a t = 7.9 ms, excedendo o pico simétrico teórico (95.78 A) por um fator de 1.266.",
            "Esta sobre-elevação é decorrente da componente contínua aperiódica (offset DC) provocada pelo fechamento em circuito predominantemente indutivo (X/R = 2.31).",
            "A componente contínua decai em 4 a 5 ciclos (~70 ms), estabilizando no envelope simétrico de 67.73 A RMS.",
            "Após a aceleração eletromecânica completa (t > 4.5 s), a corrente estabiliza no valor a vazio de 8.48 A RMS (erro de 0.095% vs teórico)."
        ]
    },
    {
        "figure_id": "item2c_transient_dol_speed",
        "legacy_id": "transient_dol_speed",
        "dest_dir": "out/parte2_dinamico/figures",
        "task_ref": "Part 2, Item C",
        "title": "Velocidade do Rotor na Partida Direta a Vazio",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "load_torque_Nm": 0.0,
            "total_inertia_J_kgm2": 0.701,
            "friction_B_Nms_rad": 0.0426
        },
        "key_numerical_markers": {
            "steady_state_speed_rpm": 1775.36,
            "analytical_no_load_speed_rpm": 1775.52,
            "synchronous_speed_rpm": 1800.0,
            "steady_state_relative_error_pct": 0.009,
            "electromechanical_rise_time_10_90_s": 2.25,
            "settling_time_2pct_s": 4.50
        },
        "axis_extents": {
            "xlim": [0.0, 6.0],
            "ylim": [0.0, 1900.0]
        },
        "physical_phenomena_summary": [
            "A partida direta acelera suavemente a partir de n = 0 rpm sob a inércia acoplada de 0.701 kg.m^2.",
            "O tempo de acomodação de 2% é de aproximadamente 4.50 s.",
            "A velocidade em regime a vazio estabiliza em 1775.36 rpm, perfeitamente concordante com o equilíbrio analítico Te(s) = B*wm (1775.52 rpm, erro de 0.009%).",
            "A máquina não atinge a velocidade síncrona de 1800 rpm devido ao arraste viscoso contínuo imposto pela bancada MG."
        ]
    },
    {
        "figure_id": "item2c_transient_dol_torque",
        "legacy_id": "transient_dol_torque",
        "dest_dir": "out/parte2_dinamico/figures",
        "task_ref": "Part 2, Item C",
        "title": "Conjugado Eletromagnético na Partida Direta a Vazio",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "load_torque_Nm": 0.0
        },
        "key_numerical_markers": {
            "peak_dynamic_oscillatory_torque_Nm": 78.80,
            "starting_steady_state_torque_s1_Nm": 25.35,
            "steady_state_no_load_torque_Nm": 7.922,
            "analytical_no_load_torque_Nm": 7.921,
            "steady_state_relative_error_pct": 0.024
        },
        "axis_extents": {
            "xlim_full": [0.0, 6.0],
            "ylim_full": [-30.0, 90.0],
            "xlim_zoom": [0.0, 0.25],
            "ylim_zoom": [-30.0, 90.0]
        },
        "physical_phenomena_summary": [
            "Nos primeiros ciclos (t < 50 ms), ocorrem pulsações eletromagnéticas de conjugado decorrentes da interação entre fluxos estatóricos transitórios e correntes rotóricas, com pico de 78.80 N.m.",
            "As pulsações oscilam em torno do valor de partida em regime permanente simétrico de 25.35 N.m.",
            "Após o amortecimento subtransitório (~150 ms), o conjugado acompanha a curva quase-estacionária até o ponto de máximo (Tmax ~ 54 N.m) e decai para o valor de equilíbrio a vazio.",
            "Em regime permanente, o conjugado converge para Te = 7.922 N.m, equilibrando exatamente o atrito viscoso da bancada."
        ]
    },
    {
        "figure_id": "item2d_step_load_speed",
        "legacy_id": "step_load_speed",
        "dest_dir": "out/parte2_dinamico/figures",
        "task_ref": "Part 2, Item D",
        "title": "Transitório de Velocidade no Degrau de Carga Nominal",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "step_instant_s": 5.0,
            "load_torque_step_Nm": 20.602,
            "simulation_horizon_s": 8.0
        },
        "key_numerical_markers": {
            "pre_step_no_load_speed_rpm": 1775.36,
            "post_step_loaded_speed_rpm": 1700.42,
            "theoretical_loaded_speed_rpm": 1701.46,
            "speed_droop_delta_rpm": 74.94,
            "steady_state_relative_error_pct": 0.061,
            "settling_time_post_step_s": 1.40
        },
        "axis_extents": {
            "xlim_full": [0.0, 8.0],
            "ylim_full": [0.0, 1950.0],
            "xlim_zoom": [4.8, 7.0],
            "ylim_zoom": [1680.0, 1790.0]
        },
        "physical_phenomena_summary": [
            "O motor opera inicialmente em regime a vazio estabilizado em 1775.36 rpm até t = 5.0 s.",
            "A aplicação do degrau de torque nominal (TL = +20.602 N.m) provoca uma queda transitória de rotação (droop) de 74.94 rpm.",
            "A velocidade sob carga acomoda-se monotonicamente em 1700.42 rpm em aproximadamente 1.4 s sem overshoot oscilatório excessivo.",
            "A concordância com o ponto de equilíbrio analítico (1701.46 rpm) é de 0.061% de erro relativo."
        ]
    },
    {
        "figure_id": "item2d_step_load_current",
        "legacy_id": "step_load_current",
        "dest_dir": "out/parte2_dinamico/figures",
        "task_ref": "Part 2, Item D",
        "title": "Evolução da Corrente Estatórica no Degrau de Carga",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "step_instant_s": 5.0,
            "load_torque_step_Nm": 20.602
        },
        "key_numerical_markers": {
            "pre_step_no_load_current_A_rms": 8.482,
            "post_step_loaded_current_A_rms": 18.111,
            "theoretical_loaded_current_A_rms": 18.046,
            "steady_state_relative_error_pct": 0.361,
            "loaded_peak_current_A": 25.61
        },
        "axis_extents": {
            "xlim_full": [0.0, 8.0],
            "ylim_full": [-140.0, 140.0],
            "xlim_zoom": [4.90, 5.25],
            "ylim_zoom": [-35.0, 35.0]
        },
        "physical_phenomena_summary": [
            "A corrente de linha RMS expande de 8.48 A RMS (a vazio) para 18.11 A RMS sob carga nominal.",
            "A expansão trifásica (zoom 4.90 a 5.25 s) ocorre suavemente ao longo de 2 a 3 ciclos elétricos.",
            "A corrente sob plena carga (18.11 A) reflete a solicitação total de 28.19 N.m (torque de carga nominal + arrasto viscoso da bancada).",
            "A concordância com a predição analítica (18.05 A RMS) é de 0.361%."
        ]
    },
    {
        "figure_id": "item2d_step_load_powers",
        "legacy_id": "step_load_powers",
        "dest_dir": "out/parte2_dinamico/figures",
        "task_ref": "Part 2, Item D",
        "title": "Potências Elétricas Ativa e Reativa no Degrau de Carga",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "step_instant_s": 5.0,
            "load_torque_step_Nm": 20.602
        },
        "key_numerical_markers": {
            "pre_step_active_power_W": 1835.80,
            "post_step_active_power_W": 5706.68,
            "theoretical_active_power_W": 5701.34,
            "active_power_relative_error_pct": 0.094,
            "pre_step_reactive_power_var": 3390.40,
            "post_step_reactive_power_var": 3881.57,
            "theoretical_reactive_power_var": 3844.67,
            "reactive_power_relative_error_pct": 0.960
        },
        "axis_extents": {
            "xlim": [0.0, 8.0],
            "ylim_P": [-500.0, 14000.0],
            "ylim_Q": [0.0, 18000.0]
        },
        "physical_phenomena_summary": [
            "A potência ativa trifásica absorvida salta de 1.84 kW para 5.71 kW para suprir a carga mecânica e o atrito da bancada.",
            "A potência reativa passa de 3.39 kvar para 3.88 kvar, refletindo o aumento do fluxo de dispersão com o aumento das correntes.",
            "O cálculo instantâneo via transformação de Clarke (alpha-beta) proporciona resposta instantânea e transparente sem defasagem.",
            "Ambas as grandezas convergem com erros sub-1% frente às predições do circuito analítico (P: 0.094%, Q: 0.960%)."
        ]
    },
    {
        "figure_id": "item2d_step_load_torque",
        "legacy_id": "step_load_torque",
        "dest_dir": "out/parte2_dinamico/figures",
        "task_ref": "Part 2, Item D",
        "title": "Conjugado Eletromagnético no Degrau de Carga Nominal",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "step_instant_s": 5.0,
            "load_torque_step_Nm": 20.602
        },
        "key_numerical_markers": {
            "pre_step_no_load_torque_Nm": 7.922,
            "post_step_loaded_torque_Nm": 28.186,
            "theoretical_equilibrium_torque_Nm": 28.192,
            "applied_shaft_torque_TL_Nm": 20.602,
            "viscous_drag_opposing_torque_Nm": 7.586,
            "steady_state_relative_error_pct": 0.021
        },
        "axis_extents": {
            "xlim_full": [0.0, 8.0],
            "ylim_full": [-35.0, 95.0],
            "xlim_zoom": [4.8, 6.8],
            "ylim_zoom": [0.0, 36.0]
        },
        "physical_phenomena_summary": [
            "Equilíbrio eletromecânico Te = TL + B*wm rigorosamente verificado: 20.602 + (0.0426 * 178.07) = 28.188 N.m.",
            "O conjugado simulado converge para 28.186 N.m com erro relativo de apenas 0.021%.",
            "A transição de conjugado responde rapidamente à solicitação do degrau com acomodação em menos de 1.0 s.",
            "O arraste viscoso da bancada MG responde por 27% do conjugado eletromagnético total requerido em regime com carga nominal."
        ]
    },
    {
        "figure_id": "item2e_regenerative_speed",
        "legacy_id": "regenerative_speed",
        "dest_dir": "out/parte2_dinamico/figures",
        "task_ref": "Part 2, Item E",
        "title": "Transitório de Velocidade na Operação como Gerador Hipersíncrono",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "step_instant_s": 5.0,
            "load_torque_step_Nm": -20.602,
            "prime_mover_operation": True
        },
        "key_numerical_markers": {
            "pre_step_no_load_speed_rpm": 1775.36,
            "synchronous_speed_rpm": 1800.0,
            "post_step_hypersynchronous_speed_rpm": 1836.42,
            "theoretical_hypersynchronous_speed_rpm": 1836.21,
            "hypersynchronous_slip": -0.02023,
            "steady_state_relative_error_pct": 0.011
        },
        "axis_extents": {
            "xlim_full": [0.0, 8.0],
            "ylim_full": [0.0, 1950.0],
            "xlim_zoom": [4.8, 7.0],
            "ylim_zoom": [1760.0, 1855.0]
        },
        "physical_phenomena_summary": [
            "O torque mecânico negativo (TL = -20.602 N.m) aciona a máquina como motor primário (prime mover).",
            "A velocidade ultrapassa a velocidade síncrona de 1800 rpm a t ~ 5.3 s, adentrando o quadrante gerador hipersíncrono.",
            "A rotação estabiliza em 1836.42 rpm (escorregamento negativo s = -2.02%).",
            "O escorregamento negativo inverte a resistência aparente do rotor R2/s < 0, transformando o rotor em fonte ativa de potência."
        ]
    },
    {
        "figure_id": "item2e_regenerative_powers",
        "legacy_id": "regenerative_powers",
        "dest_dir": "out/parte2_dinamico/figures",
        "task_ref": "Part 2, Item E",
        "title": "Inversão do Fluxo de Potência Ativa na Operação Regenerativa",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "step_instant_s": 5.0,
            "load_torque_step_Nm": -20.602
        },
        "key_numerical_markers": {
            "pre_step_active_power_W": 1835.80,
            "post_step_active_power_W": -2218.13,
            "theoretical_active_power_W": -2219.34,
            "active_power_relative_error_pct": 0.054,
            "pre_step_reactive_power_var": 3390.40,
            "post_step_reactive_power_var": 3118.39,
            "theoretical_reactive_power_var": 3119.08,
            "reactive_power_relative_error_pct": 0.022,
            "active_power_injection_into_grid_W": 2218.13
        },
        "axis_extents": {
            "xlim": [0.0, 8.0],
            "ylim_P": [-4000.0, 14000.0],
            "ylim_Q": [0.0, 18000.0]
        },
        "physical_phenomena_summary": [
            "Inversão comprovada do fluxo de potência ativa: de +1.84 kW (consumo a vazio) para -2.22 kW (geração líquida entregue à rede de 220 V).",
            "O consumo de potência reativa indutiva permanece estritamente positivo (+3.12 kvar), demonstrando que o gerador de indução gaiola de esquilo depende de excitação magnética externa da rede.",
            "A passagem pelo zero de potência ativa ocorre exatamente no cruzamento da rotação síncrona (1800 rpm).",
            "A concordância entre a simulação Simscape e a solução do circuito equivalente é excepcional (erro de 0.054% em P e 0.022% em Q)."
        ]
    },
    {
        "figure_id": "item2e_regenerative_torque",
        "legacy_id": "regenerative_torque",
        "dest_dir": "out/parte2_dinamico/figures",
        "task_ref": "Part 2, Item E",
        "title": "Conjugado Eletromagnético de Frenagem Regenerativa",
        "operating_conditions": {
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0,
            "step_instant_s": 5.0,
            "load_torque_step_Nm": -20.602
        },
        "key_numerical_markers": {
            "pre_step_motoring_torque_Nm": 7.922,
            "post_step_braking_torque_Nm": -12.410,
            "theoretical_braking_torque_Nm": -12.411,
            "applied_driving_torque_TL_Nm": -20.602,
            "opposing_friction_torque_Nm": 8.192,
            "steady_state_relative_error_pct": 0.008
        },
        "axis_extents": {
            "xlim_full": [0.0, 8.0],
            "ylim_full": [-45.0, 95.0],
            "xlim_zoom": [4.8, 6.8],
            "ylim_zoom": [-24.0, 12.0]
        },
        "physical_phenomena_summary": [
            "O conjugado eletromagnético torna-se estritamente negativo (Te = -12.41 N.m), atuando como torque de frenagem regenerativa contra o acionamento mecânico.",
            "O equilíbrio dinâmico no 4o quadrante satisfaz Te = TL + B*wm = -20.602 + (0.0426 * 192.31) = -12.410 N.m com erro relativo de apenas 0.008%.",
            "O balanço de potência confirma que a potência mecânica do acionador (3962 W) alimenta o atrito da bancada (1575 W), perdas elétricas (168 W) e potência injetada na rede (2218 W).",
            "Acomodação estável e assintótica alcançada em menos de 1.5 s após a perturbação."
        ]
    },

    # -------------------------------------------------------------
    # SINTETIZADO: PAINEL EXECUTIVO MULTI-CENÁRIO
    # -------------------------------------------------------------
    {
        "figure_id": "consolidated_transient_overview",
        "legacy_id": "consolidated_transient_overview",
        "dest_dir": "out/sintetizado/figures",
        "task_ref": "Synthesis & Executive Overview",
        "title": "Painel Comparativo de Transitórios e Balanço de Potência",
        "operating_conditions": {
            "scenarios_compared": ["DOL No-Load Startup (0-6s)", "Nominal Load Step +20.6 N.m (0-8s)", "Regenerative Prime Mover -20.6 N.m (0-8s)"],
            "voltage_LL_rms_V": 220.0,
            "frequency_Hz": 60.0
        },
        "key_numerical_markers": {
            "no_load_speed_rpm": 1775.36,
            "nominal_loaded_speed_rpm": 1700.42,
            "hypersynchronous_speed_rpm": 1836.42,
            "no_load_torque_Nm": 7.922,
            "nominal_loaded_torque_Nm": 28.186,
            "regenerative_torque_Nm": -12.410,
            "no_load_active_power_W": 1835.80,
            "nominal_loaded_active_power_W": 5706.68,
            "regenerative_active_power_W": -2218.13,
            "bench_viscous_losses_range_kW": [1.350, 1.576]
        },
        "axis_extents": {
            "xlim_transients_s": [0.0, 8.0],
            "ylim_power_kW": [-6.0, 8.0]
        },
        "physical_phenomena_summary": [
            "Visão executiva integrada comparando as três trajetórias dinâmicas essenciais da máquina de indução.",
            "Demonstração visual do cruzamento de regime motor sub-síncrono (1700.4 rpm) para gerador hipersíncrono (1836.4 rpm).",
            "Clara visualização da inversão de polaridade do fluxo de potência ativa entre operação motora (+5.71 kW) e geradora (-2.22 kW).",
            "O gráfico em barras no Subplot 4 fornece a resolução definitiva do balanço de perdas mecânicas rotacionais da bancada acoplada."
        ]
    }
]


def main():
    print("[INFO] Generating companion telemetry sidecar JSONs...")
    created_count = 0

    for item in SIDECARS:
        # 1. Target in academic-aligned directory
        target_dir = ROOT / item["dest_dir"]
        target_dir.mkdir(parents=True, exist_ok=True)
        target_file = target_dir / f"{item['figure_id']}.json"

        # 2. Legacy mirror in out/figures/ for backward compatibility
        legacy_dir = ROOT / "out" / "figures"
        legacy_dir.mkdir(parents=True, exist_ok=True)
        legacy_file = legacy_dir / f"{item['legacy_id']}.json"

        # Content dictionary (without dest_dir / legacy_id internal keys)
        payload = {k: v for k, v in item.items() if k not in ["dest_dir", "legacy_id"]}

        # Write academic target
        with open(target_file, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2, ensure_ascii=False)
        created_count += 1

        # Write legacy target
        with open(legacy_file, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2, ensure_ascii=False)

        print(f"  [OK] Generated {target_file.relative_to(ROOT)} & {legacy_file.relative_to(ROOT)}")

    print(f"\n[PASS] Successfully generated {created_count} companion telemetry sidecars.")
    return 0


if __name__ == "__main__":
    main()
