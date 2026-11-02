---
name: latex-syntax-gate
description: Standards and automated criteria for validating LaTeX syntax, siunitx physical unit notation, cleveref capitalization, booktabs clean table formatting without vertical lines, and CircuitikZ anchor conventions.
---

# SKILL: LaTeX Syntax Gate (`latex-syntax-gate`)

## 1. Contexto e Finalidade
Esta skill estabelece os padrões normativos e as regras de sintaxe LaTeX para a documentação acadêmica de engenharia elétrica do projeto ELE035. Ela fornece critérios objetivos para a redação e validação de equações, notação física de unidades, formatação de tabelas e diagramas circuítais.

---

## 2. Invariantes Tipográficos e Sintáticos

### 2.1. Notação de Unidades com `siunitx`
1. **Uso Obrigatório de Macros:** Todas as grandezas físicas escalares com unidades devem ser grafadas exclusivamente via `\SI{valor}{unidade}` ou `\si{unidade}`.
   - *Correto:* `\SI{220}{\volt}`, `\SI{14,0}{\ampere}`, `\SI{3,7}{\kilo\watt}`, `\SI{1715}{\RPM}`, `\SI{20,6020}{\Nm}`, `\SI{0,701}{\kilogram\meter\squared}`.
   - *Incorreto:* `$220 V$`, `14A`, `3.7 kW`, `$1715 rpm$`, `20.6 Nm`.
2. **Separador Decimal:** Utilizar a vírgula `,` para números em português dentro de `\SI{...}{...}` (ex.: `\SI{1,189}{\ohm}`, e não `\SI{1.189}{\ohm}`).
3. **Grandezas Adimensionais ou Porcentagens:** Utilizar `\si{\percent}` (ex.: `\SI{85,5}{\percent}`, `\SI{2,0}{\percent}`).

### 2.2. Referências Cruzadas Inteligentes (`cleveref`)
1. **Uso Exclusivo de `\cref` e `\Cref`:** Nunca utilizar `Figura~\ref{...}` ou `Tabela~\ref{...}` manualmente.
2. **Início de Frase:** Sempre utilizar `\Cref{...}` em maiúsculo no início de períodos (ex.: `\Cref{fig:circuito_ieee_t} ilustra...`).
3. **Meio de Frase:** Utilizar `\cref{...}` em minúsculo (ex.: `...conforme sintetizado na \cref{tab:parametros_consolidados}.`).
4. **Múltiplas Referências:** Agrupar referências cruzadas no mesmo comando (ex.: `\cref{fig:partida_velocidade,fig:partida_torque}`).

### 2.3. Diagramação de Tabelas com `booktabs`
1. **Banimento de Linhas Verticais:** É terminantemente proibido o uso de barras verticais (`|`) no argumento descritor de colunas do `tabular` (ex.: use `{lcccc}` e nunca `{|l|c|c|c|c|}`).
2. **Estrutura de Filetes Horizontais:**
   - `\toprule`: no topo da tabela.
   - `\midrule`: imediatamente abaixo do cabeçalho de títulos.
   - `\bottomrule`: na base inferior da tabela.
3. **Controle de Largura:** Tabelas largas com muitas colunas devem ser envolvidas em `\resizebox{\textwidth}{!}{...}` para evitar advertências de `Overfull \hbox`.

### 2.4. Diagramação Circuital no `circuitikz`
1. **Padronização:** Utilizar estilo `[american, scale=1.05, transform shape]`.
2. **Bipolos Padrão:** Empregar `R` para resistores, `L` para indutores e indutâncias de dispersão, e `open, v=...` para fontes ou terminais de tensão.
3. **Notação Fasorial de Corrente:** Utilizar setas de corrente padronizadas `short, i=$\vec{I}_{1,ph}$`.

### 2.5. Pontuação Gramatical de Fórmulas
Equações em modo *display* (`\begin{equation}...\end{equation}`) integram a oração gramatical e devem obrigatoriamente conter pontuação final (vírgula `,` ou ponto final `.`).
