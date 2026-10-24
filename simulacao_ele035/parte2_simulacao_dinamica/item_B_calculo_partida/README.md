# Parte 2: Item B — Cálculo Analítico da Corrente de Partida Direta

## Descrição do Módulo
Este módulo atende integralmente ao Item B da 2ª Parte da especificação `sim_proj.pdf`. Ele resolve analiticamente o circuito equivalente para escorregamento unitário ($s = 1,0$), calculando a corrente simétrica de partida e deduzindo o pico subtransitório instantâneo com componente contínua aperiódica (inrush).

---

## Como Executar no MATLAB
1. Navegue até esta pasta:
   ```matlab
   cd simulacao_ele035/parte2_simulacao_dinamica/item_B_calculo_partida
   ```
2. Execute o script:
   ```matlab
   run_item_B_partida
   ```

---

## Formulação Matemática
1. **Impedância em Rotor Bloqueado ($s = 1,0$):**
   $$\vec{Z}_{in}(1) = \vec{Z}_1 + \left(j X_m \parallel (R_2' + j X_2')\right) = 2,231 + j 5,165\,\Omega \quad (|Z_{in}| = 5,626\,\Omega)$$
2. **Corrente Simétrica de Partida em Regime Alternado Puro:**
   $$I_{ph,partida} = \frac{V_{ph}}{|Z_{in}(1)|} = \frac{220}{5,626} = 39,10\text{ A RMS}$$
   $$I_{line,partida} = \sqrt{3} \cdot I_{ph,partida} = 67,73\text{ A RMS}$$
   $$I_{crista,simetrica} = \sqrt{2} \cdot 67,73 = 95,78\text{ A}$$
3. **Pico de inrush (121,25 A):** obtido na simulação do Item C (componente DC do fechamento indutivo), não neste cálculo analítico simétrico.
   Devido ao comportamento indutivo do circuito ($X/R = 2,32, \tau \approx 6,14\text{ ms}$), a corrente instantânea no primeiro semiciclo atinge:
   Esse pico é amortecido nos primeiros 70 ms, estabilizando no envelope simétrico de $67,73\text{ A}$ RMS.
