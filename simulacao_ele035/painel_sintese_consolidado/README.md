# Módulo de Síntese Executiva e Painel Consolidado

## Descrição do Módulo
Este módulo compila, reconcilia e apresenta de forma comparativa e integrada todos os dados e respostas transitórias do motor de indução WEG 3,7 kW sob os diferentes regimes de operação, consumindo dinamicamente `simulacao_ele035/parametros_motor.m` ($J = 0,0555\text{ kg}\cdot\text{m}^2$, $B = 0,003651\text{ N}\cdot\text{m}\cdot\text{s/rad}$):
1. **Partida Direta / Rotor Bloqueado ($s = 1,0$):** Inrush dinâmico ($121,18\text{ A}$) vs. simétrico ($67,73\text{ A}$ RMS).
2. **Regime Permanente a Vazio ($T_L = 0$):** Equilíbrio a $1797,92\text{ rpm}$ ($P_0 = 194,25\text{ W}$, $I_0 = 7,342\text{ A}$) em total acordo com o ensaio experimental a vazio ($1799\text{ rpm}$, $194,0\text{ W}$, $7,36\text{ A}$).
3. **Degrau de Carga Nominal ($T_L = +20,602\text{ N}\cdot\text{m}$):** Operação motora sob plena carga ($1728,87\text{ rpm}$, $I_L = 14,163\text{ A}$, $P_{elec} = 4248,71\text{ W}$, $\eta_{eixo} = 87,79\%$).
4. **Frenagem Regenerativa / Gerador ($T_L = -20,602\text{ N}\cdot\text{m}$):** Operação hipersíncrona a $1857,86\text{ rpm}$ com injeção líquida de $3,54\text{ kW}$ na rede trifásica e absorção de $3,52\text{ kvar}$ de excitação reativa.

---

## Como Executar no MATLAB
1. Navegue até esta pasta:
   ```matlab
   cd simulacao_ele035/painel_sintese_consolidado
   ```
2. Execute o script de síntese:
   ```matlab
   run_painel_consolidado
   ```

---

## Estrutura de Arquivos
- `figures/consolidated_transient_overview.{png, fig, json}`: Painel de 4 subgráficos multivariáveis em 300 DPI e formato editável `.fig`.
- `results/consolidated_comparison.{csv, json}`: Tabela comparativa multidimensional confrontando Catálogo WEG, Ensaios de Laboratório, Modelo Analítico e Simulink SPS.
