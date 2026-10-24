# Parte 2: Item A — Montagem e Parametrização do Modelo Simscape

## Descrição do Módulo
Este módulo atende integralmente ao Item A da 2ª Parte da especificação `sim_proj.pdf`. Ele contém o modelo dinâmico computacional em **Simscape Specialized Power Systems (SPS)** do motor de indução trifásico WEG de 3,7 kW (5 cv).

---

## Como Abrir e Inspecionar no MATLAB / Simulink GUI
Para abrir o modelo diretamente na interface gráfica do Simulink com todos os parâmetros carregados:
1. Abra o MATLAB e navegue até esta pasta:
   ```matlab
   cd simulacao_ele035/parte2_simulacao_dinamica/item_A_modelo_simscape
   ```
2. Execute o script de abertura:
   ```matlab
   abrir_modelo
   ```
3. A janela do Simulink abrirá automaticamente exibindo o diagrama elétrico e mecânico completo.

---

## O Invariante de Mapeamento Estrela-Triângulo (ADR-002)
O bloco *Asynchronous Machine SI Units* da biblioteca SPS adota internamente enrolamentos conectados em **Estrela (Y)** e requer como especificação de entrada a tensão nominal de linha RMS ($V_{LL} = 220\text{ V}$).

Para simular o motor físico conectado em **Triângulo ($\Delta$)** garantindo perfeita equivalência externa (mesmas correntes terminais de linha, potências ativas/reativas, conjugado e velocidade do rotor sem necessidade de alterar as fontes trifásicas), aplica-se a **Transformação Estrela-Triângulo de Impedâncias**:

$$\vec{Z}_Y = \frac{\vec{Z}_\Delta}{3}$$

- $R_{1,Y} = R_1 / 3 = 1,189 / 3 = 0,39633\,\Omega$
- $R_{2,Y}' = R_2' / 3 = 1,180 / 3 = 0,39333\,\Omega$
- $L_{l1,Y} = L_{l1} / 3 = 5,725\text{ mH} / 3 = 1,90833\text{ mH}$
- $L_{l2,Y}' = L_{l2}' / 3 = 8,420\text{ mH} / 3 = 2,80667\text{ mH}$
- $L_{m,Y} = L_m / 3 = 131,571\text{ mH} / 3 = 43,85700\text{ mH}$

Os parâmetros mecânicos são invariantes com a conexão elétrica:
- $J = 0,701\text{ kg}\cdot\text{m}^2$
- $B = 0,0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$
- $p = 2$ pares de polos

---

## Configuração do Solver Numérico
- **Solver do Simulink:** `FixedStepDiscrete` com passo $T_s = 50\,\mu\text{s}$ ($20\text{ kHz}$).
- **Solver Local do Simscape:** `NE_BACKWARD_EULER_ADVANCER` para garantia de L-estabilidade em descontinuidades de chaveamento e rigidez eletromecânica.
