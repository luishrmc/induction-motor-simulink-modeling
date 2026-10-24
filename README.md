# Modelagem Analítica e Simulação Dinâmica de Motor de Indução Trifásico (MIT)
## UFMG — ELE035: Laboratório de Conversão de Energia

[![MATLAB](https://img.shields.io/badge/MATLAB-R2026b-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![Simulink](https://img.shields.io/badge/Simulink-Simscape%20Electrical-orange.svg)](https://www.mathworks.com/products/simscape.html)
[![Institution](https://img.shields.io/badge/UFMG-Engenharia%20Elétrica-red.svg)](https://www.ufmg.br/)
[![Status](https://img.shields.io/badge/Status-100%25%20Concluído%20%26%20Validado-brightgreen.svg)]()

Este repositório contém o projeto computacional completo de modelagem em regime permanente e simulação dinâmica de transitórios eletromecânicos de um **motor de indução trifásico de gaiola de esquilo WEG de 3,7 kW (5 cv)**, desenvolvido para a disciplina **ELE035 - Laboratório de Conversão de Energia** da **Universidade Federal de Minas Gerais (UFMG)**, sob orientação do Prof. Victor Flores Mendes.

O projeto atende com rigor à especificação oficial acadêmica ([`utils/docs/sim_proj.pdf`](utils/docs/sim_proj.pdf)), combinando os parâmetros consolidados nos ensaios laboratoriais ([`utils/docs/LAB_CONV_RLT_08_09_10.pdf`](utils/docs/LAB_CONV_RLT_08_09_10.pdf)), resolução matricial 100% vetorizada do circuito equivalente IEEE e simulação temporal em **Simscape Specialized Power Systems (SPS)**.

---

## 📌 Especificações do Motor e Parâmetros Experimentais Invariantes

Os parâmetros adotados correspondem à máquina ensaiada em bancada, conectada em **Triângulo ($\Delta$)** a $220\text{ V}$ RMS de linha e $60\text{ Hz}$:

| Grandeza / Parâmetro | Símbolo | Valor | Unidade | Origem / Método de Ensaio |
| :--- | :---: | :---: | :---: | :--- |
| Potência Mecânica Nominal | $P_n$ | 3,7 (5) | kW (cv) | Dados de Placa / Catálogo WEG |
| Tensão Nominal de Linha ($\Delta$) | $V_n$ | 220 | V RMS | Dados de Placa |
| Corrente Nominal de Linha | $I_n$ | 14,0 | A RMS | Dados de Placa |
| Frequência Nominal | $f_n$ | 60 | Hz | Dados de Placa |
| Número de Polos / Pares | $p / p_{pares}$ | 4 / 2 | polos | Dados de Placa ($n_s = 1800\text{ rpm}$) |
| Velocidade Nominal | $n_n$ | 1715 | rpm | Dados de Placa ($\omega_n = 179,59\text{ rad/s}$) |
| Fator de Potência Nominal | $\cos\phi$ | 0,81 | - | Dados de Placa |
| Rendimento Nominal de Placa | $\eta$ | 85,5 | % | Dados de Placa |
| **Resistência do Estator por Fase** | $R_1$ | **1,189** | $\Omega$ | Ensaio de Resistência CC (Tabela 2.4) |
| **Resistência do Rotor Referida** | $R_2'$ | **1,180** | $\Omega$ | Ensaio de Rotor Bloqueado (Tabela 2.4) |
| **Indutância de Dispersão Estatórica** | $L_{l1}$ | **5,725** | mH | Rotor Bloqueado ($X_1 = 2,158\,\Omega$) |
| **Indutância de Dispersão Rotórica** | $L_{l2}'$ | **8,420** | mH | Rotor Bloqueado ($X_2' = 3,174\,\Omega$) |
| **Indutância de Magnetização** | $L_m$ | **131,571** | mH | Ensaio a Vazio ($X_m = 49,601\,\Omega$) |
| **Momento de Inércia do Conjunto** | $J$ | **0,701** | $\text{kg}\cdot\text{m}^2$ | Ensaio de Desaceleração Livre (Seção 2.4) |
| **Coeficiente de Atrito Viscoso** | $B$ | **0,0426** | $\text{N}\cdot\text{m}\cdot\text{s/rad}$ | Perdas de Rotação Mecânica a Vazio |

---

## 🗂️ Índice Geral das Tarefas e Módulos do Projeto

O código, os modelos, as figuras interativas (`.fig`), as figuras de alta resolução (`.png`), a telemetria (`.json`/`.csv`) e os memoriais de cálculo estão agrupados por tarefa específica na pasta [`simulacao_ele035/`](simulacao_ele035/), espelhando a ementa de [`sim_proj.pdf`](utils/docs/sim_proj.pdf). Utilize os links da tabela abaixo para navegar diretamente para a documentação e os scripts de cada bloco:

### 1ª Parte: Regime Permanente Analítico

| Bloco Acadêmico | Tarefa / Descrição | Script Executável | Documentação do Bloco | Entregáveis Principais |
|---|---|---|:---:|---|
| **Itens 1.A, 1.B e 1.C** | Ponto Nominal, Torque Nominal ($T_n$) e Resolução do Circuito IEEE | [`run_item_ABC.m`](simulacao_ele035/parte1_regime_permanente/item_A_B_C_ponto_nominal/run_item_ABC.m) | [📖 README](simulacao_ele035/parte1_regime_permanente/item_A_B_C_ponto_nominal/README.md) | $T_n = 20,60\text{ N}\cdot\text{m}$, $Z_{in}$, balanço de perdas ($B\omega_m^2$) e [`nominal_metrics.csv`](simulacao_ele035/parte1_regime_permanente/item_A_B_C_ponto_nominal/nominal_metrics.csv) |
| **Itens 1.D e 1.E** | Varreduras $0 \to n_s$ e as 5 Curvas Características do Estator | [`run_all_item_E.m`](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_all_item_E.m)<br>*(ou scripts individuais)* | [📖 README](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/README.md) | 5 Gráficos: $T \times n$ ($T_{max} = 54,6\text{ N}\cdot\text{m}$), $I \times n$, $P \times n$, $\cos\phi \times n$, $\eta \times n$ (`.png`, `.fig`, `.json`) |
| **Item 1.F** | Família de Curvas de Conjugado sob Controle Escalar $V/f$ | [`run_item_F_vf_family.m`](simulacao_ele035/parte1_regime_permanente/item_F_controle_escalar_vf/run_item_F_vf_family.m) | [📖 README](simulacao_ele035/parte1_regime_permanente/item_F_controle_escalar_vf/README.md) | Sobreposição das curvas a $100\%$, $75\%$, $50\%$ e $25\%$ ($V/f = \text{cte}$), marcadores de $T_{max}$ e análise de *voltage boost* |

*Scripts individuais de curvas do Item 1.E:*
- Torque: [`run_item_E_torque.m`](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_item_E_torque.m)
- Corrente: [`run_item_E_corrente.m`](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_item_E_corrente.m)
- Potência Ativa: [`run_item_E_potencia.m`](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_item_E_potencia.m)
- Fator de Potência: [`run_item_E_fp.m`](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_item_E_fp.m)
- Rendimento: [`run_item_E_rendimento.m`](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_item_E_rendimento.m)

---

### 2ª Parte: Simulação Dinâmica Simscape (Specialized Power Systems)

| Bloco Acadêmico | Tarefa / Descrição | Script Executável | Documentação do Bloco | Entregáveis Principais |
|---|---|---|:---:|---|
| **Item 2.A** | Modelo Simscape SPS, Abertura no GUI e Parametrização $Y$ | [`abrir_modelo.m`](simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape/abrir_modelo.m)<br>[`setup_parametros_Y.m`](simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape/setup_parametros_Y.m) | [📖 README](simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape/README.md) | Diagrama [`mit_simscape_model.slx`](simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape/mit_simscape_model.slx) parametrizado ($R/3, L/3$) |
| **Item 2.B** | Cálculo Analítico de Partida em Rotor Bloqueado ($s = 1$) | [`run_item_B_partida.m`](simulacao_ele035/parte2_simulacao_dinamica/item_B_calculo_partida/run_item_B_partida.m) | [📖 README](simulacao_ele035/parte2_simulacao_dinamica/item_B_calculo_partida/README.md) | Corrente simétrica de partida ($67,73\text{ A}$ RMS), torque de partida ($25,35\text{ N}\cdot\text{m}$) e estimativa de offset CC |
| **Item 2.C** | Simulação da Partida Direta a Vazio e Validação de Inrush | [`run_item_C_simulacao.m`](simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio/run_item_C_simulacao.m) | [📖 README](simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio/README.md) | Inrush de $121,25\text{ A}$, amortecimento em $70\text{ ms}$, estabilização a $1775,36\text{ rpm}$ e convergência $< 0,1\%$ |
| **Item 2.D** | Resposta ao Degrau de Carga Nominal ($T_L = +T_{nom}$) | [`run_item_D_simulacao.m`](simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/run_item_D_simulacao.m) | [📖 README](simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/README.md) | Formas de onda de $n(t)$, $T_e(t)$, $i_a(t)$, $P(t)$ e $Q(t)$; novo equilíbrio em $1700,42\text{ rpm}$ e $T_e = 28,19\text{ N}\cdot\text{m}$ |
| **Item 2.E** | Frenagem Regenerativa / Gerador Hipersíncrono ($T_L = -T_{nom}$) | [`run_item_E_simulacao.m`](simulacao_ele035/parte2_simulacao_dinamica/item_E_operacao_regenerativa/run_item_E_simulacao.m) | [📖 README](simulacao_ele035/parte2_simulacao_dinamica/item_E_operacao_regenerativa/README.md) | Rotação hipersíncrona ($1836,42\text{ rpm}$), $T_e = -12,41\text{ N}\cdot\text{m}$, injeção ativa de $2,22\text{ kW}$ e consumo reativo de $3,12\text{ kvar}$ |

---

### Síntese Consolidada e Relatório Técnico Final

| Módulo | Descrição do Conteúdo | Arquivo Principal | Documentação / Formatos |
|---|---|---|:---:|
| **Painel de Síntese Multicenário** | Visão executiva integrada de todos os transitórios e tabela comparativa | [`run_painel_consolidado.m`](simulacao_ele035/painel_sintese_consolidado/run_painel_consolidado.m) | [📖 README](simulacao_ele035/painel_sintese_consolidado/README.md)<br>[`consolidated_comparison.csv`](simulacao_ele035/painel_sintese_consolidado/results/consolidated_comparison.csv) |
| **Relatório Técnico Final da Disciplina** | Documento acadêmico completo com deduções teóricas, gráficos e análises | [`RELATORIO_FINAL_SIMULACAO.md`](docs/RELATORIO_FINAL_SIMULACAO.md) | [📖 README docs](docs/README.md)<br>[📄 PDF Compilado](docs/RELATORIO_FINAL_SIMULACAO.pdf) |

---

## 💻 Guia Rápido de Uso no MATLAB GUI

### 1. Inspecionar e Executar Scripts Analíticos e Simulações
Todos os scripts em [`simulacao_ele035/`](simulacao_ele035/) são autônomos e estruturados em células de código (`%%`).
1. Abra o MATLAB e utilize o *Current Folder* para navegar até a pasta desejada:
   ```matlab
   cd simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator
   ```
2. Abra o script no MATLAB Editor (ex.: `run_item_E_torque.m`).
3. Posicione o cursor em qualquer seção e pressione `Ctrl+Enter` para executar interativamente e inspecionar variáveis no *Workspace*, ou clique no botão **Run** (`F5`).
4. As janelas gráficas exibem os gráficos com formatação tipográfica rigorosa em LaTeX, mantendo os arquivos `.fig` (para zoom interativo) e `.png` (para impressão) salvos na pasta `figures/`.

### 2. Abrir o Modelo Simscape no Simulink
Para inspecionar o diagrama de blocos, fontes trifásicas, configurações do solver e blocos de medição:
```matlab
cd simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape
abrir_modelo
```
O comando carrega todos os parâmetros físicos no Base Workspace e abre o arquivo [`mit_simscape_model.slx`](simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape/mit_simscape_model.slx) no Simulink GUI, pronto para simulação manual pelo botão "Play".

---

## 🏛️ Estrutura Limpa do Repositório

```text
ufmg/lab-conv/proj/
├── simulacao_ele035/                         # Árvore modular de simulação (sim_proj.pdf)
│   ├── README.md                             # Guia mestre do pacote de simulação
│   ├── parte1_regime_permanente/
│   │   ├── item_A_B_C_ponto_nominal/         # [README] [run_item_ABC.m] [nominal_metrics.csv]
│   │   ├── item_D_E_curvas_estator/          # [README] [run_item_E_*.m] [figures/] [data/]
│   │   └── item_F_controle_escalar_vf/       # [README] [run_item_F_vf_family.m] [figures/]
│   ├── parte2_simulacao_dinamica/
│   │   ├── item_A_modelo_simscape/           # [README] [abrir_modelo.m] [mit_simscape_model.slx]
│   │   ├── item_B_calculo_partida/           # [README] [run_item_B_partida.m] [resultados_partida.json]
│   │   ├── item_C_partida_direta_vazio/      # [README] [run_item_C_simulacao.m] [figures/]
│   │   ├── item_D_degrau_carga_nominal/      # [README] [run_item_D_simulacao.m] [figures/]
│   │   └── item_E_operacao_regenerativa/     # [README] [run_item_E_simulacao.m] [figures/]
│   └── painel_sintese_consolidado/           # [README] [run_painel_consolidado.m] [figures/] [results/]
├── docs/
│   ├── README.md                             # Índice da pasta de documentação
│   ├── RELATORIO_FINAL_SIMULACAO.md          # Relatório acadêmico completo em Markdown
│   └── RELATORIO_FINAL_SIMULACAO.pdf         # Relatório final compilado pronto para entrega
├── utils/
│   ├── data/                                 # Dados brutos de ensaio da bancada (CSVs de 01 a 07)
│   ├── docs/                                 # sim_proj.pdf e relatório laboratorial de referência
│   ├── memory/                               # Registros de decisões técnicas (ADRs) e digests
│   └── plan/                                 # Cronograma de desenvolvimento e checklist
├── .agents/                                  # Governança multiagente, hooks e recibos (.agents/gates/)
├── .gitignore                                # Regras estritas de exclusão de artefatos temporários
└── GEMINI.md                                 # Diretrizes globais de engenharia e modelagem
```

---

## 🛡️ Governança de Qualidade e Portões de Tolerância

O repositório adota uma política de tolerância zero para desvios numéricos entre o modelo analítico e as simulações dinâmicas de regime permanente ($\text{erro} \le 2,0\%$). Todos os testes são auditados de forma determinística por hooks executáveis em Python:

```bash
# Validação da integridade do plano e dos digests de memória
python3 .agents/hooks/plan-sync.py check
python3 .agents/hooks/memory-check.py

# Verificação estática de código MATLAB (vetorização e estilo)
bash .agents/hooks/matlab-lint.sh

# Auditoria de tolerância de regime permanente (analítico vs. Simscape)
python3 .agents/hooks/tolerance-gate.py --task 1.1   # Ponto nominal estático (Erro 0.0%)
python3 .agents/hooks/tolerance-gate.py --task 3.1   # Partida a vazio (Erro máx 0.095%)
python3 .agents/hooks/tolerance-gate.py --task 3.2   # Degrau de carga (Erro máx 0.96%)
python3 .agents/hooks/tolerance-gate.py --task 3.3   # Operação regenerativa (Erro máx 0.054%)

# Auditoria completa de entregáveis de dados, figuras e relatório
python3 .agents/hooks/deliverable-audit.py --task 4.1
python3 .agents/hooks/deliverable-audit.py --task 4.2
```

---
*Universidade Federal de Minas Gerais (UFMG) — Departamento de Engenharia Elétrica — ELE035 Conversão de Energia.*
