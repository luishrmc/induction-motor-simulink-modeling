# Modelagem Analítica e Simulação Dinâmica de Motor de Indução Trifásico (MIT)
## UFMG — ELE035: Laboratório de Conversão de Energia

[![MATLAB](https://img.shields.io/badge/MATLAB-R2026b-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![Simulink](https://img.shields.io/badge/Simulink-Simulink%20Electrical-orange.svg)](https://www.mathworks.com/products/Simulink.html)
[![LaTeX](https://img.shields.io/badge/LaTeX-Modular%20Report-008080.svg)](docs/latex/main.tex)
[![Institution](https://img.shields.io/badge/UFMG-Engenharia%20Elétrica-red.svg)](https://www.ufmg.br/)
[![Status](https://img.shields.io/badge/Status-Fase%205%20(v0.2%20%7C%2084.4%25)-blue.svg)](utils/plan/STATUS.md)

Este repositório contém o projeto computacional de modelagem em regime permanente e simulação dinâmica de transitórios eletromecânicos de um **motor de indução trifásico de gaiola de esquilo WEG de 3,7 kW (5 cv)**, desenvolvido para a disciplina **ELE035 - Laboratório de Conversão de Energia** da **Universidade Federal de Minas Gerais (UFMG)**, sob orientação do Prof. Victor Flores Mendes.

O projeto atende à especificação oficial acadêmica ([`utils/docs/sim_proj.pdf`](utils/docs/sim_proj.pdf)), combinando os parâmetros consolidados nos ensaios laboratoriais ([`utils/docs/LAB_CONV_RLT_08_09_10.pdf`](utils/docs/LAB_CONV_RLT_08_09_10.pdf)), resolução matricial 100% vetorizada do circuito equivalente em T por fase, simulação temporal em **Simulink Specialized Power Systems (SPS)** e relatório técnico modular em LaTeX ([`docs/latex/main.tex`](docs/latex/main.tex)).

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
| **Momento de Inércia Equivalente** | $J$ | **0,0555** | $\text{kg}\cdot\text{m}^2$ | Ensaio de Desaceleração Livre (`04_Mecanicos.csv`, $\Delta t = 15,210\text{ s}$) |
| **Coeficiente de Atrito Viscoso** | $B$ | **0,003651** | $\text{N}\cdot\text{m}\cdot\text{s/rad}$ | Perdas Rotacionais a Vazio ($P_{rot} = 129,568\text{ W}$ a $1799\text{ rpm}$) |

Todos os scripts analíticos e dinâmicos consomem a fonte única canônica [`simulacao_ele035/parametros_motor.m`](simulacao_ele035/parametros_motor.m).

---

## 🗂️ Índice Geral das Tarefas e Módulos do Projeto

O código, os modelos, as figuras interativas (`.fig`), as figuras de alta resolução (`.png`), a telemetria (`.json`/`.csv`) e os memoriais de cálculo estão agrupados por tarefa específica na pasta [`simulacao_ele035/`](simulacao_ele035/), espelhando a ementa de [`sim_proj.pdf`](utils/docs/sim_proj.pdf).

### 1ª Parte: Regime Permanente Analítico

| Bloco Acadêmico | Tarefa / Descrição | Script Executável | Documentação do Bloco | Entregáveis Principais |
|---|---|---|:---:|---|
| **Itens 1.A, 1.B e 1.C** | Ponto Nominal, Torque Nominal ($T_n$) e Resolução do Circuito Equivalente | [`run_item_ABC.m`](simulacao_ele035/parte1_regime_permanente/item_A_B_C_ponto_nominal/run_item_ABC.m) | [📖 README](simulacao_ele035/parte1_regime_permanente/item_A_B_C_ponto_nominal/README.md) | $T_n = 20,60\text{ N}\cdot\text{m}$, $Z_{in}$, balanço de perdas ($P_{rot} = B\omega_m^2 = 117,76\text{ W}$, $\eta_{shaft} = 87,04\%$) e [`nominal_metrics.csv`](simulacao_ele035/parte1_regime_permanente/item_A_B_C_ponto_nominal/nominal_metrics.csv) |
| **Itens 1.D e 1.E** | Varreduras $0 \to n_s$ e as 5 Curvas Características do Estator | [`run_all_item_E.m`](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_all_item_E.m)<br>*(ou scripts individuais)* | [📖 README](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/README.md) | 5 Gráficos: $T \times n$ ($T_{max} = 54,63\text{ N}\cdot\text{m}$), $I \times n$, $P \times n$, $\cos\phi \times n$, $\eta \times n$ (`.png`, `.fig`, `.json`) |
| **Item 1.F** | Família de Curvas de Conjugado sob Controle Escalar $V/f$ | [`run_item_F_vf_family.m`](simulacao_ele035/parte1_regime_permanente/item_F_controle_escalar_vf/run_item_F_vf_family.m) | [📖 README](simulacao_ele035/parte1_regime_permanente/item_F_controle_escalar_vf/README.md) | Sobreposição das curvas a $100\%$, $75\%$, $50\%$ e $25\%$ ($V/f = \text{cte}$), marcadores de $T_{max}$ e análise de *voltage boost* |

*Scripts individuais de curvas do Item 1.E:*
- Torque: [`run_item_E_torque.m`](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_item_E_torque.m)
- Corrente: [`run_item_E_corrente.m`](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_item_E_corrente.m)
- Potência Ativa: [`run_item_E_potencia.m`](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_item_E_potencia.m)
- Fator de Potência: [`run_item_E_fp.m`](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_item_E_fp.m)
- Rendimento: [`run_item_E_rendimento.m`](simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator/run_item_E_rendimento.m)

---

### 2ª Parte: Simulação Dinâmica Simulink (Specialized Power Systems)

| Bloco Acadêmico | Tarefa / Descrição | Script Executável | Documentação do Bloco | Entregáveis Principais |
|---|---|---|:---:|---|
| **Item 2.A** | Modelo Simulink SPS, Abertura no GUI, Parametrização $Y$ e Harness | [`abrir_modelo.m`](simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_Simulink/abrir_modelo.m)<br>[`setup_parametros_Y.m`](simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_Simulink/setup_parametros_Y.m)<br>[`run_sim_harness.m`](simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_Simulink/run_sim_harness.m) | [📖 README](simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_Simulink/README.md) | Diagrama [`mit_Simulink_model.slx`](simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_Simulink/mit_Simulink_model.slx) parametrizado ($R/3, L/3$) e esquema [`mit_Simulink_diagram.png`](simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_Simulink/figures/mit_Simulink_diagram.png) |
| **Item 2.B** | Cálculo Analítico de Partida em Rotor Bloqueado ($s = 1$) | [`run_item_B_partida.m`](simulacao_ele035/parte2_simulacao_dinamica/item_B_calculo_partida/run_item_B_partida.m) | [📖 README](simulacao_ele035/parte2_simulacao_dinamica/item_B_calculo_partida/README.md) | Corrente simétrica de partida ($67,73\text{ A}$ RMS), torque de partida ($25,35\text{ N}\cdot\text{m}$) e pico teórico de inrush ($120,44\text{ A}$) |
| **Item 2.C** | Simulação da Partida Direta a Vazio e Validação de Inrush | [`run_item_C_simulacao.m`](simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio/run_item_C_simulacao.m) | [📖 README](simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio/README.md) | Inrush de $121,18\text{ A}$, amortecimento em $\sim 70\text{ ms}$, estabilização a $1797,92\text{ rpm}$ ($0,36\text{ s}$) e convergência $\le 0,28\%$ |
| **Item 2.D** | Resposta ao Degrau de Carga Nominal ($T_L = +T_{nom}$) | [`run_item_D_simulacao.m`](simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/run_item_D_simulacao.m) | [📖 README](simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal/README.md) | Degrau em $t = 1,5\text{ s}$ ($0$–$3,0\text{ s}$); equilíbrio em $1728,87\text{ rpm}$, $T_e = 21,263\text{ N}\cdot\text{m}$, $I = 14,163\text{ A}$ e $P = 4248,71\text{ W}$ |
| **Item 2.E** | Frenagem Regenerativa / Gerador Hipersíncrono ($T_L = -T_{nom}$) | [`run_item_E_simulacao.m`](simulacao_ele035/parte2_simulacao_dinamica/item_E_operacao_regenerativa/run_item_E_simulacao.m) | [📖 README](simulacao_ele035/parte2_simulacao_dinamica/item_E_operacao_regenerativa/README.md) | Rotação hipersíncrona ($1857,86\text{ rpm}$), $T_e = -19,892\text{ N}\cdot\text{m}$, injeção ativa de $3,54\text{ kW}$ ($-3543,60\text{ W}$) e consumo reativo de $3,52\text{ kvar}$ |

---

### Síntese Consolidada e Relatório Técnico em LaTeX (Fase 5)

| Módulo | Descrição do Conteúdo | Arquivo Principal | Status / Formatos |
|---|---|---|---|
| **Painel de Síntese Multicenário** | Visão executiva integrada de todos os transitórios e tabela comparativa | [`run_painel_consolidado.m`](simulacao_ele035/painel_sintese_consolidado/run_painel_consolidado.m) | [📖 README](simulacao_ele035/painel_sintese_consolidado/README.md) · [`consolidated_comparison.csv`](simulacao_ele035/painel_sintese_consolidado/results/consolidated_comparison.csv) |
| **Relatório Técnico Modular (LaTeX)** | Documento acadêmico modular com deduções, CircuitikZ, figuras e análises | [`docs/latex/main.tex`](docs/latex/main.tex) | Capítulos 1–4, Conclusão e Apêndices atualizados em `docs/latex/out/main.pdf` (compilação via `latex-gate.py`) |

---

## ⚙️ Pré-requisitos, Instalação e Uso

### 1. Dependências do Ambiente
- **MATLAB R2026b** com **Simulink** e **Simulink Electrical (Specialized Power Systems)**.
- **Python 3** (biblioteca padrão; executa os hooks determinísticos de auditoria e sincronização).
- **Distribuição TeX Live** com `latexmk`, `pdflatex`, `bibtex` e pacotes `babel` (`brazilian`), `newtxtext`, `newtxmath`, `siunitx`, `circuitikz`, `booktabs`, `cleveref`, `listings`, `steinmetz`.
- *(Opcional)* **VS Code** com a extensão **LaTeX Workshop** (receitas pré-configuradas em [`.vscode/settings.json`](.vscode/settings.json)).

### 2. Configuração Inicial (Após `git clone`)
```bash
# 1. Carregue as variáveis de ambiente para execução headless (MATLAB e Python hooks)
source .agents/env.sh

# 2. Instale o hook de pre-commit localmente (obrigatório para colaboradores)
cp .agents/hooks/git-pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# 3. Verifique a integridade inicial do plano, da memória e das ferramentas
bash .agents/hooks/pre-task-audit.sh
```

### 3. Executar Scripts Analíticos e Simulações no MATLAB
Todos os scripts em [`simulacao_ele035/`](simulacao_ele035/) são autônomos e estruturados em células (`%%`):
1. **No MATLAB GUI:**
   ```matlab
   cd simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator
   run_item_E_torque   % ou use Ctrl+Enter por seção no MATLAB Editor
   ```
2. **Abrir o modelo Simulink no Simulink GUI:**
   ```matlab
   cd simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_Simulink
   abrir_modelo
   ```
3. **Execução em lote (headless CLI):**
   ```bash
   QT_QPA_PLATFORM=offscreen matlab -batch "cd('simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio'); run_item_C_simulacao;"
   ```

### 4. Compilar o Relatório LaTeX
Como `out/` é ignorado pelo Git, o PDF final é gerado localmente em `docs/latex/out/main.pdf`:
```bash
# Compilação automatizada com validação de erros, referências e citações
python3 .agents/hooks/latex-lint.py
python3 .agents/hooks/latex-gate.py
```
Ou diretamente via `latexmk` dentro de `docs/latex/` (equivalente à receita do VS Code LaTeX Workshop):
```bash
cd docs/latex
latexmk -synctex=1 -interaction=nonstopmode -file-line-error -pdf -pdflatex="pdflatex %O %S --shell-escape" -outdir=out -auxdir=out main.tex
```

---

## 🏛️ Estrutura do Repositório

```text
ufmg/lab-conv/proj/
├── simulacao_ele035/                         # Árvore modular de simulação (sim_proj.pdf)
│   ├── README.md                             # Guia mestre do pacote de simulação
│   ├── parametros_motor.m                    # Fonte canônica única (B=0.003651, J=0.0555)
│   ├── parte1_regime_permanente/
│   │   ├── item_A_B_C_ponto_nominal/         # [README] [run_item_ABC.m] [nominal_metrics.csv]
│   │   ├── item_D_E_curvas_estator/          # [README] [run_item_E_*.m] [figures/] [data/]
│   │   └── item_F_controle_escalar_vf/       # [README] [run_item_F_vf_family.m] [figures/]
│   ├── parte2_simulacao_dinamica/
│   │   ├── item_A_modelo_Simulink/           # [README] [abrir_modelo.m] [run_sim_harness.m] [mit_Simulink_model.slx] [figures/mit_Simulink_diagram.png]
│   │   ├── item_B_calculo_partida/           # [README] [run_item_B_partida.m] [resultados_partida.json]
│   │   ├── item_C_partida_direta_vazio/      # [README] [run_item_C_simulacao.m] [figures/]
│   │   ├── item_D_degrau_carga_nominal/      # [README] [run_item_D_simulacao.m] [figures/]
│   │   └── item_E_operacao_regenerativa/     # [README] [run_item_E_simulacao.m] [figures/]
│   └── painel_sintese_consolidado/           # [README] [run_painel_consolidado.m] [figures/] [results/]
├── docs/
│   ├── CONTRIBUTING.md                       # Guia de colaboração, padrões e fluxo de entrega
│   └── latex/                                # Relatório acadêmico modular em LaTeX (Fase 5)
│       ├── main.tex                          # Documento mestre
│       ├── 00_config.tex                     # Pacotes, siunitx, cleveref, listings e macros
│       ├── 02_referencias.bib                # Referências bibliográficas
│       ├── pre_textuais/                     # Capa institucional (00_capa.tex)
│       ├── cap1_introducao/                  # Capítulo 1 (Contexto e parâmetros consolidados)
│       ├── cap2_regime_permanente/           # Capítulo 2 (Regime permanente analítico e V/f)
│       ├── cap3_simulacao_dinamica/          # Capítulo 3 (Simulink SPS, partida, carga e geração)
│       ├── cap4_sintese_convergencia/        # Capítulo 4 (Painel integrado e auditoria Tier 1/2)
│       ├── pos_textuais/ & anexos/           # Conclusão geral e códigos MATLAB
│       └── img/                              # 18 figuras 300 DPI integradas ao texto
├── utils/
│   ├── data/                                 # Dados brutos de ensaio da bancada (CSVs de 01 a 07)
│   ├── docs/                                 # sim_proj.pdf e relatório laboratorial de referência
│   ├── memory/                               # ADRs, lições aprendidas, episódios e digests SHA256
│   └── plan/                                 # Cronograma, STATUS.md, CHANGELOG.md e specs 0.1–5.4
├── .agents/                                  # Governança multiagente, hooks, skills e recibos (.agents/gates/)
├── .vscode/settings.json                     # Configuração de compilação do LaTeX Workshop
├── GEMINI.md                                 # Diretrizes globais de engenharia e modelagem
└── .gitignore                                # Exclusão de build outputs (out/, *.mat, *.slxc)
```

---

## 📣 Mudanças Recentes e Prontidão para Contribuições (v0.2)

- **Consolidação do Workspace (`457260d`, `882e380`):** Os diretórios legados `matlab/` e `out/` foram consolidados em [`simulacao_ele035/`](simulacao_ele035/) e `.agents/gates/`, mantendo o harness [`run_sim_harness.m`](simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_Simulink/run_sim_harness.m) integrado junto ao modelo em `item_A_modelo_Simulink/`.
- **Migração para LaTeX Modular (`55a49b3` – `0a32b72`):** O antigo relatório monolítico `docs/RELATORIO_FINAL_SIMULACAO.{md,pdf}` foi substituído pela arquitetura modular em [`docs/latex/`](docs/latex/), com automação via `latex-lint.py`, `latex-gate.py` e hook `pre-commit` ([`.agents/hooks/git-pre-commit.sh`](.agents/hooks/git-pre-commit.sh)).
- **Marco `v0.2` (Capítulos 1 e 2 aprovados):** Tarefas `5.1` e `5.2` concluídas com zero erros de compilação e auditoria editorial aprovada (`84,4%` do esforço total concluído; ver [`utils/plan/STATUS.md`](utils/plan/STATUS.md) e [`utils/plan/CHANGELOG.md`](utils/plan/CHANGELOG.md)).
- **Próximas Contribuições:** As tarefas elegíveis em aberto são **5.3** (redação e conciliação dos Capítulos 3 e 4) e **5.4** (revisão editorial global, pós-textuais, apêndices e entrega do PDF final). Consulte [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) antes de iniciar novos commits.

---

## 🛡️ Governança de Qualidade e Portões de Verificação

O repositório adota tolerância máxima de $\le 2,0\%$ entre o modelo analítico e as simulações dinâmicas de regime permanente, além de verificação automática de sintaxe MATLAB e LaTeX:

```bash
# Validação da integridade do plano, próximos passos e memória
python3 .agents/hooks/plan-sync.py check
python3 .agents/hooks/plan-sync.py next
python3 .agents/hooks/memory-check.py

# Verificação estática de código MATLAB (vetorização e estilo)
bash .agents/hooks/matlab-lint.sh

# Auditoria de tolerância de regime permanente (analítico vs. Simulink + Tier 2 bancada/placa)
python3 .agents/hooks/tolerance-gate.py --task 1.1   # Ponto nominal estático (Erro 0.0% Tier 1)
python3 .agents/hooks/tolerance-gate.py --task 3.1   # Partida a vazio (Erro máx 0.281% Tier 1; 0.249% Tier 2)
python3 .agents/hooks/tolerance-gate.py --task 3.2   # Degrau de carga (Erro máx 0.437% Tier 1)
python3 .agents/hooks/tolerance-gate.py --task 3.3   # Operação regenerativa (Erro máx 0.289% Tier 1)

# Auditoria completa de entregáveis (figuras, tabelas e base LaTeX)
python3 .agents/hooks/deliverable-audit.py --task 4.1
python3 .agents/hooks/deliverable-audit.py --task 4.2

# Validação tipográfica e compilação headless do relatório LaTeX
python3 .agents/hooks/latex-lint.py
python3 .agents/hooks/latex-gate.py
```

---
*Universidade Federal de Minas Gerais (UFMG) — Departamento de Engenharia Elétrica — ELE035 Conversão de Energia.*
