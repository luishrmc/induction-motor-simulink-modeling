# Parte 2: Item C — Simulação da Partida Direta a Vazio e Validação de Inrush

## Descrição do Módulo
Este módulo atende integralmente ao Item C da 2ª Parte da especificação `sim_proj.pdf`. Ele simula a partida direta com rotor em repouso sem carga externa ($T_L = 0$) por um horizonte temporal de $6,0\text{ segundos}$ para validar:
1. O pico instantâneo de inrush ($121,25\text{ A}$) com componente contínua assimétrica nos primeiros semiciclos.
2. A amortização rápida do offset DC ($\approx 70\text{ ms}$) e concordância com o valor simétrico de rotor bloqueado ($67,73\text{ A}$ RMS).
3. A rotação estabilizada a vazio ($1775,36\text{ rpm}$), evidenciando o equilíbrio com o atrito da bancada acoplada ($T_e = B\omega_m = 7,92\text{ N}\cdot\text{m}$).

---

## Como Executar no MATLAB
1. Navegue até esta pasta:
   ```matlab
   cd simulacao_ele035/parte2_simulacao_dinamica/item_C_partida_direta_vazio
   ```
2. Execute o script:
   ```matlab
   run_item_C_simulacao
   ```
   *No MATLAB Editor, use `Ctrl+Enter` em cada seção para inspecionar os sinais temporais.*

---

## Figuras e Arquivos Gerados
- `figures/item2c_transient_dol_current.{png,fig}`: Forma de onda da corrente instantânea de estator e inrush.
- `figures/item2c_transient_dol_speed.{png,fig}`: Aceleração da rotação de 0 a $1775,36\text{ rpm}$.
- `figures/item2c_transient_dol_torque.{png,fig}`: Pulsação eletromagnética de partida ($78,8\text{ N}\cdot\text{m}$) e acomodação.
- `analise_convergencia.json`: Relatório de validação de erro relativo frente aos valores analíticos calculados ($\le 0,095\%$).
