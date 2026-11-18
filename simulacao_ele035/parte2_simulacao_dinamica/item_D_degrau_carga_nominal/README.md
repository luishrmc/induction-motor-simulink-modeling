# Parte 2: Item D — Degrau de Carga Nominal ($T_L = +T_{nom}$)

## Descrição do Módulo
Este módulo atende integralmente ao Item D da 2ª Parte da especificação `sim_proj.pdf`. Ele simula a resposta da máquina ao ser submetida a um degrau de conjugado mecânico resistente nominal ($T_L = +20,602\text{ N}\cdot\text{m}$) aplicado em $t = 1,5\text{ segundos}$ após a completa acomodação a vazio (horizonte total $t = 3,0\text{ s}$).

O módulo avalia e compara com a teoria:
1. Queda de velocidade de $1797,92\text{ rpm}$ para $1728,87\text{ rpm}$ ($s = 3,95\%$).
2. Salto de conjugado eletromagnético para $21,263\text{ N}\cdot\text{m}$, cobrindo a carga útil somada ao atrito ($T_L + B\omega_m$).
3. Elevação da corrente de estator para $14,163\text{ A}$ RMS (consistente com os $14,0\text{ A}$ de placa).
4. Salto de potência ativa para $4248,71\text{ W}$ e reativa para $3328,09\text{ var}$.
5. Auditoria de tolerância demonstrando convergência analítica rigorosa com erros inferiores a $0,44\%$ (muito abaixo do limite de $\le 2,0\%$).

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
