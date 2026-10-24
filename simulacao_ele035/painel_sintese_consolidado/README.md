# Módulo de Síntese Executiva e Painel Consolidado

## Descrição do Módulo
Este módulo compila, reconcilia e apresenta de forma comparativa e integrada todos os dados e respostas transitórias do motor de indução WEG 3,7 kW sob os diferentes regimes de operação:
1. **Partida Direta / Rotor Bloqueado ($s = 1,0$):** Inrush dinâmico ($121,25\text{ A}$) vs. simétrico ($67,73\text{ A}$ RMS).
2. **Regime Permanente a Vazio ($T_L = 0$):** Equilíbrio a $1775,36\text{ rpm}$ com o atrito residual acoplado da bancada ($B = 0,0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$).
3. **Degrau de Carga Nominal ($T_L = +20,602\text{ N}\cdot\text{m}$):** Operação motora sob plena carga ($1700,42\text{ rpm}$, $P_{elec} = 5,71\text{ kW}$, $\eta_{global} = 64,3\%$).
4. **Frenagem Regenerativa / Gerador ($T_L = -20,602\text{ N}\cdot\text{m}$):** Operação hipersíncrona a $1836,42\text{ rpm}$ com injeção de $2,22\text{ kW}$ na rede trifásica e absorção de $3,12\text{ kvar}$ de excitação reativa.

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
- `results/consolidated_comparison.{csv, json}`: Tabela comparativa multidimensional confrontando Catálogo WEG, Ensaios de Laboratório, Modelo Analítico e Simscape SPS.
