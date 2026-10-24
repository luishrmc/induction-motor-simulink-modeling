# Parte 2: Item D — Degrau de Carga Nominal ($T_L = +T_{nom}$)

## Descrição do Módulo
Este módulo atende integralmente ao Item D da 2ª Parte da especificação `sim_proj.pdf`. Ele simula a resposta da máquina ao ser submetida a um degrau de conjugado mecânico resistente nominal ($T_L = +20,602\text{ N}\cdot\text{m}$) aplicado em $t = 5,0\text{ segundos}$ após a completa acomodação a vazio.

O módulo avalia e compara com a teoria:
1. Queda de velocidade de $1775,36\text{ rpm}$ para $1700,42\text{ rpm}$ ($s = 5,53\%$).
2. Salto de conjugado eletromagnético para $28,186\text{ N}\cdot\text{m}$, cobrindo a carga útil somada ao atrito ($T_L + B\omega_m$).
3. Elevação da corrente de estator para $18,11\text{ A}$ RMS.
4. Salto de potência ativa para $5,71\text{ kW}$ e reativa para $3,88\text{ kvar}$.
5. Auditoria de tolerância demonstrando convergência analítica rigorosa com erros inferiores a $0,96\%$ (muito abaixo do limite de $\le 2\%$).

---

## Como Executar no MATLAB
1. Navegue até esta pasta:
   ```matlab
   cd simulacao_ele035/parte2_simulacao_dinamica/item_D_degrau_carga_nominal
   ```
2. Execute o script:
   ```matlab
   run_item_D_simulacao
   ```
   *No MATLAB Editor, use `Ctrl+Enter` para inspecionar cada seção.*

---

## Figuras e Arquivos Gerados
- `figures/item2d_step_load_speed.{png,fig}`: Velocidade sob degrau.
- `figures/item2d_step_load_torque.{png,fig}`: Conjugado sob degrau.
- `figures/item2d_step_load_current.{png,fig}`: Corrente de estator sob degrau.
- `figures/item2d_step_load_powers.{png,fig}`: Potências ativa e reativa fundamentais.
- `comparison_3.2.json`: Valores analíticos vs. simulados (auditoria de tolerância).
