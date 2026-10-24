# Parte 2: Item E — Análise Teórica da Operação Regenerativa e Fluxo de Potência

## Descrição do Módulo
Este módulo atende integralmente ao Item E da 2ª Parte da especificação `sim_proj.pdf`. Ele investiga a operação da máquina no **quadrante de frenagem regenerativa / gerador de indução**, aplicando em $t = 5,0\text{ s}$ um degrau mecânico negativo $T_L = -20,602\text{ N}\cdot\text{m}$.

---

## Como Executar no MATLAB
1. Navegue até esta pasta:
   ```matlab
   cd simulacao_ele035/parte2_simulacao_dinamica/item_E_operacao_regenerativa
   ```
2. Execute o script:
   ```matlab
   run_item_E_simulacao
   ```
   *No MATLAB Editor, use `Ctrl+Enter` para inspecionar as grandezas no Workspace.*

---

## Fundamentos Físicos da Geração Assíncrona

### 1. Reversão do Escorregamento ($s < 0$)
Quando uma máquina motriz primária (ou carga em descida/frenagem) aciona o rotor com velocidade superior à rotação do campo magnético girante do estator ($n > n_s = 1800\text{ rpm}$):
$$s = \frac{n_s - n}{n_s} = \frac{1800 - 1836,42}{1800} = -0,02023 < 0$$
O escorregamento torna-se negativo.

### 2. Inversão do Conjugado Eletromagnético ($T_e < 0$)
A velocidade relativa entre os condutores do rotor e o campo girante inverte de sentido. Consequentemente:
- A força eletromotriz induzida no rotor inverte sua polaridade.
- A corrente rotórica inverte seu sentido em relação ao campo.
- O conjugado eletromagnético torna-se estritamente negativo ($T_e = -12,410\text{ N}\cdot\text{m}$), exercendo ação de frenagem sobre o eixo para contrabalançar o torque mecânico motriz e o atrito viscoso:
  $$T_e = T_L + B\omega_m = -20,602 + (0,0426 \times 192,31) = -12,410\text{ N}\cdot\text{m}$$

### 3. Reversão do Fluxo de Potência Ativa ($P < 0$)
No circuito equivalente por fase:
$$\frac{R_2'}{s} = \frac{1,180}{-0,02023} = -58,33\,\Omega < 0$$
A resistência de carga aparente negativa comporta-se como uma **fonte ativa de potência**. A potência eletromecânica $P_{em} = T_e \omega_m = -2386\text{ W}$ flui do rotor em direção ao estator, resultando na **injeção líquida de $2218,13\text{ W}$ na rede elétrica trifásica de 220 V**.

### 4. Manutenção Obrigatória do Consumo de Potência Reativa ($Q > 0$)
Mesmo injetando potência ativa na rede, a máquina de indução **continua consumindo potência reativa indutiva** ($Q = +3118,39\text{ var}$).
**Causa:** A máquina assíncrona não possui fontes internas de excitação DC ou ímãs. Seu campo magnético girante depende exclusivamente da corrente magnetizante que entra pelo estator a partir da rede CA.

---

## Figuras e Arquivos Gerados
- `figures/item2e_regenerative_speed.{png,fig}`: Aceleração hipersíncrona até $1836,42\text{ rpm}$.
- `figures/item2e_regenerative_torque.{png,fig}`: Conjugado negativo de frenagem ($-12,41\text{ N}\cdot\text{m}$).
- `figures/item2e_regenerative_powers.{png,fig}`: Inversão da potência ativa ($P < 0$) e manutenção do consumo reativo ($Q > 0$).
- `comparison_3.3.json`: Relatório estruturado de validação e tolerância.
