# Parte 1: Item F — Controle Escalar V/f Constante

## Descrição do Módulo
Este módulo atende integralmente ao Item F da especificação `sim_proj.pdf`. Ele implementa e traça a família de curvas de conjugado vs. velocidade sob controle escalar com fluxo constante ($V/f = \text{cte}$), simulando a operação do motor sob acionamento por inversor de frequência comercial nos patamares:
- **100%:** $220\text{ V}$, $60\text{ Hz}$ ($n_s = 1800\text{ rpm}$)
- **75%:** $165\text{ V}$, $45\text{ Hz}$ ($n_s = 1350\text{ rpm}$)
- **50%:** $110\text{ V}$, $30\text{ Hz}$ ($n_s = 900\text{ rpm}$)
- **25%:** $55\text{ V}$, $15\text{ Hz}$ ($n_s = 450\text{ rpm}$)

Todas as curvas são apresentadas em um único gráfico comparativo, com os pontos de conjugado máximo ($T_{max}$) explicitamente destacados.

---

## Como Executar no MATLAB
1. Navegue até esta pasta:
   ```matlab
   cd simulacao_ele035/parte1_regime_permanente/item_F_controle_escalar_vf
   ```
2. Execute o script:
   ```matlab
   run_item_F_vf_family
   ```
   *No MATLAB Editor, use `Ctrl+Enter` para executar interativamente e inspecionar os vetores no Workspace.*

---

## Análise Física e Teórica do Comportamento
1. **Manutenção do Fluxo no Entreferro:** A densidade de fluxo magnético é proporcional à razão entre a tensão induzida e a frequência ($\Phi_m \propto E_1 / f$). Ao modular a tensão proporcionalmente à frequência ($V/f = 3,667\text{ V/Hz}$), o fluxo é preservado sem saturar o núcleo de aço-silício.
2. **Translação da Velocidade Síncrona:** O campo girante desacelera linearmente com a frequência ($1800 \to 1350 \to 900 \to 450\text{ rpm}$), permitindo controle suave de velocidade em malha aberta.
3. **Queda Ôhmica do Estator ($I_1 R_1$) e Atenuação de $T_{max}$:**
   Em frequências mais baixas, a reatância $X_1 = 2\pi f L_{l1}$ reduz significativamente, mas a resistência ôhmica do enrolamento $R_1 = 1,189\,\Omega$ permanece fixa. A queda de tensão resistiva passa a comprometer uma parcela expressiva da tensão terminal reduzida ($55\text{ V}$ em 15 Hz), enfraquecendo o fluxo resultante. Como consequência, o conjugado de ruptura decai de $54,63\text{ N}\cdot\text{m}$ (a 60 Hz) para $30,65\text{ N}\cdot\text{m}$ (a 15 Hz).
4. **Implicação em Inversores:** Evidencia a necessidade do recurso industrial de **reforço de tensão (*voltage boost*)** em baixas rotações.

---

## Arquivos Gerados
- `figures/item1f_vf_scalar_family.png`: Gráfico em alta resolução (300 DPI).
- `figures/item1f_vf_scalar_family.fig`: Gráfico interativo com ferramentas de zoom e inspeção para o MATLAB GUI.
