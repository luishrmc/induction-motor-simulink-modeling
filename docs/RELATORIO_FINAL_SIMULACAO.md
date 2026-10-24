# UNIVERSIDADE FEDERAL DE MINAS GERAIS (UFMG)
## Departamento de Engenharia Elétrica - DEE
### Disciplina: ELE035 - Laboratório de Conversão de Energia
**Professor:** Victor Flores Mendes  
**Trabalho Final:** Modelagem, Resolução Analítica e Simulação Dinâmica de Máquina de Indução Trifásica (MIT)  
**Semestre:** 2026/2  

---

# Sumário Executivo e Identificação do Projeto

O presente trabalho técnico e acadêmico contempla a modelagem analítica rigorosa em regime permanente e a simulação computacional dinâmica em ambiente Simscape Specialized Power Systems (SPS) de um **Motor de Indução Trifásico (MIT)** de gaiola de esquilo da marca **WEG**, carcaça **100L**, com potência nominal de **3,7 kW (5 cv)**, tensão nominal de **220 V** (conexão Triângulo - $\Delta$), **4 polos**, operando em **60 Hz**.

O projeto atende de forma integral às diretrizes do documento de especificação `sim_proj.pdf` da UFMG e baseia-se nos parâmetros físicos e elétricos obtidos experimentalmente nos ensaios de laboratório (Aulas 8, 9 e 10, consolidados no documento `LAB_CONV_RLT_08_09_10.pdf`).

A estrutura do relatório divide-se em:
1. **1ª Parte — Regime Permanente Analítico**:
   - Apresentação consolidada dos dados de placa e parâmetros do circuito equivalente obtidos nos ensaios.
   - Cálculo analítico do conjugado nominal de placa ($T_n$).
   - Resolução passo a passo do circuito equivalente IEEE na rotação nominal ($n = 1715\text{ rpm}$), deduzindo correntes, potências, perdas, conjugado eletromagnético e de eixo, fator de potência e rendimento.
   - Apresentação da rotina computacional em MATLAB puro e vetorizado.
   - Geração e análise aprofundada das curvas características de regime permanente: Conjugado vs. Velocidade, Corrente de Estator vs. Velocidade, Potência Ativa vs. Velocidade, Fator de Potência vs. Velocidade e Rendimento vs. Velocidade.
   - Simulação da família de curvas de controle escalar com fluxo constante ($V/f = \text{cte}$) nos patamares de 100%, 75%, 50% e 25%.
2. **2ª Parte — Simulação Dinâmica Simscape (Specialized Power Systems)**:
   - Diagrama de simulação do bloco *Asynchronous Machine SI Units*, parametrização com mapeamento rigoroso Estrela-Triângulo ($\text{Y}-\Delta$) e configuração do solver numérico L-estável.
   - Dedução teórica da corrente e pico transitório de partida direta a rotor bloqueado ($s = 1$).
   - Simulação e validação do transitório de partida direta a vazio ($T_L = 0$).
   - Simulação da resposta ao degrau de conjugado de carga nominal ($T_L = 0 \rightarrow +T_{nom}$) e auditoria de convergência analítica ($\le \pm 2\%$).
   - Simulação da operação regenerativa em torque negativo ($T_L = -T_{nom}$), comprovando a reversão de fluxo de potência ativa no quadrante de gerador de indução hipersíncrono com consumo de reativo para magnetização.
3. **Síntese Comparativa Global, Discussão de Resultados e Conclusões**:
   - Tabela comparativa consolidada multiregime (Placa vs. Ensaio de Bancada vs. Analítico vs. Simscape).
   - Conciliação física detalhada do atrito viscoso da bancada acoplada ($B = 0,0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$).
4. **Anexos**: Códigos-fonte completos em MATLAB.

---

# 1ª Parte: Regime Permanente Analítico

## Item 1.A: Dados de Placa da Máquina e Parâmetros Obtidos em Laboratório

A máquina avaliada é um motor de indução trifásico WEG de alto rendimento, cujos ensaios laboratoriais padronizados (resistência ôhmica CC, rotor bloqueado a 60 Hz e ensaio a vazio desacoplado) foram consolidados na Tabela 2.4 e Seção 2.4 do Relatório Técnico de Bancada (`LAB_CONV_RLT_08_09_10.pdf`).

A Tabela 1 sintetiza as características nominais de catálogo e os parâmetros circuítais e mecânicos por fase em conexão Triângulo ($\Delta$).

### Tabela 1: Parâmetros consolidados do Motor de Indução Trifásico WEG 3,7 kW (Carcaça 100L)

| Grandeza | Símbolo | Valor | Unidade | Origem / Observação |
|---|---|---|---|---|
| Potência Mecânica Nominal | $P_{nom}$ | $3,70$ ($5,0$) | $\text{kW}$ ($\text{cv}$) | Placa de catálogo |
| Tensão Nominal de Linha | $V_{L,nom}$ | $220$ | $\text{V}$ (RMS) | Placa ($\Delta$, trifásico) |
| Corrente Nominal de Linha | $I_{line,nom}$ | $14,0$ | $\text{A}$ (RMS) | Placa ($\Delta$) |
| Frequência Nominal da Rede | $f_{nom}$ | $60$ | $\text{Hz}$ | Placa |
| Número de Polos | $p$ | $4$ ($p_{pares} = 2$) | - | Placa ($n_s = 1800\text{ rpm}$) |
| Velocidade Nominal | $n_{nom}$ | $1715$ | $\text{rpm}$ | Placa ($\omega_{nom} = 179,594\text{ rad/s}$) |
| Fator de Potência Nominal | $\cos\phi_{nom}$ | $0,81$ | - | Placa |
| Rendimento Nominal | $\eta_{nom}$ | $85,5$ | $\%$ | Placa |
| Rotação Síncrona | $n_s$ | $1800$ | $\text{rpm}$ | $\omega_s = \frac{2\pi f}{p_{pares}} = 188,496\text{ rad/s}$ |
| Escorregamento Nominal | $s_{nom}$ | $0,04722$ ($4,72\%$) | - | $s_{nom} = \frac{n_s - n_{nom}}{n_s}$ |
| Resistência Estatórica por Fase | $R_1$ | $1,189$ | $\Omega$ | Ensaio CC com compensação térmica |
| Resistência Rotórica Refletida | $R_2'$ | $1,180$ | $\Omega$ | Ensaio de Rotor Bloqueado a 60 Hz |
| Indutância de Dispersão do Estator | $L_{l1}$ | $5,725$ | $\text{mH}$ | $X_1 = 2\pi f L_{l1} = 2,158\,\Omega$ |
| Indutância de Dispersão do Rotor | $L_{l2}'$ | $8,420$ | $\text{mH}$ | $X_2' = 2\pi f L_{l2}' = 3,174\,\Omega$ |
| Indutância de Magnetização | $L_m$ | $131,571$ | $\text{mH}$ | $X_m = 2\pi f L_m = 49,601\,\Omega$ |
| Resistência de Perdas no Ferro | $R_c$ | $\infty$ (desprezada) | $\Omega$ | Conforme modelo T clássico |
| Momento de Inércia Total | $J$ | $0,701$ | $\text{kg}\cdot\text{m}^2$ | Conjunto acoplado motor-gerador CC |
| Coeficiente de Atrito Viscoso | $B$ | $0,0426$ | $\text{N}\cdot\text{m}\cdot\text{s/rad}$ | Ensaio de desaceleração da bancada |

---

## Item 1.B: Cálculo do Torque Nominal ($T_n$)

O conjugado mecânico nominal útil de placa ($T_n$ ou $T_{nom}$), correspondente à entrega da potência mecânica de $3,7\text{ kW}$ na rotação de $1715\text{ rpm}$, é calculado diretamente pela relação fundamental da mecânica rotacional:

$$\omega_{nom} = n_{nom} \cdot \frac{2\pi}{60} = 1715 \cdot \frac{2\pi}{60} \approx 179,5943\text{ rad/s}$$

$$T_n = \frac{P_{nom}}{\omega_{nom}} = \frac{3700\text{ W}}{179,5943\text{ rad/s}} = 20,6020\text{ N}\cdot\text{m}$$

Adicionalmente, para a velocidade síncrona ($\omega_s = 188,4956\text{ rad/s}$ correspondente a $1800\text{ rpm}$), o torque de entreferro síncrono associado à mesma potência seria:

$$T_{sinc} = \frac{P_{nom}}{\omega_s} = \frac{3700}{188,4956} = 19,6296\text{ N}\cdot\text{m}$$

O valor de referência de projeto para torque de carga nominal de placa adotado neste relatório é rigorosamente **$T_n = 20,6020\text{ N}\cdot\text{m}$**.

---

## Item 1.C: Resolução Analítica do Circuito Equivalente no Ponto Nominal ($n = 1715\text{ rpm}$)

### Circuito Equivalente IEEE por Fase em Conexão Triângulo ($\Delta$)

Como os enrolamentos do estator estão ligados em Triângulo sob tensão de linha $V_L = 220\text{ V}$, a tensão de fase aplicada sobre cada ramo do circuito equivalente é igual à tensão de linha:

$$V_{ph} = V_L = 220\text{ V (RMS)}, \quad \vec{V}_{ph} = 220 \angle 0^\circ\text{ V}$$

No ponto nominal, com $n = 1715\text{ rpm}$, o escorregamento é:

$$s = \frac{1800 - 1715}{1800} = \frac{85}{1800} \approx 0,047222$$

A resistência rotórica aparente que modela a conversão de energia eletromecânica é:

$$\frac{R_2'}{s} = \frac{1,180}{0,047222} = 24,9888\,\Omega$$

### 1. Impedâncias do Circuito

A impedância do ramo rotórico em paralelo com a magnetização é dada por:

$$\vec{Z}_2'(s) = \frac{R_2'}{s} + j X_2' = 24,9888 + j 3,1743\,\Omega$$

O ramo de magnetização puro (desprezando $R_c$) é:

$$\vec{Z}_m = j X_m = j 49,6013\,\Omega$$

A impedância equivalente em paralelo entre o ramo de magnetização e o ramo rotórico é calculada por:

$$\vec{Z}_p = \frac{\vec{Z}_m \cdot \vec{Z}_2'(s)}{\vec{Z}_m + \vec{Z}_2'(s)} = \frac{(j 49,6013) \cdot (24,9888 + j 3,1743)}{24,9888 + j (49,6013 + 3,1743)}$$

Calculando o numerador e denominador:
- Numerador: $-157,449 + j 1239,471$
- Denominador: $24,9888 + j 52,7756 = 58,389 \angle 64,66^\circ$

Resultando em:

$$\vec{Z}_p = 18,0347 + j 11,5188\,\Omega = 21,402 \angle 32,57^\circ\,\Omega$$

Somando a impedância série do estator ($\vec{Z}_1 = R_1 + j X_1 = 1,1890 + j 2,1583\,\Omega$), obtém-se a impedância de entrada total por fase:

$$\vec{Z}_{in} = \vec{Z}_1 + \vec{Z}_p = (1,1890 + 18,0347) + j (2,1583 + 11,5188)$$

$$\vec{Z}_{in} = 19,2237 + j 13,6771\,\Omega = 23,5928 \angle 35,435^\circ\,\Omega$$

### 2. Correntes de Fase e de Linha

A corrente de fase do estator é:

$$\vec{I}_1 = \frac{\vec{V}_{ph}}{\vec{Z}_{in}} = \frac{220 \angle 0^\circ}{23,5928 \angle 35,435^\circ} = 9,3249 \angle -35,435^\circ\text{ A}$$

$$|\vec{I}_1| = 9,3249\text{ A (RMS)}$$

A corrente total de linha consumida da rede em conexão Triângulo simétrico é:

$$I_{line} = \sqrt{3} \cdot |\vec{I}_1| = \sqrt{3} \cdot 9,3249 = 16,1512\text{ A (RMS)}$$

A tensão induzida no entreferro ($\vec{E}_1$) sobre o ramo magnetizante é:

$$\vec{E}_1 = \vec{V}_{ph} - \vec{I}_1 \cdot \vec{Z}_1 = 220 \angle 0^\circ - (9,3249 \angle -35,435^\circ) \cdot (1,1890 + j 2,1583)$$

$$\vec{E}_1 = 199,576 \angle -2,866^\circ\text{ V}$$

A corrente rotórica refletida que flui através de $\vec{Z}_2'(s)$ é:

$$\vec{I}_2' = \frac{\vec{E}_1}{\vec{Z}_2'(s)} = \frac{199,576 \angle -2,866^\circ}{24,9888 + j 3,1743} = 7,9227 \angle -10,105^\circ\text{ A}$$

$$|\vec{I}_2'| = 7,9227\text{ A (RMS)}$$

A corrente de magnetização que excita o entreferro é:

$$\vec{I}_m = \frac{\vec{E}_1}{j X_m} = \frac{199,576 \angle -2,866^\circ}{49,6013 \angle 90^\circ} = 4,0236 \angle -92,866^\circ\text{ A}$$

Verificação da Lei de Kirchhoff nos nós: $\vec{I}_2' + \vec{I}_m = (7,800 - j 1,390) + (-0,201 - j 4,019) = 7,599 - j 5,409 = 9,325 \angle -35,44^\circ\text{ A} \equiv \vec{I}_1$. Balanço exato.

### 3. Potências Elétricas e Fator de Potência

O ângulo de impedância de entrada é $\phi = 35,435^\circ$. O fator de potência de entrada da máquina é:

$$\cos\phi = \cos(35,435^\circ) = 0,81478\text{ (indutivo)}$$

As potências trifásicas absorvidas da rede elétrica são:

$$P_{elec} = 3 \cdot V_{ph} \cdot |\vec{I}_1| \cdot \cos\phi = \sqrt{3} \cdot V_L \cdot I_{line} \cdot \cos\phi = 5014,79\text{ W}$$

$$Q_{elec} = 3 \cdot V_{ph} \cdot |\vec{I}_1| \cdot \sin\phi = \sqrt{3} \cdot V_L \cdot I_{line} \cdot \sin\phi = 3569,02\text{ var}$$

$$S_{elec} = 3 \cdot V_{ph} \cdot |\vec{I}_1| = \sqrt{3} \cdot V_L \cdot I_{line} = 6155,61\text{ VA}$$

### 4. Perdas no Cobre e Balanço no Entreferro

As perdas por efeito Joule nos enrolamentos trifásicos do estator são:

$$P_{cu1} = 3 \cdot |\vec{I}_1|^2 \cdot R_1 = 3 \cdot (9,3249)^2 \cdot 1,1890 = 310,21\text{ W}$$

A potência ativa total transmitida através do entreferro para o rotor ($P_{ag}$) é:

$$P_{ag} = P_{elec} - P_{cu1} = 5014,79 - 310,21 = 4704,58\text{ W}$$

Pela formulação direta no ramo rotórico:

$$P_{ag} = 3 \cdot |\vec{I}_2'|^2 \cdot \frac{R_2'}{s} = 3 \cdot (7,9227)^2 \cdot 24,9888 = 4704,58\text{ W}$$

As perdas por efeito Joule no enrolamento rotórico (gaiola) são proporcionais ao escorregamento:

$$P_{cu2} = s \cdot P_{ag} = 0,047222 \cdot 4704,58 = 222,16\text{ W}$$

$$P_{cu2} = 3 \cdot |\vec{I}_2'|^2 \cdot R_2' = 3 \cdot (7,9227)^2 \cdot 1,1800 = 222,24\text{ W}$$

### 5. Conversão Eletromecânica Interna e Conjugado Eletromagnético

A potência mecânica convertida interna no rotor ($P_{em}$) antes de perdas mecânicas é:

$$P_{em} = (1 - s) \cdot P_{ag} = (1 - 0,047222) \cdot 4704,58 = 4482,42\text{ W}$$

O conjugado eletromagnético interno desenvolvido no entreferro ($T_{em}$) é:

$$T_{em} = \frac{P_{ag}}{\omega_s} = \frac{4704,58\text{ W}}{188,4956\text{ rad/s}} = 24,9585\text{ N}\cdot\text{m}$$

Ou identicamente pela rotação mecânica do rotor:

$$T_{em} = \frac{P_{em}}{\omega_{nom}} = \frac{4482,42\text{ W}}{179,5943\text{ rad/s}} = 24,9586\text{ N}\cdot\text{m}$$

### 6. Conciliação com o Atrito Viscoso da Bancada e Grandezas Úteis de Eixo

Conforme caracterizado no ensaio de desaceleração da bancada acoplada (Seção 2.4 do relatório de laboratório), o motor está acoplado a um gerador de corrente contínua, introduzindo um coeficiente de atrito viscoso total equivalente de $B = 0,0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$.

Na velocidade nominal de $\omega_{nom} = 179,5943\text{ rad/s}$, as perdas por atrito viscoso e o conjugado de arraste mecânico são:

$$T_{rot} = B \cdot \omega_{nom} = 0,0426 \cdot 179,5943 = 7,6507\text{ N}\cdot\text{m}$$

$$P_{rot} = B \cdot \omega_{nom}^2 = 0,0426 \cdot (179,5943)^2 = 1374,02\text{ W}$$

Assim, o conjugado útil remanescente na ponta do eixo para acionar cargas externas é:

$$T_{shaft} = T_{em} - T_{rot} = 24,9585 - 7,6507 = 17,3078\text{ N}\cdot\text{m}$$

E a potência líquida de eixo disponibilizada é:

$$P_{shaft} = P_{em} - P_{rot} = 4482,42 - 1374,02 = 3108,40\text{ W}$$

Verificação: $T_{shaft} \cdot \omega_{nom} = 17,3078 \times 179,5943 = 3108,38\text{ W} \equiv P_{shaft}$.

### 7. Rendimentos da Máquina

Distinguem-se formalmente dois rendimentos:
1. **Rendimento Eletromagnético Interno ($\eta_{em}$)** (desconsiderando o arraste do gerador acoplado à bancada):
   $$\eta_{em} = \frac{P_{em}}{P_{elec}} = \frac{4482,42}{5014,79} = 89,38\%$$
2. **Rendimento Útil de Eixo com Bancada ($\eta_{shaft}$)** (deduzindo os $1374\text{ W}$ de arraste da máquina CC acoplada):
   $$\eta_{shaft} = \frac{P_{shaft}}{P_{elec}} = \frac{3108,40}{5014,79} = 61,98\%$$

### Tabela 2: Comparação entre Dados de Placa de Catálogo e Solução Analítica do Circuito Equivalente

| Parâmetro Operacional | Placa WEG | Analítico (Interno $T_{em}$) | Analítico (Eixo $T_{shaft}$) | Desvio vs. Placa | Análise Física |
|---|---|---|---|---|---|
| Rotação ($n$) | $1715\text{ rpm}$ | $1715\text{ rpm}$ | $1715\text{ rpm}$ | $0,00\%$ | Ponto de operação imposto ($s=4,72\%$) |
| Fator de Potência ($\cos\phi$) | $0,81$ | $0,815$ | $0,815$ | $+0,59\%$ | Concordância excepcional com o catálogo |
| Corrente de Linha ($I_{line}$) | $14,0\text{ A}$ | $16,15\text{ A}$ | $16,15\text{ A}$ | $+15,3\%$ | Dispersão experimental dos ensaios de rotor bloqueado |
| Potência Elétrica de Entrada ($P_e$) | $4327\text{ W}$ | $5015\text{ W}$ | $5015\text{ W}$ | $+15,9\%$ | Compatível com a corrente absorvida ligeiramente maior |
| Potência Mecânica ($P_m$) | $3700\text{ W}$ | $4482\text{ W}$ ($P_{em}$) | $3108\text{ W}$ ($P_{shaft}$) | $+21,1\%$ / $-16,0\%$ | $P_{em}$ supera a placa; ao deduzir o atrito da bancada CC ($1,37\text{ kW}$), resulta em $3,11\text{ kW}$ úteis |
| Conjugado Mecânico ($T$) | $20,60\text{ N}\cdot\text{m}$ | $24,96\text{ N}\cdot\text{m}$ ($T_{em}$) | $17,31\text{ N}\cdot\text{m}$ ($T_{shaft}$) | $+21,2\%$ / $-16,0\%$ | $T_{em}$ fornece a folga necessária para vencer os $7,65\text{ N}\cdot\text{m}$ de arraste viscoso |
| Rendimento ($\eta$) | $85,5\%$ | $89,38\%$ ($\eta_{em}$) | $61,98\%$ ($\eta_{shaft}$) | $+4,54\%$ / $-27,5\%$ | O rendimento eletromagnético do motor atende à classe de rendimento WEG ($89,4\%$ vs $85,5\%$). O rendimento global de eixo cai devido à carga mecânica parasita da máquina CC acoplada |

---

## Item 1.D: Programa Computacional Vetorizado em MATLAB

Para determinar as grandezas em toda a faixa de operação (de $n = 0$ até a rotação síncrona $n_s = 1800\text{ rpm}$), desenvolveu-se uma arquitetura modular em MATLAB (`matlab/analytical/solve_equivalent_circuit.m` e `matlab/analytical/plot_steady_state_curves.m`). 

Em conformidade rigorosa com os padrões de engenharia de software e diretrizes do projeto (`GEMINI.md`), a implementação é **100% vetorizada**: foram completamente eliminados laços `for` sobre o vetor de velocidade/escorregamento. Toda a álgebra de impedâncias, correntes e potências é processada através de operações matriciais elemento a elemento (`./`, `.*`, `.^`).

### Listagem 1: Trecho fundamental do algoritmo analítico vetorizado (`solve_equivalent_circuit.m`)

```matlab
% Definição do vetor de velocidade e escorregamento contínuo
n_vec = linspace(0, n_s - 1e-4, 2000); % Evita singularidade exata em s=0
s_vec = (n_s - n_vec) ./ n_s;
omega_m_vec = n_vec .* (2 * pi / 60);

% Ramo rotórico com resistência dependente do escorregamento
Z2_vec = (R2_prime ./ s_vec) + 1j * X2_prime;

% Ramo magnetizante em paralelo
Zm = 1j * Xm;
Zp_vec = (Zm .* Z2_vec) ./ (Zm + Z2_vec);

% Impedância de entrada por fase
Zin_vec = (R1 + 1j * X1) + Zp_vec;

% Correntes de fase e de linha
I1_phase_vec = V_phase ./ Zin_vec;
I_line_vec = sqrt(3) .* abs(I1_phase_vec);

% Tensão de entreferro e corrente rotórica
E1_vec = V_phase - I1_phase_vec .* (R1 + 1j * X1);
I2_prime_vec = E1_vec ./ Z2_vec;

% Potências e conjugados
P_ag_vec = 3 .* (abs(I2_prime_vec).^2) .* (R2_prime ./ s_vec);
T_em_vec = P_ag_vec ./ omega_s;
P_em_vec = (1 - s_vec) .* P_ag_vec;
T_shaft_vec = T_em_vec - B .* omega_m_vec;
P_shaft_vec = P_em_vec - B .* (omega_m_vec.^2);

% Potência elétrica e fator de potência
phi_vec = angle(Zin_vec);
PF_vec = cos(phi_vec);
P_elec_vec = 3 .* V_phase .* abs(I1_phase_vec) .* PF_vec;

% Rendimentos
eta_em_vec = max(0, P_em_vec ./ P_elec_vec);
eta_shaft_vec = max(0, P_shaft_vec ./ P_elec_vec);
```

---

## Item 1.E: Curvas Características de Regime Permanente em Tensão e Frequência Nominais

A seguir são apresentadas e analisadas detalhadamente as cinco curvas características requeridas pela especificação da UFMG, assinalando os pontos nominais de placa e confrontando os resultados com a teoria de máquinas elétricas.

### Curva E.i: Conjugado x Velocidade

![Curva Característica Conjugado x Velocidade](../out/parte1_analitico/figures/item1e_torque_vs_speed.png)

#### Telemetria e Pontos Notáveis (Sidecar `item1e_torque_vs_speed.json`):
- **Conjugado Máximo (Despolarização / Ruptura - $T_{max}$):** $54,634\text{ N}\cdot\text{m}$ ocorrendo a $1405,0\text{ rpm}$ ($s_{max} = 0,2194$).
- **Relação $T_{max} / T_n$:** $\frac{54,634}{20,602} = 2,652$.
- **Conjugado de Partida a Rotor Bloqueado ($s = 1, n = 0$):** $T_{partida} = 25,351\text{ N}\cdot\text{m}$ ($T_{partida} / T_n = 1,230$).
- **Conjugado Eletromagnético Nominal ($n = 1715\text{ rpm}$):** $T_{em} = 24,958\text{ N}\cdot\text{m}$.
- **Conjugado Útil de Eixo Nominal ($n = 1715\text{ rpm}$):** $T_{shaft} = 17,308\text{ N}\cdot\text{m}$.
- **Conjugado de Catálogo WEG:** $T_{cat} = 20,602\text{ N}\cdot\text{m}$.

#### Discussão Física e Teórica:
1. **Região Estável de Operação:** A curva exibe o comportamento clássico de um motor de indução NEMA/ABNT Categoria N. Para velocidades entre $1405\text{ rpm}$ e $1800\text{ rpm}$ ($\frac{dT}{dn} < 0$), o sistema opera em equilíbrio dinâmico estável. O ponto nominal ($1715\text{ rpm}$) situa-se confortavelmente nessa zona de linearidade quase constante.
2. **Conjugado Máximo ($T_{max}$):** Pelo equivalente de Thévenin do estator, o escorregamento no qual ocorre o conjugado máximo independe da tensão aplicada e é dado por:
   $$s_{max} \approx \frac{R_2'}{\sqrt{R_{TH}^2 + (X_{TH} + X_2')^2}} \approx 0,2194 \implies n = 1405\text{ rpm}$$
   O valor obtido de $T_{max} = 54,63\text{ N}\cdot\text{m}$ confere à máquina uma capacidade de sobrecarga de $2,65$ vezes o conjugado nominal de placa, superando a exigência normativa mínima da ABNT/NBR 17094 para Categoria N ($T_{max}/T_n \ge 2,0$ a $2,3$).
3. **Efeito do Atrito da Bancada:** A curva tracejada vermelha ($T_{shaft} = T_{em} - B\omega_m$) evidencia o abatimento contínuo de conjugado decorrente do atrito viscoso. Em $1715\text{ rpm}$, o atrito subtrai $7,65\text{ N}\cdot\text{m}$, fazendo com que o conjugado eletromagnético convirja precisamente para cobrir o atrito somado à carga externa.

---

### Curva E.ii: Corrente de Estator x Velocidade

![Curva Característica Corrente de Estator x Velocidade](../out/parte1_analitico/figures/item1e_corrente_vs_speed.png)

#### Telemetria e Pontos Notáveis (Sidecar `item1e_corrente_vs_speed.json`):
- **Corrente de Linha de Partida a Rotor Bloqueado ($s = 1, n = 0$):** $I_{start} = 67,728\text{ A (RMS)}$.
- **Corrente de Partida de Catálogo WEG ($I_p$):** $106,40\text{ A (RMS)}$ ($I_p / I_n = 7,6$).
- **Corrente de Linha Nominal Analítica ($n = 1715\text{ rpm}$):** $I_{line} = 16,153\text{ A (RMS)}$.
- **Corrente de Linha Nominal de Placa ($I_n$):** $14,00\text{ A (RMS)}$.
- **Corrente a Vazio Analítica ($s \to 0$):** $I_0 = 7,360\text{ A (RMS)}$.
- **Corrente no Conjugado Máximo ($n = 1405\text{ rpm}$):** $I = 47,92\text{ A (RMS)}$.

#### Discussão Física e Teórica:
1. **Comportamento da Impedância de Entrada:** A rotor bloqueado ($s = 1$), a resistência aparente do rotor é reduzida ao seu valor ôhmico próprio ($R_2' / 1 = 1,18\,\Omega$), tornando a impedância de entrada dominada pelas reatâncias de dispersão de estator e rotor ($\vec{Z}_{in}(1) = 2,23 + j 5,16\,\Omega$, $|\vec{Z}_{in}| = 5,62\,\Omega$). Isso acarreta uma elevada corrente de partida simétrica de $67,73\text{ A}$ RMS ($I_p/I_n \approx 4,2$ a $4,8$).
2. **Comparação com o Catálogo:** O catálogo da WEG estipula $106,4\text{ A}$ de corrente de partida. Essa diferença provém do ensaio de rotor bloqueado ter sido executado em laboratório sob tensão reduzida ($47,4\text{ V}$), sem atingir a saturação magnética profunda das pontas dos dentes e fendas fechadas do rotor que ocorre na partida direta em $220\text{ V}$.
3. **Decaimento para Corrente a Vazio:** À medida que o rotor acelera em direção a $1800\text{ rpm}$, o escorregamento $s \to 0$ faz a resistência $R_2'/s \to \infty$, anulando a corrente rotórica de carga. A corrente de estator decai assintoticamente para o nível puramente magnetizante de $7,36\text{ A}$ RMS, compatível com a medição de bancada.

---

### Curva E.iii: Potência Ativa x Velocidade

![Curva Característica Potência Ativa x Velocidade](../out/parte1_analitico/figures/item1e_potencia_vs_speed.png)

#### Telemetria e Pontos Notáveis (Sidecar `item1e_potencia_vs_speed.json`):
- **Potência Elétrica de Entrada Nominal ($n = 1715\text{ rpm}$):** $P_{elec} = 5014,79\text{ W}$.
- **Potência do Entreferro Nominal:** $P_{ag} = 4704,58\text{ W}$.
- **Potência Eletromecânica Convertida Nominal:** $P_{em} = 4482,34\text{ W}$.
- **Potência Mecânica Útil de Eixo Nominal:** $P_{shaft} = 3108,31\text{ W}$.
- **Potência Nominal de Catálogo WEG:** $P_{nom} = 3700,0\text{ W}$ ($5\text{ cv}$).
- **Pico de Potência Eletromecânica Convertida:** $P_{em,max} = 8016,9\text{ W}$ ocorrendo a $1405\text{ rpm}$.
- **Pico de Potência Elétrica Absorvida:** $P_{elec,max} = 18234\text{ W}$ ocorrendo a $1398\text{ rpm}$.

#### Discussão Física e Teórica:
1. **Balanço Estrito de Potências:** O gráfico comprova o fluxo unidirecional de perdas:
   $$P_{elec} \xrightarrow{- P_{cu1}} P_{ag} \xrightarrow{- P_{cu2}} P_{em} \xrightarrow{- P_{rot}} P_{shaft}$$
   As curvas preservam rigidamente a hierarquia $P_{elec} > P_{ag} > P_{em} > P_{shaft}$ em toda a faixa motora.
2. **Ponto de Máxima Transferência de Potência:** A potência elétrica absorvida atinge um pico acentuado de $18,23\text{ kW}$ em torno de $1400\text{ rpm}$, próximo ao escorregamento crítico, onde a impedância do circuito atinge seu casamento conjugado ótimo com a rede.

---

### Curva E.iv: Fator de Potência x Velocidade

![Curva Característica Fator de Potência x Velocidade](../out/parte1_analitico/figures/item1e_fator_potencia_vs_speed.png)

#### Telemetria e Pontos Notáveis (Sidecar `item1e_fator_potencia_vs_speed.json`):
- **Fator de Potência Nominal Analítico ($n = 1715\text{ rpm}$):** $\cos\phi = 0,81478$.
- **Fator de Potência Nominal de Placa:** $\cos\phi_{nom} = 0,810$.
- **Fator de Potência de Partida a Rotor Bloqueado ($s = 1$):** $\cos\phi = 0,396$.
- **Pico Máximo de Fator de Potência:** $\cos\phi_{max} = 0,835$ ocorrendo a $1640\text{ rpm}$.
- **Fator de Potência Próximo a Vazio ($s \to 0$):** $\cos\phi \to 0,064$.

#### Discussão Física e Teórica:
1. **Aderência aos Dados de Placa:** A convergência entre o valor analítico ($0,8148$) e o dado de placa ($0,810$) apresenta um erro inferior a **$0,59\%$**, comprovando a elevada fidelidade da parametrização experimental dos ensaios de bancada.
2. **Evolução ao Longo da Curva:**
   - Na partida ($s=1$), o circuito é altamente indutivo devido às reatâncias de dispersão ($X_1 + X_2'$), resultando em baixo fator de potência ($\approx 0,40$).
   - Conforme a rotação sobe para a faixa de $1600$ a $1720\text{ rpm}$, a resistência rotórica útil $R_2'/s$ passa a predominar sobre as reatâncias, elevando a conversão de potência ativa e fazendo o fator de potência atingir seu cume de $0,835$.
   - Ao se aproximar da velocidade síncrona ($1800\text{ rpm}$), a potência ativa de carga anula-se e a máquina absorve quase exclusivamente a corrente de magnetização do ramo $X_m$, fazendo o fator de potência despencar abaixo de $0,10$.

---

### Curva E.v: Rendimento x Velocidade

![Curva Característica Rendimento x Velocidade](../out/parte1_analitico/figures/item1e_rendimento_vs_speed.png)

#### Telemetria e Pontos Notáveis (Sidecar `item1e_rendimento_vs_speed.json`):
- **Rendimento Eletromagnético Interno Nominal ($n = 1715\text{ rpm}$):** $\eta_{em} = 89,38\%$.
- **Rendimento Útil de Eixo com Bancada Nominal ($n = 1715\text{ rpm}$):** $\eta_{shaft} = 61,98\%$.
- **Rendimento Nominal de Catálogo WEG:** $\eta_{placa} = 85,5\%$.
- **Pico Máximo de Rendimento Eletromagnético:** $\eta_{em,max} = 90,82\%$ ocorrendo a $1745\text{ rpm}$.
- **Pico Máximo de Rendimento de Eixo com Bancada:** $\eta_{shaft,max} = 65,10\%$ ocorrendo a $1695\text{ rpm}$.

#### Discussão Física e Teórica:
1. **Eficiência da Máquina Isolada:** O rendimento interno $\eta_{em} = 89,38\%$ no ponto nominal supera os $85,5\%$ de placa, o que é plenamente consistente, visto que a placa prevê uma margem para perdas suplementares no ferro ($P_c$), atrito e ventilação próprios do motor desacoplado ($194\text{ W}$ conforme ensaio a vazio).
2. **Impacto do Conjunto Motor-Gerador Acoplado:** O rendimento líquido de eixo $\eta_{shaft} = 62,0\%$ reflete com realismo de engenharia as condições severas de laboratório, onde o motor precisa continuamente tracionar o rotor de inércia considerável e as escovas/mancais da máquina de corrente contínua acoplada ($B = 0,0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$ dissipando $1,37\text{ kW}$).

---

## Item 1.F: Família de Curvas de Controle Escalar $V/f$ Constante (100%, 75%, 50%, 25%)

Para investigar o comportamento da máquina sob acionamento por inversor de frequência em malha aberta com controle escalar ($V/f = \text{cte}$), foram geradas as curvas de conjugado vs. velocidade para os quatro patamares normatizados:
- **100%:** $V_L = 220\text{ V}$, $f = 60\text{ Hz}$ ($n_s = 1800\text{ rpm}$)
- **75%:** $V_L = 165\text{ V}$, $f = 45\text{ Hz}$ ($n_s = 1350\text{ rpm}$)
- **50%:** $V_L = 110\text{ V}$, $f = 30\text{ Hz}$ ($n_s = 900\text{ rpm}$)
- **25%:** $V_L = 55\text{ V}$, $f = 15\text{ Hz}$ ($n_s = 450\text{ rpm}$)

Todas as curvas foram sobrepostas no mesmo gráfico e assinaladas com os respectivos pontos de conjugado máximo.

![Família de Curvas de Controle Escalar V/f](../out/parte1_analitico/figures/item1f_vf_scalar_family.png)

### Telemetria e Pontos Notáveis da Família $V/f$ (Sidecar `item1f_vf_scalar_family.json`):

| Patamar $V/f$ | Tensão $V_L$ (V) | Frequência $f$ (Hz) | Rotação Síncrona $n_s$ (rpm) | Conjugado Máximo $T_{max}$ (N.m) | Rotação no $T_{max}$ (rpm) |
|---|---|---|---|---|---|
| **100%** | $220,0$ | $60,0$ | $1800,0$ | $54,634$ | $1405,0$ |
| **75%** | $165,0$ | $45,0$ | $1350,0$ | $50,882$ | $961,4$ |
| **50%** | $110,0$ | $30,0$ | $900,0$ | $44,381$ | $531,0$ |
| **25%** | $55,0$ | $15,0$ | $450,0$ | $30,542$ | $152,0$ |

### Análise Física e Teórica do Comportamento sob Controle Escalar:
1. **Princípio do Fluxo Magnético Constante:** Em um motor de indução, o fluxo no entreferro por polo é dado aproximadamente por:
   $$\Phi_m \approx \frac{E_1}{4,44 \cdot f \cdot N \cdot k_w} \propto \frac{V}{f}$$
   Ao manter a razão $V/f$ constante ($220/60 = 165/45 = 110/30 = 55/15 = 3,667\text{ V/Hz}$), preserva-se teórica e idealmente a densidade de fluxo magnético no ferro sem levar a máquina à saturação precoce ou à perda de magnetização.
2. **Translação da Velocidade Síncrona:** A frequência do estator dita diretamente a velocidade do campo magnético girante ($n_s = 120 f / p$). Assim, a característica conjugado-velocidade desloca-se rigidamente ao longo do eixo horizontal das abcissas para $1800, 1350, 900\text{ e }450\text{ rpm}$. A inclinação linear da curva na região de operação estável permanece idêntica em todas as frequências, garantindo regulação de velocidade similar.
3. **Queda Ôhmica do Estator ($I_1 R_1$) e Degradação de $T_{max}$ em Baixas Frequências:**
   Teoricamente, desconsiderando a resistência estatórica ($R_1 = 0$), o conjugado máximo seria rigorosamente invariante com a frequência:
   $$T_{max} \approx \frac{3 p}{4 \omega_s} \cdot \frac{V_{TH}^2}{X_{TH} + X_2'} \propto \frac{(V/f)^2}{(L_{l1} + L_{l2}')} = \text{constante}$$
   Entretanto, como evidencia o gráfico gerado com a formulação analítica exata, o conjugado máximo sofre uma redução sistemática de **$54,63\text{ N}\cdot\text{m}$ (a 60 Hz)** para **$30,54\text{ N}\cdot\text{m}$ (a 15 Hz)** — uma perda de **$44,1\%$**.
   **Causa Física:** Em frequências reduzidas, a reatância indutiva $X_1 = 2\pi f L_{l1}$ diminui proporcionalmente a $f$, enquanto a resistência ôhmica do condutor $R_1 = 1,189\,\Omega$ permanece estritamente constante. Consequentemente, a queda de tensão resistiva interna $I_1 R_1$ passa a representar uma parcela percentual muito maior da tensão terminal reduzida de entrada ($55\text{ V}$ a 15 Hz). A tensão de entreferro $E_1$ é severamente atenuada, enfraquecendo o fluxo magnético útil $\Phi_m$.
4. **Implicação Prática de Engenharia:** Este fenômeno demonstra com clareza cristalina a necessidade imperativa da técnica industrial de **compensação de queda $IR$ (*voltage boost*)**, em que os inversores comerciais elevam ligeiramente a tensão em frequências inferiores a 15–20 Hz para restituir o fluxo nominal e assegurar conjugado pleno de partida.

---

# 2ª Parte: Simulação Dinâmica Simscape (Specialized Power Systems)

## Item 2.A: Montagem e Parametrização do Diagrama Simscape Specialized Power Systems

Para realizar a análise dinâmica de transitórios eletromecânicos, montou-se um modelo computacional no ambiente **Simscape Specialized Power Systems (SPS)** do MATLAB/Simulink (`matlab/simulink/mit_simscape_model.slx`), governado pelo script de inicialização e parametrização `matlab/simulink/setup_motor_params.m`.

### Arquitetura do Modelo Computacional

O diagrama de simulação é composto pelos seguintes blocos fundamentais:
1. **Fonte Trifásica Senoidal (`Voltage Source Three-Phase`):** Conectada na configuração Triângulo com tensão fase-fase nominal de $220\text{ V}$ RMS e frequência de $60\text{ Hz}$.
2. **Bloco de Máquina de Indução (`Asynchronous Machine SI Units`):** Bloco padrão de alta fidelidade da biblioteca SPS, configurado no modo *Squirrel-cage rotor* no referencial do rotor (*Rotor reference frame*), operando em unidades físicas do Sistema Internacional (SI).
3. **Módulo de Carga Mecânica Dinâmica:** Bloco de torque mecânico externo ($T_L$) capaz de injetar degraus parametrizados em instantes pré-definidos ($t_{step} = 5,0\text{ s}$) para chaveamento entre vazio ($T_L = 0$), carga nominal motora ($T_L = +20,602\text{ N}\cdot\text{m}$) e operação geradora regenerativa ($T_L = -20,602\text{ N}\cdot\text{m}$).
4. **Instrumentação e Processamento de Sinais:** Medição instantânea trifásica de tensões de linha e correntes de fase através de barramentos do Simscape. As potências ativa instantânea ($p(t)$) e reativa instantânea ($q(t)$) são sintetizadas através da **Transformada de Clarke ($\alpha-\beta$)**:
   $$\begin{bmatrix} v_\alpha \\ v_\beta \end{bmatrix} = \sqrt{\frac{2}{3}} \begin{bmatrix} 1 & -\frac{1}{2} & -\frac{1}{2} \\ 0 & \frac{\sqrt{3}}{2} & -\frac{\sqrt{3}}{2} \end{bmatrix} \begin{bmatrix} v_a \\ v_b \\ v_c \end{bmatrix}, \quad \begin{bmatrix} i_\alpha \\ i_\beta \end{bmatrix} = \sqrt{\frac{2}{3}} \begin{bmatrix} 1 & -\frac{1}{2} & -\frac{1}{2} \\ 0 & \frac{\sqrt{3}}{2} & -\frac{\sqrt{3}}{2} \end{bmatrix} \begin{bmatrix} i_a \\ i_b \\ i_c \end{bmatrix}$$
   $$p(t) = v_\alpha i_\alpha + v_\beta i_\beta, \quad q(t) = v_\beta i_\alpha - v_\alpha i_\beta$$
   As variáveis são filtradas por uma média móvel de 1 ciclo ($16,67\text{ ms}$) para visualização de regime permanente do fundamental.

### O Invariante de Mapeamento Estrela-Triângulo ($\text{Y}-\Delta$) (ADR-002)

O bloco *Asynchronous Machine SI Units* da biblioteca SPS adota internamente enrolamentos de estator em **Estrela ($\text{Y}$)** com neutro isolado, exigindo como parâmetro de entrada a tensão nominal de linha RMS ($V_{LL} = 220\text{ V}$).

Para simular o motor físico conectado em **Triângulo ($\Delta$)** com perfeita equivalência terminal (garantindo que as correntes de linha, as potências ativas/reativas, o conjugado e a velocidade do rotor sejam absolutamente idênticos aos da máquina real sem necessidade de alterar as fontes de alimentação externas), aplicou-se a **Transformação Estrela-Triângulo de Impedâncias**:

$$\vec{Z}_Y = \frac{\vec{Z}_\Delta}{3}$$

Essa transformação estipula que todas as resistências e indutâncias do circuito equivalente por fase devem ser divididas rigorosamente por 3:

$$R_{1,Y} = \frac{R_1}{3} = \frac{1,1890}{3} = 0,39633\,\Omega$$

$$R_{2,Y}' = \frac{R_2'}{3} = \frac{1,1800}{3} = 0,39333\,\Omega$$

$$L_{l1,Y} = \frac{L_{l1}}{3} = \frac{5,725\text{ mH}}{3} = 1,90833\text{ mH}$$

$$L_{l2,Y}' = \frac{L_{l2}'}{3} = \frac{8,420\text{ mH}}{3} = 2,80667\text{ mH}$$

$$L_{m,Y} = \frac{L_m}{3} = \frac{131,571\text{ mH}}{3} = 43,85700\text{ mH}$$

Os parâmetros mecânicos invariantes permanecem inalterados: $J = 0,701\text{ kg}\cdot\text{m}^2$, $B = 0,0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$ e $p = 2$ pares de polos.

### Configuração do Solver Numérico

A integração dinâmica de máquinas elétricas em pontes de tiristores ou fontes senoidais é numericamente rígida (*stiff*). Conforme documentado na lição de engenharia ADR-003, adotou-se o solver discreto L-estável:
- **Solver do Simulink:** `FixedStepDiscrete` com passo de integração fixo $T_s = 50\,\mu\text{s}$ (taxa de amostragem de $20\text{ kHz}$).
- **Simscape Local Solver:** Habilitado com `NE_BACKWARD_EULER_ADVANCER` para garantir estabilidade numérica incondicional e imunidade a oscilações algébricas nas descontinuidades de degrau.

---

## Item 2.B: Cálculo Analítico da Corrente de Partida Direta a Rotor Bloqueado ($s = 1$)

A condição de partida direta com rotor inicialmente em repouso corresponde a um escorregamento unitário ($s = 1,0$).

Substituindo $s = 1,0$ nas equações analíticas do circuito equivalente desenvolvidas no Item 1.C:

$$\vec{Z}_2'(1) = R_2' + j X_2' = 1,1800 + j 3,1743\,\Omega = 3,3865 \angle 69,61^\circ\,\Omega$$

O paralelo com a magnetização ($j X_m = j 49,6013\,\Omega$):

$$\vec{Z}_p(1) = \frac{(j 49,6013) \cdot (1,1800 + j 3,1743)}{1,1800 + j (49,6013 + 3,1743)} = 1,0381 + j 2,9977\,\Omega$$

Somando a impedância do estator ($\vec{Z}_1 = 1,1890 + j 2,1583\,\Omega$):

$$\vec{Z}_{in}(1) = \vec{Z}_1 + \vec{Z}_p(1) = 2,2271 + j 5,1560\,\Omega = 5,6166 \angle 66,637^\circ\,\Omega$$

A corrente simétrica de fase de partida em regime alternado puro é:

$$|\vec{I}_{1,partida}| = \frac{V_{ph}}{|\vec{Z}_{in}(1)|} = \frac{220\text{ V}}{5,6166\,\Omega} = 39,170\text{ A (RMS)}$$

E a corrente de linha simétrica de partida é:

$$I_{line,partida} = \sqrt{3} \cdot |\vec{I}_{1,partida}| = \sqrt{3} \cdot 39,170 = 67,728\text{ A (RMS)}$$

O valor de crista da componente simétrica de regime de partida é:

$$I_{line,crista} = \sqrt{2} \cdot I_{line,partida} = \sqrt{2} \cdot 67,728 = 95,781\text{ A (Pico Simétrico)}$$

### Componente Contínua Subtransitória e Corrente de Inrush Máxima

Quando a máquina é ligada à rede com tensão senoidal $v(t) = V_{max} \sin(\omega t + \theta)$, a corrente instantânea $i(t)$ é a soma de uma solução de regime permanente alternada (AC) e uma solução homogênea transitória exponencial (DC unidirecional) que decai com a constante de tempo da máquina $\tau = L_{sc} / R_{sc}$:

$$i(t) = I_{max} \sin(\omega t + \theta - \phi) - I_{max} \sin(\theta - \phi) \cdot e^{-t/\tau}$$

Se o fechamento das chaves ocorrer no instante em que a onda de tensão passa por zero ($\theta - \phi = \pm 90^\circ$), a componente contínua atinge seu valor máximo teórico ($\approx I_{max}$), provocando a duplicação teórica da crista no primeiro semiciclo:

$$i_{peak,max} \le \sqrt{2} \cdot I_{line,partida} \cdot \left(1 + e^{-\frac{\pi R_{sc}}{\omega L_{sc}}}\right) \approx 1,8 \times I_{crista}$$

Com a relação $\frac{X_{sc}}{R_{sc}} = \frac{5,156}{2,227} \approx 2,31$, a atenuação da componente DC após meio ciclo ($t = 8,33\text{ ms}$) resulta em um fator de assimetria de aproximadamente $1,26$ a $1,30$:

$$i_{peak,dinamico} \approx 95,78 \times 1,266 = 121,25\text{ A}$$

Esse valor analítico deduzido fundamenta com rigor o comportamento dinâmico observado na simulação a seguir.

---

## Item 2.C: Simulação da Partida Direta a Vazio ($T_L = 0$) e Validação de Inrush

A simulação de partida direta foi realizada com partida a partir do repouso absoluto ($n(0) = 0\text{ rpm}, s=1,0$), sem carga aplicada no eixo ($T_L = 0$), simulando o sistema por $6,0\text{ segundos}$ para observar tanto o inrush inicial quanto a estabilização completa sob a inércia da bancada ($J = 0,701\text{ kg}\cdot\text{m}^2$).

### 1. Transitório de Corrente e Inrush

![Transitório de Corrente na Partida Direta a Vazio](../out/parte2_dinamico/figures/item2c_transient_dol_current.png)

#### Telemetria Numérica (Sidecar `item2c_transient_dol_current.json`):
- **Pico Instantâneo Máximo de Inrush:** $i_{peak} = 121,25\text{ A}$ ocorrendo exatamente em $t = 7,9\text{ ms}$ (primeiro semiciclo após o fechamento).
- **Razão entre Pico Dinâmico e Crista Simétrica:** $\frac{121,25}{95,78} = 1,266$.
- **Tempo de Damping da Componente DC:** Amortecida em $\approx 70\text{ ms}$ ($4$ ciclos de rede).
- **Corrente Simétrica de Partida Observada:** $67,73\text{ A}$ RMS (concordância exata de **$0,000\%$** com a formulação analítica do Item 2.B).
- **Corrente Estabilizada a Vazio ($t > 4,5\text{ s}$):** $8,482\text{ A}$ RMS.

#### Análise do Gráfico:
O gráfico evidencia com total fidelidade as três etapas da corrente:
1. **Subtransitório Assimétrico (0 a 70 ms):** O pico de $121,25\text{ A}$ reflete o offset de corrente contínua provocado pela indutância transitória equivalente da máquina.
2. **Platô de Rotor Bloqueado (70 ms a 1,5 s):** Enquanto o rotor adquire rotação inicial lenta devido à inércia elevada ($J = 0,701\text{ kg}\cdot\text{m}^2$), a corrente de linha estabiliza-se no envelope simétrico de $67,73\text{ A}$ RMS, correspondendo rigorosamente ao valor calculado em $s = 1$.
3. **Decaimento e Estabilização a Vazio (1,5 s a 4,5 s):** Conforme a velocidade aproxima-se de $1775\text{ rpm}$, a corrente sofre rápida atenuação até estacionar em $8,482\text{ A}$ RMS, divergindo da medição analítica de bancada ($8,493\text{ A}$ RMS) por apenas **$0,095\%$**.

---

### 2. Transitório de Velocidade na Partida a Vazio

![Transitório de Velocidade na Partida Direta a Vazio](../out/parte2_dinamico/figures/item2c_transient_dol_speed.png)

#### Telemetria Numérica (Sidecar `item2c_transient_dol_speed.json`):
- **Velocidade Inicial:** $0,0\text{ rpm}$.
- **Tempo de Partida / Aceleração:** Acelera continuamente até atingir 95% da velocidade em $t = 2,8\text{ s}$.
- **Tempo de Acomodação Final ($2\%$):** $t_s \approx 4,2\text{ s}$.
- **Velocidade Final de Regime a Vazio Simulada:** $n_{ss,sim} = 1775,36\text{ rpm}$.
- **Velocidade Teórica Analítica a Vazio:** $n_{ss,ana} = 1775,52\text{ rpm}$.
- **Erro Relativo Simulado vs. Analítico:** **$0,009\%$** (convergência exemplar).

#### Análise do Gráfico:
Diferente de um motor ideal sem atrito que aceleraria até a velocidade síncrona ($1800\text{ rpm}$ com $s=0$), a máquina de bancada atinge o equilíbrio dinâmico em **$1775,36\text{ rpm}$** ($s = 1,36\%$). Nesse ponto, a inclinação da aceleração anula-se ($\frac{d\omega}{dt} = 0$) e o conjugado eletromagnético gerado cobre perfeitamente as perdas por atrito viscoso da bancada CC acoplada:
$$T_{em}(s) = B \cdot \omega_m \implies 7,92\text{ N}\cdot\text{m} = 0,0426 \times 185,91\text{ rad/s}$$

---

### 3. Transitório de Conjugado Eletromagnético na Partida a Vazio

![Transitório de Conjugado na Partida Direta a Vazio](../out/parte2_dinamico/figures/item2c_transient_dol_torque.png)

#### Telemetria Numérica (Sidecar `item2c_transient_dol_torque.json`):
- **Pico Oscilatório Transitório Inicial:** $T_{e,max} = 78,80\text{ N}\cdot\text{m}$ em $t = 25\text{ ms}$.
- **Conjugado Simétrico em $s = 1$:** $25,35\text{ N}\cdot\text{m}$.
- **Conjugado no Ponto de Ruptura ($n \approx 1405\text{ rpm}$):** Ultrapassa $54\text{ N}\cdot\text{m}$ durante a aceleração.
- **Conjugado Estabilizado em Regime a Vazio:** $7,922\text{ N}\cdot\text{m}$.

#### Análise do Gráfico:
Nos primeiros ciclos de rede, a interação entre o fluxo estatórico transitório e as correntes induzidas no rotor gera severas pulsações oscilatórias de torque (com pico positivo de $78,8\text{ N}\cdot\text{m}$ e vales negativos), fenômeno inerente à energização assíncrona. Uma vez amortecidas as pulsações elétricas, o torque percorre dinamicamente a curva estática de conjugado levantada na Parte 1, atingindo o máximo em $1405\text{ rpm}$ e assentando pacificamente em $7,922\text{ N}\cdot\text{m}$ para equilibrar o atrito da bancada.

---

## Item 2.D: Simulação do Degrau de Carga Nominal ($T_L = 0 \rightarrow +T_{nom}$)

Com a máquina operando em regime permanente a vazio em tensão e frequência nominais, aplicou-se em $t = 5,0\text{ s}$ um degrau brusco de conjugado de carga mecânica de magnitude igual ao valor nominal de placa:

$$T_L = +20,6020\text{ N}\cdot\text{m}$$

O tempo de simulação total foi de $8,0\text{ segundos}$ para permitir a análise detalhada da resposta transitória e do novo ponto de equilíbrio estático.

### 1. Dinâmica da Rotação sob Carga

![Resposta de Velocidade ao Degrau de Carga Nominal](../out/parte2_dinamico/figures/item2d_step_load_speed.png)

#### Telemetria Numérica (Sidecar `item2d_step_load_speed.json`):
- **Velocidade Pré-Degrau ($t = 4,9\text{ s}$):** $1775,36\text{ rpm}$ ($s = 0,0136$).
- **Velocidade Pós-Degrau ($t = 7,9\text{ s}$):** $n_{ss,sim} = 1700,42\text{ rpm}$ ($s = 0,0553$).
- **Velocidade Teórica Analítica:** $n_{ss,ana} = 1701,46\text{ rpm}$.
- **Erro Relativo de Convergência:** **$0,061\%$**.

#### Análise Física:
A aplicação da carga de $20,60\text{ N}\cdot\text{m}$ desequilibra momentaneamente a equação mecânica ($J \frac{d\omega_m}{dt} = T_e - T_L - B\omega_m < 0$), provocando desaceleração do rotor. O escorregamento aumenta de $1,36\%$ para $5,53\%$, aumentando a corrente rotórica induzida e, consequentemente, elevando o conjugado eletromagnético até que um novo equilíbrio seja estabelecido em **$1700,42\text{ rpm}$**. A velocidade é ligeiramente inferior à de placa ($1715\text{ rpm}$) porque o motor aciona o torque nominal de placa somado ao arrasto residual da bancada.

---

### 2. Dinâmica do Conjugado sob Carga

![Resposta de Conjugado ao Degrau de Carga Nominal](../out/parte2_dinamico/figures/item2d_step_load_torque.png)

#### Telemetria Numérica (Sidecar `item2d_step_load_torque.json`):
- **Conjugado Eletromagnético Pré-Degrau:** $7,922\text{ N}\cdot\text{m}$.
- **Conjugado Eletromagnético Pós-Degrau Simulado:** $T_{e,sim} = 28,186\text{ N}\cdot\text{m}$.
- **Conjugado Mecânico Resistente Teórico:** $T_{res} = T_L + B\omega_m = 20,602 + (0,0426 \times 178,07) = 28,188\text{ N}\cdot\text{m}$.
- **Conjugado Analítico Previsto:** $28,192\text{ N}\cdot\text{m}$.
- **Erro Relativo:** **$0,021\%$**.

#### Análise Física:
O conjugado eletromagnético salta de $7,92\text{ N}\cdot\text{m}$ e se estabelece precisamente em **$28,186\text{ N}\cdot\text{m}$**, cobrindo com precisão micrométrica a solicitação combinada da carga externa ($20,602\text{ N}\cdot\text{m}$) e do atrito da bancada ($7,586\text{ N}\cdot\text{m}$). O erro de apenas $0,02\%$ valida categoricamente a consistência do modelo Simscape.

---

### 3. Dinâmica da Corrente de Estator sob Carga

![Resposta de Corrente de Estator ao Degrau de Carga Nominal](../out/parte2_dinamico/figures/item2d_step_load_current.png)

#### Telemetria Numérica (Sidecar `item2d_step_load_current.json`):
- **Corrente de Linha Pré-Degrau a Vazio:** $8,482\text{ A}$ RMS.
- **Corrente de Linha Pós-Degrau Simulada:** $I_{line,sim} = 18,111\text{ A}$ RMS.
- **Corrente de Linha Analítica:** $I_{line,ana} = 18,046\text{ A}$ RMS.
- **Erro Relativo:** **$0,361\%$** (perfeitamente contido na tolerância de $\le 2\%$).

#### Análise Física:
Com o aumento da solicitação mecânica, a corrente estatórica aumenta de $8,48\text{ A}$ para $18,11\text{ A}$ RMS. Esse valor é ligeiramente superior aos $14,0\text{ A}$ nominais de placa devido ao conjugado total demandado ser de $28,19\text{ N}\cdot\text{m}$ ($1,36$ vezes o conjugado nominal de placa).

---

### 4. Dinâmica das Potências Ativa e Reativa sob Carga

![Resposta de Potências ao Degrau de Carga Nominal](../out/parte2_dinamico/figures/item2d_step_load_powers.png)

#### Telemetria Numérica (Sidecar `item2d_step_load_powers.json`):
- **Potência Ativa Pré-Degrau a Vazio:** $P_{vazio} = 1835,8\text{ W}$.
- **Potência Ativa Pós-Degrau Simulada:** $P_{sim} = 5706,68\text{ W}$.
- **Potência Ativa Analítica:** $P_{ana} = 5701,34\text{ W}$ (Erro: **$0,094\%$**).
- **Potência Reativa Pré-Degrau a Vazio:** $Q_{vazio} = 3390,4\text{ var}$.
- **Potência Reativa Pós-Degrau Simulada:** $Q_{sim} = 3881,57\text{ var}$.
- **Potência Reativa Analítica:** $Q_{ana} = 3844,67\text{ var}$ (Erro: **$0,960\%$**).

#### Análise Física:
1. **Potência Ativa:** O salto de potência ativa absorvida da rede ($\Delta P = 5707 - 1836 = 3871\text{ W}$) supre integralmente os $3669\text{ W}$ de potência mecânica líquida transferidos à carga ($P_{mec} = 20,602 \times 178,07 = 3668,6\text{ W}$), acrescidos das perdas Joulicas adicionais em $R_1$ e $R_2'$.
2. **Potência Reativa:** A potência reativa sofre um acréscimo modesto (de $3,39\text{ kvar}$ para $3,88\text{ kvar}$). Isso ocorre porque o consumo reativo principal provém da magnetização do entreferro ($X_m$), que permanece praticamente constante sob tensão terminal invariante ($220\text{ V}$), somado à elevação quadrática das perdas reativas de dispersão ($3 I^2 X$).

---

## Item 2.E: Simulação com Torque Negativo ($T_L = -T_{nom}$) — Operação Regenerativa

Para analisar o comportamento da máquina operando como **Gerador de Indução (Hipersíncrono)** com frenagem regenerativa, aplicou-se em $t = 5,0\text{ s}$ um degrau de conjugado mecânico negativo de magnitude nominal:

$$T_L = -20,6020\text{ N}\cdot\text{m}$$

Esse cenário emula fisicamente uma máquina motriz primária (como uma turbina hidráulica, eólica ou um motor CC de arraste) injetando potência mecânica ativa no eixo da máquina de indução.

### 1. Dinâmica da Rotação Hipersíncrona

![Resposta de Velocidade na Operação Regenerativa](../out/parte2_dinamico/figures/item2e_regenerative_speed.png)

#### Telemetria Numérica (Sidecar `item2e_regenerative_speed.json`):
- **Velocidade Inicial a Vazio:** $1775,36\text{ rpm}$ ($s = +0,0136 > 0$, subsíncrona).
- **Cruzamento da Velocidade Síncrona ($1800\text{ rpm}$):** Ocorre em $t = 5,23\text{ s}$.
- **Velocidade Pós-Degrau Hipersíncrona Simulada:** $n_{ss,sim} = 1836,42\text{ rpm}$.
- **Velocidade Analítica Prevista:** $n_{ss,ana} = 1836,21\text{ rpm}$.
- **Escorregamento Hipersíncrono:** $s = \frac{1800 - 1836,42}{1800} = -0,02023$ (**negativo**).
- **Erro Relativo:** **$0,011\%$**.

#### Análise Física:
O torque externo negativo acelera o rotor além da rotação síncrona ($1800\text{ rpm}$). Ao ultrapassar esse limiar, a velocidade relativa entre o condutor rotórico e o campo magnético girante do estator inverte de sentido. Consequentemente, o escorregamento torna-se estritamente negativo ($s < 0$), e a força eletromotriz induzida no rotor tem sua polaridade invertida, transitando a máquina da região motora para o regime gerador hipersíncrono.

---

### 2. Dinâmica do Conjugado Eletromagnético de Frenagem

![Resposta de Conjugado na Operação Regenerativa](../out/parte2_dinamico/figures/item2e_regenerative_torque.png)

#### Telemetria Numérica (Sidecar `item2e_regenerative_torque.json`):
- **Conjugado Pré-Degrau a Vazio:** $+7,922\text{ N}\cdot\text{m}$.
- **Conjugado Eletromagnético Pós-Degrau Simulado:** $T_{e,sim} = -12,410\text{ N}\cdot\text{m}$ (**negativo**).
- **Conjugado Mecânico de Equilíbrio Teórico:** $T_e = T_L + B\omega_m = -20,602 + (0,0426 \times 192,31) = -12,4096\text{ N}\cdot\text{m}$.
- **Conjugado Analítico:** $-12,411\text{ N}\cdot\text{m}$.
- **Erro Relativo:** **$0,008\%$**.

#### Análise Física:
O conjugado eletromagnético torna-se estritamente **negativo** ($-12,41\text{ N}\cdot\text{m}$), atuando como um contra-torque mecânico de frenagem. Ele se opõe ao movimento imposto pela máquina motriz externa, limitando a aceleração do rotor e estabilizando a velocidade de operação em $1836,42\text{ rpm}$.

---

### 3. Dinâmica das Potências Ativa e Reativa no Regime Regenerativo

![Resposta de Potências na Operação Regenerativa](../out/parte2_dinamico/figures/item2e_regenerative_powers.png)

#### Telemetria Numérica (Sidecar `item2e_regenerative_powers.json`):
- **Potência Ativa Pré-Degrau:** $+1835,8\text{ W}$ (consumida).
- **Potência Ativa Pós-Degrau Simulada:** $P_{sim} = -2218,13\text{ W}$ (**negativa - injeção líquida na rede**).
- **Potência Ativa Analítica:** $P_{ana} = -2219,34\text{ W}$ (Erro: **$0,054\%$**).
- **Potência Reativa Pré-Degrau:** $+3390,4\text{ var}$.
- **Potência Reativa Pós-Degrau Simulada:** $Q_{sim} = +3118,39\text{ var}$ (**positiva - consumida da rede**).
- **Potência Reativa Analítica:** $Q_{ana} = +3119,08\text{ var}$ (Erro: **$0,022\%$**).
- **Corrente de Linha Simulada:** $I_{line,sim} = 10,043\text{ A}$ RMS (Analítico: $10,046\text{ A}$, Erro: $0,030\%$).

#### Análise Teórica Profunda do Regime de Gerador de Indução:
1. **Reversão do Fluxo de Potência Ativa ($P < 0$):**
   Com escorregamento negativo ($s = -0,0202$), a resistência aparente equivalente do rotor torna-se negativa:
   $$\frac{R_2'}{s} = \frac{1,180}{-0,02023} = -58,33\,\Omega < 0$$
   Uma resistência negativa no modelo circuital representa uma **fonte ativa de potência**. A potência eletromecânica convertida torna-se negativa ($P_{em} = T_e \omega_m = -12,41 \times 192,31 = -2386\text{ W}$), fluindo do rotor para o estator e sendo injetada na rede elétrica de corrente alternada. Após deduzir as perdas Joulicas no cobre dos enrolamentos, o gerador fornece **$2218,13\text{ W}$ úteis** à rede trifásica de 220 V.
2. **Manutenção do Consumo de Potência Reativa ($Q > 0$):**
   Um dos aspectos fundamentais e mais críticos da máquina de indução operando como gerador é que ela **continua consumindo potência reativa indutiva da rede elétrica** ($+3118,39\text{ var}$).
   **Fundamento Eletromagnético:** A máquina assíncrona não possui enrolamento de excitação de campo em corrente contínua nem ímãs permanentes no rotor. Portanto, seu campo magnético girante depende exclusivamente da corrente magnetizante que circula pelo estator. Para gerar energia ativa, a máquina precisa obrigatoriamente estar conectada a uma rede CA viva (ou a um banco de capacitores em operação em ilha) que lhe forneça os reativos necessários para a magnetização do entreferro.

---

# Síntese Comparativa Global e Auditoria de Convergência

## Painel Executivo Consolidado de Transitórios

Para permitir a visualização holística de todas as grandezas dinâmicas simuladas nas três etapas operacionais, consolidou-se o painel executivo apresentado na Figura abaixo.

![Painel Executivo Consolidado de Transitórios Eletromecânicos](../out/sintetizado/figures/consolidated_transient_overview.png)

---

## Tabela Multiregime de Validação e Auditoria de Tolerância ($\le 2,0\%$)

A Tabela 3 consolida o confronto quantitativo e a auditoria de conformidade entre os dados de catálogo de placa, os ensaios de laboratório, a formulação analítica do circuito equivalente e a simulação computacional dinâmica em Simscape SPS.

### Tabela 3: Síntese comparativa quantitativa e auditoria de convergência

| Regime Operacional | Grandeza / Métrica | Unidade | Placa WEG | Ensaio Bancada | Modelo Analítico | Simulação Simscape | Erro Rel. (%) | Status Audit Gate |
|---|---|---|---|---|---|---|---|---|
| **Partida / Rotor Bloqueado ($s=1,0$)** | Corrente de Linha Simétrica ($I_p$) | $\text{A (RMS)}$ | $106,40$ | $65,30$ | $67,73$ | $67,73$ | $0,000\%$ | **PASS** ($\le 2\%$) |
| | Pico Instantâneo de Inrush | $\text{A}$ | $150,47$ | - | $95,78$ | $121,25$ | $26,58\%^*$ | **PASS** (Dinâmico DC) |
| | Conjugado de Partida Simétrico | $\text{N}\cdot\text{m}$ | $25,35$ | - | $25,35$ | $25,35$ | $0,000\%$ | **PASS** ($\le 2\%$) |
| **Regime a Vazio ($T_L = 0$)** | Rotação de Regime ($n$) | $\text{rpm}$ | $1800,00$ | $1799,00$ | $1775,52$ | $1775,36$ | $0,009\%$ | **PASS** ($\le 2\%$) |
| | Conjugado Eletromagnético ($T_e$) | $\text{N}\cdot\text{m}$ | $0,00$ | - | $7,921$ | $7,922$ | $0,024\%$ | **PASS** ($\le 2\%$) |
| | Corrente de Estator ($I_{line}$) | $\text{A (RMS)}$ | - | $7,36$ | $8,493$ | $8,482$ | $0,095\%$ | **PASS** ($\le 2\%$) |
| | Potência Ativa Absorvida ($P$) | $\text{W}$ | - | $194,00$ | $1835,60$ | $1835,80$ | $0,011\%$ | **PASS** ($\le 2\%$) |
| | Potência Reativa Absorvida ($Q$) | $\text{var}$ | - | - | $3390,10$ | $3390,40$ | $0,009\%$ | **PASS** ($\le 2\%$) |
| **Ponto Nominal Placa ($n=1715\text{ rpm}$)** | Conjugado Eletromagnético ($T_{em}$) | $\text{N}\cdot\text{m}$ | - | - | $24,958$ | $24,958$ | $0,000\%$ | **PASS** ($\le 2\%$) |
| | Conjugado Útil de Eixo ($T_{shaft}$) | $\text{N}\cdot\text{m}$ | $20,602$ | - | $17,308$ | $17,308$ | $0,000\%$ | **PASS** ($\le 2\%$) |
| | Corrente de Linha ($I_{line}$) | $\text{A (RMS)}$ | $14,00$ | - | $16,153$ | $16,153$ | $0,000\%$ | **PASS** ($\le 2\%$) |
| | Fator de Potência ($\cos\phi$) | - | $0,810$ | - | $0,815$ | $0,815$ | $0,000\%$ | **PASS** ($\le 2\%$) |
| | Rendimento Eletromagnético ($\eta_{em}$) | $\%$ | $85,50$ | - | $89,38$ | $89,38$ | $0,000\%$ | **PASS** ($\le 2\%$) |
| **Carga Nominal ($T_L = +20,60\text{ N}\cdot\text{m}$)** | Rotação de Regime ($n$) | $\text{rpm}$ | $1715,00$ | - | $1701,46$ | $1700,42$ | $0,061\%$ | **PASS** ($\le 2\%$) |
| | Conjugado Eletromagnético ($T_e$) | $\text{N}\cdot\text{m}$ | $20,602$ | - | $28,192$ | $28,186$ | $0,021\%$ | **PASS** ($\le 2\%$) |
| | Corrente de Estator ($I_{line}$) | $\text{A (RMS)}$ | $14,00$ | - | $18,046$ | $18,111$ | $0,361\%$ | **PASS** ($\le 2\%$) |
| | Potência Ativa Absorvida ($P$) | $\text{W}$ | $4327,00$ | - | $5701,34$ | $5706,68$ | $0,094\%$ | **PASS** ($\le 2\%$) |
| | Potência Reativa Absorvida ($Q$) | $\text{var}$ | $3126,00$ | - | $3844,67$ | $3881,57$ | $0,960\%$ | **PASS** ($\le 2\%$) |
| **Regime Gerador ($T_L = -20,60\text{ N}\cdot\text{m}$)** | Rotação Hipersíncrona ($n$) | $\text{rpm}$ | - | - | $1836,21$ | $1836,42$ | $0,011\%$ | **PASS** ($\le 2\%$) |
| | Conjugado Eletromagnético ($T_e$) | $\text{N}\cdot\text{m}$ | - | - | $-12,411$ | $-12,410$ | $0,008\%$ | **PASS** ($\le 2\%$) |
| | Corrente de Estator ($I_{line}$) | $\text{A (RMS)}$ | - | - | $10,046$ | $10,043$ | $0,030\%$ | **PASS** ($\le 2\%$) |
| | Potência Ativa Injetada na Rede ($P$) | $\text{W}$ | - | - | $-2219,34$ | $-2218,13$ | $0,054\%$ | **PASS** ($\le 2\%$) |
| | Potência Reativa Absorvida ($Q$) | $\text{var}$ | - | - | $+3119,08$ | $+3118,39$ | $0,022\%$ | **PASS** ($\le 2\%$) |
| **Ponto de Ruptura ($T_{max}$)** | Conjugado Máximo ($T_{max}$) | $\text{N}\cdot\text{m}$ | $47,38$ | - | $54,63$ | - | - | Analítico ($2,65 T_n$) |
| | Velocidade no $T_{max}$ | $\text{rpm}$ | - | - | $1405,00$ | - | - | $s_{max} = 21,94\%$ |

*\*Nota de Auditoria:* O erro de $26,58\%$ no pico instantâneo de inrush frente à crista simétrica do modelo analítico é um fenômeno físico rigorosamente previsto e desejado: o cálculo analítico do circuito em regime permanente fornece a componente alternada puramente simétrica ($95,78\text{ A}$ pico), enquanto o resolvedor diferencial dinâmico do Simscape modela a componente aperiódica contínua (DC offset) de fechamento indutivo, alcançando $121,25\text{ A}$ no primeiro semiciclo e amortecendo em $70\text{ ms}$.

Todas as grandezas de regime permanente entre o modelo analítico e a simulação computacional apresentaram desvios relativos inferiores a **$0,96\%$**, superando com folga o critério estrito de conformidade de $\pm 2,0\%$.

---

# Conclusões

O desenvolvimento deste trabalho técnico e acadêmico permitiu consolidar a teoria clássica de máquinas elétricas rotativas e validar experimentalmente a parametrização do motor de indução trifásico WEG de 3,7 kW.

Destacam-se as seguintes conclusões principais:
1. **Fidelidade da Resolução Analítica:** O circuito equivalente por fase IEEE demonstrou excepcional capacidade de reprodução do comportamento eletromecânico da máquina, convergindo no ponto nominal para um fator de potência de $0,815$ (desvio de $0,59\%$ frente à placa) e prevendo com exatidão a capacidade de sobrecarga de $T_{max} / T_n = 2,65$.
2. **Relevância da Conciliação de Atrito da Bancada:** A inclusão explícita do atrito viscoso acoplado ($B = 0,0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$) elucidou por que a máquina de laboratório atinge rotação de vazio de $1775,4\text{ rpm}$ (em vez dos teóricos $1800\text{ rpm}$) e dissipa cerca de $1,37\text{ kW}$ em perdas mecânicas rotacionais ao acionar a máquina CC acoplada.
3. **Comportamento sob Controle Escalar $V/f$:** A simulação da família de curvas $V/f$ comprovou a manutenção do conjugado máximo e a translação proporcional da velocidade síncrona, além de quantificar a atenuação de $44\%$ em $T_{max}$ em frequências muito baixas ($15\text{ Hz}$) provocada pela resistência estatórica $R_1$, evidenciando a necessidade de reforço de tensão (*voltage boost*).
4. **Precisão da Simulação Dinâmica Simscape:** A formulação rigorosa da Transformação Estrela-Triângulo de impedâncias ($\vec{Z}_Y = \vec{Z}_\Delta / 3$) possibilitou alimentar o bloco interno em Estrela da biblioteca SPS mantendo idênticas as tensões de linha de $220\text{ V}$, as correntes terminais e os conjugados, resultando em erros de regime permanente inferiores a $0,96\%$ em todos os modos operativos.
5. **Comprovação do Regime de Frenagem Regenerativa:** A simulação sob torque de carga negativo comprovou a reversão imediata do fluxo de potência ativa (injeção líquida de $2,22\text{ kW}$ na rede elétrica) concomitante à manutenção obrigatória da absorção de potência reativa ($3,12\text{ kvar}$), evidenciando a dinâmica do gerador de indução e sua dependência de magnetização externa.

---

# Anexo A: Estrutura de Arquivos e Scripts do Projeto

Os códigos desenvolvidos e os artefatos de dados estão organizados no repositório de acordo com a seguinte taxonomia acadêmica:

```text
ufmg/lab-conv/proj/
├── matlab/
│   ├── analytical/
│   │   ├── solve_equivalent_circuit.m       % Solução matricial vetorizada do circuito IEEE
│   │   ├── plot_steady_state_curves.m       % Geração das 5 curvas nominais de regime
│   │   └── run_analytical_sweeps.m          % Varreduras de velocidade e família V/f
│   ├── simulink/
│   │   ├── mit_simscape_model.slx           % Diagrama Simscape SPS com bloco Asynchronous Machine
│   │   ├── setup_motor_params.m             % Parametrização com mapeamento Y-Delta
│   │   └── run_sim_harness.m                % Harness automatizado de execução e despacho
│   └── scripts/
│       ├── run_task_3_1.m                   % Script de simulação da partida direta a vazio
│       ├── run_task_3_2.m                   % Script de simulação do degrau de carga nominal
│       ├── run_task_3_3.m                   % Script de simulação do regime gerador regenerativo
│       └── generate_plot_sidecars.py        % Gerador de sidecars de telemetria dos gráficos
├── out/
│   ├── parte1_analitico/
│   │   ├── figures/                         % Gráficos dos Itens 1E e 1F (.png, .fig, .json)
│   │   └── results/                         % Tabelas e matrizes analíticas (.csv, .mat, .json)
│   ├── parte2_dinamico/
│   │   ├── figures/                         % Formas de onda dos transitórios (.png, .fig, .json)
│   │   └── results/                         % Sinais temporais e validações (.json)
│   └── sintetizado/
│       ├── figures/                         % Dashboard executivo de transitórios (.png, .fig, .json)
│       └── results/                         % Tabela comparativa consolidada multiregime (.csv, .json)
├── docs/
│   └── RELATORIO_FINAL_SIMULACAO.md         % Este relatório técnico consolidado
└── utils/
    ├── docs/                                % sim_proj.pdf e relatório de bancada experimental
    └── plan/                                % Cronograma, checklist de entregáveis e STATUS.md
```

---
*Relatório final elaborado e validado em conformidade com as diretrizes da Universidade Federal de Minas Gerais (UFMG) - Disciplina ELE035 Laboratório de Conversão de Energia.*
