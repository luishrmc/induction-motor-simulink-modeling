# Parte 1: Itens A, B e C — Ponto Nominal e Circuito Equivalente

## Descrição do Módulo
Este módulo atende integralmente aos Itens A, B e C da 1ª Parte da especificação `sim_proj.pdf` da UFMG. Ele contém o equacionamento analítico completo, o cálculo do torque nominal ($T_n$) e a resolução do circuito equivalente IEEE para a velocidade nominal de $1715\text{ rpm}$ ($s = 0,04722$).

---

## Como Executar no MATLAB
1. Abra o MATLAB e navegue até esta pasta:
   ```matlab
   cd simulacao_ele035/parte1_regime_permanente/item_A_B_C_ponto_nominal
   ```
2. Execute o script principal:
   ```matlab
   run_item_ABC
   ```
   *Dica para o MATLAB Editor:* O script está organizado em seções (`%%`). Você pode clicar em cada seção e pressionar `Ctrl+Enter` para executar e inspecionar as variáveis no Workspace.

---

## Fórmulas Fundamentais e Equacionamento
1. **Torque Nominal de Placa ($T_n$):**
   $$\omega_{nom} = n_{nom} \cdot \frac{2\pi}{60} = 1715 \cdot \frac{2\pi}{60} \approx 179,594\text{ rad/s}$$
   $$T_n = \frac{P_{nom}}{\omega_{nom}} = \frac{3700\text{ W}}{179,594\text{ rad/s}} = 20,6020\text{ N}\cdot\text{m}$$

2. **Impedância de Entrada por Fase ($\Delta$):**
   $$\vec{Z}_2'(s) = \frac{R_2'}{s} + j X_2' = 24,9888 + j 3,1743\,\Omega$$
   $$\vec{Z}_p = \frac{j X_m \cdot \vec{Z}_2'(s)}{j X_m + \vec{Z}_2'(s)} = 18,0347 + j 11,5188\,\Omega$$
   $$\vec{Z}_{in} = (R_1 + j X_1) + \vec{Z}_p = 19,22 + j 13,68\,\Omega \quad (|Z_{in}| = 23,59\,\Omega, \, \phi = 35,44^\circ)$$

3. **Correntes e Potências:**
   - Corrente de fase: $I_1 = V_{ph} / |Z_{in}| = 9,325\text{ A RMS}$
   - Corrente de linha: $I_{line} = \sqrt{3} \cdot I_1 = 16,153\text{ A RMS}$
   - Fator de potência: $\cos\phi = \cos(35,44^\circ) = 0,8147$
   - Potência ativa de entrada: $P_{elec} = 5014,70\text{ W}$
   - Potência mecânica convertida interna: $P_{em} = (1 - s) P_{ag} = 4482,32\text{ W}$
   - Conjugado eletromagnético interno: $T_{em} = P_{ag} / \omega_s = 24,958\text{ N}\cdot\text{m}$

4. **Conciliação com o Atrito Viscoso da Bancada Acoplada ($B = 0,0426\text{ N}\cdot\text{m}\cdot\text{s/rad}$):**
   - Conjugado útil no eixo: $T_{shaft} = T_{em} - B \omega_{nom} = 24,958 - 7,651 = 17,307\text{ N}\cdot\text{m}$
   - Potência útil no eixo: $P_{shaft} = P_{em} - B \omega_{nom}^2 = 4482,32 - 1374,03 = 3108,29\text{ W}$
   - Rendimento eletromagnético interno: $\eta_{em} = 89,38\%$
   - Rendimento de eixo com bancada: $\eta_{shaft} = 61,98\%$

---

## Arquivos Gerados
- `nominal_metrics.csv`: Tabela estruturada com o confronto numérico entre catálogo WEG e modelo analítico.
