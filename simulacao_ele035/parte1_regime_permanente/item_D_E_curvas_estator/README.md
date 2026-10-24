# Parte 1: Itens D e E — Curvas Características em Regime Permanente

## Descrição do Módulo
Este módulo atende integralmente aos Itens D e E da especificação `sim_proj.pdf`. Ele contém scripts MATLAB modulares, autônomos e 100% vetorizados para traçar as cinco curvas características do motor de indução sob tensão ($220\text{ V}$) e frequência ($60\text{ Hz}$) nominais:
1. **Conjugado x Velocidade** (`run_item_E_torque.m`): $T_{em}$ e $T_{shaft}$, assinalando $T_{max} = 54,63\text{ N}\cdot\text{m}$ ($1405\text{ rpm}$), $T_{partida} = 25,35\text{ N}\cdot\text{m}$, ponto nominal ($1715\text{ rpm}$) e torque de placa ($20,60\text{ N}\cdot\text{m}$).
2. **Corrente de Estator x Velocidade** (`run_item_E_corrente.m`): Corrente de linha e de fase RMS, assinalando partida ($67,73\text{ A}$ RMS), nominal ($16,15\text{ A}$ RMS) e placa ($14,0\text{ A}$ RMS).
3. **Potência Ativa x Velocidade** (`run_item_E_potencia.m`): Balanço de potências $P_{elec}$, $P_{ag}$, $P_{em}$ e $P_{shaft}$.
4. **Fator de Potência x Velocidade** (`run_item_E_fp.m`): Curva de $\cos\phi$, assinalando nominal ($0,8148$ vs. placa $0,810$) e partida ($0,396$).
5. **Rendimento x Velocidade** (`run_item_E_rendimento.m`): Rendimento eletromagnético interno $\eta_{em} = 89,38\%$ e rendimento no eixo com a bancada $\eta_{shaft} = 61,98\%$.

---

## Como Executar no MATLAB

### Opção 1: Executar uma curva específica
Navegue até esta pasta e abra o script desejado no MATLAB Editor:
```matlab
cd simulacao_ele035/parte1_regime_permanente/item_D_E_curvas_estator
run_item_E_torque      % Executa e exibe o gráfico de torque
run_item_E_corrente    % Executa e exibe o gráfico de corrente
run_item_E_potencia    % Executa e exibe o gráfico de potência
run_item_E_fp          % Executa e exibe o gráfico de fator de potência
run_item_E_rendimento  % Executa e exibe o gráfico de rendimento
```
*Cada script pode ser inspecionado interativamente seção por seção (`%%`) com `Ctrl+Enter`.*

### Opção 2: Executar todas as 5 curvas em lote
```matlab
run_all_item_E
```

---

## Estrutura de Saídas
- `figures/`: Contém os arquivos `.png` em 300 DPI e os arquivos `.fig` editáveis para análise interativa de zoom no MATLAB.
- `data/`: Contém os sidecars JSON com as coordenadas numéricas exatas e o arquivo `analytical_baseline.mat`.
