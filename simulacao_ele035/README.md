# Workspace Acadêmico de Simulação e Análise — UFMG ELE035
## Trabalho Final de Simulação: Motor de Indução Trifásico WEG 3,7 kW (5 cv)
**Disciplina:** ELE035 - Laboratório de Conversão de Energia  
**Professor:** Victor Flores Mendes  
**Departamento:** Engenharia Elétrica - UFMG  

---

## 1. Visão Geral da Estrutura

Esta pasta (`simulacao_ele035/`) foi estruturada para espelhar **rigorosamente a sequência de tópicos e procedimentos do documento oficial da disciplina** (`utils/docs/sim_proj.pdf`).

Para cada tarefa, o código fonte em MATLAB, os parâmetros, a documentação teórica e as figuras geradas encontram-se **agrupados no mesmo diretório**, permitindo inspeção rápida tanto por linha de comando quanto via MATLAB GUI.

```text
simulacao_ele035/
├── parte1_regime_permanente/
│   ├── item_A_B_C_ponto_nominal/          % Resolução do ponto nominal de catálogo (1715 rpm)
│   │   ├── run_item_ABC.m                 % Script autônomo (Ctrl+Enter por seção)
│   │   ├── nominal_metrics.csv            % Tabela comparativa (Placa vs. Calculado)
│   │   └── README.md                      % Equacionamento e deduções passo a passo
│   ├── item_D_E_curvas_estator/            % As 5 curvas características de regime pleno
│   │   ├── run_item_E_torque.m            % 1. Torque x Velocidade (Tmax, Tn, Tpartida)
│   │   ├── run_item_E_corrente.m          % 2. Corrente de Estator x Velocidade
│   │   ├── run_item_E_potencia.m          % 3. Potência Ativa x Velocidade (Pelec, Pag, Pem, Pshaft)
│   │   ├── run_item_E_fp.m                % 4. Fator de Potência x Velocidade
│   │   ├── run_item_E_rendimento.m        % 5. Rendimento x Velocidade (interno vs. bancada)
│   │   ├── run_all_item_E.m               % Script mestre que executa as 5 curvas
│   │   ├── figures/                       % Figuras em alta resolução (.png 300 DPI e .fig)
│   │   └── data/                          % Sidecars JSON e vetores analíticos
│   └── item_F_controle_escalar_vf/        % Curvas sob controle V/f constante
│       ├── run_item_F_vf_family.m         % Curvas a 100%, 75%, 50% e 25% com marcadores Tmax
│       ├── figures/                       % Gráficos sobrepostos (.png e .fig)
│       └── README.md                      % Análise teórica da queda IR e voltage boost
└── parte2_simulacao_dinamica/
    ├── item_A_modelo_simscape/            % Diagrama Simscape SPS e parametrização
    │   ├── abrir_modelo.m                 % Abre o modelo no Simulink GUI com 1 clique
    │   ├── mit_simscape_model.slx         % Modelo Simscape SPS (unidades SI, referencial rotor)
    │   ├── setup_parametros_Y.m           % Transformação Estrela-Triângulo de impedâncias (R/3, L/3)
    │   └── README.md                      % Explicação dos blocos e convenções
    ├── item_B_calculo_partida/            % Cálculo analítico em rotor bloqueado (s = 1)
    │   ├── run_item_B_partida.m           % Solução em s=1 (Ip simétrico e estimativa de pico DC)
    │   ├── resultados_partida.json        % Dados numéricos exportados
    │   └── README.md                      % Dedução do inrush e constante de tempo L/R
    ├── item_C_partida_direta_vazio/       % Transitório de partida direta a vazio (TL = 0)
    │   ├── run_item_C_simulacao.m         % Executa simulação por 6.0s e plota waveforms
    │   ├── figures/                       % Corrente (inrush), velocidade e torque (.png, .fig)
    │   ├── analise_convergencia.json      % Validação numérica frente ao analítico
    │   └── README.md                      % Discussão do amortecimento e estabilização
    ├── item_D_degrau_carga_nominal/       % Transitório com degrau de carga (TL = +Tnom)
    │   ├── run_item_D_simulacao.m         % Executa degrau em t = 5.0s por 8.0s
    │   ├── figures/                       % Velocidade, conjugado, corrente, potências P e Q
    │   ├── convergencia_nominal.csv       % Auditoria de tolerância (erro <= 2%)
    │   └── README.md                      % Análise do novo equilíbrio eletromecânico
    └── item_E_operacao_regenerativa/      % Operação regenerativa / gerador (TL = -Tnom)
        ├── run_item_E_simulacao.m         % Executa degrau negativo em t = 5.0s por 8.0s
        ├── figures/                       % Velocidade hipersíncrona, P gerada, Q indutivo
        ├── comparison_3.3.json            % Dados consolidados de simulação
        └── analise_fluxo_potencia.md      % Teoria do gerador assíncrono e reversão de potência
```

---

## 2. Guia de Uso no MATLAB GUI

### Para Inspecionar Códigos e Curvas
1. No MATLAB, navegue até a pasta de interesse (ex: `parte1_regime_permanente/item_D_E_curvas_estator`).
2. Abra qualquer script `run_item_*.m` no MATLAB Editor.
3. Use `Ctrl+Enter` para rodar seção por seção (`%%`) ou clique em **Run** para executar o script completo.
4. As figuras interativas abrem na tela e salvam automaticamente versões `.fig` (com zoom/pan ativos) e `.png` (para relatórios em 300 DPI) na pasta `figures/`.

### Para Inspecionar o Modelo Simscape no Simulink
1. Navegue até `parte2_simulacao_dinamica/item_A_modelo_simscape`.
2. Digite no Command Window:
   ```matlab
   abrir_modelo
   ```
3. O Simulink abrirá imediatamente com todas as variáveis e parâmetros físicos em unidades SI carregados no Workspace.
